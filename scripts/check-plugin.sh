#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

echo "== claude plugin validate"
claude plugin validate .

echo "== schema, fixtures, em dashes, private names, frontmatter"
python3 - <<'PY'
import glob
import json
import os
import sys

import jsonschema
import yaml

failures = []

schema = json.load(open("schema/loop-runner.schema.json"))
validator_class = jsonschema.validators.validator_for(schema)
validator_class.check_schema(schema)
validator = validator_class(schema)

fixture_count = 0
for case_file in sorted(glob.glob("evals/**/case.yaml", recursive=True)):
    case_dir = os.path.dirname(case_file)
    config_path = os.path.join(case_dir, "project", ".claude", "loop-runner.json")
    if not os.path.exists(config_path):
        continue
    fixture_count += 1
    expects_invalid = "schema-invalid" in (yaml.safe_load(open(case_file)).get("tags") or [])
    try:
        accepted = validator.is_valid(json.load(open(config_path)))
    except json.JSONDecodeError:
        accepted = False
    if accepted == expects_invalid:
        verdict = "accepted" if accepted else "rejected"
        failures.append(f"schema {verdict} {config_path}, expected the opposite")
print(f"schema checked against {fixture_count} config fixtures")

shipped_roots = [".claude-plugin", "skills", "agents", "schema", "evals", "scripts/check-plugin.sh", ".github/workflows/plugin-ci.yml"]
private_names = [name.strip().lower() for name in os.environ.get("PRIVATE_NAMES", "").split(",") if name.strip()]
em_dash = chr(0x2014)

def shipped_files():
    for root in shipped_roots:
        if os.path.isfile(root):
            yield root
        for path in glob.glob(os.path.join(root, "**", "*"), recursive=True):
            if os.path.isfile(path) and "/results/" not in path:
                yield path

for path in shipped_files():
    try:
        text = open(path, encoding="utf-8").read()
    except UnicodeDecodeError:
        continue
    if em_dash in text:
        failures.append(f"em dash in {path}")
    lowered = text.lower()
    for name in private_names:
        if name in lowered:
            failures.append(f"private name in {path}")

def frontmatter(path):
    lines = open(path, encoding="utf-8").read().split("\n")
    if not lines or lines[0] != "---":
        return {}
    end = lines.index("---", 1)
    return yaml.safe_load("\n".join(lines[1:end])) or {}

for path in sorted(glob.glob("skills/*/SKILL.md") + glob.glob("agents/*.md")):
    meta = frontmatter(path)
    for key in ("name", "description"):
        if not str(meta.get(key) or "").strip():
            failures.append(f"{path} has no {key} in frontmatter")

for failure in failures:
    print(f"FAIL: {failure}")
if failures:
    sys.exit(1)
print("all static checks passed")
PY

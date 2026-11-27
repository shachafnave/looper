---
name: loop-runner
description: Use when a build path and done criteria are agreed and the work should run as gated loops, each written by one agent and checked by someone other than its author, optionally configured by .claude/loop-runner.json.
---

# Loop runner

Turn agreed done criteria into a loop table, save it as a plan file, then run
the loops one at a time. Every loop has a gate, and the agent that wrote a loop
never gates it.

## Step 1: Load and validate the config

The project root is the top of the git work tree (`git rev-parse
--show-toplevel`), not the current directory. If that command fails for any reason, refuse with exactly this line and
nothing before it, then add any detail on the next lines:
"Cannot start: this folder is not a git repository. Run `git init` and try
again." Look for
`.claude/loop-runner.json` there. Every path in the config is relative to that
root.

- **Missing:** say "No .claude/loop-runner.json found, using defaults." and use
  the defaults table below.
- **Present:** check it against the rules below. These rules are complete on
  their own; the plugin also ships them as a JSON schema for editors, but do
  not depend on finding that file.

| Check | Failure line to print |
| --- | --- |
| The file parses as a JSON object | `.claude/loop-runner.json` is not valid JSON |
| Every key is one of `reviewer_agent`, `review_skill`, `ui_gate_skill`, `error_skill`, `commands_from`, `ship_skill`, `plan_dir`, `spec_dir`, `on_new_file`, `rules_file` | Unknown key: `<key>` |
| Every value is a string | `<key>` must be a string |
| No value is empty or only whitespace, or starts or ends with whitespace | `<key>` is blank |
| `commands_from` is `file` or `file#Section`, with a file part and no space before `#` | `commands_from` has no file |
| `plan_dir`, `spec_dir`, `rules_file` and the file part of `commands_from` are relative and stay inside the root (no leading `/` or `~`, no `..` that leaves it) | `<key>` points outside the project |
| `rules_file` and the `commands_from` file exist | `<key>` `<path>` does not exist |
| The `#Section` exists in that file as a heading or table title | section `<Section>` not found in `<file>` |
| `reviewer_agent` is an installed agent; `review_skill`, `ui_gate_skill`, `error_skill`, `ship_skill` are installed skills | `<key>` `<name>` is not installed |
| A bare name matches exactly one installed agent or skill, counting project and plugin entries together | `<name>` is ambiguous, choose `<full name>` or `<full name>` |

Names may be bare (`reviewer`) or namespaced (`plugin:reviewer`). A namespaced
name must match exactly.

**Refuse to start** if any check fails. Refusing means: no branch, no plan
file, no dispatch. Run the checks in table order for every key. Once a key
fails a check, skip that key's later checks, so each bad key prints exactly
one line. Then print every failure line, in this
shape:

```
Cannot start: .claude/loop-runner.json is invalid.
- Unknown key: `auto_merge`
- reviewer_agent `security-hawk` is not installed
Fix the file and run the loop runner again.
```

An unknown key is never ignored, and a missing agent or skill is never swapped
for a default. Offering a fallback is still starting; the user fixes the file.

### Defaults

| Key | Default |
| --- | --- |
| `reviewer_agent` | `loop-reviewer`, this plugin's agent, resolved by the same name check as configured names |
| `review_skill` | none: dispatch the reviewer agent directly |
| `ui_gate_skill` | none: plain `user-yes` gate on UI loops |
| `error_skill` | none: note the error in the loop's evidence |
| `commands_from` | ask the user once, store the answer in the plan |
| `ship_skill` | none: stop at an open PR |
| `plan_dir`, `spec_dir` | `docs/loops/` |
| `on_new_file` | none |
| `rules_file` | none |

Announce the resolved settings in one short list before step 2.

## Step 2: Prepare

1. If `rules_file` is set, read it now, before planning or dispatching
   anything, and pass its path to every loop agent as "read this first".
   When the user corrects the runner or a loop agent during the run, write the
   correction into `rules_file` as a one-line rule in the same loop, show the
   line, and record it in that loop's evidence.
2. Read the current branch with `git symbolic-ref --short HEAD` (this works
   in a repo with no commits). The default branch is the one the remote's HEAD
   names; with no remote, it is `init.defaultBranch`, else `main`. If the
   current branch is the default branch, run `git switch -c
   loops/<short-name>` (this also works with no commits). Never commit on the
   default branch.
3. Resolve build, lint and test commands: from the `commands_from` table if
   set, otherwise ask the user once.

## Step 3: Write the loop table

Write the plan file to `<plan_dir>/<YYYY-MM-DD>-<short-name>.md`. It holds:

- the done criteria, the branch, and the resolved commands;
- the loop table, exactly these columns:

| Loop | Agent | Output | Gate |
| --- | --- | --- | --- |
| 1. Failing test for `greet` | `general-purpose` | `test/greet.test.ts` | `command`: test fails for the right reason |
| 2. Implement `greet` | `general-purpose` | `src/greet.ts` | `review` by `agent-loop-runner:loop-reviewer` |
| 3. Ship | main thread | open PR | `user-yes` |

- an empty **Evidence** section with one heading per loop.

Any spec or design doc a loop produces is saved under `<spec_dir>/` with the
same date prefix, and the plan links to it.

Gate types: `user-yes`, `command`, `review`. A `review` row names the reviewer,
which is never the agent in the Agent column. Mark loops that create or change a
UI surface with `(UI)`. Show the table to the user before loop 1.

## Step 4: Run each loop

One loop at a time, in order:

1. **Announce:** "Loop N: <name>. Agent: <agent>. Gate: <gate>."
2. **UI first:** if the loop is marked `(UI)` and `ui_gate_skill` is set, run
   that skill before dispatching, and do not build until it passes.
3. **Dispatch** the named agent with only that loop's brief: its goal, its
   output location, the `rules_file` to read first, and the commands. Not the
   whole plan, not other loops, not your reasoning.
4. **New files:** for every file the loop created, run the `on_new_file`
   instruction in this same loop.
5. **Run the gate:**
   - `user-yes`: ask, and pass only on an explicit yes. Record the user's exact
     words in quotes.
   - `command`: run the command; record the command and its output.
   - `review`: dispatch `reviewer_agent` (through `review_skill` when set) with
     only the output location and the gate. The reviewer is a fresh agent,
     never the authoring agent and never this main thread. The gate passes only
     when the reviewer raises no objection that quotes a line, or every
     remaining objection is a gap you defended to the user and the user
     accepted. Record each objection, its quoted line, and how it was resolved.
6. **Errors:** any unexpected failure is an error: a command that fails when
   the gate expected it to pass, an agent that errors, a gate that cannot run.
   Call `error_skill` if set, otherwise write the error in the loop's
   evidence; then the gate counts as failed and step 8 applies. A failure the
   gate expects (a red test in a failing-test loop) is a pass, not an error.
7. **Record evidence** under the loop's heading in the plan file.
8. **Advance or loop back:** on pass, go to the next loop. On fail, send the
   findings or the failing output to the authoring agent and re-run the gate;
   a `review` gate always uses a fresh reviewer. After three failed attempts
   at the same gate, stop and ask the user.

## Step 5: Ship

The final loop uses `ship_skill` if set; otherwise it stops at an open PR.
Before anything outward-facing (push, opening a PR, making a repo public,
publishing, deploying), stop and ask. The gate is the user's yes.

## No self-review

The agent that wrote a loop never gates it. This holds when the user asks to
save time, when the author "already knows the code", and when the diff is
tiny. Say why in one line: a review only tests the work when it comes from a
context that did not write it. Then dispatch `reviewer_agent`. If the user
still refuses a real review, record the gate as not passed and do not advance.

| Thought | Reality |
| --- | --- |
| "I'll ignore the unknown key and carry on." | Refuse and name it. |
| "The configured agent is missing, I'll use the default." | Refuse and name it. |
| "I'll just commit on main, it's small." | Branch first. |
| "The author can check its own loop." | Dispatch `reviewer_agent`. |
| "The reviewer's note has no quoted line, but I'll fix it anyway." | Fine, but only line-quoted objections block the gate. |
| "Pushing is part of the loop." | Ask first. |

#!/usr/bin/env bash
set -eu
case_dir="$(cd "$(dirname "$0")" && pwd)"
exec bash "$case_dir/../../../scaffold-project.sh" "$case_dir/project" no-git

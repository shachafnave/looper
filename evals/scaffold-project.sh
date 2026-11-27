#!/usr/bin/env bash
set -eu
project_source="$1"
git_mode="${2:-git}"
cp -R "$project_source"/. .
if [ "$git_mode" = "git" ]; then
  git init -q -b main
  git config user.email eval@example.invalid
  git config user.name eval
fi

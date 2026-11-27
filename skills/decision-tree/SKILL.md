---
name: decision-tree
description: Use after an interview brief is confirmed and before any plan or code, when the next step is deciding who the users are, what shape the thing takes (web app, CLI, Claude plugin or skill, MCP server, library), how many tools, and which repo it lives in.
---

# Decision tree

Turn a confirmed brief into one chosen path and v1 done criteria. Walk the
same four branches every time, in order. Ask the user only where the brief
does not settle a branch.

## The four branches

| # | Branch | Options |
| --- | --- | --- |
| 1 | Users | people, AI agents, both |
| 2 | Shape | web app, CLI, Claude plugin or skill, MCP server, library |
| 3 | Scope | one deep tool, several tools |
| 4 | Lives in | this repo, its own repo |

Walk all four even when one seems obvious. A skipped branch is a hidden
assumption.

## Settled, open, or in conflict

For each branch, classify the brief first:

- **Settled**: the brief names the answer or a constraint forces it. Decide
  it and cite the brief line.
- **Open**: the brief is silent or vague ("the team", "users"). Ask.
- **In conflict**: two brief lines rule out every option between them (for
  example "must be a web app" and "no hosting"). Name both lines. Ask.

A vague word for the users ("the team", "folks", "users") is open on branch
1: the people or agents question is still unanswered.

## Asking

Ask one question per message, only for open or conflicting branches. The
question names the branch and offers two to four concrete options, each with
what it costs or gives up. For a conflict, include an option that satisfies
both lines if one exists (a static file opened locally satisfies "web app"
and "no hosting"), and say which line each option bends.

Until every open branch is answered, show the decided branches and mark the
path as pending. Never declare a final path on a guessed answer.

## Output

Every branch is written in exactly this form:

```
Branch: <name>
Choice: <option>
Why: <the brief line or constraint that decides it>
Flips if: <the concrete fact that would change the choice>
```

Then:

```
Path: <users> / <shape> / <scope> / <lives in>, one line, one path only

v1 done criteria:
- [command] <exact command> exits 0 / prints <expected>
- [user yes] <the user confirms ...>
```

Each done criterion is tagged `[command]` or `[user yes]`. A command
criterion names the exact command and its expected result. A user-yes
criterion names the exact thing the user looks at and confirms. Cut any
criterion that is neither, such as "works well", "is clear", or "is easy".

## Quick checks before sending

- Four branches, each with Choice, Why, Flips if.
- No question asked about a settled branch.
- Conflicts named with both brief lines quoted.
- Exactly one Path line, or the word pending if a branch is open.
- Every done criterion tagged `[command]` or `[user yes]`.

## Common mistakes

| Mistake | Fix |
| --- | --- |
| Dropping the scope branch because the answer is obviously one tool | Write it anyway with its Flips if. |
| Asking where the output is read when the users branch is open | Ask people, agents, or both first; delivery follows. |
| A compound question covering three things | One question, one branch, concrete options. |
| Quietly picking one side of a conflict | Quote both lines and let the user choose. |
| Done criteria about quality or clarity | Rewrite as a command or a user yes, or cut. |

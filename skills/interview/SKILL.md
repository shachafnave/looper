---
name: interview
description: Use when a user asks to build, make, or set up something and the goal, the users, the constraints, or what done looks like is missing, vague, or contradictory. Also use when a request looks fully specified, to confirm it before any code is written.
---

# Interview

Turn a request into a confirmed brief before anything is built. The brief is
the only output. Planning, code, and files come after the user confirms it.

## The brief

The brief has exactly these four sections, in this order:

```
Goal: what changes for the user when this exists, in one or two sentences.
Users: who uses it, how many, and where (device, tool, channel).
Constraints: limits the user stated, plus every decision the user made in the interview.
Done: the observable check that tells the user it worked.
```

Each line holds facts the user said. Anything you inferred goes on its own
line that starts with `Assumption:`. A brief that names a tool, schedule,
format, or host the user never mentioned has a hidden assumption in it.

## Each message

Every message during the interview is one of two shapes.

**A question message** is at most two short sentences of context followed by
one question that ends in a single question mark. A question with "and", or a
list of options inside one question, is still one question only if one answer
settles it. Offering two or three labeled choices for one decision is fine.

**The brief message** is the four sections above, then this line:
`Is this brief right? Reply yes, or tell me what to change.`

There is no third shape. No plan, file list, architecture, or code appears in
any message until the user replies yes to the brief.

## Order of work

1. Read the opening request. Mark each brief section as known, missing, or
   in conflict.
2. If two stated requirements cannot both hold, the first question names the
   conflict in plain words and asks the user to choose. Never pick for them.
   Record the choice under Constraints as `Decided: ...`.
3. Ask about the missing section that would change the build the most.
   Users and Done are usually missing in a vague request; ask for them.
4. After each answer, update the sections. When all four are known, send the
   brief message. Do not ask about details the build can settle later
   (file format, column names, run time, hosting); list them under
   `Open for planning:` after Done.
5. Stop at eight questions even if something is still missing. Send the brief
   with the gap marked `Assumption:` or `Open for planning:`.
6. If the user changes the brief, send the revised brief and the same
   confirmation line. Repeat until yes.
7. On yes, hand the brief to the next step. Write it to a file only if the
   project names a place for briefs.

## Over-specified requests

When the opening request already covers all four sections, ask only about a
real gap that changes the output (for example, what happens to an input the
rules do not cover). Zero or one question is normal. Never re-ask a stated
fact. Then send the brief message. A complete request still needs a yes
before any code.

## Red flags

| Thought | Do instead |
| --- | --- |
| "Two quick questions in one message saves time." | One question. The next message asks the next one. |
| "The request is detailed, I can start coding." | Send the brief and wait for yes. |
| "I'll show the plan so they can react to it." | Show the brief. The plan comes after yes. |
| "They probably use Slack and cron." | Ask, or write it as `Assumption:`. |
| "The conflict is obvious, I'll take the sensible side." | Name it and ask the user to choose. |
| "I need the column names before I can build." | That is planning detail. Put it under `Open for planning:`. |
| "All four are known, but one more detail would help." | Send the brief now. The detail goes under `Open for planning:`. |

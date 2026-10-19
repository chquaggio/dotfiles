---
name: harvest-feedback
description: "Collect the `feedback` auto memories from every project on this machine and propose where each correction belongs in the dotfiles (AGENTS.md, a rule, a skill, a lint check or a hook), then apply the approved ones and retire the promoted memories. Run when the user types /harvest-feedback. Leaves `user`, `project` and `reference` memories alone, and ordinary memory upkeep within one project needs no skill."
disable-model-invocation: true
allowed-tools: Bash(~/.claude/skills/harvest-feedback/collect.py*)
---

# harvest-feedback

Auto memory keeps the corrections the user gives in a session, per project and per machine.
This skill moves the ones that hold beyond their project into the dotfiles, where every
session and every machine sees them.

## Step 1: The memories

```!
~/.claude/skills/harvest-feedback/collect.py
```

If there are none, say so and stop.

## Step 2: Decide a destination for each memory

Read the dotfiles' `claude/common/AGENTS.md`, `claude/common/rules/`, `claude/common/skills/`
and the profile directories first, so each decision rests on what they already say. Then
pick one destination per memory:

| The memory | Destination |
| :- | :- |
| Already said by AGENTS.md, a rule or a skill | Delete the memory; cite the line that covers it |
| Contradicts AGENTS.md or a rule | Ask the user which one wins |
| Holds in every project | `claude/common/AGENTS.md`: the rule plus its reason in one clause |
| Holds for one file type or area | A path-scoped rule in `claude/common/rules/` |
| Belongs to a procedure | The skill that runs that procedure |
| A tool could check it | A lint rule or hook; propose the check instead of prose |
| Differs by machine (permissions, identity, installed tools) | `claude/<profile>/` |
| Holds for its project only | Keep the memory, or move it to that project's CLAUDE.md |

Write each proposed line the way AGENTS.md asks agent-facing text to be written, using the
`writing-for-agents` skill when it is installed. A line that would cause no mistake if it
were missing is not worth adding.

## Step 3: Get approval

Show one table: memory file, what it says in one line, destination, the exact text or check
proposed. Wait for the user's answer per row. Change nothing before it.

## Step 4: Apply and retire

For each approved row:
1. Edit the destination file in the dotfiles repo printed in Step 1.
2. Delete the memory file and its line in that project's `MEMORY.md`, once its content
   lives in the dotfiles or the user chose to drop it.

Leave committing to the user (`/github-push`).

Done when every collected memory has an answered disposition, `git -C <dotfiles repo> diff`
shows exactly the approved edits, and rerunning `~/.claude/skills/harvest-feedback/collect.py`
lists only the memories the user chose to keep.

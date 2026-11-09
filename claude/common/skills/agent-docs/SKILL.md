---
name: agent-docs
description: "House conventions for documents an agent reads: CLAUDE.md, AGENTS.md, SKILL.md, `.claude/rules/`, specs, plans, ADRs, handoffs. Use alongside `writing-for-agents` whenever creating or editing one of them. Not for READMEs, user-facing docs or code comments, which follow AGENTS.md's writing rules."
---

# agent-docs

The project-level choices `writing-for-agents` leaves open. Load that skill too; this one
does not repeat it. Where these documents live is in AGENTS.md.

- Every always-loaded line changes behaviour; a line whose removal would cause no mistake
  is removed. CLAUDE.md stays under 200 lines.
- The environment is the source of truth: `package.json`, `pyproject.toml`, the directory
  layout and `--help` output are looked up. Written down is what cannot be looked up: the
  unwritten convention, the reason behind a choice, the gotcha no config confesses.
- Multi-step procedures are skills, loaded on demand; conventions for one area of a repo
  are path-scoped rules in `.claude/rules/`.
- A skill's description names its triggers and the cases it leaves out; its body is a
  procedure with the exact commands and a done-criterion the agent can check. Workflows
  with side effects (push, deploy, release) carry `disable-model-invocation: true`.
- Specs, plans and ADRs are self-contained: files and interfaces involved, what is out of
  scope, acceptance criteria written as checkable tests, an end-to-end verification step.
  A plan holds only work some criterion needs.
- Domain vocabulary lives in `CONTEXT.md` at the repo root.

Done when the document satisfies every rule above, each checked against the text.

# Global preferences

Rationale behind these rules lives in ~/.claude/OPINIONS.md; read it before a
non-trivial design or architecture decision.

## Working with me
- I am a senior engineer and AI expert. Lead with one recommendation and its
  reason; alternatives only where they differ materially.
- Correctness, clarity and long-term maintainability outrank delivery speed;
  simplicity outranks speculative robustness and scalability. The cheapest
  design that is clean and correct wins until a real requirement or a
  demonstrated failure asks for more.
- Bug fixes start with a reproduction, end-to-end, as close as possible to how
  an end user hits it. Fix the root cause (often a shared module rather than
  the call site) and check where else the same cause bites.
- Data values I type in chat (IDs, codes, table names) may have lost casing or
  format: confirm them against raw query or file output before diagnosing.
- Git: commit, push and tag only when I ask, as separate commands, authored by
  me alone (no co-author trailer).

## Writing, everywhere
Chat, documents, comments, commit messages.
- Plain words, complete over dense. Concise means every word does work; it
  does not mean short. A technical term is used where it is the right word and
  glossed in plain words the first time it carries the point.
- State the thing directly (Y) rather than contrasting it with what it is not
  ("not X, but Y").
- Present tense, describing current behaviour, for a reader arriving cold.
  When new information invalidates a passage, rewrite it as if known from the
  start; history lives in git and CHANGELOG.
- Prose passes stop-slop: adverbs cut, one idea per construction, no triads,
  no hollow openers, no em-dash chains.

## Chat
- Answer in the language I write in, in my register.
- Start with the answer; stop when it is complete. Every sentence carries
  information I lack (framing, praise, agreement and recaps carry none).
- Explain from the concrete case up to the general rule.
- Separate fact from interpretation. A claim about behaviour carries its
  evidence: ran, read or recalled; "works" means you ran it. Where you cannot
  verify, say "uncertain" or "cannot verify"; state what you can and cannot do.
- If my premise is wrong, say so with evidence; if you are disproved, revise
  without ceremony.
- Research: primary, verifiable sources, cross-checked; a source's words appear
  as a quotation, presented neutrally.
- "In plain text" or "print" → the content in one Markdown code block, nothing
  else.

## Human-readable documents
READMEs, design docs, runbooks, CHANGELOG, user-facing docs.
- Order: what it is, why it exists, how to use it, then internals.
- One document answers one question completely, as one page rather than
  several stubs. Details that would crowd it go in a separate document or stay
  in a chat session.
- Language: the one the document already uses. New user-facing docs follow the
  project's convention (several projects keep them in Italian); developer docs
  are in English.
- CHANGELOG: the `github-push` format, one timestamped "Push Summary" per
  push: Conversation Context (the why, in prose), then commits and their files.

## Agent-facing documents
CLAUDE.md, AGENTS.md, SKILL.md, `.claude/rules/`, specs, plans, ADRs, handoffs.
Write and edit them with the `writing-for-agents` skill; the rules below are
the project-level choices it leaves open.
- Every always-loaded line changes behaviour; a line whose removal would cause
  no mistake is removed. CLAUDE.md stays under 200 lines.
- The environment is the source of truth: `package.json`, `pyproject.toml`,
  the directory layout and `--help` output are looked up. Written down is what
  cannot be looked up: the unwritten convention, the reason behind a choice,
  the gotcha no config confesses.
- Multi-step procedures are skills, loaded on demand; conventions for one area
  of a repo are path-scoped rules in `.claude/rules/`.
- A skill's description names its triggers and the cases it leaves out; its
  body is a procedure with the exact commands and a done-criterion the agent
  can check. Workflows with side effects (push, deploy, release) carry
  `disable-model-invocation: true`.
- Specs, plans and ADRs are self-contained: files and interfaces involved,
  what is out of scope, an end-to-end verification step. They live in
  `docs/specs/`, `docs/plans/` and `docs/adr/`; domain vocabulary in
  `CONTEXT.md` at the repo root.

## Issue tracker
- The tracker holds tasks; documentation holds knowledge. An issue reads at a
  glance: imperative title; why it matters; an acceptance criterion the agent
  can check; what is out of scope; a link to the spec or ADR that carries the
  detail.
- Comments: as short as the point allows, in the language of the repo's
  user-facing docs.
- Where the tracker allows: anything found but left unfixed in a session
  becomes an issue rather than a TODO comment; commits reference the issue; a
  closing comment says how the fix was verified. Closing is my call.
- Labels: mattpocock's triage vocabulary where its flow is set up; elsewhere
  `bug`, `feat`, `debt`, `idea`.

## Code
- A comment says what the code cannot: intent, a non-obvious constraint, why
  an alternative was rejected. As short as the point allows.
- Validate at system boundaries (user input, external APIs, file and DB
  reads); inside, code trusts its callers.
- Errors propagate loudly. A handler exists only where it does something:
  retry, a fallback I asked for, context added to the message.
- Abstraction is earned by the second caller: logic used once stays inline
  under a good name.
- Edge cases live in tests. An inline guard exists for a demonstrated failure
  or an established practice of the domain.
- Intention-revealing names and flat design over engineered indirection.

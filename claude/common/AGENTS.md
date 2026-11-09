# Global preferences

Before adding a module, a dependency or a public interface, read
~/.claude/OPINIONS.md: the reasoning behind these rules.

## Working with me

- I am a senior engineer and AI expert. Lead with one recommendation and its
  reason; alternatives only where they differ materially. A request with two
  readings that build different things gets a question before any code.
- Correctness, clarity and long-term maintainability outrank delivery speed;
  simplicity outranks speculative robustness and scalability. The cheapest
  design that is clean and correct wins until a real requirement or a
  demonstrated failure asks for more. A choice costly to reverse (schema,
  public interface, stored identifier, auth boundary) gets deliberate design
  up front.
- Bug fixes start with a reproduction as close to how an end user hits it as
  possible without touching shared or production systems, captured as a
  failing test where one can be written. Without a reproduction, the fix is
  labelled a hypothesis. The fix goes at the root cause, often a shared module
  upstream of the call site; other places the same cause bites go in the
  report.
- Git: commit, push and tag only on an explicit request for that action, each
  as its own Bash call.

## Scope

- Build exactly what the task names. A useful extra (CLI, entry point, flag,
  config option, module, dependency) goes in the final report as a one-line
  suggestion.
- The diff holds only what the task needs; code the change makes dead is
  deleted. The ranking above orders choices inside the task.
- Behaviour changes go test-first: a failing test from an acceptance criterion
  or a demonstrated failure, seen red, then the least code that turns it green.
- Anything found but left unfixed goes in the final report as a proposed issue
  (title, one-line why); I decide what gets filed.

## Writing, everywhere

Chat, documents, comments, commit messages.

- Plain words. Concise means every word does work; completeness is never cut
  to save words. Project and domain jargon is glossed in plain words the first
  time it carries the point.
- Documents and comments describe the current state, in present tense, for a
  reader arriving cold. When new information invalidates a passage, rewrite it
  as if known from the start. Records keep their history: commit messages,
  CHANGELOG, and ADRs (superseded by a new ADR, never edited).
- Documents and chat prose follow the `no-claudish` skill, loaded before the
  first prose reply. Comments and commit messages are as short as the point
  allows.

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

## Agent-facing documents

- CLAUDE.md, AGENTS.md, SKILL.md, `.claude/rules/`, specs, plans, ADRs and
  handoffs are written with the `writing-for-agents` and `agent-docs` skills.
- Specs, plans and ADRs live where the repo already keeps them, else in
  `docs/specs/`, `docs/plans/` and `docs/adr/`, overriding skill defaults such
  as `docs/superpowers/`.

## Issue tracker

- Creating, commenting on, labelling or closing an issue goes through the
  `issue-tracker` skill. Commits reference the issue when one exists.

## Code

- A comment states what the code cannot: its intent or a non-obvious
  constraint, as it holds now. Decisions and their history (ADR, plan, chat,
  earlier behaviour) stay in git, ADRs and CHANGELOG. Existing comments stay
  unless the change makes them wrong.
- Flat design and intention-revealing names. A function's name says what it
  does in the domain; failure and fallback behaviour live in its signature,
  return type and raised exceptions (`get_user` raises `UserNotFound`; the
  HTTP layer maps it to 404).
- Validate at system boundaries (user input, external APIs, file and DB
  reads); inside, code trusts its callers.
- Errors propagate loudly. A handler exists only where it does something:
  retry, a fallback I asked for, context added to the message, translation at
  a boundary (a domain error to an HTTP status).
- A condition or expression used once stays inline, under a local variable
  when it needs a name; a long function may split into named steps. Other
  extraction waits for a second caller, and a test is no caller.
- An edge case that matters gets a test. An inline guard needs a demonstrated
  failure or an unambiguous best practice of the domain.

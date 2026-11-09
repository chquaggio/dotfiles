# Opinions

Longer-form reasoning behind the rules in
~/personal/dotfiles/claude/common/AGENTS.md. Read it before adding a module, a
dependency or a public interface.

## Against defensive noise

Agent-written code drifts toward a recognizable pattern: every function
distrusts its input and re-validates it, try/except blocks wrap code that
cannot plausibly fail, and single-use conditions get extracted into one-line
named functions. As one r/ExperiencedDevs commenter put it (in the thread on
Armin Ronacher's unease about agent-built codebases,
https://www.reddit.com/r/ExperiencedDevs/comments/1ukttup/): "it seems that
every function written does not trust the input and adds a lot of noisy type
checks. [...] It's nothing bad, impacting performance, or worth blocking a
merge, but it does make the overall codebase less readable and less easy to
reason about."

That is the failure mode I want to avoid. The individual guards are each
defensible; their accumulation is not. What I want instead:

- **Validate at boundaries, trust inside.** Check user input, external API
  responses, and file/DB reads once, at the edge of the system. Past that
  edge, functions trust their callers. A type check deep inside internal code
  is a smell.
- **Errors propagate loudly.** A try/except is justified only when the
  handler does something: retry, apply a fallback I asked for, add context to
  the message, translate the error at a boundary. Catch-and-continue "to be
  safe" hides bugs and makes control flow unreadable.
- **Abstraction is earned by the second caller.** Extracting a condition or
  expression used once into its own function adds a name to learn and a hop
  to follow, for zero reuse. Inline it, under a local variable if it needs a
  name; extract when a second caller appears. Splitting a long function into
  named steps is different: each step is a paragraph heading for the reader.
- **Edge cases belong in tests.** If an edge case matters, write a test that
  pins it. Add inline defenses only for failures that have been demonstrated,
  or where they are an unambiguous best practice of the domain. Non fasciarsi
  la testa prima di rompersela: don't bandage your head before breaking it.
- **Readability is the budget everything else spends from.** Clear,
  intention-revealing names and flat, simple design beat cleverness and
  engineered indirection, even when the clever version is shorter.

## Against unrequested surface area

Defensive noise is armor inside a function. Its sibling is armor around the
task: a CLI nobody asked for, flags and config options for cases nobody has,
a dependency pulled in for a convenience. Both come from the same bias: the
model reads "complete" as safe. Every extra is code to review, test and
maintain, and review capacity is the scarce resource when an agent writes the
code.

A test-first loop is the fence. Each failing test comes from an acceptance
criterion or a demonstrated failure, and the code stops when the tests pass.
An extra the agent thinks useful goes in its report as a suggestion, where it
costs one line and I decide.

## Quality over delivery speed, simplicity over speculation

Correctness, clarity and long-term maintainability rank above delivery speed:
I would rather build the right thing slowly than the wrong thing fast. The
same ranking forbids overengineering. Development cost tracks complexity, and
YAGNI is itself a cost argument: speculative robustness and scalability
produce the armor described above. The cheapest design that is clean and
correct is usually the right one, and the time to invest in more is when a
real requirement or a demonstrated failure asks for it.

The exception is a decision that is costly to reverse: a database schema, a
public interface, an identifier other systems store, an auth boundary. Code
is cheap to change later; these are not, so they get deliberate design up
front.

## Code describes the present

A comment or a docstring serves a reader arriving cold, who needs to know
what the code does and what constraint it obeys today. Narrating the decision
that produced it ("as decided in ADR-12", "changed to X because of Y") serves
a reader of the past, duplicates the ADR or commit that already holds that
story, and rots when the next decision lands.

Names follow the same logic. `get_user_or_404` welds one caller's fallback
into the function's identity; the 404 belongs to the HTTP layer, and the
function's contract belongs in its signature and the exception it raises.

## Bug fixing starts at reproduction

Before touching code, reproduce the bug in the setting closest to how an end
user hits it, captured as a failing test where one can be written. A fix
without a reproduction is a hypothesis. Once reproduced, chase the root
cause: it often lives in a shared module upstream of the call site where the
symptom surfaced. Other places the same cause bites are reported, so fixing
them is a decision of its own.

## Trust, but state your evidence

Claims about behavior come with their verification level attached: "verified
by running X and observing Y" is a different statement from "inferred from
reading the code", and both are different from "recalled". Never present the
weaker one in the voice of the stronger.

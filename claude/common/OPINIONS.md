# Opinions

Longer-form rationale behind the rules in ~/.claude/AGENTS.md. Read this
before non-trivial design or architecture decisions.

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

That is exactly the failure mode I want to avoid. The individual guards are
each defensible; their accumulation is not. What I want instead:

- **Validate at boundaries, trust inside.** Check user input, external API
  responses, and file/DB reads once, at the edge of the system. Past that
  edge, functions trust their callers. A type check deep inside internal code
  is a smell, not a virtue.
- **Errors propagate loudly.** A try/except is justified only when the
  handler can do something meaningful — retry, apply a fallback I explicitly
  asked for, add context to the message. Catch-and-continue "to be safe"
  hides bugs and makes control flow unreadable.
- **Abstraction is earned by the second caller.** Extracting a condition or
  expression used exactly once into its own function adds a name to learn and
  a hop to follow, for zero reuse. Inline it; if a second caller appears,
  extract then.
- **Edge cases belong in tests, not inline armor.** If an edge case matters,
  write a test that pins it. Add inline defenses only for failures that have
  actually been demonstrated, or where it is an unambiguous established best
  practice for that domain. Otherwise: non fasciarsi la testa prima di
  rompersela — don't bandage your head before breaking it.
- **Readability is the budget everything else spends from.** Clear,
  intention-revealing names and flat, simple design beat cleverness and
  engineered indirection, even when the clever version is shorter.

## Quality over delivery speed, simplicity over speculation

Never trade correctness, clarity, or long-term maintainability for delivery
speed: I would rather build the right thing slowly than the wrong thing fast.
That said, this is not a license to overengineer. Development cost correlates
with complexity, and YAGNI is itself a cost argument — robustness and
scalability pursued "regardless of effort" produce exactly the speculative
armor described above. Simplicity outranks speculative robustness and
scalability: the cheapest design that is clean and correct is usually the
right one, and the time to invest in more is when a real requirement or a
demonstrated failure asks for it.

## Bug fixing starts at reproduction

Before touching code, reproduce the bug end-to-end, in the setting closest to
how an end user actually hits it. A fix without a reproduction is a
hypothesis. Once reproduced, chase the root cause — it often lives in a
shared module rather than at the call site where the symptom surfaced — and
check whether the same cause bites elsewhere before declaring the fix done.

## Trust, but state your evidence

Claims about behavior come with their verification level attached: "verified
by running X and observing Y" is a different statement from "inferred from
reading the code", and both are different from "recalled". Never present the
weaker one in the voice of the stronger.

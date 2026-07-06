# Global preferences

Rationale behind these rules lives in ~/.claude/OPINIONS.md — read it before
non-trivial design or architecture decisions.

## General
- Assume a senior engineer and AI expert. Be concise; lead with the answer or
  a recommendation, not a menu of options.
- Never claim a fix or feature works without having checked; state your
  verification level explicitly ("verified by running X" vs. "inferred from
  reading the code").
- Git: never commit, push, or tag unless I ask. Run commit and push as
  separate commands. Never add yourself as co-author in commit messages.
- Technical decisions: never trade correctness, clarity, or long-term
  maintainability for delivery speed. But simplicity outranks speculative
  robustness or scalability — the cheapest design that is clean and correct
  is usually the right one; invest in more only on demonstrated need.
- Bug fixes: first reproduce the bug end-to-end, as close as possible to how
  an end user hits it. Then fix at the root cause (often a shared module, not
  the call site) and check whether the same cause bites elsewhere.
- When I type data values in chat (IDs, codes, table names), I may not
  preserve exact casing or format — confirm against raw query/file output
  before basing a diagnosis on them.
- When new information invalidates something written earlier in a document,
  rewrite the section as if it had been known from the start — no
  "Correction:" notes or changelog-style addenda. Code and doc comments
  describe present behavior for a fresh reader; history belongs in commits
  and CHANGELOG.
- Chat with me in English. Match each document's existing language convention
  (several of my projects keep user-facing docs in Italian).

## Code style
- Validate at system boundaries (user input, external APIs, file/DB reads);
  internal code trusts its callers — no re-checking types/None on every hop.
- Use try/except only where the handler does something meaningful (retry, a
  fallback I asked for, enriching the message). Otherwise let errors
  propagate loudly; never catch-and-continue to be "safe".
- Abstraction is earned by the second caller: logic used once stays inline
  under a good name, not extracted into a one-line helper.
- Edge cases are covered by tests, not by speculative inline guards. Add
  inline defenses only for demonstrated failures or genuinely established
  best practice in that domain.
- Prefer readable, intention-revealing names and simple flat design over
  engineered indirection.

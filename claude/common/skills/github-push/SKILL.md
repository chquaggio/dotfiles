---
name: github-push
description: "Commit and push to GitHub: a deterministic preflight (push identity, gitleaks), the repo's own checks, one or more Commitizen-style commits grouped by task, and a CHANGELOG.md entry that preserves the why. Run when the user types /github-push. A plain request to commit or push follows the global git rules without this skill; the push hook still runs the preflight."
disable-model-invocation: true
allowed-tools: Bash(~/.claude/skills/github-push/preflight.py*)
---

# github-push

Commit the work of this conversation, as one commit or several grouped by task, record why
in CHANGELOG.md, and push.

The changelog is the most important artifact. Commit messages say what changed; the
changelog's Conversation Context says what the user asked, what was considered, and why the
final shape won.

Hard rules (the user's global preferences; they override anything below):
- Never commit or push unless the user asked in this conversation.
- Commit and push are separate commands.
- No `Co-Authored-By` or other self-attribution trailer.

## Step 1: Preflight

The deterministic checks ran when this skill loaded:

```!
~/.claude/skills/github-push/preflight.py 2>&1; echo "preflight exit: $?"
```

`preflight.py` reports the branch, checks the push identity (ssh and gh authenticate as one
account, and that account can push to origin), and scans uncommitted files and unpushed
commits with gitleaks and a filename check. A PreToolUse hook reruns it on every `git push`,
on unpushed commits only, and blocks the push when gitleaks finds something.

Resolve every `FAIL` before Step 2:
- **identity**: stop and report it; switching accounts is the user's call. When ssh did not
  authenticate, the key is usually missing from the agent: `ssh-add ~/.ssh/id_ed25519`, after
  `eval "$(ssh-agent -s)"` if no agent runs. A greeting that names a different account than
  `~/.claude/rules/git-identity.md` is a mismatch too.
- **secret** or **secret file**: list the findings with file and line, then ask per file:
  1. **Move to the repo's secret mechanism** (recommended: vault, `.env` plus `.env.example`,
     secret manager) and reference it; gitignore the raw file.
  2. **Skip it**: leave it unstaged.
  3. **Include anyway**: the user has been warned. For a gitleaks finding the push hook keeps
     blocking until the line carries a `gitleaks:allow` comment or its fingerprint is in
     `.gitleaksignore`. On a public repo, say that a real secret must be rotated.

  An `.env.example` keeps every key with descriptive placeholder values. A staged file comes
  out with `git rm --cached`. A secret inside an unpushed commit needs that commit rewritten:
  ask before running `git reset --soft` or `git commit --amend`.
- **warn visibility PUBLIC**: repeat it in the final report.

After a fix, rerun `~/.claude/skills/github-push/preflight.py` and continue when it exits 0.

## Step 2: Run the repo's own checks

Before staging anything, run what the repo's CI would run, locally:
- lint config present (`.ansible-lint`, `.yamllint`, `.eslintrc*`, `ruff.toml`,
  `pyproject.toml [tool.ruff]`, `.golangci.yml`, …) → run that linter;
- a syntax/compile step that is cheap (`ansible-playbook --syntax-check site.yml`,
  `tsc --noEmit`, `python -m compileall`, `go vet`) → run it;
- a `.github/workflows/*.yml` lint/test job → mirror its commands.

A failure stops the push; report it and fix or ask. Skip silently only when the repo has
no such tooling at all.

**Documentation contract.** If the repo's `CLAUDE.md` declares which docs must track
which changes (service tables, architecture diagram, runbooks…), check every planned
commit against it *before* committing: a change and the doc that describes it go in
the same commit. Run any doc-consistency script the contract names.

## Step 3: Decide the commit split

Default is **one commit**. Split into several when the user asks, or when the diff
clearly contains independent tasks (a feature, an unrelated bug fix, a docs refresh).
Grouping rules:
- one commit = one task a reviewer could accept or revert on its own;
- a file belongs to exactly one commit; if a file serves two tasks, use
  `git add -p` to split hunks, or put it with the task it mostly serves;
- order: refactors and fixes the later commits depend on come first; docs last, unless
  a doc change belongs with the code it documents (then it rides along);
- `CHANGELOG.md` goes in the **last** commit.

Show the user the planned groups (subject + files) before committing when there are more
than two commits or when the grouping is a judgment call.

## Step 4: CHANGELOG.md entry — one per push

### 4.1 Conversation Context

Review the whole conversation and write flowing prose (3–8 sentences; more only when
the work was large): the user's original request and starting point, key decisions and
why, alternatives considered and rejected, the final approach. A teammate skimming this
should understand the why without reading the diff.

### 4.2 Commits and changes

List each commit in push order with its subject, then its files with a one-line
description of what changed. Exclude `CHANGELOG.md` itself.

### 4.3 Format

```markdown
## [YYYY-MM-DD HH:MM] Push Summary

### Conversation Context
<narrative>

### Commits
1. `type(scope): subject`
   - `path/to/file`: what changed
   - `path/to/other`: what changed
2. `type(scope): subject`
   - `path/to/file`: what changed

---
```

For a single-commit push, use the same layout with one numbered item. Prepend the entry
to `CHANGELOG.md` (create it if missing) using the current local date and time.

## Step 5: Version bump — releases only

Bump `[project] version` in `pyproject.toml` only when the user says "release" (or
asks for a bump), never on an ordinary push: feature-branch pushes would otherwise churn
the version without meaning. Bump by the highest change type since the last release:
`feat` → minor; anything else → patch; an explicitly noted breaking change → major.
Run `uv lock` if `uv.lock` exists. Version and lockfile ride in the last commit,
typed `chore(release): version X.Y.Z`. A repo-specific push skill may override this
(e.g. one where every push is a release).

## Step 6: Commit and push

For each planned group, in order:

```bash
git add <files of this group>          # never `git add -A` when splitting
git commit -m "<type>(<scope>): <subject>" -m "<body>"
```

[Commitizen / Conventional Commits](https://www.conventionalcommits.org/) format:
- **types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `security`
- **scope**: short area name (`containers`, `firewall`, `api`, `ui`); omit if the commit spans many areas
- **subject**: imperative, lowercase, no trailing period, ≤ 72 chars
- **body**: one or two sentences of *why*, only when the subject can't carry it
- **no trailers**: no `Signed-off-by` unless the repo requires DCO

Single-commit pushes may use `git add -A` after the preflight passed.

Then, as a separate command:

```bash
git push            # or: git push -u origin HEAD  when the branch has no upstream
```

When the push hook blocks, its message names the finding: resolve it as in Step 1. Never
work around the hook.

## Step 7: Report

Tell the user: the repo visibility if public; each commit's subject and file count; whether
anything was gitignored, exampled or needs rotating; the new version if bumped; the checks
that ran and passed.

## Error handling

- Nothing to commit → say so; never create an empty commit.
- Lint or syntax check fails → stop before committing; show the output.
- Push rejected (remote ahead) → suggest `git pull --rebase`; ask before running it.
- Never force-push unless the user explicitly asks.

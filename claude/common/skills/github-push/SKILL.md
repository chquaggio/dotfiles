---
name: github-push
description: "Push code to GitHub with the profile's git identity, a secrets scan, lint checks, one or more Commitizen-style commits, and a CHANGELOG.md entry that preserves the why. Use this skill whenever the user says /github-push, wants to push to GitHub, or asks to commit and push their changes. Also trigger when the user mentions updating a changelog before pushing."
---

# github-push

Full push workflow: pick the right SSH identity, make sure no secret is about to be
published, run the repo's own checks, commit — as one commit or several, grouped by
task — write a CHANGELOG.md entry that captures the conversation context, push.

The changelog is the most important artifact: it preserves **why** changes were made.
Commit messages say what; the changelog's Conversation Context says what the user
asked, what was considered, and why the final shape was chosen.

Hard rules (from the user's global preferences, they override anything below):
- Never commit or push unless the user asked in this conversation.
- Never add a `Co-Authored-By` trailer or any other self-attribution.
- Commit and push are separate commands.

## Step 1: Git identity

The account and key are defined per machine profile in `~/.claude/rules/git-identity.md`
(already loaded in context); this skill never hardcodes them.

```bash
ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf <key> | cut -d' ' -f2)" || ssh-add <key>
ssh -T git@github.com 2>&1 | head -1   # "Hi <account>!" must match the rule
gh auth status 2>&1 | grep -E 'Logged in|account'
```

If `ssh-add` fails because no agent is running: `eval "$(ssh-agent -s)"`, then retry.
If GitHub greets a different account, `gh` is logged into another one, or
`git remote get-url origin` is not under the profile's account, stop and ask before pushing.

## Step 2: Secrets scan

Scan every changed, staged and untracked file **that is not gitignored**
(`git status --porcelain` lists exactly those). A public remote makes this the most
important step: check visibility with `gh repo view --json visibility -q .visibility`
and say so in the report when it is PUBLIC.

**Filenames to flag:** `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks`,
`*.secret(s)`, `credentials.*`, `service-account*.json`, `*.keystore`, `id_rsa`,
`id_ed25519*`, `token(s).json`, `.npmrc`, `.pypirc`, `*.tfvars`, `.htpasswd`,
`.vault_pass`, unencrypted `vault*.yml` (an Ansible vault file that does not start with
`$ANSIBLE_VAULT;` is a leak).

**Content to flag** — a *literal* value assigned to a secret-looking key:
`(API_KEY|SECRET|SECRET_KEY|PASSWORD|PASSWD|TOKEN|AUTH|AWS_SECRET_ACCESS_KEY)[A-Z_]*\s*[=:]\s*["']?[^\s"'{$]{8,}`,
`-----BEGIN .*PRIVATE KEY-----`, `sk-[A-Za-z0-9]{20,}`, `ghp_[A-Za-z0-9]{30,}`,
`eyJ[A-Za-z0-9_-]{20,}\.` (JWT).

**Not a finding:** templated or indirected values — `{{ var }}`, `${VAR}`, `$VAR`,
`os.getenv(...)`, `lookup('env', ...)` — and placeholder words (`changeme`,
`your_..._here`, `example`). Ansible/Compose repos reference every secret this way; only
the literal is a leak.

If anything is flagged, **stop and list it** with the file and line, then ask per file:
1. **Move to the repo's secret mechanism** (recommended — vault, `.env` + `.example`,
   secret manager) and reference it; add the raw file to `.gitignore` if it is a file.
2. **Skip it** — leave unstaged.
3. **Include anyway** — the user has been warned. If the remote is public, say that the
   value must be treated as compromised and rotated, even if it is removed later.

When creating an `.example` companion, keep every key and replace values with
descriptive placeholders. If the sensitive file was already staged: `git rm --cached`.

## Step 3: Run the repo's own checks

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

## Step 4: Decide the commit split

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

## Step 5: CHANGELOG.md entry — one per push

### 5.1 Conversation Context

Review the whole conversation and write flowing prose (3–8 sentences; more only when
the work was large): the user's original request and starting point, key decisions and
why, alternatives considered and rejected, the final approach. A teammate skimming this
should understand the why without reading the diff.

### 5.2 Commits and changes

List each commit in push order with its subject, then its files with a one-line
description of what changed. Exclude `CHANGELOG.md` itself.

### 5.3 Format

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

## Step 6: Version bump — releases only

Bump `[project] version` in `pyproject.toml` only when the user says "release" (or
asks for a bump), never on an ordinary push: feature-branch pushes would otherwise churn
the version without meaning. Bump by the highest change type since the last release:
`feat` → minor; anything else → patch; an explicitly noted breaking change → major.
Run `uv lock` if `uv.lock` exists. Version and lockfile ride in the last commit,
typed `chore(release): version X.Y.Z`. A repo-specific push skill may override this
(e.g. one where every push is a release).

## Step 7: Commit and push

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
- **no trailers**: no `Co-Authored-By`, no `Signed-off-by` unless the repo requires DCO

Single-commit pushes may use `git add -A` after the secrets scan has passed.

Then, as a separate command:

```bash
git push            # or: git push -u origin HEAD  when the branch has no upstream
```

## Step 8: Report

Tell the user: the repo visibility if public; each
commit's subject and file count; whether anything was gitignored/exampled or rotated;
the new version if bumped; the checks that ran and passed.

## Error handling

- Nothing to commit → say so; never create an empty commit.
- Lint or syntax check fails → stop before committing; show the output.
- Push rejected (remote ahead) → suggest `git pull --rebase`; ask before running it.
- Never force-push unless the user explicitly asks.

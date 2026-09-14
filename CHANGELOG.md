## [2026-09-14 11:04] Push Summary

### Conversation Context
The owner asked whether Claude was picking up the status line. It was not, for two
reasons that shared one cause: `~/.claude/statusline.py` did not exist and
`~/.claude/settings.json` was a real file with no `statusLine` key. `make link_claude`
had been run and had failed silently — `~/.claude/skills/stop-slop` was a leftover real
directory from before the repo took the config over, `ln -sfnT` refuses to overwrite a
real directory, and the recipe's `|| exit 1` aborted the whole run there. Because
`skills` sorts before `statusline.py` and the profile layer runs after `common`, one
stale directory silently blocked the status line, a skill, and every `work` setting. The
failure was reproduced against scratch directories before anything was changed, and the
scratch result matched the real `~/.claude` exactly. The fix collects collisions and
reports them together at the end rather than exiting at the first: the exit code stays
non-zero, so a leftover is still loud, but it no longer takes down the entries that
happen to sort after it. Reporting-and-continuing was chosen over checking all
collisions up front because it keeps one linking pass and one code path.

With the profile layer finally linked, `~/.claude/settings.json` became the repo file,
which surfaced a second question: the work profile allowed `Bash(*)` under
`defaultMode: auto`, and per the settings schema a blanket allow rule bypasses the
auto-mode classifier unless `autoMode.classifyAllShell` is set. Nothing not named in
`deny` was reviewed at all. Both layers were added, because they catch different things:
literal `deny`/`ask` prefix rules are deterministic but miss a destructive command
chained behind `&&`, while the classifier reads the whole command and catches it.
Dropping `Bash(*)` from `allow` was considered and rejected as too much friction for now.
`defaultMode` also arrived as `auto` rather than `plan` — Claude Code wrote it through
the new symlink, which is the repo-is-live-config design working as intended, and it was
kept because it reflects how the profile is actually run.

### Commits
1. `fix(claude): report every blocked link instead of stopping at the first`
   - `Makefile`: `link_claude` collects collisions into `blocked` and reports them all at
     the end, still exiting non-zero; each `ln` failure now blocks only its own item
     instead of the entries sorting after it and the profile layer that follows
2. `feat(claude): confirm or deny globally destructive actions in the work profile`
   - `claude/work/settings.json`: `deny` rules for unrecoverable commands (root and home
     `rm -rf`, `mkfs`, `shutdown`, mirror push) and for writes to SSH keys and Claude
     credentials; `ask` rules for destructive-but-needed ones (`sudo`, `rm -rf`,
     `kubectl delete`, `terraform apply`/`destroy`, `docker prune`, `git push`, package
     publishes); `autoMode.classifyAllShell` so the classifier sees Bash commands despite
     the `Bash(*)` allow, plus `hard_deny`/`soft_deny` entries over `$defaults`;
     `defaultMode` recorded as `auto`

---

## [2026-09-09 22:53] Push Summary

### Conversation Context
The owner asked for a review of every installed Claude Code skill and plugin and for a portable identity of the setup, in the spirit of CLAUDE.md and OPINIONS.md. The copy-based `make backup_claude` had drifted: `personal/claude/` was never committed, `settings.json` differed from the live file, one skill was missing. The chosen design replaces backup with symlinks: `claude/common/` holds the shared identity (AGENTS.md, CLAUDE.md, OPINIONS.md, RTK.md, skills, path-scoped rules, hooks, statusline) and `claude/personal/` and `claude/work/` each hold a full settings.json plus a git-identity rule; `make link_claude` links every item into `~/.claude` one by one so runtime state there never enters git. A base-plus-delta merge for settings.json was considered and rejected as machinery for a 50-line file. AGENTS.md gained sections on communication, human-readable documents, agent-facing documents and the issue tracker from a six-question interview, then went through the mattpocock `writing-for-agents` pass (positive phrasing, one source of truth per rule). Settings changes: superpowers off to trial mattpocock-skills, deny rules for destructive git commands and secret files, a ruff PostToolUse hook, a context-usage statusline, the rtk PreToolUse hook. github-push now reads the identity from the profile rule and bumps versions only on release.

### Commits
1. `feat(claude): symlink-based config with a shared core and profile overlays`
   - `Makefile`: `link_claude` replaces `backup_claude`/`restore_claude`; per-item `ln -sfnT` from `claude/common` then `claude/$(DEVENV)`
   - `README.md`, `AGENTS.md`: describe the `claude/` layout and the no-backup workflow
   - `claude/common/AGENTS.md`: rewritten cross-agent preferences (working with me, writing, chat, documents, agent docs, issue tracker, code)
   - `claude/common/CLAUDE.md`, `OPINIONS.md`, `RTK.md`: shared, moved from `work/claude/`
   - `claude/common/skills/`: github-push (profile identity, release-only bump), stop-slop, teaching-the-session
   - `claude/common/rules/`: context7, python (path-scoped), lua (path-scoped)
   - `claude/common/hooks/format-python.sh`, `claude/common/statusline.py`: ruff-on-edit hook and status line
   - `claude/personal/settings.json`, `claude/work/settings.json`: full per-profile settings with deny rules, hooks, statusline
   - `claude/personal/rules/git-identity.md`, `claude/work/rules/git-identity.md`: account and key per profile

---


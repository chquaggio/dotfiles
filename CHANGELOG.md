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


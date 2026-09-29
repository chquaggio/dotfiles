## [2026-09-29 17:22] Push Summary

### Conversation Context
The session began as a `/doctor` health check across both profiles. It found the global
AGENTS.md loading twice in every project under the home directory: CLAUDE.md imports it,
and Claude Code also reads `~/.claude/AGENTS.md` as project instructions, so the symlink
duplicated about 1.5k tokens per session. The Makefile now keeps AGENTS.md out of
`~/.claude` and links opencode and pi straight to the repo copy. The same check trimmed
this repo's AGENTS.md to what the code cannot show, cut RTK.md to its behavioural lines,
moved the context7 rule to the work profile (personal does not enable context7), and
disabled work plugins with zero lifetime use: the three LSP plugins had no language
server on PATH. Tracked Python bytecode was dropped and ignored. The owner then moves to
a new job with a Mac, so `work/` is ported from the Linux VM to macOS on this branch,
while `personal/` stays on Windows/WSL. The Makefile serves both machines, so it drops
GNU-only flags instead of branching per OS; `link_claude` keeps its refusal to replace
a real file through an explicit check, because BSD `ln` has no `-T`. SSH keys move from
`keychain` to the macOS Keychain, lazygit gets `XDG_CONFIG_HOME` so it reads
`~/.config` on macOS, and a Brewfile plus a README setup guide make the Mac ready to
clone and restore. Only the Linux side was tested; the BSD behaviour is reasoned from
the tools' documented semantics and will be confirmed on the Mac.

### Commits
1. `chore: stop tracking Python bytecode`
   - `.gitignore`: ignore `__pycache__/`
   - `claude/common/__pycache__/statusline.cpython-312.pyc`: removed from the index
2. `fix(claude): load the global AGENTS.md once`
   - `Makefile`: skip AGENTS.md when linking into `~/.claude`; opencode and pi link to the repo copy
3. `chore(claude): scope the context7 rule to work and trim RTK.md`
   - `claude/common/RTK.md`: reduced to the hook, `rtk proxy` and `rtk gain`
   - `claude/work/rules/context7.md`: moved from `claude/common/rules/`
4. `docs: trim AGENTS.md to what the repo cannot show`
   - `AGENTS.md`: removed derivable trees, target lists, key-files table and the Lua section covered by the lua rule
5. `chore(claude): narrow work allows, disable unused plugins and skill`
   - `claude/work/settings.json`: dropped blanket Bash and project write allows; disabled frontend-design and the three LSP plugins; turned off the teaching-the-session skill
6. `feat(work): port the work profile to macOS`
   - `Makefile`: portable `grep -E`/`sed -E` in help, `cp -R` without trailing-slash sources, explicit non-symlink check in `link_claude`
   - `work/config/.zshrc`: Apple Silicon Homebrew, `XDG_CONFIG_HOME`, `bat`, `$HOME` paths, no `keychain`
   - `work/config/lazygit/config.yml`: `$HOME` instead of `/home/dev` in the commit-message command
   - `work/Brewfile`: packages for the work Mac
   - `claude/work/rules/git-identity.md`: key held by the macOS Keychain
7. `docs: document the work Mac setup`
   - `README.md`: rewritten around the two profiles, with a step-by-step Mac setup
   - `AGENTS.md`: the Makefile must stay portable across GNU and BSD tools
   - `claude/common/rules/lua.md`: both configs use `vim.uv`

---

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


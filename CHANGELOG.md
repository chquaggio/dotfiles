## [2026-10-15 20:16] Push Summary

### Conversation Context
The owner asked for an assessment of the Claude Code config for strict use on servers,
a better way to carry their opinions into sessions, and the right primitive for each job.
A test showed the rtk hook let `git push` run without its ask prompt: Claude Code matches
permission rules against the command a hook returns, and rtk marks an ask match by
rewriting without a decision. The owner kept rtk, so a wrapper now drops rtk's rewrite
wherever it could change a permission outcome. Deleting `CLAUDE.md` would have unloaded
the global preferences in every repo with its own CLAUDE.md, so it stays the entry point,
and AGENTS.md is no longer linked into `~/.claude`, where Claude Code loaded it twice.
Several rules matched something other than intended: `Edit(/etc/**)` in user settings
covers `~/.claude/etc`, `Read(./.env)` only the working directory, and `Bash(rm -rf /*)`
refused every recursive delete by absolute path, while Claude Code's own critical-path
guard already protects the root. github-push now runs a deterministic preflight (push
identity, gitleaks) when it loads and as a hook on every push; while gh is logged out the
SSH account is the identity, and only repos under it pass. Prompts for gated commands
were unreadable, so a mod puts a plain-language explanation into the prompt, written by
Haiku from the command alone; a hook that forces short commands was rejected because the
owner accepts long commands and wants to see what they do. The Python rule now names a
house stack (FastAPI, SQLAlchemy 2 async, Polars, httpx, pytest) that new projects get
from a tested scaffold, whose SQLite fixture needed SQLAlchemy's savepoint recipe after a
commit leaked between tests. context7 is dropped in favour of installed sources and raw
docs; unattended server jobs were designed and deferred.

### Commits
1. `fix(claude): stop the rtk hook from bypassing ask rules`
   - `claude/common/hooks/rtk-rewrite.py`: runs rtk's rewrite and drops it for ask
     matches and for wrappers or assignments Claude Code strips before matching
   - `claude/work/settings.json`, `claude/personal/settings.json`: the Bash hook runs the wrapper
2. `fix(claude): load global instructions once, through CLAUDE.md`
   - `scripts/link.zsh`: AGENTS.md stays out of `~/.claude`; opencode and pi link the repo file
3. `fix(claude): make permission rules match what they say`
   - `claude/work/settings.json`, `claude/personal/settings.json`: `.env` rules match at
     any depth, with `.env.example` readable; `Edit(//etc/**)` is absolute; the `rm -rf`
     wildcards that refused every absolute path are gone
4. `chore(claude): drop commit and pr attribution`
   - `claude/work/settings.json`, `claude/personal/settings.json`: empty `attribution`
5. `feat(claude): deterministic preflight for github-push`
   - `claude/common/skills/github-push/preflight.py`: branch, identity and gitleaks checks
   - `claude/common/skills/github-push/SKILL.md`: user-invoked only, injects the preflight
   - `Brewfile`: gitleaks
   - `claude/work/settings.json`, `claude/personal/settings.json`: preflight hook on `git push`
   - `claude/work/rules/git-identity.md`: the SSH account is the identity while gh is logged out
6. `feat(claude): add harvest-feedback skill`
   - `claude/common/skills/harvest-feedback/`: collects feedback memories, proposes where each belongs
7. `feat(claude): house python stack and python-project scaffold`
   - `claude/common/rules/python.md`: house stack as the default, project choices first
   - `claude/common/skills/python-project/`: scaffold script, templates, ruff and mypy checks
8. `feat(claude): explain-before-approve mod for permission prompts`
   - `claude/common/mods/explain-before-approve/`: the mod and its tests
   - `scripts/link.zsh`: links the children of `mods/`
   - `claude/work/settings.json`, `claude/personal/settings.json`: `CLAUDE_CODE_PLUGIN_DIRS`
   - `AGENTS.md`: the layout lists `mods/`
9. `chore(claude): drop context7`
   - `claude/common/rules/context7.md`: removed
   - `claude/work/settings.json`: plugin entry removed, keys in the order its uninstall wrote
10. `docs(claude): adopt the RTK.md that rtk init writes`
    - `claude/common/RTK.md`: rtk's current instructions
11. `chore(work): keep settings changed from claude code`
    - `claude/work/settings.json`: effort xhigh for Opus 5.5, auto-compact and away summary off

---

## [2026-10-13 16:08] Push Summary

### Conversation Context
This push finishes the work profile's move from WSL to a MacBook Pro (Apple Silicon),
done in one session; the port commits themselves were pushed earlier by the owner. The
snacks dashboard showed the same pokemon on every start and cut tall sprites: snacks
caches a terminal section's output for an hour per working directory, and the section
had a fixed 17-line height while gen 1-6 sprites run from 7 to 26 lines. A fixed 26
lines fixed the cut but left empty rows, so the config now picks the pokemon itself and
sizes the section to that sprite. The same change hides "[Process exited 0]", which
Neovim 0.12 draws as virtual text that snacks' own hiding no longer finds.

The owner asked for a statusline closer to tokyonight. Three styles were mocked up
(LazyVim stock, slanted powerline, bubbles); the stock one won because both bars then
come from tokyonight itself: lualine, which copilot.lua had switched off, is back, and
tmux sources the theme file tokyonight.nvim ships instead of nord-tmux, which had never
been installed on the Mac. Claude Code then warned that the work profile's Write()
permission rules never match, since file paths are checked only against Edit() rules;
each had an Edit() twin, so they were removed with no change in protection.

Asked whether the Makefile's readability mattered, the review found shell logic buried
in recipes, a report block written twice, backup targets that printed "Failed" and
exited 0, and two install models side by side (symlinks for ~/.config and ~/.claude,
copies for the home dotfiles). The owner agreed to symlink everything: the linking
logic moved to scripts/link.zsh, the backup targets went, and the Makefile became a
dispatcher. Mac and WSL each link their own clone and profile, so tools on one machine
write only that profile's files; claude/common is the one shared layer. docker_plugins
became macOS-only, since Linux docker packages already put compose and buildx where
the CLI looks.

### Commits
1. `fix(work): size dashboard pokemon to its sprite and hide the exit message`
   - `work/config/nvim/lua/plugins/snacks.lua`: pick a random gen 1-6 sprite in Lua, `cat` it at its own height, `ttl = 0`, clear the exit-message extmark
2. `refactor(make): symlink every config through scripts/link.zsh`
   - `scripts/link.zsh`: new; links config, home and claude groups, reports blocked items, never overwrites real files
   - `Makefile`: dispatcher with `.PHONY`; `restore`, `link_config`, `link_home`, `link_claude`, `tpm`; backup targets removed; `docker_plugins` macOS-only
   - `README.md`: new target table, "the repo is the live config", Mac/WSL sync
   - `AGENTS.md`: new targets and where the linking logic lives
3. `fix(claude): drop Write() permission rules that never match`
   - `claude/work/settings.json`: remove three Write() rules covered by Edit() twins; model set to opus via /model
4. `feat(work): tokyonight statusline in nvim and tmux`
   - `work/config/nvim/lua/plugins/copilot.lua`: stop disabling lualine
   - `work/config/tmux.conf`: tokyonight moon theme from tokyonight.nvim, tmux-prefix-highlight, 24h clock; nord-tmux removed
5. `chore(work): update neovim plugins`
   - `work/config/nvim/lazy-lock.json`: plugin versions from the owner's `:Lazy update`

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


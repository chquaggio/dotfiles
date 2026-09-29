# AGENTS.md

This repository is a **personal dotfiles** configuration manager. It stores and
syncs development environment configs (Neovim, tmux, Zsh, lazygit) across two
environments: `personal` and `work`.

## Environments

`personal/` and `work/` share one layout but are not auto-synced: make a change
in one environment and port it to the other by hand when needed.

Every Makefile target requires `DEVENV=personal` or `DEVENV=work`; `make help
DEVENV=...` lists them. The Makefile runs under `/bin/zsh`. There is no build
step, test suite or CI.

## claude/

`claude/` is not backed up: `make link_claude` symlinks it into `~/.claude`, so
the repo is the live config and edits show up in `git status`. Shared
preferences go in `claude/common/`; anything that differs by machine
(permissions, model, hooks that need a locally installed binary, git identity)
goes in the profile directory. Never add `~/.claude.json`, `.credentials.json`
or any file under `~/.claude/projects/` — they hold tokens and machine-local
state.

## Conventions

- Lua style lives in the path-scoped rule `claude/common/rules/lua.md`. On top
  of it: plugin spec files are named after the plugin (`copilot.lua`), LSP
  config files after the server (`pylsp.lua`); files open with a header comment
  on their purpose and loading mechanism, LazyVim-style.
- Python lint config lives only in the LSP settings: pycodestyle ignores W391,
  W503 (+ E302 in work), max line 136.
- Makefile: `@` prefix on user-facing output, existence checks (`[ -d ... ]`,
  `[ -f ... ]`) before destructive operations, a success/failure message per
  operation.
- Zsh: `#` comments per section; functions use `name() { ... }`, no `function`
  keyword.
- lazygit custom commands use `runCommand` to invoke headless Neovim scripts.
- `lazy-lock.json` pins plugin versions: update via `:Lazy update` in Neovim,
  then `make backup_config`.
- Commit messages follow conventional commits (the format the headless
  CopilotChat script in `lua/scripts/run_cc_headless.lua` enforces).

# AGENTS.md

This repository is a **personal dotfiles** configuration manager. It stores and
syncs development environment configs (Neovim, tmux, Zsh, lazygit) across two
environments: `personal` (Ubuntu under WSL) and `work` (macOS, Apple Silicon).

## Repository Structure

```
dotfiles/
├── Makefile                  # Backup/restore orchestration (zsh shell)
├── Brewfile                  # macOS dependencies (`make brew`)
├── personal/config/          # Personal environment configs
│   ├── nvim/                 # LazyVim-based Neovim config (Lua)
│   ├── lazygit/config.yml    # lazygit custom commands
│   ├── tmux.conf             # tmux configuration
│   ├── .zshrc                # Zsh shell config
│   ├── .zprofile             # Login env: brew shellenv, XDG_CONFIG_HOME (work only)
│   └── .zsh_plugins.txt      # Antidote plugin list
├── work/config/              # Work environment configs (same structure)
├── claude/                   # Coding-agent global config, symlinked into ~/.claude
│   ├── common/               # Shared identity: AGENTS.md (canonical cross-agent
│   │                         # prefs), CLAUDE.md (imports it), OPINIONS.md, RTK.md,
│   │                         # skills/, rules/ (path-scoped), hooks/, statusline.py
│   ├── personal/             # Profile overlay: settings.json, rules/git-identity.md
│   └── work/                 # Same shape as personal/
└── cheat_sheets/             # Reference docs (vim, tmux, aws)
```

Both `personal/` and `work/` follow the same layout. Key differences:
- **personal**: Powerlevel10k, WSL clipboard, lua_ls + pylsp, neo-tree
- **work**: macOS only. robbyrussell theme, launchd ssh-agent + Keychain, secrets from
  the login Keychain (`security find-generic-password`), fnm, pylsp only, codeium, rest.nvim.
  No Linux branches and no hardcoded `/home/...` paths: use `$HOME`/`~`.

## Build / Backup / Restore Commands

`help`, `brew` and `docker_plugins` run without `DEVENV`; every other target requires
`DEVENV=personal` or `DEVENV=work`:

```bash
make help                            # Show available targets (default goal)
make brew                            # brew bundle --file=Brewfile
make docker_plugins                  # Merge cliPluginsExtraDirs into ~/.docker/config.json
make backup DEVENV=personal          # Full backup (nvim, lazygit, tmux, zsh)
make backup_config DEVENV=personal   # Copy back ~/.config dirs that are NOT symlinks
make backup_tmux DEVENV=personal     # ~/.tmux.conf
make backup_zsh DEVENV=personal      # ~/.zshrc, ~/.zsh_plugins.txt (+ .zprofile if versioned)
make restore DEVENV=personal         # restore_config + restore_tmux + restore_zsh + link_claude
make restore_config DEVENV=personal  # Symlink nvim/, lazygit/, opencode/ into ~/.config
make restore_tmux DEVENV=personal    # Copy ~/.tmux.conf; clone TPM if missing
make restore_zsh DEVENV=personal     # Copy ~/.zshrc, plugins (+ .zprofile if versioned)
make link_claude DEVENV=personal     # Symlink claude/common + claude/personal into
                                     # ~/.claude; link AGENTS.md for opencode and pi
```

The Makefile must run on both BSD (macOS) and GNU userland: no `ln -T`, no GNU regex
(`\+`, `\s`), no trailing slash on a `cp -R` source. `restore_config` and
`link_claude` share `LINK_FN`, which never overwrites a real file or directory: it
reports it as blocked and keeps linking the rest. To test, use a throwaway home
(`HOME=$(mktemp -d) make restore DEVENV=work`), never the real one.

`claude/` and the `~/.config` dirs are not backed up: the symlinks make the repo the live config, so edits show
up in `git status`. Shared preferences go in `claude/common/`; anything that differs by
machine (permissions, model, hooks that need a locally installed binary, git identity)
goes in the profile directory. Never add `~/.claude.json`, `.credentials.json` or any
file under `~/.claude/projects/` — they hold tokens and machine-local state.

The Makefile uses `/bin/zsh` as its shell. There is no build step, test suite,
or CI/CD pipeline.

## Testing

There is no test framework or test files in this repository. The `.gitignore`
excludes `.tests/`, `tt.*`, `foo.*`, `debug`, and `.repro` -- these patterns
are used for throwaway scratch files; do not commit files matching them.

## Formatting and Linting

**Lua:** StyLua (`{personal,work}/config/nvim/stylua.toml`): 2 spaces, 120
column width. Run: `stylua personal/config/nvim/lua/` (or `work/`).

**Python:** pycodestyle ignores W391, W503 (+ E302 in work). Max line 136.
Black formatter enabled via LazyVim extras. Config lives in LSP settings only.

**Shell:** No linter configured. Follow existing `.zshrc` conventions.

## Code Style Guidelines

### Lua (Neovim Plugin Configs)

**Indentation:** 2 spaces, no tabs. Max line width: 120 characters.

**Plugin spec pattern:** Each plugin gets its own file in `lua/plugins/`.
Return a single table (or list of tables) from each file:

```lua
return {
  "author/plugin-name",
  dependencies = { "dep/name" },
  opts = {
    -- configuration
  },
}
```

**Imports:** Use `require()` calls. Prefer `local` variables.

**LSP configs:** Place server configs in `lua/lsp/<server>.lua`. Each file
returns a `vim.lsp.Config` table with `cmd`, `filetypes`, `root_markers`,
and `settings`. Annotate with `---@type vim.lsp.Config`.

**Error handling:** Use `pcall()` for optional module loading. Report failures
with `vim.notify()` at `vim.log.levels.WARN`:
```lua
local ok, err = pcall(vim.lsp.config, "server", config)
if not ok then
  vim.notify("Failed to configure server: " .. tostring(err), vim.log.levels.WARN)
end
```

**Naming conventions:**
- `snake_case` for variables and functions
- Plugin spec files named after the plugin (e.g., `copilot.lua`, `fzf.lua`)
- LSP config files named after the server (e.g., `pylsp.lua`, `lua_ls.lua`)

**Comments:** Use `--` for single-line comments. Place header comments at the
top of files explaining purpose and loading mechanism. Use LazyVim-style
comments referencing default config URLs.

**Keymaps:** Use `vim.keymap.set()` with `desc`, `noremap`, and `silent` opts:
```lua
vim.keymap.set("n", "<leader>rr", "<cmd>Rest run<CR>",
  { noremap = true, silent = true, desc = "Run REST request" })
```

**Neovim API version:** Personal config uses Neovim 0.11+ APIs (`vim.uv`,
`vim.lsp.config()`, `vim.lsp.enable()`). Work config uses older APIs
(`vim.loop`). Match the convention of whichever environment you're editing.

### Makefile

- Shell: `/bin/zsh`
- Use `@` prefix to suppress command echo for user-facing output
- Guard destructive operations with existence checks (`[ -d ... ]`, `[ -f ... ]`)
- Print success/failure messages for each operation

### Zsh Configuration

- Use `#` comments to describe sections
- Group related config: plugins, PATH, aliases, functions, SSH, external tools
- Shell functions use `name() { ... }` syntax (no `function` keyword)
- Aliases for common tools: `vim=nvim`, `cat="batcat -p"` (personal, Ubuntu); work aliases `cat` to
  `bat -p` only when `bat` exists. Work has no `python` alias: uv provides `python`/`python3` in `~/.local/bin`

### YAML (lazygit)

- 2-space indentation
- lazygit custom commands use `runCommand` to invoke headless Neovim scripts

## Key Files Reference

| File | Purpose |
|------|---------|
| `*/config/nvim/init.lua` | Neovim entry point; bootstraps lazy.nvim, mason, LSP |
| `*/config/nvim/lua/config/lazy.lua` | lazy.nvim plugin manager setup |
| `*/config/nvim/lua/config/lsp.lua` | LSP server registration (0.11+ APIs) |
| `*/config/nvim/lua/config/keymaps.lua` | Custom keybindings |
| `*/config/nvim/lua/config/options.lua` | Neovim option overrides |
| `*/config/nvim/lua/plugins/*.lua` | Individual plugin configurations |
| `*/config/nvim/lua/lsp/*.lua` | LSP server config tables |
| `*/config/nvim/lua/scripts/*.lua` | Utility scripts (headless commit msg) |
| `*/config/nvim/lazyvim.json` | LazyVim extras list |
| `*/config/nvim/stylua.toml` | StyLua formatter settings |

## Important Notes

- No cursor rules (`.cursorrules`, `.cursor/rules/`) or copilot instructions
  (`.github/copilot-instructions.md`) exist in this repository.
- Changes should generally be made to **one environment** (`personal/` or
  `work/`) and manually ported to the other if needed -- they are not auto-synced.
- The `lazy-lock.json` files pin plugin versions; update them via `:Lazy update`
  in Neovim. With `~/.config/nvim` symlinked (`restore_config`) the change is already
  in the repo; commit it.
- Commit messages follow conventional commits format (as enforced by the
  headless CopilotChat script in `lua/scripts/run_cc_headless.lua`).

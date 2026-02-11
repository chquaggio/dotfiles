# AGENTS.md

This repository is a **personal dotfiles** configuration manager. It stores and
syncs development environment configs (Neovim, tmux, Zsh, lazygit) across two
environments: `personal` and `work`.

## Repository Structure

```
dotfiles/
├── Makefile                  # Backup/restore orchestration (zsh shell)
├── personal/config/          # Personal environment configs
│   ├── nvim/                 # LazyVim-based Neovim config (Lua)
│   ├── lazygit/config.yml    # lazygit custom commands
│   ├── tmux.conf             # tmux configuration
│   ├── .zshrc                # Zsh shell config
│   └── .zsh_plugins.txt      # Antidote plugin list
├── work/config/              # Work environment configs (same structure)
└── cheat_sheets/             # Reference docs (vim, tmux, aws)
```

Both `personal/` and `work/` follow the same layout. Key differences:
- **personal**: Powerlevel10k, WSL clipboard, lua_ls + pylsp, neo-tree
- **work**: robbyrussell theme, keychain SSH, pylsp only, codeium, kulala

## Build / Backup / Restore Commands

All commands require `DEVENV=personal` or `DEVENV=work`:

```bash
make backup DEVENV=personal          # Full backup (nvim, lazygit, tmux, zsh)
make backup_config DEVENV=personal   # nvim/ and lazygit/ from ~/.config/
make backup_tmux DEVENV=personal     # ~/.tmux.conf
make backup_zsh DEVENV=personal      # ~/.zshrc and ~/.zsh_plugins.txt
make restore DEVENV=personal         # Full restore (inverse of backup)
make restore_config DEVENV=personal  # Restore nvim/ and lazygit/
make restore_tmux DEVENV=personal    # Restore ~/.tmux.conf
make restore_zsh DEVENV=personal     # Restore ~/.zshrc and plugins
make help DEVENV=personal            # Show available targets
```

The Makefile uses `/bin/zsh` as its shell. There is no build step, test suite,
or CI/CD pipeline. The `DEVENV` variable is **required** for every target.

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
- Aliases for common tools: `vim=nvim`, `cat="batcat -p"`, `python=python3`

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
  in Neovim, then back up with `make backup_config`.
- Commit messages follow conventional commits format (as enforced by the
  headless CopilotChat script in `lua/scripts/run_cc_headless.lua`).

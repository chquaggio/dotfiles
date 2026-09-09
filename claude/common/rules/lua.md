---
paths:
  - "**/*.lua"
---

# Lua (Neovim config)

- StyLua: 2 spaces, 120 columns. `snake_case` names, `local` by default.
- LazyVim layout: one plugin spec per file in `lua/plugins/`, returning a table;
  one LSP server per file in `lua/lsp/`, returning a `---@type vim.lsp.Config`.
- Keymaps go through `vim.keymap.set(mode, lhs, rhs, { desc = ..., silent = true })`;
  `desc` is required.
- Optional modules load with `pcall(require, ...)`; a failure is reported with
  `vim.notify(..., vim.log.levels.WARN)`, never swallowed.
- Match the Neovim API level of the config being edited: `vim.uv` and
  `vim.lsp.config()` in the personal config, `vim.loop` in the work one.

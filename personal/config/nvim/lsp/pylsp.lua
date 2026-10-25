-- Python LSP Configuration for Neovim 0.11+
-- This config is loaded by lua/config/lsp.lua using vim.lsp.config()
--
-- The pylsp (Python Language Server Protocol) provides:
-- - Code completion, go-to-definition, find references
-- - Linting via pycodestyle, pyflakes, etc.
-- - Formatting (when configured)
--
-- Install: mason will install pylsp automatically via ensure_installed
-- Manual install: pip install python-lsp-server

---@type vim.lsp.Config
return {
  cmd = { "pylsp" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { "W391", "W503" },
          maxLineLength = 136,
        },
        -- Additional plugins can be configured here:
        -- pylint = { enabled = true },
        -- black = { enabled = true },
        -- pyflakes = {
        --   enabled = false,
        -- },
      },
    },
  },
}

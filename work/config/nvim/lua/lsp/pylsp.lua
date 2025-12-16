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
          ignore = { "W391", "W503", "E302" },
          maxLineLength = 136,
        },
        -- pyflakes = {
        --   enabled = false,
        -- },
      },
    },
  },
}

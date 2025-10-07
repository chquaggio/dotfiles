-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("mason-lspconfig").setup()

vim.lsp.config("pylsp", require("lsp.pylsp"))
vim.lsp.enable("pylsp")

-- Register copilot-chat filetype
require("render-markdown").setup({
  file_types = { "markdown", "copilot-chat" },
})

-- Adjust chat display settings
require("CopilotChat").setup({
  highlight_headers = false,
  separator = "---",
  error_header = "> [!ERROR] Error",
})

require("mini.surround").setup()

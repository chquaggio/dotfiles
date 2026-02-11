-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Setup mason-lspconfig with error handling
local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok then
  mason_lspconfig.setup()
end

-- Configure LSP servers using built-in vim.lsp APIs (Neovim 0.11+)
vim.lsp.config("pylsp", require("lsp.pylsp"))
vim.lsp.enable("pylsp")

-- Setup mini.surround
require("mini.surround").setup()

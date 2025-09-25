-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("mason-lspconfig").setup()

vim.lsp.config("pylsp", require("lsp.pylsp"))
vim.lsp.enable("pylsp")

require("mini.surround").setup()

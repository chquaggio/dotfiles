-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Setup mason-lspconfig with error handling
local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok then
  mason_lspconfig.setup()
end

-- Setup mini.surround
require("mini.surround").setup()

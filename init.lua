-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("mason").setup()
require("mason-lspconfig").setup()
require("lspconfig").pylsp.setup({
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { "W391" },
          maxLineLength = 136,
        },
      },
    },
  },
})

-- local navbuddy = require("nvim-navbuddy")
--
-- require("lspconfig").clangd.setup({
--   on_attach = function(client, bufnr)
--     navbuddy.attach(client, bufnr)
--   end,
-- })

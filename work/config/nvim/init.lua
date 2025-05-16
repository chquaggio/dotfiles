-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("mason").setup()
require("mason-lspconfig").setup()
require("lspconfig").pylsp.setup({
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { "W391", "W503" },
          maxLineLength = 136,
        },
        -- pyflakes = {
        --   enabled = false,
        -- },
      },
    },
  },
})

require("mini.surround").setup()

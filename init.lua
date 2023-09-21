-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.env.DEBUG_CODEIUM = "debug"
require("neo-tree").setup({
  window = {
    mappings = {
      ["<left>"] = "navigate_up",
      ["<right>"] = "open",
    },
  },
  filesystem = {
    window = {
      mappings = {
        ["<left>"] = "navigate_up",
        ["<right>"] = "open",
      },
    },
  },
  buffers = {
    window = {
      mappings = {
        ["<left>"] = "navigate_up",
        ["<right>"] = "open",
      },
    },
  },
})
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

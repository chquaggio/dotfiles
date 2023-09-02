-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
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

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
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
  },
}

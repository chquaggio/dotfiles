return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function()
    -- Define arrow key mappings once to avoid duplication
    local arrow_mappings = {
      ["<left>"] = "navigate_up",
      ["<right>"] = "open",
    }

    return {
      window = {
        mappings = arrow_mappings,
      },
      filesystem = {
        window = {
          mappings = arrow_mappings,
        },
      },
      buffers = {
        window = {
          mappings = arrow_mappings,
        },
      },
    }
  end,
}

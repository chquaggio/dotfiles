return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },

  keys = {
    { "<leader>rr", desc = "Send request" },
    { "<leader>ra", desc = "Send all requests" },
    { "<leader>rb", desc = "Open scratchpad" },
  },

  opts = {
    global_keymaps = false,
    global_keymaps_prefix = "<leader>r",
    kulala_keymaps_prefix = "",
  },
}

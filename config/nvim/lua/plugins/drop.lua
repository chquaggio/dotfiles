return {
  -- drop nvim
  {
    "folke/drop.nvim",
    enabled = false,
    event = "VimEnter",
    config = function()
      require("drop").setup({
        screensaver = 1000 * 60 * 2,
      })
    end,
  },
}

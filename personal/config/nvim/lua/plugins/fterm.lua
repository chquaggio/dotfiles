return {
  "numToStr/FTerm.nvim",
  pin = true,
  config = function()
    local fterm = require("FTerm")
    fterm.setup({
      border = "single",
      dimensions = {
        height = 0.7,
        width = 0.7,
      },
    })
  end,
}

local cmp = require("cmp")

cmp.setup({
  sources = {
    -- { name = "copilot", group_index = 2 },
    { name = "codeium", group_index = 2 },
  },
  formatting = {
    format = require("lspkind").cmp_format({
      mode = "symbol",
      maxwidth = 50,
      ellipsis_char = "...",
      symbol_map = { Codeium = "" },
    }),
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      require("copilot_cmp.comparators").prioritize,

      -- Below is the default comparitor list and order for nvim-cmp
      cmp.config.compare.offset,
      -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
})

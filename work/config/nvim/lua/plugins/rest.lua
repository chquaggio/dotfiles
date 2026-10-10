-- rest.nvim: run HTTP requests from .http files (https://github.com/rest-nvim/rest.nvim).
-- No setup() call: options go in vim.g.rest_nvim (see :h rest-nvim.config). lazy.nvim
-- installs the luarocks dependencies from the plugin's rockspec (nvim-nio, mimetypes,
-- xml2lua, fidget.nvim, tree-sitter-http) through hererocks, which needs a C compiler
-- (Xcode Command Line Tools). Requests are sent with curl.
--
-- tree-sitter-http only builds when luarocks can find its build back-end, which it looks
-- for in hererocks' own tree, not in the per-plugin tree lazy.nvim installs into. On a
-- new machine, once (after the first nvim start has built hererocks), run
--   ~/.local/share/nvim/lazy-rocks/hererocks/bin/luarocks install luarocks-build-treesitter-parser
-- then :Lazy build rest.nvim. Without it the build fails and lazy.nvim removes every rock.
return {
  "rest-nvim/rest.nvim",
  ft = "http",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "http")
      end,
    },
  },
  keys = {
    { "<leader>rr", "<cmd>Rest run<cr>", ft = "http", desc = "Run request under cursor" },
    { "<leader>rl", "<cmd>Rest last<cr>", ft = "http", desc = "Re-run last request" },
    { "<leader>ro", "<cmd>Rest open<cr>", ft = "http", desc = "Open result pane" },
    { "<leader>re", "<cmd>Rest env select<cr>", ft = "http", desc = "Select .env file" },
  },
}

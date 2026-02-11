return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = { "lua_ls", "pylsp" },
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    -- Note: We use Neovim 0.11+ built-in vim.lsp.config() API
    -- instead of nvim-lspconfig, so that dependency is not needed
  },
}

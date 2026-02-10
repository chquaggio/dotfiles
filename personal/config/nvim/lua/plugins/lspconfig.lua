return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pylsp = {
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                ignore = { "W391", "W503" },
                maxLineLength = 136,
              },
            },
          },
        },
      },
    },
  },
}

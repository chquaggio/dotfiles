return {
  "folke/snacks.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    dashboard = {
      preset = {
        header = [[
      ██████╗ ██╗   ██╗ ██████╗  ██████╗  ██████╗ ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
      ██╔═══██╗██║   ██║██╔═══██╗██╔════╝ ██╔════╝ ██║██╔═══██╗██║   ██║██║████╗ ████║
      ██║   ██║██║   ██║██║   ██║██║  ███╗██║  ███╗██║██║   ██║██║   ██║██║██╔████╔██║
      ██║▄▄ ██║██║   ██║██║   ██║██║   ██║██║   ██║██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
      ╚██████╔╝╚██████╔╝╚██████╔╝╚██████╔╝╚██████╔╝██║╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
      ╚══▀▀═╝  ╚═════╝  ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
        ]],
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
        {
          section = "terminal",
          cmd = "pokemon-colorscripts -r 1-6 --no-title; sleep .1",
          random = 10,
          pane = 2,
          indent = 4,
          height = 15,
        },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
      },
    },
  },
}

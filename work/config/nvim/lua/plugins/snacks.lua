-- The dashboard pokemon is picked here rather than with `pokemon-colorscripts -r`, so the
-- terminal section can take this sprite's height: sprites run from 7 to 26 lines, and a
-- fixed height either truncates the tall ones or leaves empty rows under the short ones.
-- The sprite files are plain ANSI text, so `cat` shows them without starting Python.
local function random_pokemon()
  local exe = vim.fn.exepath("pokemon-colorscripts") -- not in Homebrew: absent on some machines
  if exe == "" then
    return nil
  end
  local root = vim.fn.fnamemodify(vim.fn.resolve(exe), ":h")
  local ok, mons = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. "/pokemon.json"), "\n"))
  if not ok then
    vim.notify("Dashboard pokemon: cannot read pokemon.json: " .. tostring(mons), vim.log.levels.WARN)
    return nil
  end
  math.randomseed(vim.uv.hrtime())
  local file = root .. "/colorscripts/small/regular/" .. mons[math.random(721)].name -- gens 1-6: dex 1-721
  return { cmd = "cat " .. vim.fn.shellescape(file), height = #vim.fn.readfile(file) }
end

local pokemon = random_pokemon()

-- Neovim 0.12 draws "[Process exited 0]" as virtual text, which snacks' own hiding
-- (it looks for a buffer line) misses: clear it for the pokemon terminal.
vim.api.nvim_create_autocmd("TermClose", {
  callback = function(ev)
    if not (vim.b[ev.buf].term_title or ""):find("colorscripts", 1, true) then
      return
    end
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        vim.api.nvim_buf_clear_namespace(ev.buf, vim.api.nvim_create_namespace("nvim.terminal.exitmsg"), 0, -1)
      end
    end, 50)
  end,
})

return {
  "folke/snacks.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    dashboard = {
      width = 70,
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
          cmd = pokemon and pokemon.cmd,
          enabled = pokemon ~= nil,
          padding = 1,
          pane = 2,
          indent = 4,
          height = pokemon and pokemon.height,
          -- snacks caches terminal output for an hour per cwd by default: a new pokemon every start
          ttl = 0,
        },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
      },
    },
  },
}

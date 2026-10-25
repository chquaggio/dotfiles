-- LSP Configuration using Neovim 0.11+ built-in APIs
-- The server definitions live in lsp/*.lua, which Neovim reads by itself; this file adds
-- what a definition cannot hold (lua_ls's on_init) and enables the servers.

-- lua_ls: workspace-aware setup, for better completions of the Neovim runtime and plugins
vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      -- Skip workspace setup if there's a .luarc.json/.luarc.jsonc file
      -- (project has its own Lua configuration)
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    -- Apply Neovim-specific Lua settings for better completions
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        version = "LuaJIT",
        -- Tell the language server how to find Lua modules
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- You can add additional paths here if needed:
          -- "${3rd}/luv/library",
          -- "${3rd}/busted/library",
        },
      },
    })
  end,
})

-- Python: ruff lints and formats, basedpyright checks types. Markdown: rumdl.
vim.lsp.enable({ "lua_ls", "ruff", "basedpyright", "rumdl" })

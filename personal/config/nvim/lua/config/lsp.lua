-- LSP Configuration using Neovim 0.11+ built-in APIs
-- This file configures LSP servers using vim.lsp.config() and vim.lsp.enable()
-- instead of the nvim-lspconfig plugin

-- Load LSP configurations
local pylsp_config = require("lsp.pylsp")
local lua_ls_config = require("lsp.lua_ls")

-- Configure lua_ls with on_init callback for workspace-aware setup
-- This improves completions for Neovim runtime and plugins
lua_ls_config.on_init = function(client)
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
end

-- Configure and enable pylsp (Python Language Server)
local ok, err = pcall(vim.lsp.config, "pylsp", pylsp_config)
if ok then
  vim.lsp.enable("pylsp")
else
  vim.notify("Failed to configure pylsp: " .. tostring(err), vim.log.levels.WARN)
end

-- Configure and enable lua_ls (Lua Language Server)
ok, err = pcall(vim.lsp.config, "lua_ls", lua_ls_config)
if ok then
  vim.lsp.enable("lua_ls")
else
  vim.notify("Failed to configure lua_ls: " .. tostring(err), vim.log.levels.WARN)
end

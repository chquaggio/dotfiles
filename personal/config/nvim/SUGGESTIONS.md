# Neovim 0.11+ Configuration - Additional Suggestions

This document contains optional improvements and best practices for your Neovim configuration.

## Current Status ✅

Your configuration is now using **Neovim 0.11+ best practices**:
- ✅ Native `vim.lsp.config()` and `vim.lsp.enable()` APIs
- ✅ Modern `vim.uv` instead of deprecated `vim.loop`
- ✅ lua_ls configured with workspace-aware on_init
- ✅ Clean LSP configuration in dedicated file
- ✅ Proper error handling

## Additional Suggestions (Optional)

### 1. LSP Enhancements

#### Add LSP Progress Notifications
You can enable better LSP loading feedback:

```lua
-- In lua/config/lsp.lua, add at the top:
-- Enable LSP progress UI (Neovim 0.10+)
vim.lsp.handlers["$/progress"] = vim.lsp.handlers["$/progress"]
```

LazyVim likely handles this already through Snacks.nvim, so verify first.

#### Add LSP Inlay Hints Toggle
Neovim 0.10+ has built-in inlay hints support:

```lua
-- In lua/config/keymaps.lua, add:
vim.keymap.set("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle Inlay Hints" })
```

#### Document Additional LSP Servers
If you use other languages, you can add their LSP configs:

```lua
-- Create lua/lsp/[server_name].lua files following the pattern
-- Then add to lua/config/lsp.lua:
local server_config = require("lsp.server_name")
vim.lsp.config("server_name", server_config)
vim.lsp.enable("server_name")
```

### 2. Diagnostic Configuration

Consider customizing diagnostic display (if not already done by LazyVim):

```lua
-- In lua/config/options.lua or lua/config/lsp.lua:
vim.diagnostic.config({
  virtual_text = {
    prefix = "●", -- Could be '■', '▎', etc.
    source = "if_many", -- Show source if multiple sources
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})
```

### 3. Performance Optimizations

#### Consider Lazy-Loading More Plugins
Your current setup has `lazy = false` in lua/config/lazy.lua line 24.
Consider enabling lazy-loading for better startup time:

```lua
defaults = {
  lazy = true, -- Enable lazy-loading by default
  version = false,
},
```

Then mark frequently-used plugins as `lazy = false` or use proper events/keys.

#### Profile Startup Time
Check your startup performance:
```vim
:StartupTime
```
Or use: `nvim --startuptime startup.log`

### 4. Modern Lua Features

#### Use vim.iter for Functional Programming
Neovim 0.10+ includes `vim.iter()` for functional operations:

```lua
-- Instead of loops, you can use:
local files = vim.iter(vim.fs.dir("/path")):filter(function(name)
  return name:match("%.lua$")
end):totable()
```

#### Use vim.fs for File System Operations
```lua
-- Find files in parents:
local root = vim.fs.root(0, {".git", "package.json"})

-- Find all matching files:
local lua_files = vim.fs.find("*.lua", {
  limit = math.huge,
  type = "file",
  path = vim.fn.stdpath("config"),
})
```

### 5. LSP Capabilities

If you need to extend LSP capabilities (usually not needed with LazyVim + blink.cmp):

```lua
-- In lua/config/lsp.lua, before vim.lsp.config():
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Then add to your config:
pylsp_config.capabilities = capabilities
lua_ls_config.capabilities = capabilities
```

### 6. Documentation

#### Add a README to Your nvim Config
Create `personal/config/nvim/README.md` documenting:
- Which Neovim version is required (0.11+)
- What LSP servers are configured
- Custom keybindings you've added
- How to install dependencies

### 7. Git Hooks

Consider adding a pre-commit hook to format Lua files:

```bash
# .git/hooks/pre-commit
#!/bin/bash
stylua --check personal/config/nvim/lua/
```

You already have stylua.toml, so this would ensure consistency.

### 8. Completion Sources

Your blink.cmp configuration is already excellent! Consider:
- Adding `lazydev` for better Neovim API completion
- Configuring snippet engines if needed

### 9. Testing LSP Configuration

Verify your LSP setup:
```vim
:lua print(vim.inspect(vim.lsp.config["lua_ls"]))
:lua print(vim.inspect(vim.lsp.config["pylsp"]))
:checkhealth vim.lsp
:LspInfo
```

## What NOT to Do

❌ Don't mix nvim-lspconfig with vim.lsp.config() - pick one approach
❌ Don't use `vim.loop` (deprecated) - use `vim.uv` instead
❌ Don't manually manage LSP client lifecycle - let vim.lsp.enable() handle it
❌ Avoid heavy plugins if LazyVim already provides the functionality

## Resources

- [Neovim 0.11 LSP Documentation](https://neovim.io/doc/user/lsp.html)
- [LazyVim Documentation](https://www.lazyvim.org/)
- [vim.lsp.config Examples](https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/config.lua)

## Summary

Your configuration is now following Neovim 0.11+ best practices! The suggestions above are
optional enhancements you can implement based on your workflow needs.

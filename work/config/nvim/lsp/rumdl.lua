-- rumdl language server. Only the overrides of rumdl's defaults live here
-- (`rumdl config --defaults` lists them all). A `.rumdl.toml` found upward from the
-- file is read first; these settings win over it.
-- Rule options are kebab-case as in .rumdl.toml. Global options use camelCase.
-- `disableRules` and `enableRules` work only under `init_options`.

---@type vim.lsp.Config
return {
  cmd = { "rumdl", "server" },
  filetypes = { "markdown" },
  root_markers = { ".rumdl.toml", "rumdl.toml", "pyproject.toml", ".git" },
  settings = {
    rumdl = {
      lineLength = 144,
      MD013 = { reflow = true },
    },
  },
  init_options = {
    enableAutoFix = true,
  },
}

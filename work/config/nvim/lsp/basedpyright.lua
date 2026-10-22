-- basedpyright language server. Same chain as ruff.lua: the project's venv build first, then
-- Mason's. The venv's python also resolves imports, unless the project's pyright config sets
-- venvPath/venv.
--
-- Editor settings are a fallback: a project with a `[tool.pyright]` / `[tool.basedpyright]`
-- section or a pyrightconfig.json ignores them (tested: its typeCheckingMode and rule
-- severities beat the ones below). They apply to files without such a config.
--
-- Only the overrides of basedpyright's defaults live here. `standard` is the mode fantaquoggio
-- uses (the server's own default is `recommended`, far noisier). Three rules are off because
-- ruff reports the same thing (F401, F841, B018); organizing imports is ruff's too.
-- Do not set `stubPath`, even to its default: the server then warns in every project without
-- a `typings` directory. Options that exist only in a config file (pythonVersion, strict,
-- executionEnvironments, ...) cannot be set here.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/basedpyright-langserver"

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local bin = require("config.python").venv_path(config.root_dir, "bin/basedpyright-langserver") or mason_bin
    return vim.lsp.rpc.start({ bin, "--stdio" }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "pyrightconfig.json", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  before_init = function(_, config)
    local python = require("config.python").venv_path(config.root_dir, "bin/python")
    if python then
      config.settings = vim.tbl_deep_extend("force", config.settings or {}, { python = { pythonPath = python } })
    end
  end,
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        typeCheckingMode = "standard",
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
          reportUnusedExpression = "none",
        },
      },
    },
  },
}

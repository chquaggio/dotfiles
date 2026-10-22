-- ruff language server. Lint, format and fix-all come from the ruff the project pins, so the
-- editor, CI and pre-commit agree. A project without ruff (or without a venv yet) falls back
-- to the Mason build.
--
-- `configuration` holds only the overrides of ruff's defaults (`ruff config` lists them all);
-- `filesystemFirst` makes the project's pyproject.toml / ruff.toml win over it, so it only
-- fills what a project leaves unset. `lint.select` and `lint.ignore` are fantaquoggio's.
-- An empty Lua table is sent as `[]`, which the server rejects for map-typed options
-- (`per-file-ignores`, `isort.sections`, ...): use `vim.empty_dict()` there.
local mason_ruff = vim.fn.stdpath("data") .. "/mason/bin/ruff"

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local bin = require("config.python").venv_path(config.root_dir, "bin/ruff") or mason_ruff
    return vim.lsp.rpc.start({ bin, "server" }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  init_options = {
    settings = {
      configurationPreference = "filesystemFirst",
      configuration = {
        ["line-length"] = 132,
        ["target-version"] = "py313",
        lint = {
          select = { "E", "F", "W", "I", "UP", "B", "SIM", "RUF", "ANN", "DTZ", "PL" },
          ignore = { "PLR0913", "PLR2004", "ANN401" },
        },
      },
    },
  },
}

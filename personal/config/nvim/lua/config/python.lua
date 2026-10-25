local M = {}

-- The root of an LSP client is the nearest pyproject.toml, which in a uv workspace is a
-- member package; the venv sits at the workspace root, so it is searched upward.
---@param root_dir string?
---@param name string file inside the venv, e.g. "bin/ruff"
---@return string? path
function M.venv_path(root_dir, name)
  if not root_dir then
    return nil
  end
  local venv = vim.fs.find(".venv", { path = root_dir, upward = true, type = "directory" })[1]
  local path = venv and (venv .. "/" .. name)
  return path and vim.uv.fs_stat(path) and path or nil
end

return M

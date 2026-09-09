#!/usr/bin/env bash
# PostToolUse: ruff-format a Python file Claude just edited. Prefers the project's
# own ruff (pinned version, project config); falls back to uvx. No-op for other files.
file=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))')
case "$file" in
  *.py) ;;
  *) exit 0 ;;
esac
ruff="${CLAUDE_PROJECT_DIR:-.}/.venv/bin/ruff"
if [ -x "$ruff" ]; then
  "$ruff" format --quiet "$file"
elif command -v uvx >/dev/null; then
  uvx --quiet ruff format --quiet "$file"
fi
exit 0

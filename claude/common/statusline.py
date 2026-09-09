#!/usr/bin/env python3
"""Status line: model · project@branch · context-usage bar. Reads Claude Code's JSON on stdin."""

import json
import os
import subprocess
import sys

d = json.load(sys.stdin)
model = d.get("model", {}).get("display_name", "?")
cw = d.get("context_window") or {}
pct = cw.get("used_percentage") or 0
size = cw.get("context_window_size") or 0
cwd = d.get("workspace", {}).get("current_dir") or os.getcwd()

git = subprocess.run(
    ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True
)
branch = f"@{git.stdout.strip()}" if git.returncode == 0 else ""

filled = round(pct / 10)
color = "\033[32m" if pct < 50 else "\033[33m" if pct < 75 else "\033[31m"
bar = f"{color}{'█' * filled}{'░' * (10 - filled)}\033[0m"
size_k = f"/{size // 1000}k" if size else ""
print(f"{model} │ {os.path.basename(cwd)}{branch} │ {bar} {pct:.0f}%{size_k}")

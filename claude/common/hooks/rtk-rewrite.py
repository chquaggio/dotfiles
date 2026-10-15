#!/usr/bin/env python3
"""PreToolUse: rtk's Bash rewrite, kept only where it cannot change a permission outcome.

Claude Code matches permission rules against the command a hook returns, so `Bash(git push*)`
never matches `rtk git push`. rtk reads the rules itself: it leaves a deny match alone, and
marks an ask match by rewriting without a decision, expecting a prompt that never comes. Its
matcher also misses the wrappers and assignments Claude Code strips before matching
(`timeout 30 git push`), and returns allow for them. Both cases run unrewritten here, so
Claude Code matches the command Claude wrote.

Usage in settings.json: `rtk-rewrite.py rtk hook claude`, the arguments being the rtk hook to
wrap. rtk recognizes only a hook whose command is exactly `rtk hook claude`, so `rtk gain`
warns "No hook installed" although rtk runs, and `rtk init -g` would add a second, unwrapped
hook that brings the ask bypass back: update rtk's files with `rtk init -g --no-patch`.
"""

import json
import re
import subprocess
import sys

# https://code.claude.com/docs/en/permissions#process-wrappers, at the start of any subcommand
STRIPPED_PREFIX = re.compile(
    r"(?:^|[;&|(){}\n])\s*"
    r"(?:(?:timeout|time|nice|nohup|stdbuf|command|builtin|noglob|xargs)\s|[A-Za-z_][A-Za-z0-9_]*=)"
)

hook_input = sys.stdin.read()
command = json.loads(hook_input).get("tool_input", {}).get("command", "")
if STRIPPED_PREFIX.search(command):
    sys.exit(0)

rewrite = subprocess.run(
    sys.argv[1:],
    input=hook_input,
    capture_output=True,
    text=True,
    check=True,
).stdout
if (
    rewrite.strip()
    and "permissionDecision" in json.loads(rewrite)["hookSpecificOutput"]
):
    sys.stdout.write(rewrite)

#!/usr/bin/env python3
"""Print every `feedback` auto memory on this machine, with the project it came from.

Auto memory is per project and machine-local (~/.claude/projects/<project>/memory/), so a
correction given in one repo never reaches the others until it moves into the dotfiles.
"""

import re
from datetime import date
from pathlib import Path

FRONTMATTER = re.compile(r"\A---\n(.*?)\n---\n", re.S)
FEEDBACK = re.compile(r"^\s*type:\s*feedback\s*$", re.M)

# This file lives at <repo>/claude/common/skills/harvest-feedback/collect.py
print(f"dotfiles repo: {Path(__file__).resolve().parents[4]}")
memories = []
for path in sorted(Path.home().glob(".claude/projects/*/memory/*.md")):
    frontmatter = FRONTMATTER.match(path.read_text())
    if frontmatter and FEEDBACK.search(frontmatter.group(1)):
        memories.append(path)
if not memories:
    print("no feedback memories under ~/.claude/projects/*/memory/")
for path in memories:
    saved = date.fromtimestamp(path.stat().st_mtime)
    print(f"\n=== {path}  (project dir {path.parents[1].name}, saved {saved})")
    print(path.read_text().strip())

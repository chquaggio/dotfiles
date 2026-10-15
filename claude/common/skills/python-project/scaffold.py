#!/usr/bin/env python3
"""Create a Python project on the house stack (~/.claude/rules/python.md).

    scaffold.py DIR --python 3.15 [--api] [--db sqlite|postgres] [--data] [--http]

Runs `uv init --package`, adds the dependencies of each chosen capability, appends the
tool configuration, renders the templates, then runs the checks the project lives by.
Exits 1 when a check fails.
"""

import argparse
import re
import subprocess
import sys
import tomllib
from pathlib import Path

TEMPLATES = Path(__file__).resolve().parent / "templates"
DEV = ["pytest", "pytest-asyncio", "ruff", "mypy"]
DRIVERS = {"sqlite": "aiosqlite", "postgres": "asyncpg"}
# SQLite runs in memory; any other database waits for TEST_DATABASE_URL
TEST_DATABASE_URLS = {"sqlite": "sqlite+aiosqlite:///:memory:", "postgres": ""}

parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
parser.add_argument("dir", type=Path)
parser.add_argument("--python", required=True, help="version to pin, such as 3.15")
parser.add_argument(
    "--api", action="store_true", help="FastAPI app with a health router"
)
parser.add_argument("--db", choices=DRIVERS, help="SQLAlchemy async and the db fixture")
parser.add_argument("--data", action="store_true", help="Polars")
parser.add_argument("--http", action="store_true", help="httpx client, respx in tests")
args = parser.parse_args()


def uv(*cmd: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["uv", *cmd], cwd=args.dir, text=True, check=True)


subprocess.run(
    ["uv", "init", "--package", "--python", args.python, str(args.dir)], check=True
)
pyproject = args.dir / "pyproject.toml"
package = tomllib.loads(pyproject.read_text())["project"]["name"].replace("-", "_")

runtime = []
if args.api:
    runtime.append("fastapi[standard]")
if args.db:
    runtime += ["sqlalchemy[asyncio]", DRIVERS[args.db]]
if args.data:
    runtime.append("polars")
if args.http:
    runtime.append("httpx")
if runtime:
    uv("add", *runtime)
uv("add", "--dev", *DEV, *(["respx"] if args.http else []))
pyproject.write_text(
    pyproject.read_text() + "\n" + (TEMPLATES / "pyproject-tools.toml").read_text()
)

values = {
    "package": package,
    "test_database_url": TEST_DATABASE_URLS.get(args.db or "", ""),
}


def render(text: str) -> str:
    return re.sub(r"\{\{(\w+)\}\}", lambda match: values[match.group(1)], text)


for capability in [
    name for name, chosen in (("api", args.api), ("db", args.db)) if chosen
]:
    root = TEMPLATES / capability
    for source in sorted(path for path in root.rglob("*") if path.is_file()):
        target = args.dir / render(str(source.relative_to(root)))
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(render(source.read_text()))

has_tests = (args.dir / "tests").is_dir()
checks = [
    ["ruff", "format", "--check", "."],
    ["ruff", "check", "."],
    ["mypy", "src", *(["tests"] if has_tests else [])],
    *([["pytest", "-q", "-rs"]] if has_tests else []),
]
failed = []
for check in checks:
    print(f"\n$ uv run {' '.join(check)}", flush=True)
    if subprocess.run(["uv", "run", *check], cwd=args.dir).returncode != 0:
        failed.append(" ".join(check))
print(
    f"\n{package}: " + (f"FAILED {', '.join(failed)}" if failed else "all checks pass")
)
sys.exit(1 if failed else 0)

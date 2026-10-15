---
name: python-project
description: "Create a new Python project on the house stack from ~/.claude/rules/python.md: uv, FastAPI, SQLAlchemy 2 async with a rolled-back test fixture, Polars, httpx, pytest, ruff and mypy configured with the user's checks. Use when the user starts a new Python project, service, API or data pipeline. Not for an existing project: there its own choices win, and a missing capability is added by hand following the rule."
allowed-tools: Bash(~/.claude/skills/python-project/scaffold.py*)
---

# python-project

`scaffold.py` builds the project so every new one looks the same: the user knows the
layout before opening it.

## Step 1: Settle the inputs

Ask in one question for whatever the request leaves open:
- **Directory**: the new project's path. Its name becomes the package (`acme-api` → `acme_api`).
- **Capabilities**, each a flag:
  - `--api`: FastAPI app with a health router, schemas and routers packages, and a test
  - `--db sqlite` or `--db postgres`: SQLAlchemy 2 async, `models/` with `Base`, `db.py`
    with the session dependency, and the `db` fixture in `tests/conftest.py`
  - `--data`: Polars
  - `--http`: httpx, with respx in the dev dependencies
- **Python version**: the newest stable one in `uv python list --only-installed`, unless
  the user names another.

## Step 2: Scaffold

```bash
~/.claude/skills/python-project/scaffold.py <dir> --python <X.Y> [--api] [--db sqlite|postgres] [--data] [--http]
```

The script runs `uv init --package`, adds the dependencies, appends the ruff, mypy,
pyright and pytest configuration, renders the templates, then runs `ruff format --check`,
`ruff check`, `mypy` and `pytest`.

A failing check in a fresh scaffold is a template bug. Report it with the output, fix
the template under `~/.claude/skills/python-project/templates/` (a symlink into the
dotfiles repo), and regenerate. Never patch only the generated copy.

## Step 3: Report

Give the user the file tree (`git -C <dir> ls-files`, plus untracked files), and the
commands they will use:
- `--api`: `uv run fastapi dev src/<package>/main.py`
- `--db`: the app reads `DATABASE_URL`; the tests use `TEST_DATABASE_URL` and never
  touch the app's database. With `--db sqlite` the tests run in memory. With
  `--db postgres` the database test skips until `TEST_DATABASE_URL` points at a test
  database: say so.

Done when the script's last line reads `<package>: all checks pass`.

---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
---

# Python

- `uv` runs everything: `uv run <cmd>`, `uv add`, `uv lock`. No `pip`, no bare
  `python`; a missing tool is added with `uv add --dev`.
- Target the Python version the project pins (`.python-version`, `requires-python`,
  or the Dockerfile's `FROM python:X.Y`), never the local interpreter: no syntax or
  stdlib API newer than that version. Unpinned project → ask before assuming one.
  Within that: `X | None`, builtin generics (`list[str]`), `type` aliases, `match`
  where it reads better than an `if` chain; nothing from `typing` that has a builtin
  equivalent.
- ruff formats and lints. Before claiming done: `uv run ruff check --fix . && uv run
  ruff format .`; run `uv run mypy` too when the project configures it.
- Tests: pytest, `asyncio_mode = auto` — async tests are plain `async def test_*`.
  External HTTP goes through `respx`; the DB fixture in `tests/conftest.py` is the
  only database tests touch.
- SQLAlchemy 2.0 style: `Mapped[...]` columns, `select()` executed on an async
  session; no legacy `Query`. Pydantic v2 API: `model_validate`, `model_dump`,
  `ConfigDict`.
- FastAPI: one router per resource, dependencies through `Depends`, request and
  response schemas in `schemas/`, ORM models in `models/`.

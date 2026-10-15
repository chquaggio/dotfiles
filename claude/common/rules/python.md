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
- 3.15+ projects: imports stay at module top. One that is heavy or needed on few
  paths becomes `lazy import x` / `lazy from x import y` (PEP 810) instead of an
  import inside a function. `lazy` is allowed only at module scope and outside
  `try`, so an optional dependency stays an eager `try: import` at the top; a lazy
  import's errors surface at first use, not at startup.
- 3.15+ projects: flatten with unpacking in comprehensions (PEP 798),
  `[*xs for xs in groups]`, `{**d for d in ds}`, over a nested `for` or
  `itertools.chain`.
- ruff formats and lints. Before claiming done: `uv run ruff check --fix . && uv run
  ruff format .`; run `uv run mypy` too when the project configures it.

## House stack

The user knows this stack and reviews work in it fastest, so it is the default. A
project's existing choices win. The stack applies to a new project, which starts from
the `python-project` skill, and to a capability the project hasn't chosen yet.

- Web API: FastAPI. One router per resource, dependencies through `Depends`, request
  and response schemas in `schemas/`, ORM models in `models/`.
- Validation: Pydantic v2 API: `model_validate`, `model_dump`, `ConfigDict`.
- Database: SQLAlchemy 2 async. `Mapped[...]` columns, `select()` executed on an
  `AsyncSession`; no legacy `Query`.
- Dataframes: Polars, built from expressions; a row-wise `map_elements` is the last
  resort. Lazy frames (`scan_*`, `.lazy()` … `.collect()`) for anything read from disk.
- HTTP client: httpx.
- Tests: pytest with `asyncio_mode = auto`, so async tests are plain `async def test_*`.
  External HTTP goes through `respx`. Database tests use the `db` fixture in
  `tests/conftest.py`, which rolls each test back, and touch no other database.

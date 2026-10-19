import os
from collections.abc import AsyncIterator
from typing import Any

import pytest
from sqlalchemy import Connection, event
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, create_async_engine

from {{package}}.models import Base

# Tests touch only this database, never the one in DATABASE_URL
TEST_DATABASE_URL = os.environ.get("TEST_DATABASE_URL", "{{test_database_url}}")


@pytest.fixture(scope="session")
async def engine() -> AsyncIterator[AsyncEngine]:
    if not TEST_DATABASE_URL:
        pytest.skip("set TEST_DATABASE_URL to run the database tests")
    engine = create_async_engine(TEST_DATABASE_URL)
    if engine.dialect.name == "sqlite":
        # The sqlite driver defers BEGIN, so the savepoint in `db` would be the outermost
        # transaction and releasing it a commit. SQLAlchemy's sqlite recipe: the driver
        # stops managing transactions and SQLAlchemy emits BEGIN itself.
        @event.listens_for(engine.sync_engine, "connect")
        def disable_driver_transactions(dbapi_connection: Any, _: Any) -> None:
            dbapi_connection.isolation_level = None

        @event.listens_for(engine.sync_engine, "begin")
        def emit_begin(connection: Connection) -> None:
            connection.exec_driver_sql("BEGIN")

    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.drop_all)
        await connection.run_sync(Base.metadata.create_all)
    yield engine
    await engine.dispose()


@pytest.fixture
async def db(engine: AsyncEngine) -> AsyncIterator[AsyncSession]:
    # A commit inside a test releases a savepoint; the outer transaction rolls it all back
    async with engine.connect() as connection:
        transaction = await connection.begin()
        session = AsyncSession(
            bind=connection,
            join_transaction_mode="create_savepoint",
            expire_on_commit=False,
        )
        yield session
        await session.close()
        await transaction.rollback()

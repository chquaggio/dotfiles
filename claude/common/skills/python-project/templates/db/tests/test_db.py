from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession


async def test_db_answers(db: AsyncSession) -> None:
    assert await db.scalar(text("select 1")) == 1

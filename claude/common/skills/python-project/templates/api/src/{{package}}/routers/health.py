from fastapi import APIRouter

from {{package}}.schemas.health import Health

router = APIRouter(prefix="/health", tags=["health"])


@router.get("")
async def read_health() -> Health:
    return Health(status="ok")

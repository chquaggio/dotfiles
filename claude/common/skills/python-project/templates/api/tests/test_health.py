from httpx import ASGITransport, AsyncClient

from {{package}}.main import app


async def test_health_reports_ok() -> None:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/health")
    assert response.json() == {"status": "ok"}

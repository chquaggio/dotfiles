from fastapi import FastAPI

from {{package}}.routers import health

app = FastAPI()
app.include_router(health.router)

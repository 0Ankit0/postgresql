import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from routes import router
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
import os
from dotenv import load_dotenv

load_dotenv()
DSN = os.getenv("DATABASE_URL", "")

@asynccontextmanager
async def lifespan(app: FastAPI):
    from pg_notify_listener import listen_to_notifications
    task = asyncio.create_task(listen_to_notifications(DSN))
    yield
    task.cancel()

app = FastAPI(lifespan=lifespan)
app.include_router(router)
templates = Jinja2Templates(directory="templates")



@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse(request=request, name="chat.html", context={"request": request})
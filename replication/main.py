from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from routes import router
from starlette.middleware.sessions import SessionMiddleware
from dotenv import load_dotenv
import os

load_dotenv()  # Load environment variables from .env file

app = FastAPI()
app.add_middleware(SessionMiddleware, secret_key=os.getenv("SESSION_SECRET_KEY","default"))

app.include_router(router)

@app.get("/")
async def root():
    return RedirectResponse(url="/docs")

from sqlalchemy import create_engine, func, text
from dotenv import load_dotenv
import fastapi.responses as response
from fastapi import FastAPI
from routes import router

app = FastAPI()


@app.get("/")
def redirect_to_docs():
    return response.RedirectResponse(url="/docs")

app.include_router(router)
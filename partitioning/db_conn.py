from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncSession,
    async_sessionmaker
)
from dotenv import load_dotenv
import os

load_dotenv()


DATABASE_URL = os.getenv("DATABASE_URL","")

engine = create_async_engine(
    DATABASE_URL,

    # important production configs
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,
    pool_recycle=3600,

    echo=True,
    future=True
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False
)
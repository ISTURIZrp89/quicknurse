import os
from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import sessionmaker, DeclarativeBase

DATABASE_URL = os.environ.get("QUICKNURSE_DB_URL", "sqlite:///./quicknurse.db")

# Convert sqlite:// to sqlite+aiosqlite:// for async
ASYNC_DATABASE_URL = DATABASE_URL
if DATABASE_URL.startswith("sqlite://"):
    ASYNC_DATABASE_URL = DATABASE_URL.replace("sqlite://", "sqlite+aiosqlite://")
elif DATABASE_URL.startswith("postgresql://"):
    ASYNC_DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://")

# Sync engine (usado por Alembic y tareas legacy)
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
)

# Async engine (usado por FastAPI endpoints)
async_engine = create_async_engine(
    ASYNC_DATABASE_URL,
    echo=False,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
AsyncSessionLocal = async_sessionmaker(
    async_engine, class_=AsyncSession, expire_on_commit=False
)


class Base(DeclarativeBase):
    pass


def init_db():
    import app.models  # noqa: ensures models are registered
    Base.metadata.create_all(bind=engine)


# Dependency para endpoints sync (legacy)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Dependency para endpoints async
async def get_async_db():
    async with AsyncSessionLocal() as session:
        yield session
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from app.api import symptoms, guides, notifications, planes_pae, timers, dashboard, seed, chat
from app.api import calculadoras, farmacologia, education, auth
from app.database import init_db
from app.config import get_settings
from app.logging_config import configure_logging, get_logger
import os

configure_logging()
logger = get_logger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("starting_up", version="1.0.0")
    init_db()
    yield
    logger.info("shutting_down")

app = FastAPI(
    title="QuickNurse API",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

settings = get_settings()
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS.split(",") if settings.ALLOWED_ORIGINS != "*" else ["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(symptoms.router, prefix="/api/v1/symptoms", tags=["symptoms"])
app.include_router(guides.router, prefix="/api/v1/guides", tags=["guides"])
app.include_router(notifications.router, prefix="/api/v1/notifications", tags=["notifications"])
app.include_router(planes_pae.router, prefix="/api/v1/planes_pae", tags=["planes_pae"])
app.include_router(timers.router, prefix="/api/v1/timers", tags=["timers"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["chat"])
app.include_router(dashboard.router, prefix="/api/v1/dashboard", tags=["dashboard"])
app.include_router(seed.router, prefix="/api/v1/seed", tags=["seed"])
app.include_router(calculadoras.router, prefix="/api/v1/calculadoras", tags=["calculadoras"])
app.include_router(farmacologia.router, prefix="/api/v1/farmacologia", tags=["farmacologia"])
app.include_router(education.router, prefix="/api/v1/education", tags=["education"])

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "quicknurse-backend"}

# Servir archivos estáticos (imágenes, etc.)
static_dir = os.path.join(os.path.dirname(__file__), "..", "static")
if os.path.exists(static_dir):
    app.mount("/static", StaticFiles(directory=static_dir), name="static")

# Servir Flutter web build (DESPUÉS de rutas API)
flutter_web_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "flutter", "build", "web"))
if os.path.exists(flutter_web_path):
    app.mount("/assets", StaticFiles(directory=os.path.join(flutter_web_path, "assets")), name="assets")
    app.mount("/canvaskit", StaticFiles(directory=os.path.join(flutter_web_path, "canvaskit")), name="canvaskit")
    app.mount("/icons", StaticFiles(directory=os.path.join(flutter_web_path, "icons")), name="icons")

    @app.get("/{full_path:path}")
    async def serve_flutter(full_path: str):
        # Primero intenta archivo estático
        file_path = os.path.join(flutter_web_path, full_path)
        if os.path.isfile(file_path):
            return FileResponse(file_path)
        # Si no existe, sirve index.html (SPA routing)
        return FileResponse(os.path.join(flutter_web_path, "index.html"))
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import PlanPAE, TimerTurno
from datetime import datetime, timezone
import os

router = APIRouter()

GUIDES_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "guides")
GUIDES_DIR = os.path.abspath(GUIDES_DIR)

@router.get("/")
def dashboard(db: Session = Depends(get_db)):
    ahora = datetime.now(timezone.utc)
    hoy = ahora.replace(hour=0, minute=0, second=0, microsecond=0)
    hoy_ms = int(hoy.timestamp() * 1000)

    planes_pae = db.query(PlanPAE).count()
    timer_activo = db.query(TimerTurno).filter(TimerTurno.activo == True).first()
    timers_hoy = db.query(TimerTurno).filter(TimerTurno.entrada >= hoy_ms).count()

    # Guías clínicas
    guias_disponibles = 0
    try:
        if os.path.isdir(GUIDES_DIR):
            guias_disponibles = sum(1 for f in os.listdir(GUIDES_DIR) if f.endswith(".md"))
    except Exception:
        pass

    timer_info = None
    if timer_activo:
        ahora_ms = int(ahora.timestamp() * 1000)
        segundos = (ahora_ms - timer_activo.entrada) // 1000
        ganancia = (segundos / 3600) * timer_activo.tarifa
        timer_info = {
            "centro": timer_activo.centro,
            "segundos": segundos,
            "ganancia": round(ganancia, 2),
        }

    return {
        "planes_pae": planes_pae,
        "timer_activo": timer_info,
        "timers_hoy": timers_hoy,
        "guias_disponibles": guias_disponibles,
        "chat_ia": "online",
    }

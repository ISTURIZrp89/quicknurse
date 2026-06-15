from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import TimerTurno
from datetime import datetime, timezone
from typing import Optional

router = APIRouter()

class TimerResponse(BaseModel):
    id: int
    centro: str = ""
    entrada: int
    salida: Optional[int] = None
    tarifa: float = 0.0
    activo: bool = True
    segundos: int = 0

@router.get("/")
def listar_timers(db: Session = Depends(get_db)):
    """Lista todos los timers (activos e historial)"""
    timers = db.query(TimerTurno).order_by(TimerTurno.entrada.desc()).limit(50).all()
    return [
        {
            "id": t.id,
            "centro": t.centro,
            "entrada": t.entrada,
            "salida": t.salida,
            "tarifa": t.tarifa,
            "activo": t.activo,
        }
        for t in timers
    ]

@router.post("/clock-in")
def clock_in(db: Session = Depends(get_db)):
    activo = db.query(TimerTurno).filter(TimerTurno.activo == True).first()
    if activo:
        raise HTTPException(400, "Ya hay un timer activo")

    timer = TimerTurno(
        centro="",
        entrada=int(datetime.now(timezone.utc).timestamp() * 1000),
        tarifa=0.0,
        activo=True,
    )
    db.add(timer)
    db.commit()
    db.refresh(timer)
    return {"id": timer.id, "entrada": timer.entrada}

@router.post("/clock-out")
def clock_out(db: Session = Depends(get_db)):
    timer = db.query(TimerTurno).filter(TimerTurno.activo == True).first()
    if not timer:
        raise HTTPException(404, "No hay timer activo")

    timer.salida = int(datetime.now(timezone.utc).timestamp() * 1000)
    timer.activo = False
    db.commit()

    segundos = (timer.salida - timer.entrada) // 1000
    ganancia = (segundos / 3600) * timer.tarifa
    return {"salida": timer.salida, "segundos": segundos, "ganancia": round(ganancia, 2)}

@router.get("/activo")
def timer_activo(db: Session = Depends(get_db)):
    timer = db.query(TimerTurno).filter(TimerTurno.activo == True).first()
    if not timer:
        return {"activo": False}
    ahora = int(datetime.now(timezone.utc).timestamp() * 1000)
    segundos = (ahora - timer.entrada) // 1000
    ganancia = (segundos / 3600) * timer.tarifa
    return {
        "activo": True,
        "id": timer.id,
        "centro": timer.centro,
        "entrada": timer.entrada,
        "tarifa": timer.tarifa,
        "segundos": segundos,
        "ganancia": round(ganancia, 2),
    }

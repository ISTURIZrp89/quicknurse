from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Turno
from datetime import datetime
import time

router = APIRouter()


@router.post("/")
def crear_turno(turno_data: dict, db: Session = Depends(get_db)):
    turno_id = turno_data.get("id")
    if not turno_id:
        raise HTTPException(status_code=400, detail="id requerido")
    
    existing = db.query(Turno).filter(Turno.turno_id == turno_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="turno_id ya existe")
    
    ahora_ms = int(time.time() * 1000)
    turno = Turno(
        turno_id=turno_id,
        centro=turno_data.get("centro", ""),
        especialidad=turno_data.get("especialidad", ""),
        tarifa=float(turno_data.get("tarifa", 0.0)),
        horas=float(turno_data.get("horas", 0.0)),
        estado="DISPONIBLE",
        creado_en=ahora_ms,
    )
    db.add(turno)
    db.commit()
    db.refresh(turno)
    return {"id": turno.turno_id, "estado": turno.estado, "centro": turno.centro, "especialidad": turno.especialidad, "tarifa": turno.tarifa, "horas": turno.horas}


@router.get("/")
def listar_turnos(db: Session = Depends(get_db)):
    turnos = db.query(Turno).all()
    return [
        {"id": t.turno_id, "centro": t.centro, "especialidad": t.especialidad, "tarifa": t.tarifa, "horas": t.horas, "estado": t.estado}
        for t in turnos
    ]


@router.patch("/{turno_id}/aplicar")
def aplicar_turno(turno_id: str, db: Session = Depends(get_db)):
    turno = db.query(Turno).filter(Turno.turno_id == turno_id).first()
    if not turno:
        raise HTTPException(status_code=404, detail="Turno no encontrado")
    turno.estado = "APLICADO"
    db.commit()
    return {"id": turno.turno_id, "estado": turno.estado}


@router.patch("/{turno_id}/estado")
def cambiar_estado_turno(turno_id: str, estado: str, db: Session = Depends(get_db)):
    turno = db.query(Turno).filter(Turno.turno_id == turno_id).first()
    if not turno:
        raise HTTPException(status_code=404, detail="Turno no encontrado")
    estados_validos = ["DISPONIBLE", "APLICADO", "CONFIRMADO", "CANCELADO"]
    if estado not in estados_validos:
        raise HTTPException(status_code=400, detail="Estado inválido")
    turno.estado = estado
    db.commit()
    return {"id": turno.turno_id, "estado": turno.estado}


@router.delete("/{turno_id}")
def eliminar_turno(turno_id: str, db: Session = Depends(get_db)):
    turno = db.query(Turno).filter(Turno.turno_id == turno_id).first()
    if not turno:
        raise HTTPException(status_code=404, detail="Turno no encontrado")
    db.delete(turno)
    db.commit()
    return {"deleted": True}
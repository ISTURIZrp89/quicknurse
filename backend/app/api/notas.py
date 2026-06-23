from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import NotaTraspaso
import time

router = APIRouter()


@router.post("/")
def crear_nota(nota_data: dict, db: Session = Depends(get_db)):
    ahora_ms = int(time.time() * 1000)
    nota = NotaTraspaso(
        paciente=nota_data.get("paciente", ""),
        diagnostico=nota_data.get("diagnostico", ""),
        resumen=nota_data.get("resumen", ""),
        signos_vitales=nota_data.get("signos_vitales", ""),
        actualizado=ahora_ms,
        completada=nota_data.get("completada", False),
        prioridad=nota_data.get("prioridad", "baja"),
    )
    db.add(nota)
    db.commit()
    db.refresh(nota)
    return {
        "id": nota.id,
        "paciente": nota.paciente,
        "diagnostico": nota.diagnostico,
        "resumen": nota.resumen,
        "signos_vitales": nota.signos_vitales,
        "completada": nota.completada,
        "prioridad": nota.prioridad,
    }


@router.get("/")
def listar_notas(db: Session = Depends(get_db)):
    notas = db.query(NotaTraspaso).all()
    return [
        {
            "id": n.id,
            "paciente": n.paciente,
            "diagnostico": n.diagnostico,
            "resumen": n.resumen,
            "signos_vitales": n.signos_vitales,
            "completada": n.completada,
            "prioridad": n.prioridad,
        }
        for n in notas
    ]


@router.get("/{nota_id}")
def obtener_nota(nota_id: int, db: Session = Depends(get_db)):
    nota = db.query(NotaTraspaso).filter(NotaTraspaso.id == nota_id).first()
    if not nota:
        raise HTTPException(status_code=404, detail="Nota no encontrada")
    return {
        "id": nota.id,
        "paciente": nota.paciente,
        "diagnostico": nota.diagnostico,
        "resumen": nota.resumen,
        "signos_vitales": nota.signos_vitales,
        "completada": nota.completada,
        "prioridad": nota.prioridad,
    }


@router.patch("/{nota_id}")
def actualizar_nota(nota_id: int, nota_data: dict, db: Session = Depends(get_db)):
    nota = db.query(NotaTraspaso).filter(NotaTraspaso.id == nota_id).first()
    if not nota:
        raise HTTPException(status_code=404, detail="Nota no encontrada")
    if "paciente" in nota_data:
        nota.paciente = nota_data["paciente"]
    if "diagnostico" in nota_data:
        nota.diagnostico = nota_data["diagnostico"]
    if "resumen" in nota_data:
        nota.resumen = nota_data["resumen"]
    if "signos_vitales" in nota_data:
        nota.signos_vitales = nota_data["signos_vitales"]
    if "completada" in nota_data:
        nota.completada = nota_data["completada"]
    if "prioridad" in nota_data:
        nota.prioridad = nota_data["prioridad"]
    nota.actualizado = int(time.time() * 1000)
    db.commit()
    return {
        "id": nota.id,
        "paciente": nota.paciente,
        "diagnostico": nota.diagnostico,
        "resumen": nota.resumen,
        "signos_vitales": nota.signos_vitales,
        "completada": nota.completada,
        "prioridad": nota.prioridad,
    }


@router.delete("/{nota_id}")
def eliminar_nota(nota_id: int, db: Session = Depends(get_db)):
    nota = db.query(NotaTraspaso).filter(NotaTraspaso.id == nota_id).first()
    if not nota:
        raise HTTPException(status_code=404, detail="Nota no encontrada")
    db.delete(nota)
    db.commit()
    return {"deleted": True}
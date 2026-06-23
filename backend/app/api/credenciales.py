from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Credencial
import time

router = APIRouter()


@router.post("/")
def crear_credencial(cred_data: dict, db: Session = Depends(get_db)):
    ahora_ms = int(time.time() * 1000)
    cred = Credencial(
        nombre=cred_data.get("nombre", ""),
        emisor=cred_data.get("emisor", ""),
        numero=cred_data.get("numero", ""),
        fecha_expiracion=cred_data.get("fecha_expiracion", ""),
        activa=cred_data.get("activa", True),
        creado_en=ahora_ms,
    )
    db.add(cred)
    db.commit()
    db.refresh(cred)
    return {"id": cred.id, "nombre": cred.nombre, "emisor": cred.emisor, "numero": cred.numero, "activa": cred.activa}


@router.get("/")
def listar_credenciales(db: Session = Depends(get_db)):
    creds = db.query(Credencial).all()
    return [
        {"id": c.id, "nombre": c.nombre, "emisor": c.emisor, "numero": c.numero, "fecha_expiracion": c.fecha_expiracion, "activa": c.activa}
        for c in creds
    ]


@router.get("/{cred_id}")
def obtener_credencial(cred_id: int, db: Session = Depends(get_db)):
    cred = db.query(Credencial).filter(Credencial.id == cred_id).first()
    if not cred:
        raise HTTPException(status_code=404, detail="Credencial no encontrada")
    return {"id": cred.id, "nombre": cred.nombre, "emisor": cred.emisor, "numero": cred.numero, "fecha_expiracion": cred.fecha_expiracion, "activa": cred.activa}


@router.patch("/{cred_id}")
def actualizar_credencial(cred_id: int, cred_data: dict, db: Session = Depends(get_db)):
    cred = db.query(Credencial).filter(Credencial.id == cred_id).first()
    if not cred:
        raise HTTPException(status_code=404, detail="Credencial no encontrada")
    if "nombre" in cred_data:
        cred.nombre = cred_data["nombre"]
    if "emisor" in cred_data:
        cred.emisor = cred_data["emisor"]
    if "numero" in cred_data:
        cred.numero = cred_data["numero"]
    if "fecha_expiracion" in cred_data:
        cred.fecha_expiracion = cred_data["fecha_expiracion"]
    if "activa" in cred_data:
        cred.activa = cred_data["activa"]
    db.commit()
    return {"id": cred.id, "nombre": cred.nombre, "emisor": cred.emisor, "numero": cred.numero, "fecha_expiracion": cred.fecha_expiracion, "activa": cred.activa}


@router.delete("/{cred_id}")
def eliminar_credencial(cred_id: int, db: Session = Depends(get_db)):
    cred = db.query(Credencial).filter(Credencial.id == cred_id).first()
    if not cred:
        raise HTTPException(status_code=404, detail="Credencial no encontrada")
    db.delete(cred)
    db.commit()
    return {"deleted": True}
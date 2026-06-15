from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_
from app.database import get_db
from app.models import DrugReference
from app.services.drug_data import get_drugs, add_drug, update_drug

router = APIRouter()

COMPATIBILIDAD_IV = {
    ("norepinefrina", "fentanilo"): "compatible",
    ("fentanilo", "norepinefrina"): "compatible",
    ("norepinefrina", "propofol"): "compatible",
    ("propofol", "norepinefrina"): "compatible",
    ("furosemida", "midazolam"): "incompatible",
    ("midazolam", "furosemida"): "incompatible",
    ("furosemida", "dopamina"): "incompatible",
    ("dopamina", "furosemida"): "incompatible",
    ("amiodarona", "furosemida"): "incompatible",
    ("furosemida", "amiodarona"): "incompatible",
    ("heparina", "amiodarona"): "incompatible",
    ("amiodarona", "heparina"): "incompatible",
    ("heparina", "furosemida"): "incompatible",
    ("furosemida", "heparina"): "incompatible",
    ("heparina", "diazepam"): "incompatible",
    ("diazepam", "heparina"): "incompatible",
    ("ceftriaxona", "gluconato de calcio"): "incompatible",
    ("gluconato de calcio", "ceftriaxona"): "incompatible",
    ("propofol", "ketamina"): "compatible",
    ("ketamina", "propofol"): "compatible",
    ("midazolam", "fentanilo"): "compatible",
    ("fentanilo", "midazolam"): "compatible",
    ("dopamina", "norepinefrina"): "compatible",
    ("norepinefrina", "dopamina"): "compatible",
    ("insulina", "heparina"): "compatible",
    ("heparina", "insulina"): "compatible",
    ("omeprazol", "furosemida"): "incompatible",
    ("furosemida", "omeprazol"): "incompatible",
    ("diazepam", "propofol"): "precaucion",
    ("propofol", "diazepam"): "precaucion",
    ("vancomicina", "furosemida"): "precaucion",
    ("furosemida", "vancomicina"): "precaucion",
}


def _med_to_dict(m: DrugReference) -> dict:
    return {
        "id": m.id,
        "nombre_generico": m.nombre_generico,
        "categoria": m.categoria,
        "indicacion": m.indicacion,
        "dosis_adulto": m.dosis_adulto,
        "dosis_pediatrica": m.dosis_pediatrica,
        "via": m.via,
        "precauciones": m.precauciones,
        "alerta": m.alerta,
        "presentacion": m.presentacion or "",
        "contraindicaciones": m.contraindicaciones or "",
        "interacciones": m.interacciones or "",
        "efectos_adversos": m.efectos_adversos or "",
        "embarazo_lactancia": m.embarazo_lactancia or "",
        "mecanismo_accion": m.mecanismo_accion or "",
    }


@router.get("/categorias")
def listar_categorias():
    return {
        "categorias": sorted(set(d["categoria"] for d in get_drugs()))
    }


@router.get("")
@router.get("/")
def listar_medicamentos(
    categoria: str = Query("", min_length=0),
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=200),
    db: Session = Depends(get_db),
):
    query = db.query(DrugReference)
    if categoria:
        query = query.filter(DrugReference.categoria == categoria)
    total = query.count()
    meds = (
        query.order_by(DrugReference.nombre_generico)
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )
    return {
        "resultados": [_med_to_dict(m) for m in meds],
        "total": total,
        "page": page,
        "per_page": per_page,
        "total_pages": max(1, (total + per_page - 1) // per_page),
    }


@router.get("/buscar")
def buscar_medicamento(
    q: str = Query("", min_length=0),
    page: int = Query(1, ge=1),
    per_page: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
):
    q = q.strip().lower()
    query = db.query(DrugReference)
    if q:
        query = query.filter(
            or_(
                DrugReference.nombre_generico.ilike(f"%{q}%"),
                DrugReference.categoria.ilike(f"%{q}%"),
                DrugReference.indicacion.ilike(f"%{q}%"),
            )
        )
    total = query.count()
    meds = (
        query.order_by(DrugReference.nombre_generico)
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )
    return {
        "resultados": [_med_to_dict(m) for m in meds],
        "total": total,
        "query": q,
        "page": page,
        "per_page": per_page,
        "total_pages": max(1, (total + per_page - 1) // per_page),
    }


@router.get("/compatibilidad-iv")
def compatibilidad_iv(farmaco_a: str = Query(...), farmaco_b: str = Query(...)):
    a = farmaco_a.strip().lower()
    b = farmaco_b.strip().lower()
    resultado = COMPATIBILIDAD_IV.get((a, b), None)
    if resultado is None:
        resultado = "desconocida"
    return {
        "farmaco_a": farmaco_a,
        "farmaco_b": farmaco_b,
        "compatibilidad": resultado,
    }

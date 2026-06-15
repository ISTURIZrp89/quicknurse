from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app import models
from app.security import get_current_user
from app.services.llm_service import pae_con_llm

router = APIRouter()

@router.get("/")
def get_planes_pae(db: Session = Depends(get_db)):
    return db.query(models.PlanPAE).all()

@router.post("/")
def create_plan_pae(plan: dict, db: Session = Depends(get_db)):
    nuevo_plan = models.PlanPAE(**plan)
    db.add(nuevo_plan)
    db.commit()
    db.refresh(nuevo_plan)
    return nuevo_plan

@router.get("/suggest")
def suggest_pae_template(sintoma: str = Query(..., min_length=2)):
    # 1. Búsqueda local básica
    sintoma_lower = sintoma.lower()
    templates = {
        "dolor": {"diagnostico": "00132 Dolor agudo", "objetivo": "1400 Manejo dolor", "intervenciones": "Administrar analgesia, valorar EVA c/4h", "evaluacion": "EVA < 3"},
        "fiebre": {"diagnostico": "00007 Hipertermia", "objetivo": "3740 Tratamiento fiebre", "intervenciones": "Antipiréticos, control térmico", "evaluacion": "Temperatura < 37.5 C"},
    }
    
    for k, v in templates.items():
        if k in sintoma_lower:
            return {"source": "local", "template": v}
            
    # 2. Si no hay local, buscar IA
    llm_resp = pae_con_llm(sintoma)
    if llm_resp:
        return {"source": "ai", "template": llm_resp}
        
    raise HTTPException(status_code=404, detail="No se pudo generar plantilla para ese síntoma")

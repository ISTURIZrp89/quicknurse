from fastapi import APIRouter, Query
from pydantic import BaseModel
from app.services.triage import evaluar_sintomas
from app.services.llm_service import triage_con_llm

router = APIRouter()

class SymptomRequest(BaseModel):
    symptoms: str
    age: int | None = None
    sex: str | None = None
    vital_signs: dict | None = None

class SymptomResponse(BaseModel):
    diagnosis: str
    confidence: float
    recommendation: str
    source: str = "offline_rules"
    priority: str = "observacion"
    red_flag: bool = False

@router.post("/", response_model=SymptomResponse)
def analyze_symptoms(
    request: SymptomRequest,
    llm: bool = Query(False, description="Usar LLM para analisis profundo"),
):
    resultado = evaluar_sintomas(
        request.symptoms,
        age=request.age,
        sex=request.sex,
        vital_signs=request.vital_signs,
    )

    # Si offline es de baja confianza o se pide LLM
    usar_llm = llm or resultado["confidence"] < 0.60
    if usar_llm:
        try:
            llm_result = triage_con_llm(
                request.symptoms,
                age=request.age,
                sex=request.sex,
                vital_signs=request.vital_signs
            )
            if llm_result:
                # Asegurar claves requeridas
                resultado = {
                    "diagnosis": llm_result.get("diagnosis", resultado["diagnosis"]),
                    "confidence": llm_result.get("confidence", 0.7),
                    "recommendation": llm_result.get("recommendation", resultado["recommendation"]),
                    "source": "ai_triage",
                    "priority": llm_result.get("priority", resultado["priority"]),
                    "red_flag": llm_result.get("red_flag", resultado["red_flag"]),
                }
        except Exception:
            pass  # Si LLM falla, usar resultado offline

    return SymptomResponse(
        diagnosis=resultado["diagnosis"],
        confidence=resultado["confidence"],
        recommendation=resultado["recommendation"],
        source=resultado.get("source", "offline_rules"),
        priority=resultado.get("priority", "observacion"),
        red_flag=resultado.get("red_flag", False),
    )

from fastapi import APIRouter, Body
from typing import Optional

router = APIRouter()

CALCULADORAS_DISPONIBLES = [
    {"id": "imc", "nombre": "Índice de Masa Corporal", "descripcion": "Calcula el IMC a partir de peso y altura"},
    {"id": "goteo-iv", "nombre": "Goteo Intravenoso", "descripcion": "Calcula gotas/minuto para perfusión IV"},
    {"id": "dosis", "nombre": "Cálculo de Dosis", "descripcion": "Calcula volumen a administrar según dosis requerida"},
    {"id": "apgar", "nombre": "Test de Apgar", "descripcion": "Valora estado del recién nacido (0-10)"},
    {"id": "pews", "nombre": "PEWS (Pediatric Early Warning Score)", "descripcion": "Score de alerta temprana pediátrica"},
    {"id": "superficie-corporal", "nombre": "Superficie Corporal", "descripcion": "Fórmula de Mosteller"},
    {"id": "creatinina", "nombre": "Depuración de Creatinina", "descripcion": "Fórmula de Cockcroft-Gault"},
    {"id": "pam", "nombre": "Presión Arterial Media", "descripcion": "Calcula PAM a partir de PAS y PAD"},
    {"id": "glasgow", "nombre": "Escala de Glasgow", "descripcion": "Escala de coma (3-15)"},
    {"id": "infusion-uci", "nombre": "Infusión UCI", "descripcion": "Calcula velocidad de infusión en ml/h"},
]


@router.get("/")
def listar_calculadoras():
    return {"calculadoras": CALCULADORAS_DISPONIBLES}


@router.post("/imc")
def calcular_imc(peso: float = Body(..., ge=0.1, le=500), altura: float = Body(..., ge=10, le=250)):
    """IMC = peso(kg) / (altura(m))^2"""
    altura_m = altura / 100.0
    imc = round(peso / (altura_m ** 2), 2)
    if imc < 18.5:
        clasificacion = "Bajo peso"
    elif imc < 25:
        clasificacion = "Normal"
    elif imc < 30:
        clasificacion = "Sobrepeso"
    elif imc < 35:
        clasificacion = "Obesidad grado I"
    elif imc < 40:
        clasificacion = "Obesidad grado II"
    else:
        clasificacion = "Obesidad grado III"
    return {"imc": imc, "clasificacion": clasificacion, "peso_kg": peso, "altura_cm": altura}


@router.post("/goteo-iv")
def calcular_goteo(
    volumen: float = Body(..., ge=1, le=50000),
    horas: float = Body(..., ge=0.1, le=168),
    factor_goteo: int = Body(20, ge=10, le=60),
):
    """Gotas/min = (volumen * factor_goteo) / (horas * 60)"""
    gotas_min = round((volumen * factor_goteo) / (horas * 60), 1)
    ml_h = round(volumen / horas, 1)
    return {
        "gotas_por_minuto": gotas_min,
        "ml_por_hora": ml_h,
        "volumen_ml": volumen,
        "horas": horas,
        "factor_goteo": factor_goteo,
    }


@router.post("/dosis")
def calcular_dosis(
    dosis_requerida: float = Body(..., ge=0.001, le=100000),
    concentracion_stock: float = Body(..., ge=0.001, le=100000),
    volumen_stock: float = Body(..., ge=0.1, le=10000),
):
    """Volumen a administrar = (dosis_requerida * volumen_stock) / concentracion_stock"""
    if concentracion_stock <= 0:
        return {"error": "La concentración del stock debe ser mayor a 0"}
    volumen_admin = round((dosis_requerida * volumen_stock) / concentracion_stock, 2)
    return {
        "volumen_a_administrar_ml": volumen_admin,
        "dosis_requerida": dosis_requerida,
        "concentracion_stock": concentracion_stock,
        "volumen_stock_ml": volumen_stock,
    }


@router.post("/apgar")
def calcular_apgar(
    color: int = Body(..., ge=0, le=2),
    frecuencia: int = Body(..., ge=0, le=2),
    reflejo: int = Body(..., ge=0, le=2),
    tono: int = Body(..., ge=0, le=2),
    respiracion: int = Body(..., ge=0, le=2),
):
    """Apgar: 5 parámetros (0-2 cada uno). Total 0-10."""
    total = color + frecuencia + reflejo + tono + respiracion
    if total >= 8:
        interpretacion = "Normal (buen estado)"
    elif total >= 5:
        interpretacion = "Depresión leve-moderada (requiere reanimación)"
    else:
        interpretacion = "Depresión severa (requiere reanimación inmediata)"
    return {
        "total": total,
        "color": color,
        "frecuencia_cardiaca": frecuencia,
        "reflejo_irritabilidad": reflejo,
        "tono_muscular": tono,
        "esfuerzo_respiratorio": respiracion,
        "interpretacion": interpretacion,
    }


@router.post("/pews")
def calcular_pews(
    comportamiento: int = Body(..., ge=0, le=2),
    cardiovascular: int = Body(..., ge=0, le=2),
    respiratorio: int = Body(..., ge=0, le=2),
):
    """PEWS: 3 parámetros (0-2 cada uno). Total 0-6."""
    total = comportamiento + cardiovascular + respiratorio
    if total == 0:
        recomendacion = "Continuar monitoreo cada 4h"
    elif total <= 2:
        recomendacion = "Monitoreo cada 2h. Evaluar necesidad de intervención."
    elif total <= 4:
        recomendacion = "Monitoreo cada 1h. Notificar al médico."
    else:
        recomendacion = "Monitoreo continuo. Intervención inmediata."
    return {
        "total": total,
        "comportamiento": comportamiento,
        "cardiovascular": cardiovascular,
        "respiratorio": respiratorio,
        "recomendacion": recomendacion,
    }


@router.post("/superficie-corporal")
def calcular_superficie_corporal(
    peso_kg: float = Body(..., ge=0.1, le=300),
    altura_cm: float = Body(..., ge=10, le=250),
):
    """Mosteller: SC(m2) = sqrt(peso(kg) * altura(cm) / 3600)"""
    sc = round(((peso_kg * altura_cm) / 3600) ** 0.5, 3)
    return {"superficie_corporal_m2": sc, "peso_kg": peso_kg, "altura_cm": altura_cm}


@router.post("/creatinina")
def calcular_creatinina(
    edad: int = Body(..., ge=1, le=120),
    peso: float = Body(..., ge=1, le=300),
    creatinina: float = Body(..., ge=0.1, le=20),
    es_masculino: bool = Body(...),
):
    """Cockcroft-Gault: CrCl = ((140 - edad) * peso) / (72 * Cr) * (0.85 si mujer)"""
    crcl = ((140 - edad) * peso) / (72 * creatinina)
    if not es_masculino:
        crcl *= 0.85
    crcl = round(crcl, 2)
    if crcl < 15:
        estadio = "ERCA Estadio 5 (Fallo renal)"
    elif crcl < 30:
        estadio = "ERCA Estadio 4 (Disminución severa)"
    elif crcl < 60:
        estadio = "ERCA Estadio 3 (Disminución moderada)"
    elif crcl < 90:
        estadio = "ERCA Estadio 2 (Disminución leve)"
    else:
        estadio = "ERCA Estadio 1 (Normal o aumentado)"
    return {
        "depuracion_creatinina_ml_min": crcl,
        "estadio": estadio,
        "edad": edad,
        "peso_kg": peso,
        "creatinina": creatinina,
        "sexo": "masculino" if es_masculino else "femenino",
    }


@router.post("/pam")
def calcular_pam(
    sistolica: float = Body(..., ge=30, le=300),
    diastolica: float = Body(..., ge=10, le=200),
):
    """PAM = PAS + (2 * PAD) / 3"""
    pam = round((sistolica + 2 * diastolica) / 3, 1)
    return {
        "pam_mmhg": pam,
        "presion_sistolica": sistolica,
        "presion_diastolica": diastolica,
    }


@router.post("/glasgow")
def calcular_glasgow(
    ocular: int = Body(..., ge=1, le=4),
    verbal: int = Body(..., ge=1, le=5),
    motor: int = Body(..., ge=1, le=6),
):
    """Glasgow: ocular(1-4) + verbal(1-5) + motor(1-6). Total 3-15."""
    total = ocular + verbal + motor
    if total >= 13:
        severidad = "Lesión leve"
    elif total >= 9:
        severidad = "Lesión moderada"
    else:
        severidad = "Lesión severa"
    return {
        "total": total,
        "ocular": ocular,
        "verbal": verbal,
        "motor": motor,
        "severidad": severidad,
    }


@router.post("/infusion-uci")
def calcular_infusion_uci(
    dosis_mcg_kg_min: float = Body(..., ge=0.001, le=1000),
    peso: float = Body(..., ge=0.1, le=300),
    soluto_mg: float = Body(..., ge=0.1, le=100000),
    solvente_ml: float = Body(..., ge=1, le=5000),
):
    """ml/h = (dosis(mcg/kg/min) * peso(kg) * 60) / (soluto(mg) / solvente(ml) * 1000)"""
    concentracion_mcg_ml = (soluto_mg * 1000) / solvente_ml
    ml_h = round((dosis_mcg_kg_min * peso * 60) / concentracion_mcg_ml, 2)
    return {
        "ml_por_hora": ml_h,
        "dosis_mcg_kg_min": dosis_mcg_kg_min,
        "peso_kg": peso,
        "soluto_mg": soluto_mg,
        "solvente_ml": solvente_ml,
        "concentracion_mcg_ml": round(concentracion_mcg_ml, 2),
    }

from fastapi import APIRouter, Query, HTTPException
import random
import re
import os
import json

router = APIRouter()

EDUCATION_JSON = os.path.join(os.path.dirname(__file__), "..", "..", "data", "education.json")

MATERIAS = []
QUIZZES = {}
FLASHCARDS = {}
DATOS_CURIOSOS = []


def _load_education_data():
    global MATERIAS, QUIZZES, FLASHCARDS, DATOS_CURIOSOS
    if not os.path.isfile(EDUCATION_JSON):
        _init_default_data()
        return
    try:
        with open(EDUCATION_JSON, encoding="utf-8") as f:
            data = json.load(f)
        MATERIAS = []
        QUIZZES = {}
        FLASHCARDS = {}
        for subject in data:
            sid = subject.get("id", "")
            MATERIAS.append({
                "id": sid,
                "nombre": subject.get("nombre", sid),
                "descripcion": subject.get("descripcion", ""),
                "icono": subject.get("icono", "📚"),
                "imagen": subject.get("imagen", ""),
                "imagen_licencia": subject.get("imagen_licencia", ""),
                "imagen_atribucion": subject.get("imagen_atribucion", ""),
            })
            flashcards = subject.get("flashcards", [])
            if flashcards:
                FLASHCARDS[sid] = [
                    {"id": i, "frontal": f.get("pregunta", ""), "reverso": f.get("respuesta", "")}
                    for i, f in enumerate(flashcards)
                ]
            quizzes = subject.get("quizzes", [])
            if quizzes:
                QUIZZES[sid] = [
                    {
                        "id": i,
                        "pregunta": q.get("pregunta", ""),
                        "opciones": q.get("opciones", []),
                        "respuesta_correcta": q.get("correcta", 0),
                        "explicacion": q.get("explicacion", ""),
                    }
                    for i, q in enumerate(quizzes)
                ]
    except Exception as e:
        print(f"Error cargando education.json: {e}")
        _init_default_data()


def _init_default_data():
    global MATERIAS, QUIZZES, FLASHCARDS, DATOS_CURIOSOS
    MATERIAS = [
        {"id": "cardiologia", "nombre": "Cardiología", "descripcion": "Enfermedades cardiovasculares, ECG, arritmias", "icono": "🫀"},
        {"id": "neonatologia", "nombre": "Neonatología", "descripcion": "Cuidados del recién nacido, test de Apgar, reanimación neonatal", "icono": "👶"},
        {"id": "farmacologia", "nombre": "Farmacología", "descripcion": "Farmacocinética, farmacodinamia, dosificación", "icono": "💊"},
        {"id": "anatomia", "nombre": "Anatomía", "descripcion": "Anatomía humana básica para enfermería", "icono": "🦴"},
        {"id": "fundamentos", "nombre": "Fundamentos de Enfermería", "descripcion": "Conceptos básicos, procedimientos, cuidados", "icono": "📋"},
    ]
    if not DATOS_CURIOSOS:
        DATOS_CURIOSOS = [
            {"id": 1, "dato": "El corazón humano late aproximadamente 100,000 veces al día y bombea unos 7,570 litros de sangre."},
            {"id": 2, "dato": "Los pulmones tienen una superficie de aproximadamente 70 metros cuadrados (similar a una cancha de tenis)."},
            {"id": 3, "dato": "El hígado es el único órgano que puede regenerarse completamente después de una donación parcial."},
            {"id": 4, "dato": "La sangre recorre todo el cuerpo cada 20-30 segundos."},
            {"id": 5, "dato": "El intestino delgado mide aproximadamente 6-7 metros de largo."},
        ]


def _normalize_materia(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^a-z0-9]+", "", value)
    return value


_load_education_data()


@router.get("/subjects")
def listar_materias():
    return {"materias": MATERIAS}


@router.get("/quizzes")
def obtener_quizzes(materia: str = Query("")):
    materia_key = _normalize_materia(materia)
    if materia_key and materia_key in QUIZZES:
        return {"materia": materia_key, "total": len(QUIZZES[materia_key]), "quizzes": QUIZZES[materia_key]}
    elif materia_key:
        return {"materia": materia_key, "error": "Materia no encontrada", "materias_disponibles": list(QUIZZES.keys())}
    total = sum(len(q) for q in QUIZZES.values())
    return {"materias": list(QUIZZES.keys()), "total_preguntas": total, "quizzes_por_materia": QUIZZES}


@router.get("/flashcards")
def obtener_flashcards(materia: str = Query("")):
    materia_key = _normalize_materia(materia)
    if materia_key and materia_key in FLASHCARDS:
        return {"materia": materia_key, "total": len(FLASHCARDS[materia_key]), "flashcards": FLASHCARDS[materia_key]}
    elif materia_key:
        return {"materia": materia_key, "error": "Materia no encontrada", "materias_disponibles": list(FLASHCARDS.keys())}
    total = sum(len(f) for f in FLASHCARDS.values())
    return {"materias": list(FLASHCARDS.keys()), "total_flashcards": total, "flashcards_por_materia": FLASHCARDS}


@router.get("/fact-of-day")
def fact_of_day():
    if not DATOS_CURIOSOS:
        _init_default_data()
    fact = random.choice(DATOS_CURIOSOS) if DATOS_CURIOSOS else {"id": 0, "dato": "Educación médica continua."}
    return {"dato_curioso": fact}


@router.post("/reload")
def recargar():
    """Recarga datos desde education.json sin reiniciar servidor"""
    _load_education_data()
    return {"ok": True, "materias": len(MATERIAS), "quizzes": sum(len(v) for v in QUIZZES.values()), "flashcards": sum(len(v) for v in FLASHCARDS.values())}

from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import NotaTraspaso, PlanPAE, TimerTurno, DrugReference, User
import time
import os
import json
import tempfile

from app.services.drug_data import get_drugs, save_drugs_to_json
from app.services.text_extractor import extract_text

router = APIRouter()

NOTAS_DEMO = [
    {"paciente": "Juan Pérez", "diagnostico": "Neumonía adquirida en comunidad", "resumen": "Paciente estable, Sat O2 95% con oxígeno suplementario a 2L/min. Afebril. Continúa antibioticoterapia.", "signos_vitales": "PA: 120/80, FC: 75, FR: 18, T: 37.0°C, Sat: 95%"},
    {"paciente": "María García", "diagnostico": "Colecistitis aguda", "resumen": "Paciente con dolor abdominal en CID, náuseas, vómitos. Evaluación por cirugía. NPO. Hidratación Endovenosa.", "signos_vitales": "PA: 130/85, FC: 88, FR: 20, T: 38.2°C, Sat: 96%"},
    {"paciente": "Pedro López", "diagnostico": "ACV isquémico hemisférico derecho", "resumen": "Hemiparesia izquierda 3/5, disartria leve. NIHSS 8. Evaluación por neurología. TAC sin contraste.", "signos_vitales": "PA: 145/90, FC: 72, FR: 16, T: 36.8°C, Sat: 97%"},
    {"paciente": "Ana Torres", "diagnostico": "Neumonía adquirida en comunidad LII", "resumen": "Paciente estable hemodinámicamente, Sat O2 93% con oxígeno suplementario a 2L/min, afebril desde hace 48h, continúa antibioticoterapia.", "signos_vitales": "PA: 120/80, FC: 75, FR: 18, T: 37.0°C, Sat: 95%"},
    {"paciente": "Carlos Rivera", "diagnostico": "Sepsis urinaria", "resumen": "Paciente con ITU complicada, urocultivo positivo E. coli BLEE. Inicia meropenem. Monitorizar función renal.", "signos_vitales": "PA: 95/60, FC: 110, FR: 22, T: 38.8°C, Sat: 94%"},
    {"paciente": "Laura Mendoza", "diagnostico": "Crisis asmática moderada", "resumen": "Paciente con sibilancias y uso de músculos accesorios. Sat O2 90% al aire. Inicia salbutamol nebulizado c/20min y corticoides IV.", "signos_vitales": "PA: 110/70, FC: 105, FR: 28, T: 37.2°C, Sat: 90%"},
]

PLANES_DEMO = [
    {"paciente": "María García", "valoracion": "Paciente con dolor abdominal en CID, náuseas, vómitos, fiebre 38.5°C. Signo de McBurney positivo.", "diagnostico_nanda": "Dolor agudo (00132) r/c proceso inflamatorio m/p informe verbal de dolor, expresión facial de dolor", "objetivos_noc": "NOC 1605 Control del dolor: paciente referirá dolor 3/10 o menos en 4h", "intervenciones_nic": "NIC 2210 Administración de analgésicos (Paracetamol 1g IV c/8h). NIC 1400 Manejo del dolor: valorar EVA cada 2h", "evaluacion": "Paciente refiere disminución del dolor de 8/10 a 4/10 post analgesia"},
    {"paciente": "Ana Torres", "valoracion": "Paciente con tos productiva, Sat O2 93% con O2 suplementario, fiebre 38.0°C, expectoración verdosa.", "diagnostico_nanda": "Limpieza ineficaz de la vía aérea (00031) r/c infección respiratoria m/p tos productiva, sonidos respiratorios anormales", "objetivos_noc": "NOC 0410 Estado respiratorio: permeabilidad de las vías aéreas", "intervenciones_nic": "NIC 3250 Fisioterapia respiratoria. NIC 3350 Monitoreo respiratorio. NIC 2300 Administración de oxígeno", "evaluacion": "Paciente con mejoría de SatO2 a 96%, expectoración más fluida, FR 18 rpm"},
    {"paciente": "Carlos Rivera", "valoracion": "Paciente con fiebre 38.8°C, TA 95/60, FC 110, urocultivo positivo E. coli BLEE, creatinina elevada.", "diagnostico_nanda": "Riesgo de shock (00205) r/c sepsis de origen urinario", "objetivos_noc": "NOC 0802 Signos vitales: TA>100/60, FC<100, FR<20, T<38°C en 24h", "intervenciones_nic": "NIC 4250 Manejo de la sepsis: fluidoterapia, antibioticoterapia. NIC 6680 Monitoreo de signos vitales c/4h c/2h si inestable", "evaluacion": "Paciente con mejoría PA 110/70, FC 95, aún febril 38.2°C"},
    {"paciente": "Laura Mendoza", "valoracion": "Paciente con sibilancias audibles, SatO2 90%, FR 28, uso de músculos accesorios.", "diagnostico_nanda": "Patrón respiratorio ineficaz (00032) r/c broncoespasmo m/p sibilancias, taquipnea, uso de músculos accesorios", "objetivos_noc": "NOC 0415 Estado respiratorio: SatO2 >94%, FR <24 en 2h, sibilancias disminuidas", "intervenciones_nic": "NIC 3230 Fisioterapia respiratoria: técnicas de respiración con labios fruncidos. NIC 2310 Administración de broncodilatadores inhalados", "evaluacion": "Paciente con mejoría SatO2 95%, FR 22, disminución de sibilancias, aún requiere O2 por cánula nasal"},
]


@router.post("/")
def cargar_demo(db: Session = Depends(get_db)):
    """Carga datos demo (notas, planes, fármacos desde JSON)"""
    count = {"notas": 0, "planes": 0, "medicamentos": 0}

    ahora_ms = int(time.time() * 1000)

    if db.query(NotaTraspaso).count() == 0:
        for n in NOTAS_DEMO:
            db.add(NotaTraspaso(**n, actualizado=ahora_ms))
            count["notas"] += 1

    if db.query(PlanPAE).count() == 0:
        for p in PLANES_DEMO:
            db.add(PlanPAE(**p, timestamp=ahora_ms))
            count["planes"] += 1

    if db.query(DrugReference).count() < 50:
        actuales = {m.nombre_generico for m in db.query(DrugReference).all()}
        nuevos = 0
        for m in get_drugs():
            if m["nombre_generico"] not in actuales:
                db.add(DrugReference(**m))
                nuevos += 1
        count["medicamentos"] = nuevos

    db.commit()
    return {"ok": True, "creados": count}


@router.post("/reload/drugs")
def recargar_farmacos(db: Session = Depends(get_db)):
    """Recarga todos los fármacos desde drugs.json (borra y reinserta)"""
    drugs = get_drugs()
    if not drugs:
        raise HTTPException(400, "No hay datos de fármacos disponibles")
    db.query(DrugReference).delete()
    for m in drugs:
        db.add(DrugReference(**m))
    db.commit()
    return {"ok": True, "total": len(drugs)}


@router.post("/upload/drugs")
async def subir_farmacos(file: UploadFile = File(...), db: Session = Depends(get_db)):
    """Sube un archivo JSON con fármacos y recarga la BD"""
    if not file.filename.endswith(".json"):
        raise HTTPException(400, "Solo archivos JSON")
    content = await file.read()
    try:
        drugs = json.loads(content)
    except json.JSONDecodeError:
        raise HTTPException(400, "JSON inválido")
    if not isinstance(drugs, list) or len(drugs) == 0:
        raise HTTPException(400, "El JSON debe ser una lista de fármacos")
    save_drugs_to_json(drugs)
    db.query(DrugReference).delete()
    for m in drugs:
        db.add(DrugReference(**m))
    db.commit()
    return {"ok": True, "total": len(drugs), "archivo": file.filename}


@router.post("/upload/guide")
async def subir_guia(file: UploadFile = File(...)):
    """Sube una guía clínica (MD, TXT, PDF, DOCX) para RAG — extrae texto automáticamente"""
    if not any(file.filename.lower().endswith(ext) for ext in [".md", ".txt", ".pdf", ".docx"]):
        raise HTTPException(400, "Formatos aceptados: .md, .txt, .pdf, .docx")
    guides_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "guides"))
    os.makedirs(guides_dir, exist_ok=True)
    dest = os.path.join(guides_dir, file.filename)
    content = await file.read()
    with open(dest, "wb") as f:
        f.write(content)

    result = {
        "ok": True,
        "archivo": file.filename,
        "path": dest,
        "tamano_bytes": len(content),
    }

    ext = os.path.splitext(file.filename)[1].lower()
    if ext in (".pdf", ".docx"):
        texto = extract_text(dest)
        if texto:
            txt_path = os.path.splitext(dest)[0] + "_extracted.txt"
            with open(txt_path, "w", encoding="utf-8") as f:
                f.write(texto)
            palabras = len(texto.split())
            result["texto_extraido"] = txt_path
            result["palabras_extraidas"] = palabras
            result["tamano_texto"] = len(texto)
        else:
            result["error_extraccion"] = "No se pudo extraer texto del documento"

    return result


@router.post("/upload/content")
async def subir_contenido_educativo(file: UploadFile = File(...)):
    """Sube contenido educativo (JSON con materias, flashcards, quizzes)"""
    if not file.filename.endswith(".json"):
        raise HTTPException(400, "Solo archivos JSON")
    content = await file.read()
    try:
        data = json.loads(content)
    except json.JSONDecodeError:
        raise HTTPException(400, "JSON inválido")
    data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "data"))
    os.makedirs(data_dir, exist_ok=True)
    dest = os.path.join(data_dir, file.filename)
    with open(dest, "wb") as f:
        f.write(content)
    return {"ok": True, "archivo": file.filename, "registros": len(data) if isinstance(data, list) else 1}

import json
import urllib.request
import urllib.parse
import re
import os

OLLAMA_HOST = "http://localhost:11434"
MODELO_MEDICO = "phi4-mini:latest"

GUIDES_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "app", "guides"))

# IMPORTANTE: NO diagnosticar enfermedades, solo brindar soporte de enfemeria
PROMPT_TRIAGE = """Eres un ASISTENTE DE SOPORTE para profesionales de enfermeria.
NO EMITAS DIAGNOSTICOS MEDICOS. Tu rol es sugerir prioridades de atencion, banderas rojas (red flags), e intervenciones de enfermeria inmediatas basadas en los sintomas presentados.

Responde UNICAMENTE con este JSON exacto (sin markdown):
{{
  "diagnosis": "Posible area o sindrome (NO diagnostico medico definitivo)",
  "confidence": 0.9,
  "recommendation": "Accion inmediata de enfermeria y signos vitales a monitorizar",
  "red_flag": true/false,
  "priority": "emergencia|urgente|observacion"
}}

Datos del paciente:
Sintomas: {sintomas}
Edad: {age}
Sexo: {sex}
Signos Vitales: {vital_signs}
"""

PROMPT_PAE = """Eres un especialista en Procesos de Atencion de Enfermeria (PAE) usando taxonomia NANDA-NIC-NOC.
NO diagnosticas enfermedades, solo elaboras diagnosticos de ENFERMERIA.

Responde UNICAMENTE con este JSON:
{{
  "diagnostico": "Codigo y Nombre NANDA (Ej. 00132 Dolor agudo)",
  "objetivo": "Codigo y Nombre NOC",
  "intervenciones": "Lista separada por comas de 3 intervenciones NIC especificas",
  "evaluacion": "Criterio de evaluacion"
}}

Problema/Sintoma del paciente: {sintoma}
"""


def _llm_call(prompt: str, max_tokens: int = 300) -> dict | None:
    payload = json.dumps({
        "model": MODELO_MEDICO,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.1,
        "max_tokens": max_tokens,
    }).encode()
    req = urllib.request.Request(
        f"{OLLAMA_HOST}/api/generate",
        data=payload,
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            text = data.get("response", "")
            match = re.search(r"\{.*\}", text, re.DOTALL)
            if match:
                return json.loads(match.group())
            return None
    except Exception as e:
        print(f"LLM error: {e}")
        return None


def triage_con_llm(sintomas: str, age: int=0, sex: str="", vital_signs: dict | None=None) -> dict | None:
    prompt = PROMPT_TRIAGE.format(
        sintomas=sintomas,
        age=age,
        sex=sex,
        vital_signs=json.dumps(vital_signs) if vital_signs else "{}"
    )
    return _llm_call(prompt)


def pae_con_llm(sintoma: str) -> dict | None:
    prompt = PROMPT_PAE.format(sintoma=sintoma)
    return _llm_call(prompt)


def rag_query_guide(question: str) -> dict | None:
    import fnmatch
    best_match = None
    best_score = 0
    if not os.path.isdir(GUIDES_ROOT):
        return None
    for fname in os.listdir(GUIDES_ROOT):
        if not fnmatch.fnmatch(fname.lower(), "*.md") and not fnmatch.fnmatch(fname.lower(), "*.txt"):
            continue
        path = os.path.join(GUIDES_ROOT, fname)
        try:
            with open(path, encoding="utf-8", errors="ignore") as f:
                content = f.read().lower()
            score = content.count(question.lower())
            if score > best_score:
                best_score = score
                best_match = (fname, content)
        except Exception:
            continue
    if not best_match:
        return None
    fname, content = best_match
    snippet = content[:800].replace("\n", " ")
    rag_prompt = f"""Eres asistente de soporte medico. Usa la informacion de la guia clinica para responder la pregunta del profesional de enfermeria. No emitas diagnosticos. Brinda pasos, referencias y recomendaciones.

Guia ({fname}):
{snippet}

Pregunta: {question}

Responde con JSON: {{"answer": "texto", "source": "{fname}"}}"""
    return _llm_call(rag_prompt, max_tokens=500)

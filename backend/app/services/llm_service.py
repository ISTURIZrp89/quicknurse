import json
import os
import re
import math
from collections import defaultdict
import urllib.request

OLLAMA_HOST = "http://localhost:11434"
MODELO_MEDICO = "phi4-mini:latest"

GUIDES_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "app", "guides"))

# IMPORTANT: NO diagnosticar enfermedades, solo brindar soporte de enfermería
PROMPT_TRIAGE = """Eres un ASISTENTE DE SOPORTE para profesionales de enfermería.
NO EMITAS DIAGNÓSTICOS MÉDICOS. Tu rol es sugerir prioridades de atención, banderas rojas (red flags), e intervenciones de enfermería inmediatas basadas en los síntomas presentados.

Responde UNICAMENTE con este JSON exacto (sin markdown):
{
  "diagnosis": "Posible área o síndrome (NO diagnóstico médico definitivo)",
  "confidence": 0.9,
  "recommendation": "Acción inmediata de enfermería y signos vitales a monitorizar",
  "red_flag": true/false,
  "priority": "emergencia|urgente|observacion"
}

Datos del paciente:
Síntomas: {sintomas}
Edad: {age}
Sexo: {sex}
Signos vitales: {vital_signs}
"""

PROMPT_PAE = """Eres un especialista en Procesos de Atención de Enfermería (PAE) usando taxonomía NANDA-NIC-NOC.
NO diagnosticas enfermedades, solo elaboras diagnósticos de ENFERMERÍA.

Responde UNICAMENTE con este JSON:
{
  "diagnostico": "Código y Nombre NANDA (Ej. 00132 Dolor agudo)",
  "objetivo": "Código y Nombre NOC",
  "intervenciones": "Lista separada por comas de 3 intervenciones NIC específicas",
  "evaluacion": "Criterio de evaluación"
}

Problema/Síntoma del paciente: {sintoma}
"""

# BM25 parameters
BM25_K1 = 1.2
BM25_B = 0.75
STOP_WORDS = {
    "de","la","el","en","y","a","los","del","se","las","por","un","para","con","no","una","su","al","lo","le","si","ya",
    "me","mi","tu","te","sus","nos","nosotros","vosotros","ellos","ellas","se","más","como","pero","sus","le","les",
    "esto","esta","eso","aquello","aquel","aquella","aquí","ahí","allí","allá","hoy","ayer","mañana","pronto","tarde","temprano",
    "todo","nada","algo","alguien","nadie","cada","varios","algunos","ninguno","cierto","cierta","ciertos","varios","mucho","pocos",
    "bien","mal","peor","mejor","mejor","siempre","nunca","también","además","incluso","excepto","solo","justo","apenas","pronto",
    "aunque","puesto","porque","pues","mientras","antes","después","durante","desde","hacia","hasta","según","contra","entre",
    "sobre","bajo","tras","mediante","vía","sin","con","para","por",
    "the","and","of","to","in","is","that","it","for","on","with","as","this","was","are","be","at","an","by","from","or"
}

def _tokenize(text: str) -> list[str]:
    text = text.lower()
    text = re.sub(r"[^a-záéíóúüñ0-9\s]", " ", text)
    tokens = [t.strip() for t in text.split() if len(t.strip()) > 2 and t.strip() not in STOP_WORDS]
    return tokens

def _compute_bm25(query_tokens: list[str], doc_tokens: list[str]) -> float:
    if not doc_tokens or not query_tokens:
        return 0.0
    doc_len = len(doc_tokens)
    avgdl = max(1.0, 100.0)  # Approximate; could precompute from corpus
    tf = defaultdict(int)
    for t in doc_tokens:
        tf[t] += 1
    score = 0.0
    for qt in query_tokens:
        ft = tf.get(qt, 0)
        if ft == 0:
            continue
        idf = math.log((1.0) / (1.0 + ft))  # Use simple IDF since corpus is local
        numerator = ft * (BM25_K1 + 1.0)
        denominator = ft + BM25_K1 * (1.0 - BM25_B + BM25_B * (doc_len / avgdl))
        score += idf * numerator / denominator
    return score


def _rag_search(question: str, max_snippets: int = 3) -> tuple[str, list[str]]:
    """BM25-inspired search across clinical guides. Returns (context, sources)."""
    if not os.path.isdir(GUIDES_ROOT):
        return "", []
    results = []
    q_tokens = _tokenize(question)
    for fname in os.listdir(GUIDES_ROOT):
        if not fname.lower().endswith((".md", ".txt")):
            continue
        path = os.path.join(GUIDES_ROOT, fname)
        try:
            with open(path, encoding="utf-8", errors="ignore") as f:
                content = f.read()
                # Split into paragraphs for finer-grained matching
                paragraphs = [p.strip() for p in content.split("\n\n") if len(p.strip()) > 50]
                if not paragraphs:
                    paragraphs = [content]
                best_score = 0.0
                best_para = ""
                for para in paragraphs:
                    para_tokens = _tokenize(para)
                    s = _compute_bm25(q_tokens, para_tokens)
                    if s > best_score:
                        best_score = s
                        best_para = para
                # Bonus if filename matches query
                name_tokens = _tokenize(fname.replace(".md", "").replace(".txt", ""))
                name_score = sum(1 for t in q_tokens if t in name_tokens) * 0.5
                total_score = best_score + name_score
                if total_score > 0:
                    snippet = best_para.replace("\n", " ") if best_para else content[:400].replace("\n", " ")
                    results.append((total_score, fname, snippet[:500]))
        except Exception:
            continue
    results.sort(reverse=True)
    context_parts = []
    sources = []
    for _, fname, snippet in results[:max_snippets]:
        context_parts.append(f"--- {fname} ---\n{snippet}")
        sources.append(fname.replace(".md", "").replace(".txt", ""))
    return "\n\n".join(context_parts), sources


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
    """BM25-based RAG search through clinical guides. Returns LLM-generated answer if relevant context found."""
    context, sources = _rag_search(question)
    if not context or not sources:
        return None
    rag_prompt = f"""Eres asistente de soporte médico. Usa la información de las guías clínicas para responder la pregunta del profesional de enfermería. No emitas diagnósticos. Brinda pasos, referencias y recomendaciones.

Guías clínicas:
{context}

Pregunta: {question}

Responde con JSON: {{"answer": "texto", "source": "nombre de la guía principal"}}"""
    return _llm_call(rag_prompt, max_tokens=600)

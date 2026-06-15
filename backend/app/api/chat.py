from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
import os
import json
import urllib.request
import urllib.error
import time
import re

from app.database import get_db
from app.models import ChatConversation

router = APIRouter()

OLLAMA_HOST = os.environ.get("OLLAMA_HOST", "http://localhost:11434")
OLLAMA_MODEL = os.environ.get("OLLAMA_MODEL", "llama3.2:3b")
HF_TOKEN = os.environ.get("HF_TOKEN", "")
GUIDES_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "guides"))

_ollama_available = None
_ollama_check_time = 0
_ollama_models = []


def _check_ollama() -> bool:
    global _ollama_available, _ollama_check_time, _ollama_models
    now = time.time()
    if now - _ollama_check_time < 30 and _ollama_available is not None:
        return _ollama_available
    try:
        req = urllib.request.Request(f"{OLLAMA_HOST}/api/tags")
        with urllib.request.urlopen(req, timeout=3) as resp:
            data = json.loads(resp.read().decode())
            _ollama_models = [m["name"] for m in data.get("models", [])]
            _ollama_available = True
    except Exception:
        _ollama_available = False
        _ollama_models = []
    _ollama_check_time = now
    return _ollama_available


def _call_ollama(model: str, mensaje: str, system: str = "") -> str | None:
    if not system:
        system = "Eres un asistente médico clínico especializado en enfermería. Responde breve, preciso y profesional en español."
    payload = json.dumps({
        "model": model,
        "prompt": f"[INST] <<SYS>>\n{system}\n<</SYS>>\n{mensaje} [/INST]",
        "stream": False,
        "temperature": 0.1,
        "max_tokens": 500,
    }).encode()
    try:
        req = urllib.request.Request(
            f"{OLLAMA_HOST}/api/generate",
            data=payload,
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode())
            return data.get("response", "")
    except Exception as e:
        print(f"Ollama error: {e}")
        return None


# ─── HuggingFace Inference API ────────────────────────────────────
HF_MODELS = {
    "hf-deepseek": "deepseek-ai/DeepSeek-Coder-1.3B-instruct",
    "hf-mistral": "mistralai/Mistral-7B-Instruct-v0.3",
    "hf-meditron": "epfl-llm/meditron-7b",
}

def _call_huggingface(model_id: str, mensaje: str, system: str = "") -> str | None:
    hf_model = HF_MODELS.get(model_id)
    if not hf_model:
        return None
    if not system:
        system = "Eres un asistente médico clínico especializado en enfermería."
    try:
        headers = {"Authorization": f"Bearer {HF_TOKEN}", "Content-Type": "application/json"}
        payload = json.dumps({
            "inputs": f"<s>[INST] {system}\n{mensaje} [/INST]",
            "parameters": {"max_new_tokens": 500, "temperature": 0.1, "return_full_text": False},
        }).encode()
        req = urllib.request.Request(
            f"https://api-inference.huggingface.co/models/{hf_model}",
            data=payload,
            headers=headers,
        )
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read().decode())
            if isinstance(data, list) and len(data) > 0:
                return data[0].get("generated_text", str(data[0]))
            if isinstance(data, dict) and "generated_text" in data:
                return data["generated_text"]
            return str(data)
    except Exception as e:
        print(f"HF error: {e}")
        return None


# ─── RAG (búsqueda en guías) ──────────────────────────────────────
def _rag_search(question: str, max_snippets: int = 3) -> tuple[str, list[str]]:
    """Busca en guías y retorna (contexto, fuentes)."""
    if not os.path.isdir(GUIDES_DIR):
        return "", []
    results = []
    q_lower = question.lower()
    words = q_lower.split()
    for fname in os.listdir(GUIDES_DIR):
        if not fname.lower().endswith((".md", ".txt")):
            continue
        path = os.path.join(GUIDES_DIR, fname)
        try:
            with open(path, encoding="utf-8", errors="ignore") as f:
                content = f.read()
            score = sum(1 for w in words if w in content.lower())
            if score > 0:
                # Extraer snippet relevante
                idx = content.lower().find(q_lower[:30])
                if idx == -1:
                    idx = 0
                start = max(0, idx - 100)
                end = min(len(content), idx + 400)
                snippet = content[start:end].replace("\n", " ")
                results.append((score, fname, snippet))
        except Exception:
            continue
    results.sort(reverse=True)
    context_parts = []
    sources = []
    for _, fname, snippet in results[:max_snippets]:
        context_parts.append(f"--- {fname} ---\n{snippet}")
        sources.append(fname.replace(".md", "").replace(".txt", ""))
    return "\n\n".join(context_parts), sources


def _web_search(query: str, max_results: int = 5) -> list[dict]:
    """Search the web using DuckDuckGo, return list of {title, snippet, url}"""
    try:
        from duckduckgo_search import DDGS
        with DDGS() as ddgs:
            results = []
            for r in ddgs.text(query, max_results=max_results):
                results.append({
                    "title": r.get("title", ""),
                    "snippet": r.get("body", ""),
                    "url": r.get("href", ""),
                })
            return results
    except ImportError:
        pass
    except Exception as e:
        print(f"DuckDuckGo search error: {e}")

    # Fallback: HTTP-based search via requests
    try:
        import requests
        from urllib.parse import quote
        url = f"https://html.duckduckgo.com/html/?q={quote(query)}"
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                          "AppleWebKit/537.36 (KHTML, like Gecko) "
                          "Chrome/120.0.0.0 Safari/537.36"
        }
        resp = requests.get(url, headers=headers, timeout=10)
        if resp.status_code == 200:
            results = []
            # Simple HTML parsing for result snippets
            import html as html_mod
            text = resp.text
            # Find result blocks
            for item in re.finditer(
                r'class="result__a"[^>]*href="([^"]*)"[^>]*>(.*?)</a>.*?'
                r'class="result__snippet"[^>]*>(.*?)</(?:a|span|div)',
                text, re.DOTALL
            ):
                href = html_mod.unescape(item.group(1))
                title = re.sub(r'<[^>]+>', '', item.group(2)).strip()
                snippet = re.sub(r'<[^>]+>', '', item.group(3)).strip()
                results.append({"title": title, "snippet": snippet, "url": href})
                if len(results) >= max_results:
                    break
            return results
    except Exception as e:
        print(f"Web search fallback error: {e}")

    return []


class ChatRequest(BaseModel):
    mensaje: str
    modelo: str = ""
    use_rag: bool = False
    use_web: bool = False


class ChatResponse(BaseModel):
    respuesta: str
    modelo_usado: str = ""
    tipo: str = "local"
    fuentes: list[str] = []
    web_results: list[dict] = []


@router.post("/", response_model=ChatResponse)
def enviar_mensaje(request: ChatRequest):
    msg = request.mensaje.strip()
    if not msg:
        return ChatResponse(respuesta="Escribe una consulta médica.", tipo="error")

    modelo = request.modelo.strip() if request.modelo else OLLAMA_MODEL
    usar_rag = request.use_rag
    usar_web = request.use_web
    fuentes: list[str] = []
    web_results: list[dict] = []
    system_prompt = (
        "Eres un asistente médico clínico especializado en enfermería. "
        "Responde breve, preciso y profesional en español. "
        "NO emitas diagnósticos médicos definitivos. Brinda información de apoyo."
    )

    # RAG: buscar en guías si está activado
    if usar_rag:
        rag_context, fuentes = _rag_search(msg)
        if rag_context:
            system_prompt += (
                "\n\nContexto de guías clínicas disponibles:\n" + rag_context +
                "\n\nUsa esta información si es relevante para responder."
            )

    # Web search: buscar en internet si está activado
    if usar_web:
        web_results = _web_search(msg)
        if web_results:
            web_context_parts = []
            for i, r in enumerate(web_results, 1):
                web_context_parts.append(
                    f"[{i}] {r['title']}\n{r['snippet']}\nFuente: {r['url']}"
                )
            system_prompt += (
                "\n\nResultados de búsqueda web:\n" +
                "\n\n".join(web_context_parts) +
                "\n\nUsa esta información si es relevante para responder. "
                "Menciona las fuentes cuando corresponda."
            )

    # Detectar si es modelo HuggingFace
    is_hf = modelo.startswith("hf-")

    if is_hf:
        if not HF_TOKEN:
            return ChatResponse(
                respuesta="⚠️ Se requiere token de HuggingFace.\n\nConfigura HF_TOKEN en el entorno para usar modelos HF.\n\nMientras tanto, usa modelos locales de Ollama.",
                tipo="error",
                web_results=web_results,
            )
        resp = _call_huggingface(modelo, msg, system_prompt)
        if resp:
            return ChatResponse(respuesta=resp, modelo_usado=modelo, tipo="huggingface", fuentes=fuentes, web_results=web_results)
        return ChatResponse(
            respuesta="Error al comunicarse con HuggingFace. Verifica tu token y conexión.",
            tipo="error",
            web_results=web_results,
        )

    # Modelo local Ollama
    if not _check_ollama():
        return ChatResponse(
            respuesta="⚠️ Ollama no está corriendo.\n\nPara usar el chat local:\n"
                      "1. Inicia Ollama: ollama serve\n"
                      "2. Descarga un modelo: ollama pull llama3.2:3b\n\n"
                      "Modelos recomendados: llama3.2:3b, phi4-mini, medllama2",
            tipo="error",
            web_results=web_results,
        )

    modelos_disponibles = _ollama_models
    modelo_a_usar = modelo

    if modelo not in modelos_disponibles:
        aliases = {
            "llama3.2": ["llama3.2:3b", "llama3.2:1b", "llama3"],
            "llama3": ["llama3.2:3b", "llama3:8b", "llama3"],
            "phi4": ["phi4-mini:latest", "phi4:latest"],
            "phi4-mini": ["phi4-mini:latest"],
            "medllama2": ["medllama2:latest"],
            "mistral": ["mistral:7b", "mistral"],
        }
        candidatos = aliases.get(modelo, [modelo])
        for candidato in candidatos:
            if candidato in modelos_disponibles:
                modelo_a_usar = candidato
                break
        else:
            if modelos_disponibles:
                modelo_a_usar = modelos_disponibles[0]
            else:
                return ChatResponse(
                    respuesta="No hay modelos disponibles en Ollama. "
                              f"Descarga uno: ollama pull {OLLAMA_MODEL}",
                    tipo="error",
                    web_results=web_results,
                )

    resp = _call_ollama(modelo_a_usar, msg, system_prompt)
    if resp:
        return ChatResponse(respuesta=resp, modelo_usado=modelo_a_usar, tipo="local", fuentes=fuentes, web_results=web_results)

    return ChatResponse(
        respuesta="Error al comunicarse con Ollama. Verifica que el servidor esté activo.",
        tipo="error",
        web_results=web_results,
    )


@router.get("/modelos")
def listar_modelos():
    local = _check_ollama()
    modelos = []
    if local:
        modelos = _ollama_models
    recomendados = [
        {"id": "llama3.2:3b", "nombre": "Llama 3.2 3B", "tipo": "local"},
        {"id": "phi4-mini", "nombre": "Phi4 Mini", "tipo": "local"},
        {"id": "mistral:7b", "nombre": "Mistral 7B", "tipo": "local"},
        {"id": "medllama2", "nombre": "MedLlama2", "tipo": "local"},
        {"id": "hf-deepseek", "nombre": "DeepSeek Coder (HF)", "tipo": "huggingface"},
        {"id": "hf-mistral", "nombre": "Mistral HF", "tipo": "huggingface"},
        {"id": "hf-meditron", "nombre": "Meditron (HF)", "tipo": "huggingface"},
    ]
    return {
        "local_disponible": local,
        "modelos_locales": modelos,
        "modelos_recomendados": recomendados,
        "modelo_default": OLLAMA_MODEL,
        "hf_disponible": bool(HF_TOKEN),
    }


@router.get("/estado")
def estado_chat():
    local = _check_ollama()
    return {
        "ollama_activo": local,
        "modelos_disponibles": len(_ollama_models) if local else 0,
        "modelos": _ollama_models if local else [],
        "modelo_default": OLLAMA_MODEL,
        "hf_token_configurado": bool(HF_TOKEN),
    }


# ─── Conversation persistence ──────────────────────────────────

@router.get("/conversaciones")
def listar_conversaciones(db: Session = Depends(get_db)):
    """List all saved conversations"""
    conversaciones = db.query(ChatConversation).order_by(
        ChatConversation.actualizado_en.desc()
    ).all()
    return [
        {
            "id": c.id,
            "titulo": c.titulo,
            "modelo": c.modelo,
            "mensajes": json.loads(c.mensajes) if c.mensajes else [],
            "creado_en": c.creado_en,
            "actualizado_en": c.actualizado_en,
        }
        for c in conversaciones
    ]


@router.post("/conversaciones")
def guardar_conversacion(data: dict, db: Session = Depends(get_db)):
    """Save a conversation with title, model, messages"""
    titulo = data.get("titulo", "")
    modelo = data.get("modelo", "")
    mensajes = data.get("mensajes", [])
    now = int(time.time() * 1000)

    conv = ChatConversation(
        titulo=titulo,
        modelo=modelo,
        mensajes=json.dumps(mensajes, ensure_ascii=False),
        creado_en=now,
        actualizado_en=now,
    )
    db.add(conv)
    db.commit()
    db.refresh(conv)
    return {
        "id": conv.id,
        "titulo": conv.titulo,
        "modelo": conv.modelo,
        "creado_en": conv.creado_en,
        "actualizado_en": conv.actualizado_en,
    }


@router.delete("/conversaciones/{conv_id}")
def eliminar_conversacion(conv_id: int, db: Session = Depends(get_db)):
    """Delete a conversation"""
    conv = db.query(ChatConversation).filter(ChatConversation.id == conv_id).first()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversación no encontrada")
    db.delete(conv)
    db.commit()
    return {"status": "ok", "id": conv_id}

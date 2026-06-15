import os
import re
from fastapi import APIRouter, HTTPException, UploadFile, File, Query
from fastapi.responses import PlainTextResponse

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GUIDES_DIR = os.path.join(BASE_DIR, "guides")
os.makedirs(GUIDES_DIR, exist_ok=True)

router = APIRouter()

@router.get("/", response_model=dict)
def list_guides():
    md_files = sorted([f for f in os.listdir(GUIDES_DIR) if f.lower().endswith((".md", ".txt"))])
    return {"guides": md_files}

# Search y RAG primero para que no los atrape /{filename}
@router.get("/search", response_model=dict)
def search_guides(query: str = Query(..., min_length=2)):
    pattern = re.compile(re.escape(query), re.IGNORECASE)
    results = []
    for fname in os.listdir(GUIDES_DIR):
        if not fname.lower().endswith((".md", ".txt")):
            continue
        path = os.path.join(GUIDES_DIR, fname)
        with open(path, encoding="utf-8", errors="ignore") as f:
            text = f.read()
        if pattern.search(text):
            snippet = text[:200].replace("\n", " ")
            results.append({"file": fname, "snippet": snippet})
    return {"query": query, "matches": results}

@router.get("/rag", response_model=dict)
def rag_guides(question: str = Query(..., min_length=3)):
    from app.services.llm_service import rag_query_guide
    result = rag_query_guide(question)
    if result:
        return result
    return {"answer": "No se encontro informacion relevante en las guias.", "source": None}

@router.get("/{filename}", response_class=PlainTextResponse)
def get_guide(filename: str):
    safe_path = os.path.normpath(os.path.join(GUIDES_DIR, filename))
    if not safe_path.startswith(GUIDES_DIR) or not os.path.isfile(safe_path):
        raise HTTPException(404, "Guia no encontrada")
    with open(safe_path, encoding="utf-8") as f:
        return PlainTextResponse(f.read())

@router.post("/upload", response_model=dict)
def upload_guide(file: UploadFile = File(...), overwrite: bool = Query(False)):
    filename = os.path.basename(file.filename)
    safe_path = os.path.normpath(os.path.join(GUIDES_DIR, filename))
    if not safe_path.startswith(GUIDES_DIR):
        raise HTTPException(400, "Ruta no permitida")
    if os.path.exists(safe_path) and not overwrite:
        raise HTTPException(409, "Archivo ya existe. Use overwrite=true para sobreescribir")
    content = file.file.read().decode("utf-8", errors="ignore")
    with open(safe_path, "w", encoding="utf-8") as f:
        f.write(content)
    return {"status": "ok", "filename": filename}

import os
import re


def extract_text_from_pdf(path: str) -> str:
    try:
        import fitz
        doc = fitz.open(path)
        text = "\n".join(page.get_text() for page in doc)
        doc.close()
        return text.strip()
    except ImportError:
        return ""


def extract_text_from_docx(path: str) -> str:
    try:
        from docx import Document
        doc = Document(path)
        return "\n".join(p.text for p in doc.paragraphs if p.text.strip()).strip()
    except ImportError:
        return ""


def extract_text(path: str) -> str:
    ext = os.path.splitext(path)[1].lower()
    if ext == ".pdf":
        return extract_text_from_pdf(path)
    elif ext == ".docx":
        return extract_text_from_docx(path)
    elif ext in (".md", ".txt"):
        with open(path, encoding="utf-8", errors="ignore") as f:
            return f.read().strip()
    return ""

import os


def test_guides_directory():
    guides_dir = os.path.join(os.path.dirname(__file__), "..", "guides")
    assert os.path.isdir(guides_dir), f"Guides dir not found: {guides_dir}"
    files = [f for f in os.listdir(guides_dir) if f.endswith((".md", ".txt"))]
    assert len(files) >= 5, f"Expected >=5 guides, got {len(files)}"


def test_guides_index_exists():
    index_path = os.path.join(os.path.dirname(__file__), "..", "data", "guides_index.json")
    assert os.path.isfile(index_path), "guides_index.json not found"
    import json
    with open(index_path, encoding="utf-8") as f:
        index = json.load(f)
    assert len(index) >= 5, f"Expected >=5 guide entries, got {len(index)}"


def test_rag_search_finds_content():
    import sys
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
    from app.api.chat import _rag_search
    ctx, sources = _rag_search("reanimación cardiopulmonar")
    assert len(sources) >= 1, f"Expected RAG to find results, got {sources}"
    assert len(ctx) > 50, "Expected meaningful context"


def test_rag_search_sepsis():
    import sys
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
    from app.api.chat import _rag_search
    ctx, sources = _rag_search("manejo de sepsis y antibióticos")
    assert len(sources) >= 1, f"Expected sepsis results, got {sources}"

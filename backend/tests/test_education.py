import json
import os


def _load_education():
    path = os.path.join(os.path.dirname(__file__), "..", "data", "education.json")
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def test_education_subjects_count():
    data = _load_education()
    assert len(data) >= 10, f"Expected >=10 subjects, got {len(data)}"


def test_education_all_have_images():
    data = _load_education()
    missing = [s["nombre"] for s in data if not s.get("imagen")]
    assert not missing, f"Subjects missing images: {missing}"


def test_education_all_have_licenses():
    data = _load_education()
    missing = [s["nombre"] for s in data if not s.get("imagen_licencia")]
    assert not missing, f"Subjects missing licenses: {missing}"


def test_education_content_counts():
    data = _load_education()
    total_fc = sum(len(s.get("flashcards", [])) for s in data)
    total_qz = sum(len(s.get("quizzes", [])) for s in data)
    assert total_fc >= 100, f"Expected >=100 flashcards, got {total_fc}"
    assert total_qz >= 50, f"Expected >=50 quizzes, got {total_qz}"


def test_education_image_files_exist():
    data = _load_education()
    missing = []
    for s in data:
        img = s.get("imagen", "")
        if img and img.startswith("/static/"):
            rel = img.lstrip("/")
            path = os.path.join(os.path.dirname(__file__), "..", rel)
            if not os.path.isfile(path):
                missing.append(f"{s['nombre']}: {path}")
    assert not missing, "\n".join(missing)

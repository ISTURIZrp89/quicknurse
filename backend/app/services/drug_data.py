# -*- coding: utf-8 -*-
"""
Farmacología QuickNurse — 826+ fármacos.
Cargado desde drugs.json (si existe) o desde este módulo como fallback.
"""
import json
import os

JSON_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "data", "drugs.json")

MEDS_EXTENDED = []

# Intentar cargar desde JSON
loaded_from_json = False
try:
    if os.path.isfile(JSON_PATH):
        with open(JSON_PATH, encoding="utf-8") as f:
            MEDS_EXTENDED = json.load(f)
        loaded_from_json = True
except Exception as e:
    print(f"Error cargando drugs.json: {e}")


def get_drugs() -> list[dict]:
    return MEDS_EXTENDED


def save_drugs_to_json(drugs: list[dict]) -> bool:
    """Guarda lista de fármacos a JSON. Crea directorio si no existe."""
    try:
        os.makedirs(os.path.dirname(JSON_PATH), exist_ok=True)
        with open(JSON_PATH, "w", encoding="utf-8") as f:
            json.dump(drugs, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"Error guardando drugs.json: {e}")
        return False


def add_drug(drug: dict) -> dict:
    """Agrega un fármaco a la lista y guarda en JSON."""
    MEDS_EXTENDED.append(drug)
    save_drugs_to_json(MEDS_EXTENDED)
    return drug


def update_drug(index: int, drug: dict) -> dict | None:
    """Actualiza un fármaco por índice y guarda."""
    if 0 <= index < len(MEDS_EXTENDED):
        MEDS_EXTENDED[index] = drug
        save_drugs_to_json(MEDS_EXTENDED)
        return drug
    return None


__all__ = ["get_drugs", "save_drugs_to_json", "add_drug", "update_drug"]

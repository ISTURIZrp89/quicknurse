from app.services.drug_data import get_drugs


def test_drugs_count():
    drugs = get_drugs()
    assert len(drugs) >= 100, f"Expected >=100 drugs, got {len(drugs)}"


def test_drugs_have_all_fields():
    required = [
        "nombre_generico", "categoria", "indicacion", "dosis_adulto",
        "dosis_pediatrica", "via", "presentacion", "contraindicaciones",
        "interacciones", "efectos_adversos", "embarazo_lactancia",
        "mecanismo_accion", "precauciones", "alerta",
    ]
    drugs = get_drugs()
    errors = []
    for d in drugs:
        for field in required:
            if field not in d or not d[field]:
                errors.append(f"{d.get('nombre_generico', '?')} missing {field}")
    assert not errors, "\n".join(errors[:10])


def test_drugs_no_placeholder_text():
    placeholders = ["Consultar", "condiciones que contraindiquen", "Verificar dosis"]
    drugs = get_drugs()
    errors = []
    for d in drugs:
        for key, val in d.items():
            if isinstance(val, str) and any(p in val for p in placeholders):
                errors.append(f"{d['nombre_generico']}.{key}: {val[:40]}")
    assert not errors, "\n".join(errors[:10])


def test_drug_categories():
    drugs = get_drugs()
    categories = set(d["categoria"] for d in drugs)
    assert len(categories) <= 30, f"Too many categories: {len(categories)}"
    assert len(categories) >= 15, f"Too few categories: {len(categories)}"


def test_drugs_key_drugs_present():
    drugs = get_drugs()
    names = {d["nombre_generico"].split("(")[0].strip().lower() for d in drugs}
    name_main = {d["nombre_generico"].split("(")[0].strip().lower() for d in drugs}
    all_text = " ".join(d["nombre_generico"].lower() for d in drugs)
    key = ["adrenalina", "naloxona", "omeprazol", "furosemida", "metformina",
           "amoxicilina", "heparina", "morfina", "diazepam", "insulina"]
    missing = [k for k in key if k not in all_text]
    assert not missing, f"Key drugs missing from entire dataset: {missing}"

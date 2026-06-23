from fastapi.testclient import TestClient
import sys
import os
import pytest

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

os.environ["QUICKNURSE_DB_URL"] = "sqlite:///./test_quicknurse.db"

from app.main import app
from app.database import init_db, Base, engine, SessionLocal
from app.models import User, UserRole
from app.security import get_password_hash, create_access_token

CLINICIAN_USER_ID = 1

@pytest.fixture(scope="module", autouse=True)
def setup_db():
    Base.metadata.drop_all(bind=engine)
    init_db()
    db = SessionLocal()
    user = User(
        id=CLINICIAN_USER_ID,
        username="testclinician",
        password_hash=get_password_hash("test123"),
        rol=UserRole.CLINICIAN,
        activo=True,
    )
    db.add(user)
    db.commit()
    db.close()
    yield

client = TestClient(app)

def auth_header():
    token = create_access_token({"sub": "testclinician", "user_id": CLINICIAN_USER_ID, "role": "clinician"})
    return {"Authorization": f"Bearer {token}"}


def test_health():
    r = client.get("/health")
    assert r.status_code == 200

def test_create_patient():
    r = client.post("/api/v1/patients", json={
        "user_id": 1,
        "clinician_id": 1,
        "first_name": "John",
        "last_name": "Doe",
        "date_of_birth": "1990-01-15",
        "sex": "M",
    }, headers=auth_header())
    assert r.status_code == 201
    assert r.json()["full_name"] == "John Doe"

def test_list_patients():
    r = client.get("/api/v1/patients", headers=auth_header())
    assert r.status_code == 200
    assert len(r.json()) >= 1

def test_get_patient():
    r = client.get("/api/v1/patients/1", headers=auth_header())
    assert r.status_code == 200
    assert r.json()["full_name"] == "John Doe"

def test_get_patient_not_found():
    r = client.get("/api/v1/patients/999", headers=auth_header())
    assert r.status_code == 404

def test_patient_schema_validation():
    r = client.post("/api/v1/patients", json={
        "first_name": "John"
    }, headers=auth_header())
    assert r.status_code == 422

def test_add_vital_signs():
    r = client.post("/api/v1/patients/1/vitals", json={
        "bp_systolic": 120, "bp_diastolic": 80,
        "heart_rate": 72, "spo2": 98,
        "temperature": 36.5, "source": "manual",
    }, headers=auth_header())
    assert r.status_code == 201

def test_get_vitals_history():
    r = client.get("/api/v1/patients/1/vitals", headers=auth_header())
    assert r.status_code == 200
    assert len(r.json()) >= 1

def test_get_latest_vitals():
    r = client.get("/api/v1/patients/1/vitals/latest", headers=auth_header())
    assert r.status_code == 200

def test_get_vitals_trend():
    r = client.get("/api/v1/patients/1/vitals/trend?parameter=bp_systolic&days=7", headers=auth_header())
    assert r.status_code == 200

def test_get_therapeutic_classes():
    r = client.get("/api/v1/medications/therapeutic-classes", headers=auth_header())
    assert r.status_code == 200

def test_search_medications():
    r = client.get("/api/v1/medications", headers=auth_header())
    assert r.status_code == 200

def test_create_episode():
    r = client.post("/api/v1/episodes/patients/1", json={
        "chief_complaint": "Dolor abdominal",
        "episode_type": "emergency",
    }, headers=auth_header())
    assert r.status_code == 201
    assert r.json()["chief_complaint"] == "Dolor abdominal"

def test_list_episodes():
    r = client.get("/api/v1/episodes/patients/1", headers=auth_header())
    assert r.status_code == 200
    assert len(r.json()) >= 1

def test_get_episode():
    r = client.get("/api/v1/episodes/1", headers=auth_header())
    assert r.status_code == 200

def test_close_episode():
    r = client.post("/api/v1/episodes/1/close", headers=auth_header())
    assert r.status_code == 200
    assert r.json()["status"] == "closed"

def test_create_note():
    r = client.post("/api/v1/episodes/1/notes", json={
        "content": "Paciente evoluciona favorablemente",
        "note_type": "progress",
    }, headers=auth_header())
    assert r.status_code == 201

def test_list_notes():
    r = client.get("/api/v1/episodes/1/notes", headers=auth_header())
    assert r.status_code == 200
    assert len(r.json()) >= 1

def test_create_prescription_no_med():
    r = client.post("/api/v1/patients/1/prescriptions", json={
        "medication_id": 999,
        "dose": "500mg",
        "frequency": "cada 8h",
        "quantity": 30,
    }, headers=auth_header())
    assert r.status_code == 400
    assert "Medicamento no encontrado" in r.text

def test_list_prescriptions():
    r = client.get("/api/v1/patients/1/prescriptions", headers=auth_header())
    assert r.status_code == 200

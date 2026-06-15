from fastapi.testclient import TestClient
import sys
import os
import pytest

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# BD en memoria para tests
os.environ["QUICKNURSE_DB_URL"] = "sqlite:///./test_quicknurse.db"

from app.main import app
from app.database import init_db, Base, engine

# Limpiar BD de test antes de arrancar
@pytest.fixture(autouse=True)
def reset_db():
    Base.metadata.drop_all(bind=engine)
    init_db()
    yield

client = TestClient(app)

def test_health_check():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok", "service": "quicknurse-backend"}

def test_symptoms_cardiac():
    r = client.post("/api/v1/symptoms/", json={"symptoms": "Tengo un fuerte dolor de pecho y presion"})
    assert r.status_code == 200
    data = r.json()
    assert "Coronario" in data["diagnosis"]
    assert data["confidence"] == 0.95
    assert "EMERGENCIA" in data["recommendation"]

def test_symptoms_respiratory():
    r = client.post("/api/v1/symptoms/", json={"symptoms": "Dificultad para respirar"})
    assert r.status_code == 200
    data = r.json()
    assert "Respiratoria" in data["diagnosis"]

def test_symptoms_default():
    r = client.post("/api/v1/symptoms/", json={"symptoms": "Me duele un poco el pie"})
    assert r.status_code == 200
    data = r.json()
    assert "inespecíficos" in data["diagnosis"]
    assert data["confidence"] == 0.50

def test_guides_list():
    r = client.get("/api/v1/guides/")
    assert r.status_code == 200
    data = r.json()
    assert len(data["guides"]) >= 2

def test_turnos_crud():
    r = client.post("/api/v1/turnos/", json={
        "id": "test_turno_1", "centro": "Hospital Test",
        "especialidad": "Urgencias", "tarifa": 70.0, "horas": 8.0
    })
    assert r.status_code == 200
    assert r.json()["estado"] == "DISPONIBLE"

    r = client.get("/api/v1/turnos/")
    assert any(t["id"] == "test_turno_1" for t in r.json())

    r = client.patch("/api/v1/turnos/test_turno_1/aplicar")
    assert r.status_code == 200

def test_credenciales_crud():
    r = client.post("/api/v1/credenciales/", json={
        "nombre": "Licencia RN", "emisor": "Junta Estatal", "numero": "RN-12345"
    })
    assert r.status_code == 200
    assert r.json()["nombre"] == "Licencia RN"

def test_notas_crud():
    r = client.post("/api/v1/notas/", json={
        "paciente": "Hab 101", "diagnostico": "Diabetes", "resumen": "Estable"
    })
    assert r.status_code == 200
    assert r.json()["paciente"] == "Hab 101"

def test_planes_pae_crud():
    r = client.post("/api/v1/planes_pae/", json={
        "paciente": "PAC-001", "valoracion": "Fiebre",
        "diagnostico_nanda": "Hipertermia"
    })
    assert r.status_code == 200
    assert r.json()["paciente"] == "PAC-001"

def test_timers():
    r = client.post("/api/v1/timers/clock-in")
    assert r.status_code == 200
    data = r.json()
    assert "entrada" in data

    r = client.get("/api/v1/timers/activo")
    assert r.json()["activo"] == True

    r = client.post("/api/v1/timers/clock-out")
    assert r.status_code == 200
    assert "segundos" in r.json()

def test_dashboard():
    r = client.get("/api/v1/dashboard/")
    assert r.status_code == 200
    data = r.json()
    assert "turnos_disponibles" in data
    assert "credenciales_activas" in data

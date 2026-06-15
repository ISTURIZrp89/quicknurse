# QuickNurse Backend API

Backend FastAPI para QuickNurse - Micro-SaaS de evaluación de síntomas y gestión de guías médicas.

## Stack
- Python 3.14 + FastAPI
- SQLAlchemy + SQLite (persistencia sin dependencias externas)
- Telegram Bot API integrado
- Sin Redis, sin Docker, sin cloud

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/health` | Health check |
| POST | `/api/v1/symptoms/` | Analizar síntomas (triage español offline) |
| GET | `/api/v1/guides/` | Listar guías médicas |
| POST | `/api/v1/notifications/` | Enviar alerta Telegram |
| GET/POST | `/api/v1/turnos/` | CRUD turnos enfermería |
| PATCH | `/api/v1/turnos/{id}/aplicar` | Aplicar a turno |
| PATCH | `/api/v1/turnos/{id}/estado?estado=X` | Cambiar estado turno |
| GET/POST/DELETE | `/api/v1/credenciales/` | CRUD credenciales |
| GET/POST/DELETE | `/api/v1/notas/` | CRUD notas traspaso |
| GET/POST/DELETE | `/api/v1/planes_pae/` | CRUD planes PAE |

## Run

```bash
/usr/bin/python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Tests

```bash
/usr/bin/python3 -m pytest tests/ -v
```

## Estructura

```
app/
├── main.py          # App + lifespan
├── database.py      # SQLAlchemy engine
├── models.py        # Modelos ORM
├── api/             # Routers (symptoms, guides, notifications, turnos, credenciales, notas, planes_pae)
├── services/        # Lógica (triage, telegram)
└── guides/          # Guías markdown
```

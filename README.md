# QuickNurse 🩺

Micro-SAS de evaluación de síntomas y gestión clínica para profesionales de enfermería.

**Stack**: FastAPI + SQLite + Flutter Web + Ollama (IA local opcional)

---

## 🚀 Despliegue

### Opción A: Local (desarrollo)

```bash
# Backend
cd backend
pip install -r requirements.txt  # fastapi, uvicorn, sqlalchemy
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000

# Seed datos (farmacología + guías)
curl -X POST http://localhost:8000/api/v1/seed/

# Frontend (Flutter Web)
cd ../flutter
flutter build web
# El backend sirve automáticamente el build en http://localhost:8000
```

### Opción B: Vercel (serverless, SIN IA local)

La API puede desplegarse en Vercel como funciones serverless:

1. Fork/clona este repo
2. Conéctalo a Vercel
3. Configura en `vercel.json`:

```json
{
  "builds": [
    { "src": "backend/app/main.py", "use": "@vercel/python" }
  ],
  "routes": [
    { "src": "/api/(.*)", "dest": "backend/app/main.py" },
    { "src": "/(.*)", "dest": "flutter/build/web/$1" }
  ]
}
```

4. Variables de entorno en Vercel:
   - `ALLOWED_ORIGINS=*`
   - No es necesario `DATABASE_URL` (usa SQLite local efímera, recomendado: PostgreSQL en producción)

**⚠️ SQLite en Vercel**: Los datos son efímeros (se pierden al redeploy). Para producción, configura PostgreSQL (Vercel Postgres u otro).

**⚠️ IA Local**: La función de chat/triage con Ollama NO funciona en Vercel. Deshabilita llamadas LLM o usa OpenRouter como fallback cloud.

### Opción C: Docker (recomendado para producción con IA local)

```dockerfile
FROM python:3.12
WORKDIR /app
COPY backend/ .
RUN pip install -r requirements.txt
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```yaml
# docker-compose.yml
version: '3'
services:
  quicknurse:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./data:/app/quicknurse.db
  ollama:
    image: ollama/ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
```

---

## 🤖 IA Local (Ollama)

QuickNurse soporta modelos locales vía Ollama para:
- **Triage de síntomas** (`?llm=true`)
- **Sugerencias PAE** (NANDA-NIC-NOC)
- **Chat médico** (SymptomScreen + Chat IA)
- **RAG en guías clínicas** (`/api/v1/guides/rag`)

### Modelos recomendados:

| Modelo | Uso | Tamaño | RAM |
|--------|-----|--------|-----|
| **phi4-mini** (default) | Triage, PAE, Chat | ~3GB | 8GB |
| **medllama2** | Chat médico especializado | ~4GB | 8GB |
| **llama3.2:3b** | Chat general rápido | ~2GB | 4GB |
| **qwen2.5:7b** | Mejor calidad, respuestas detalladas | ~4.5GB | 8GB |

### Instalación para usuarios finales:

```bash
# 1. Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 2. Descargar modelo (phi4-mini liviano)
ollama pull phi4-mini:latest

# 3. Verificar
ollama run phi4-mini:latest "Hola, ¿cómo puedo ayudarte?"
```

### Configurar modelo en la app:

Editar `backend/app/services/llm_service.py` línea 8:
```python
MODELO_MEDICO = "phi4-mini:latest"  # Cambiar al modelo descargado
```

### Fallback a Cloud (OpenRouter)

Si no hay Ollama, el chat usa OpenRouter con modelos gratuitos (Gemini, Llama3, Phi4). Configurar en `.env`:
```
OPENROUTER_API_KEY=sk-or-v1-...
```

---

## 📱 Funcionalidades

| Módulo | Endpoint | Descripción |
|--------|----------|-------------|
| Dashboard | `/api/v1/dashboard/` | Resumen del día |
| Síntomas | `POST /api/v1/symptoms/` | Triage offline + LLM |
| Guías | `/api/v1/guides/` | 9 guías clínicas + búsqueda + RAG |
| PAE | `/api/v1/planes_pae/` | Planes enfermería con templates NANDA-NIC-NOC |
| Farmacología | `/api/v1/farmacologia/` | 209 medicamentos + compatibilidad IV |
| Calculadoras | `/api/v1/calculadoras/` | 12 fórmulas clínicas |
| Chat IA | `POST /api/v1/chat/` | Dual: Ollama local + OpenRouter cloud |
| Educación | `/api/v1/education/` | 6 materias, quizzes, flashcards |
| Cronómetro | `/api/v1/timers/` | Alertas RCP, FC, FR |
| Notas | `/api/v1/notas/` | Notas de guardia CRUD |
| Seed | `POST /api/v1/seed/` | Carga datos demo y farmacología |

---

## 📚 Estructura del proyecto

```
quicknurse/
├── backend/
│   ├── app/
│   │   ├── main.py           # FastAPI app + Flutter SPA servir
│   │   ├── models.py          # SQLAlchemy modelos
│   │   ├── database.py        # SQLite conexión
│   │   ├── config.py          # Pydantic Settings
│   │   ├── security.py        # JWT auth
│   │   ├── api/               # Routers
│   │   ├── services/          # Lógica: triage, llm, drug_data
│   │   ├── guides/            # Guías clínicas (markdown)
│   │   └── services/drug_data.py  # 209 medicamentos
│   └── requirements.txt
├── flutter/
│   ├── lib/
│   │   ├── main.dart          # 10-tab navegación responsive
│   │   ├── screens/           # 10 pantallas
│   │   └── services/
│   │       └── api_service.dart
│   └── build/web/             # Build Flutter Web
└── README.md
```

---

## 🔧 FAQ / Troubleshooting

**Q: ¿Necesito Ollama para usar la app?**
No. El triage offline funciona sin IA. Chat usa fallback cloud (OpenRouter). IA local es opcional para respuestas más rápidas y privadas.

**Q: ¿Cómo agrego mis propias guías clínicas?**
Usa `POST /api/v1/guides/upload` o copia archivos `.md`/`.txt` a `backend/app/guides/`.

**Q: Error "flutter build web --release" falla**
Solución: `flutter build web --no-wasm-dry-run` o quitar `const` de constructores en pantallas.

**Q: Error de doble prefijo en rutas**
Solución: El backend usa prefijos en `main.py`, no en los routers individuales. Verificar `app.include_router(r.router, prefix="...")`.

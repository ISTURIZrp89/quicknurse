# QuickNurse App (Flutter)

App Flutter para QuickNurse - Evaluación de síntomas, guías médicas y gestión clínica.

## Stack
- Flutter 3.44 / Dart 3.12
- Material 3 (tema teal)
- HTTP client para backend API

## Requisitos
- Backend QuickNurse corriendo en `localhost:8000`
- Android emulator o iOS simulator
- `flutter pub get`

## Run

```bash
cd /home/isturiz/quicknurse_app
flutter run
```

## Tests

```bash
flutter test
flutter analyze
```

## Estructura

```
lib/
├── main.dart              # App + HomeScreen + NavigationBar
├── models/
│   └── symptom_response.dart  # Modelo respuesta API síntomas
├── services/
│   └── api_service.dart   # HTTP client endpoints
└── screens/
    ├── symptom_screen.dart # Input síntomas + resultado
    └── guides_screen.dart  # Lista guías disponibles
```

## Notas
- Android emulator apunta a `10.0.2.2:8000` para localhost host
- iOS simulator usa `localhost:8000`
- Sin dependencias externas pesadas (solo `http` package)

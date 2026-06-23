import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;

@JS()
external JSPromise _jsInitWebLLM();

@JS()
external JSPromise _jsChatWebLLM(String messagesJson);

@JS()
external JSPromise _jsGetWebLLMStatus();

class WebLLMService {
  static bool _modelLoaded = false;
  static bool _initialized = false;
  static double _progress = 0;
  static String? _error;

  static bool get modelLoaded => _modelLoaded;
  static bool get initialized => _initialized;
  static double get progress => _progress;
  static String? get error => _error;
  static bool get isAvailable => kIsWeb;

  static Future<String> initModel() async {
    if (!kIsWeb) return 'web only';
    if (_modelLoaded) return 'ok';
    if (_initialized) return 'loading';

    _initialized = true;
    try {
      final jsResult = await _jsInitWebLLM().toDart;
      final result = jsResult?.dartify();
      final str = result?.toString() ?? 'error';
      if (str == 'ok') _modelLoaded = true;
      else _error = str;
      return str;
    } catch (e) {
      _error = e.toString();
      return 'error: $e';
    }
  }

  static Future<String> chat(String systemPrompt, String userMessage) async {
    if (!kIsWeb || !_modelLoaded) {
      return offlineFallback(userMessage);
    }

    final messages = jsonEncode([
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ]);

    try {
      final jsResult = await _jsChatWebLLM(messages).toDart;
      final str = jsResult?.dartify().toString() ?? '{}';
      final decoded = jsonDecode(str);
      if (decoded is Map && decoded['error'] != null) {
        return '⚠️ Modelo: ${decoded['error']}';
      }
      return (decoded is Map ? decoded['response'] : null) as String? ?? 'Sin respuesta';
    } catch (e) {
      return offlineFallback(userMessage);
    }
  }

  static Future<Map<String, dynamic>> getStatus() async {
    if (!kIsWeb) return {'loaded': false};
    try {
      final jsResult = await _jsGetWebLLMStatus().toDart;
      final str = jsResult?.dartify().toString() ?? '{}';
      final decoded = jsonDecode(str);
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return {'loaded': _modelLoaded};
    } catch (_) {
      return {'loaded': _modelLoaded, 'progress': _progress, 'error': _error};
    }
  }

  static String offlineFallback(String query) {
    final q = query.toLowerCase();
    if (q.contains('rcp') || q.contains('reanimacion') || q.contains('reanimación') || q.contains('paro')) {
      return '**RCP Básico:**\n1. Verificar seguridad\n2. Comprobar consciencia\n3. Llamar emergencias\n4. Iniciar compresiones (100-120/min, 5-6cm)\n5. Ventilaciones 30:2\n\n*Modo offline — respuesta básica. Conéctate al servidor para más precisión.*';
    }
    if (q.contains('fiebre') || q.contains('temperatura')) {
      return '**Manejo de fiebre:**\nParacetamol 500-1000mg c/6-8h\nIbuprofeno 400-600mg c/8h\nMedios físicos si >39°C\nMonitorizar cada 4h\n\n*Modo offline.*';
    }
    if (q.contains('dolor') || q.contains('analgesia') || q.contains('eva')) {
      return '**Escala EVA:**\nLeve (1-3): Paracetamol/AINEs\nModerado (4-6): Tramadol/Codeína\nSevero (7-10): Morfina/Fentanilo\n\n*Modo offline.*';
    }
    if (q.contains('presion') || q.contains('presión') || q.contains('tension') || q.contains('hipertension') || q.contains('hta')) {
      return '**Crisis hipertensiva:**\nPA >180/120: urgencia\nReposo, evaluar causas\nMedicación según protocolo\nMonitorizar cada 15min\n\n*Modo offline.*';
    }
    if (q.contains('heparina') || q.contains('anticoagulante')) {
      return '**Heparina:**\nHBPM: Enoxaparina 1mg/kg c/12h\nHNF: Bolo 60-80U/kg, infusión 12-18U/kg/h\nMonitorizar aPTT (1.5-2.5x control)\nAntídoto: Protamina\n\n*Modo offline.*';
    }
    if (q.contains('insulina') || q.contains('diabetes') || q.contains('glucemia')) {
      return '**Insulina rápida (Regular):**\nSC: 0.1-0.15 U/kg antes comidas\nIV: 0.05-0.1 U/kg/h en infusión\nMonitorizar glucemia c/1h\nRiesgo: hipoglucemia\n\n*Modo offline.*';
    }
    return '⚠️ Sin conexión al servidor y modelo offline no disponible.\n\n**Descarga el modelo Phi-3 desde Ajustes > IA offline** para respuestas sin internet.\n\nMientras, Farmacología, Guías y Educación siguen funcionando offline con datos locales.';
  }
}

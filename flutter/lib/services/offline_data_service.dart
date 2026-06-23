import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;

class OfflineDataService {
  static Map<String, dynamic>? _drugsCache;
  static Map<String, dynamic>? _educationCache;
  static Map<String, dynamic>? _educationDetailsCache;
  static Map<String, dynamic>? _guidesIndexCache;
  static Map<String, String>? _guidesCache;

  static bool get isWeb => kIsWeb;

  static Future<Map<String, dynamic>> loadDrugs() async {
    if (_drugsCache != null) return _drugsCache!;
    final raw = await rootBundle.loadString('assets/data/drugs.json');
    final data = json.decode(raw);
    _drugsCache = {'resultados': data, 'total': data is List ? data.length : 0};
    return _drugsCache!;
  }

  static Future<Map<String, dynamic>> loadEducation() async {
    if (_educationCache != null) return _educationCache!;
    final raw = await rootBundle.loadString('assets/data/education.json');
    _educationCache = {'materias': json.decode(raw)};
    return _educationCache!;
  }

  static Future<Map<String, dynamic>> loadEducationDetails() async {
    if (_educationDetailsCache != null) return _educationDetailsCache!;
    final raw = await rootBundle.loadString('assets/data/education_details.json');
    _educationDetailsCache = {'detalles': json.decode(raw)};
    return _educationDetailsCache!;
  }

  static Future<List<String>> loadGuideList() async {
    if (_guidesIndexCache != null) {
      return List<String>.from(_guidesIndexCache!['guides'] ?? []);
    }
    try {
      final raw = await rootBundle.loadString('assets/data/guides_index.json');
      _guidesIndexCache = json.decode(raw);
      return List<String>.from(_guidesIndexCache!['guides'] ?? []);
    } catch (_) {
      return [];
    }
  }

  static Future<String> loadGuide(String name) async {
    if (_guidesCache != null && _guidesCache!.containsKey(name)) {
      return _guidesCache![name]!;
    }
    try {
      final raw = await rootBundle.loadString('assets/data/guides/$name');
      _guidesCache ??= {};
      _guidesCache![name] = raw;
      return raw;
    } catch (e) {
      return '# Guía no disponible offline\n\nEl contenido de *$name* no está disponible sin conexión.';
    }
  }

  static void clearCache() {
    _drugsCache = null;
    _educationCache = null;
    _educationDetailsCache = null;
    _guidesIndexCache = null;
    _guidesCache = null;
  }
}

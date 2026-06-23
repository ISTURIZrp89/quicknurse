import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/symptom_response.dart';

class ApiService {
  static String get _baseUrl {
    if (kIsWeb) {
      return '/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }
  static String get baseUrl => _baseUrl;

  static Future<SymptomResponse> analyzeSymptoms(String symptoms, {bool llm = false, int? age, String? sex}) async {
    final url = Uri.parse('$_baseUrl/symptoms/?llm=$llm');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'symptoms': symptoms, 'age': age, 'sex': sex}),
    );
    if (response.statusCode == 200) {
      return SymptomResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<String>> getGuides() async {
    final url = Uri.parse('$_baseUrl/guides/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map;
      return List<String>.from(data['guides']);
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<String> getGuideContent(String name) async {
    final url = Uri.parse('$_baseUrl/guides/$name');
    final response = await http.get(url);
    if (response.statusCode == 200) return response.body;
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getNotas() async {
    final url = Uri.parse('$_baseUrl/notas/');
    final response = await http.get(url);
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<void> crearNota(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/notas/');
    await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
  }

  static Future<void> eliminarNota(int id) async {
    final url = Uri.parse('$_baseUrl/notas/$id');
    await http.delete(url);
  }

  static Future<List<Map<String, dynamic>>> getPlanesPae() async {
    final url = Uri.parse('$_baseUrl/planes_pae/');
    final response = await http.get(url);
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<void> crearPlanPae(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/planes_pae/');
    await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
  }

  static Future<void> eliminarPlanPae(int id) async {
    final url = Uri.parse('$_baseUrl/planes_pae/$id');
    await http.delete(url);
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final url = Uri.parse('$_baseUrl/dashboard/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getTimer() async {
    final url = Uri.parse('$_baseUrl/timers/');
    final response = await http.get(url);
    if (response.statusCode == 200) return Map<String, dynamic>.from(jsonDecode(response.body));
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> enviarMensajeChat(String mensaje, {String? modelo, bool useRag = false, bool useWeb = false}) async {
    final url = Uri.parse('$_baseUrl/chat/');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mensaje': mensaje,
        'modelo': modelo ?? 'phi4-mini',
        'use_rag': useRag,
        'use_web': useWeb,
      }),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) return body;
      return {'respuesta': body.toString(), 'fuentes': []};
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // ─── Conversaciones ──────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getConversaciones() async {
    final url = Uri.parse('$_baseUrl/chat/conversaciones');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<void> guardarConversacion(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/chat/conversaciones');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  static Future<void> eliminarConversacion(int id) async {
    final url = Uri.parse('$_baseUrl/chat/conversaciones/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  // ─── Calculadoras ──────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getCalculadoras() async {
    final url = Uri.parse('$_baseUrl/calculadoras/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // ─── Farmacología ──────────────────────────────────────────────
  static Future<List<String>> getFarmacologiaCategorias() async {
    final url = Uri.parse('$_baseUrl/farmacologia/categorias');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['categorias']);
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getFarmacologia({String? categoria, int page = 1, int perPage = 20}) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (categoria != null && categoria.isNotEmpty) params['categoria'] = categoria;
    final url = Uri.parse('$_baseUrl/farmacologia/').replace(queryParameters: params);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return {'resultados': decoded, 'total': decoded.length, 'page': 1, 'per_page': decoded.length, 'total_pages': 1};
      }
      return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> buscarFarmacologia(String query, {int page = 1, int perPage = 50}) async {
    final params = <String, String>{
      'q': query,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    final url = Uri.parse('$_baseUrl/farmacologia/buscar').replace(queryParameters: params);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return {'resultados': decoded, 'total': decoded.length, 'page': 1, 'per_page': decoded.length, 'total_pages': 1};
      }
      return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getCompatibilidadIV(String fA, String fB) async {
    final url = Uri.parse('$_baseUrl/farmacologia/compatibilidad-iv?farmaco_a=${Uri.encodeComponent(fA)}&farmaco_b=${Uri.encodeComponent(fB)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return [Map<String, dynamic>.from(jsonDecode(response.body))];
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // ─── Educación ─────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getEducationSubjects() async {
    final url = Uri.parse('$_baseUrl/education/subjects');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['materias'] is List) {
        return List<Map<String, dynamic>>.from(body['materias'] as List);
      }
      if (body is List) {
        return List<Map<String, dynamic>>.from(body);
      }
      return [];
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getEducationQuizzes(String subject) async {
    final url = Uri.parse('$_baseUrl/education/quizzes?materia=${Uri.encodeComponent(subject)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['quizzes'] is List) {
        return List<Map<String, dynamic>>.from(body['quizzes'] as List);
      }
      return [];
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getEducationFlashcards(String subject) async {
    final url = Uri.parse('$_baseUrl/education/flashcards?materia=${Uri.encodeComponent(subject)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['flashcards'] is List) {
        return List<Map<String, dynamic>>.from(body['flashcards'] as List);
      }
      return [];
    }
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getFactOfDay() async {
    final url = Uri.parse('$_baseUrl/education/fact-of-day');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final dato = body['dato_curioso'];
        if (dato is Map<String, dynamic>) return dato;
        return body;
      }
      return {};
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // ─── Pacientes ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/patients');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Error: ${response.body}');
  }

  static Future<List<dynamic>> listPatients({bool activeOnly = true}) async {
    final url = Uri.parse('$_baseUrl/patients?active_only=$activeOnly');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getPatient(int id) async {
    final url = Uri.parse('$_baseUrl/patients/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<List<dynamic>> searchPatients(String query) async {
    final url = Uri.parse('$_baseUrl/patients/search?q=${Uri.encodeComponent(query)}');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  // ─── Signos Vitales ─────────────────────────────────────────
  static Future<Map<String, dynamic>> addVitalSigns(int patientId, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/patients/$patientId/vitals');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Error: ${response.body}');
  }

  static Future<List<dynamic>> getVitalsHistory(int patientId, {int days = 30}) async {
    final url = Uri.parse('$_baseUrl/patients/$patientId/vitals?days=$days');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  // ─── Episodios ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> createEpisode(int patientId, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/episodes/patients/$patientId');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Error: ${response.body}');
  }

  static Future<List<dynamic>> listEpisodes(int patientId) async {
    final url = Uri.parse('$_baseUrl/episodes/patients/$patientId');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  // ─── Prescripciones ─────────────────────────────────────────
  static Future<List<dynamic>> listPrescriptions(int patientId) async {
    final url = Uri.parse('$_baseUrl/patients/$patientId/prescriptions');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> createPrescription(int patientId, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/patients/$patientId/prescriptions');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Error: ${response.body}');
  }

  // ─── Notas Clínicas ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createNote(int episodeId, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/episodes/$episodeId/notes');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception('Error: ${response.body}');
  }

  static Future<List<dynamic>> listNotes(int episodeId) async {
    final url = Uri.parse('$_baseUrl/episodes/$episodeId/notes');
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error: ${response.statusCode}');
  }

  // ─── Guías ───────────────────────────────────────────────────
  static Future<void> uploadGuide(String filename, String content) async {
    final url = Uri.parse('$_baseUrl/guides/upload');
    final request = http.MultipartRequest('POST', url);
    request.fields['overwrite'] = 'true';
    request.files.add(http.MultipartFile.fromString(
      'file',
      content,
      filename: filename,
    ));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Error al subir guía: ${response.statusCode}');
    }
  }
}

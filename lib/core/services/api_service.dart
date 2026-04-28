import 'dart:convert';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// URL base del backend según la plataforma:
/// - Web / Chrome      → http://localhost:5000
/// - Emulador Android  → http://10.0.2.2:5000
/// - Simulador iOS     → http://localhost:5000
/// - Dispositivo real  → cambiar por la IP local de tu PC
String get kBaseUrl {
  if (kIsWeb) {
    // Usa el mismo host desde donde se abrió la app web.
    // Así funciona tanto en localhost como desde otro dispositivo en la red.
    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
    return 'http://$host:5000';
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5000'; // emulador → PC
  }
  return 'http://localhost:5000'; // iOS simulator
}

const String _tokenKey = 'auth_token';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  // ─── Token ────────────────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ─── Headers ──────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── Respuesta ────────────────────────────────────────────────────────────

  static dynamic _parse(http.Response res) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      if (res.statusCode >= 200 && res.statusCode < 300) return {};
      throw ApiException(res.statusCode, 'Error ${res.statusCode}');
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body['data'] ?? body;
    }
    final msg = body['message'] ?? body['error'] ?? 'Error ${res.statusCode}';
    throw ApiException(res.statusCode, msg.toString());
  }

  static const _timeout = Duration(seconds: 15);

  // ─── GET ──────────────────────────────────────────────────────────────────

  static Future<dynamic> get(String path, {bool auth = true}) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(auth: auth),
    ).timeout(_timeout);
    return _parse(res);
  }

  // ─── POST ─────────────────────────────────────────────────────────────────

  static Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    ).timeout(_timeout);
    return _parse(res);
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────

  static Future<dynamic> put(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    ).timeout(_timeout);
    return _parse(res);
  }

  // ─── UPLOAD (multipart) ──────────────────────────────────────────────────

  static Future<String?> uploadFile(String path, List<int> bytes,
      String filename, {bool auth = true}) async {
    final uri = Uri.parse('$kBaseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    if (auth) {
      final token = await getToken();
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
    }
    final ext = filename.split('.').last.toLowerCase();
    final mime = const {
      'jpg': 'image/jpeg', 'jpeg': 'image/jpeg',
      'png': 'image/png',  'webp': 'image/webp',
    }[ext] ?? 'image/jpeg';
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: MediaType.parse(mime),
    ));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final parsed = _parse(res);
    return (parsed['url'] ?? parsed['data']?['url'])?.toString();
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  static Future<dynamic> delete(String path, {bool auth = true}) async {
    final res = await http.delete(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(auth: auth),
    ).timeout(_timeout);
    return _parse(res);
  }
}

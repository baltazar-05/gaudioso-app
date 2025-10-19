// lib/services/api_service.dart
//
// HTTP helper that centralizes base URL, headers, and JSON helpers.

import 'dart:convert';

import 'package:gaudioso_app/core/api_config.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Reads API_BASE from --dart-define; defaults to http://10.0.2.2:8080 for Android emulators.
  static final String baseUrl = ApiConfig.baseUrl;

  static Map<String, String> _headers({Map<String, String>? extra}) {
    final base = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer <token>', // plug auth here when needed
    };
    if (extra != null) base.addAll(extra);
    return base;
  }

  static Future<dynamic> getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.get(uri, headers: _headers());
    _check(resp);
    return json.decode(utf8.decode(resp.bodyBytes));
  }

  static Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.post(uri, headers: _headers(), body: json.encode(body));
    _check(resp);
    return json.decode(utf8.decode(resp.bodyBytes));
  }

  static Future<dynamic> putJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.put(uri, headers: _headers(), body: json.encode(body));
    _check(resp);
    return json.decode(utf8.decode(resp.bodyBytes));
  }

  static Future<void> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.delete(uri, headers: _headers());
    _check(resp);
  }

  static void _check(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }
}

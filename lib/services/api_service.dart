// lib/services/api_service.dart
//
// HTTP helper that centralizes base URL, headers, JSON helpers, token usage and timeouts.

import 'dart:convert';
import 'dart:typed_data';

import 'package:gaudioso_app/core/api_config.dart';
import 'package:gaudioso_app/services/auth/session_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static final String baseUrl = ApiConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 60);
  static final SessionStorage _session = SessionStorage();

  static Uri _uri(String path, [Map<String, String>? query]) {
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  static Future<Map<String, String>> _headers({
    Map<String, String>? extra,
    bool includeJsonContentType = true,
    String? accept,
  }) async {
    final base = <String, String>{};
    if (includeJsonContentType) {
      base['Content-Type'] = 'application/json; charset=utf-8';
    }
    base['Accept'] = accept ?? 'application/json';

    final user = await _session.currentUser();
    final token = user?['token'];
    if (token is String && token.isNotEmpty) {
      base['Authorization'] = 'Bearer $token';
    }
    if (extra != null) base.addAll(extra);
    return base;
  }

  static Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final uri = _uri(path, query);
    final resp = await http.get(uri, headers: await _headers()).timeout(_timeout);
    _check(resp, uri);
    return json.decode(utf8.decode(resp.bodyBytes));
  }

  static Future<dynamic> postJson(String path, Map<String, dynamic> body,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query);
    final resp = await http
        .post(uri, headers: await _headers(), body: json.encode(body))
        .timeout(_timeout);
    _check(resp, uri);
    return json.decode(utf8.decode(resp.bodyBytes));
  }

  static Future<dynamic> putJson(String path, Map<String, dynamic> body,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query);
    final resp = await http
        .put(uri, headers: await _headers(), body: json.encode(body))
        .timeout(_timeout);
    _check(resp, uri);
    return json.decode(utf8.decode(resp.bodyBytes));
  }

  static Future<void> delete(String path, {Map<String, String>? query}) async {
    final uri = _uri(path, query);
    final resp = await http.delete(uri, headers: await _headers()).timeout(_timeout);
    _check(resp, uri);
  }

  static Future<Uint8List> getBytes(
    String path, {
    Map<String, String>? query,
    String accept = 'application/octet-stream',
  }) async {
    final uri = _uri(path, query);
    final resp = await http
        .get(uri, headers: await _headers(includeJsonContentType: false, accept: accept))
        .timeout(_timeout);
    _check(resp, uri, expectedContentType: accept);
    return resp.bodyBytes;
  }

  static Future<dynamic> uploadFile(String path, String filePath,
      {String fieldName = 'file', MediaType? contentType}) async {
    final uri = _uri(path);
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(await _headers(includeJsonContentType: false));
    req.files.add(await http.MultipartFile.fromPath(fieldName, filePath, contentType: contentType));
    final resp = await req.send().timeout(_timeout);
    final body = await resp.stream.bytesToString();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode} @ ${uri.path}: $body');
    }
    return json.decode(body);
  }

  static Future<Uint8List> getBytesAbsolute(String url) async {
    final headers = await _headers(includeJsonContentType: false);
    final resp = await http.get(Uri.parse(url), headers: headers).timeout(_timeout);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode} @ $url');
    }
    return resp.bodyBytes;
  }

  static void _check(http.Response r, Uri uri, {String? expectedContentType}) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode} @ ${uri.path}: ${r.body}');
    }
    if (expectedContentType != null) {
      final ct = r.headers['content-type'];
      if (ct != null && !ct.toLowerCase().contains(expectedContentType.toLowerCase())) {
        throw Exception('Conteudo inesperado (${ct}) para ${uri.path}');
      }
    }
  }
}

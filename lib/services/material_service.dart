import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:gaudioso_app/core/api_config.dart';
import '../models/material.dart';

class MaterialService {
  static final baseUrl = ApiConfig.endpoint('/api/materiais');
  // Use --dart-define=API_BASE to override the base URL when deploying remotely.
  // 👉 se rodar no celular físico, troque para seu IP local (ex: http://192.168.0.10:8080/api/materiais)

  Future<List<MaterialItem>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => MaterialItem.fromJson(e)).toList();
    }
    throw Exception("Erro ao listar materiais: ${res.statusCode}");
  }

  Future<void> adicionar(MaterialItem m) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(m.toJson()),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Erro ao adicionar material: ${res.statusCode}");
    }
  }

  Future<void> atualizar(MaterialItem m) async {
    final res = await http.put(
      Uri.parse("$baseUrl/${m.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(m.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception("Erro ao atualizar material: ${res.statusCode}");
    }
  }

  Future<void> excluir(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception("Erro ao excluir material: ${res.statusCode}");
    }
  }
}

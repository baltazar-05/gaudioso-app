import 'dart:convert';
import 'dart:developer' show log;
import 'package:http/http.dart' as http;

import 'package:gaudioso_app/core/api_config.dart';
import '../models/cliente.dart';

class ClienteService {
  static final baseUrl = ApiConfig.endpoint('/api/clientes');
  // Use --dart-define=API_BASE to override the base URL when deploying remotely.
  // 👉 se for celular físico, use o IP da sua máquina (ex: http://192.168.0.10:8080/api/clientes)

  Future<List<Cliente>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    log("Resposta clientes: ${res.statusCode} - ${res.body}"); // debug

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Cliente.fromJson(e)).toList();
    }
    throw Exception("Erro ao listar clientes: ${res.statusCode}");
  }

  Future<void> adicionar(Cliente c) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(c.toJson()),
    );
    log("Adicionar cliente: ${res.statusCode} - ${res.body}"); // debug

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Erro ao adicionar cliente");
    }
  }

  Future<void> atualizar(Cliente c) async {
    final res = await http.put(
      Uri.parse("$baseUrl/${c.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(c.toJson()),
    );
    log("Atualizar cliente: ${res.statusCode} - ${res.body}"); // debug

    if (res.statusCode != 200) {
      throw Exception("Erro ao atualizar cliente");
    }
  }

  Future<void> excluir(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    log("Excluir cliente: ${res.statusCode}"); // debug

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception("Erro ao excluir cliente");
    }
  }
}

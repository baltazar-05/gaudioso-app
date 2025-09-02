import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente.dart';

class ClienteService {
  static const baseUrl = "http://10.0.2.2:8080/api/clientes";
  // 👉 se for celular físico, use o IP da sua máquina (ex: http://192.168.0.10:8080/api/clientes)

  Future<List<Cliente>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    print("Resposta clientes: ${res.statusCode} - ${res.body}"); // debug

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
    print("Adicionar cliente: ${res.statusCode} - ${res.body}"); // debug

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
    print("Atualizar cliente: ${res.statusCode} - ${res.body}"); // debug

    if (res.statusCode != 200) {
      throw Exception("Erro ao atualizar cliente");
    }
  }

  Future<void> excluir(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    print("Excluir cliente: ${res.statusCode}"); // debug

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception("Erro ao excluir cliente");
    }
  }
}

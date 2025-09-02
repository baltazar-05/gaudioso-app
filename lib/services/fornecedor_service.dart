import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fornecedor.dart';

class FornecedorService {
  static const baseUrl = "http://10.0.2.2:8080/api/fornecedores";
  // se for em celular físico, use o IP local ex: http://192.168.0.10:8080/api/fornecedores

  Future<List<Fornecedor>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Fornecedor.fromJson(e)).toList();
    }
    throw Exception("Erro ao listar fornecedores: ${res.statusCode}");
  }

  Future<void> adicionar(Fornecedor f) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(f.toJson()),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Erro ao adicionar fornecedor");
    }
  }

  Future<void> atualizar(Fornecedor f) async {
    final res = await http.put(
      Uri.parse("$baseUrl/${f.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(f.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception("Erro ao atualizar fornecedor");
    }
  }

  Future<void> excluir(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception("Erro ao excluir fornecedor");
    }
  }
}

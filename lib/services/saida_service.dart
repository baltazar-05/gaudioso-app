import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saida.dart';

class SaidaService {
  static const baseUrl = "http://10.0.2.2:8080/api/saidas";
  // em celular físico: troque pelo IP da sua máquina

  Future<List<Saida>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Saida.fromJson(e)).toList();
    }
    throw Exception("Erro ao listar saídas: ${res.statusCode}");
  }

  Future<void> adicionar(Saida s) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(s.toJson()),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Erro ao adicionar saída");
    }
  }

  Future<void> atualizar(Saida s) async {
    final res = await http.put(
      Uri.parse("$baseUrl/${s.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(s.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception("Erro ao atualizar saída");
    }
  }

  Future<void> excluir(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception("Erro ao excluir saída");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entrada.dart';

class EntradaService {
  static const baseUrl = "http://10.0.2.2:8080/api/entradas";

  Future<List<Entrada>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Entrada.fromJson(e)).toList();
    }
    throw Exception("Erro ao listar entradas: ${res.statusCode}");
  }

  Future<void> adicionar(Entrada e) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(e.toJson()),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("Erro ao adicionar entrada");
    }
  }

  Future<void> atualizar(Entrada e) async {
    final res = await http.put(
      Uri.parse("$baseUrl/${e.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(e.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception("Erro ao atualizar entrada");
    }
  }

  Future<void> excluir(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception("Erro ao excluir entrada");
    }
  }
}

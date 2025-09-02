import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estoque.dart';

class EstoqueService {
  static const baseUrl = "http://10.0.2.2:8080/api/estoque";
  // 👉 Em celular físico, troque pelo IP da sua máquina

  Future<List<Estoque>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Estoque.fromJson(e)).toList();
    }
    throw Exception("Erro ao buscar estoque: ${res.statusCode}");
  }
}

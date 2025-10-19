import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:gaudioso_app/core/api_config.dart';
import '../models/estoque.dart';

class EstoqueService {
  static final baseUrl = ApiConfig.endpoint('/api/estoque');
  // Use --dart-define=API_BASE to override the base URL when deploying remotely.
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

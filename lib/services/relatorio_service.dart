import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/relatorio.dart';

class RelatorioService {
  static const baseUrl = "http://10.0.2.2:8080/api/relatorios";
  // 👉 em celular físico, use o IP da máquina

  Future<List<Relatorio>> gerar(String dataInicio, String dataFim) async {
    final uri = Uri.parse("$baseUrl?dataInicio=$dataInicio&dataFim=$dataFim");
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Relatorio.fromJson(e)).toList();
    }
    throw Exception("Erro ao gerar relatório: ${res.statusCode}");
  }
}

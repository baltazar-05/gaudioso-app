import 'dart:convert';
import 'dart:typed_data';

import 'package:gaudioso_app/core/api_config.dart';
import 'package:http/http.dart' as http;

import '../models/relatorio.dart';
import '../models/lucro_real_data.dart';
import '../models/lucro_esperado_data.dart';
import '../models/movimentacao_data.dart';

class RelatorioService {
  static final baseUrl = ApiConfig.endpoint('/api/relatorios');
  // Use --dart-define=API_BASE to override the base URL when deploying remotamente.
  // Em celular físico, use o IP da máquina.

  Future<List<Relatorio>> gerar(String dataInicio, String dataFim) async {
    final uri = Uri.parse('$baseUrl?dataInicio=$dataInicio&dataFim=$dataFim');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Relatorio.fromJson(e)).toList();
    }
    throw Exception('Erro ao gerar relatório: ${res.statusCode}');
  }

  Future<Uint8List> gerarPdf(String dataInicio, String dataFim, {String? usuario}) async {
    final query = <String, String>{
      'dataInicio': dataInicio,
      'dataFim': dataFim,
    };
    final usuarioVal = usuario?.trim();
    if (usuarioVal != null && usuarioVal.isNotEmpty) {
      query['usuario'] = usuarioVal;
    }
    final uri = Uri.parse('$baseUrl/lucro/pdf').replace(queryParameters: query);

    final res = await http.get(
      uri,
      headers: const {'Accept': 'application/pdf'},
    );

    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
    throw Exception('Erro ao gerar PDF (${res.statusCode})');
  }

  Future<Uint8List> gerarMovimentacaoPdf(String dataInicio, String dataFim) async {
    final uri = Uri.parse('$baseUrl/movimentacao/pdf').replace(
      queryParameters: {
        'dataInicio': dataInicio,
        'dataFim': dataFim,
      },
    );
    final res = await http.get(
      uri,
      headers: const {'Accept': 'application/pdf'},
    );
    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
    throw Exception('Erro ao gerar PDF (${res.statusCode})');
  }

  Future<Uint8List> gerarLucroEsperadoPdf({String? usuario, String? dataInicio, String? dataFim}) async {
    final query = <String, String>{
      if (dataInicio != null && dataInicio.isNotEmpty) 'dataInicio': dataInicio,
      if (dataFim != null && dataFim.isNotEmpty) 'dataFim': dataFim,
    };
    final usuarioVal = usuario?.trim();
    if (usuarioVal != null && usuarioVal.isNotEmpty) {
      query['usuario'] = usuarioVal;
    }
    final uri = Uri.parse('$baseUrl/lucro-esperado/pdf').replace(queryParameters: query);
    final res = await http.get(
      uri,
      headers: const {'Accept': 'application/pdf'},
    );

    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
    throw Exception('Erro ao gerar PDF (${res.statusCode})');
  }

  Future<LucroRealData> buscarLucroRealResumo(String dataInicio, String dataFim) async {
    final uri = Uri.parse('$baseUrl/lucro').replace(
      queryParameters: {
        if (dataInicio.isNotEmpty) 'dataInicio': dataInicio,
        if (dataFim.isNotEmpty) 'dataFim': dataFim,
      },
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return LucroRealData.fromJson(data);
    }
    throw Exception('Erro ao carregar resumo de lucro (${res.statusCode})');
  }

  Future<LucroEsperadoData> buscarLucroEsperadoResumo({String? usuario}) async {
    final query = <String, String>{};
    final usuarioVal = usuario?.trim();
    if (usuarioVal != null && usuarioVal.isNotEmpty) {
      query['usuario'] = usuarioVal;
    }
    final uri = Uri.parse('$baseUrl/lucro-esperado').replace(queryParameters: query);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return LucroEsperadoData.fromJson(data);
    }
    throw Exception('Erro ao carregar lucro esperado (${res.statusCode})');
  }

  Future<MovimentacaoData> buscarMovimentacao(
      {String? dataInicio, String? dataFim}) async {
    final query = <String, String>{};
    if (dataInicio != null && dataInicio.isNotEmpty) {
      query['dataInicio'] = dataInicio;
    }
    if (dataFim != null && dataFim.isNotEmpty) {
      query['dataFim'] = dataFim;
    }
    final uri =
        Uri.parse('$baseUrl/movimentacao').replace(queryParameters: query);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return MovimentacaoData.fromJson(data);
    }
    throw Exception('Erro ao carregar movimentação (${res.statusCode})');
  }
}

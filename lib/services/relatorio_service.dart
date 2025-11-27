import 'dart:typed_data';

import 'package:gaudioso_app/services/api_service.dart';

import '../models/relatorio.dart';
import '../models/lucro_real_data.dart';
import '../models/lucro_esperado_data.dart';
import '../models/movimentacao_data.dart';

class RelatorioService {
  static const _path = '/api/relatorios';

  Future<List<Relatorio>> gerar(String dataInicio, String dataFim) async {
    final query = _query({
      'dataInicio': dataInicio,
      'dataFim': dataFim,
    });
    final data = await ApiService.getJson(_path, query: query);
    if (data is List) {
      return data.map((e) => Relatorio.fromJson(e)).toList();
    }
    throw Exception('Resposta inesperada ao gerar relatorio');
  }

  Future<Uint8List> gerarPdf(String dataInicio, String dataFim, {String? usuario}) {
    final query = _query({
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'usuario': usuario,
    });
    return ApiService.getBytes('$_path/lucro/pdf', query: query, accept: 'application/pdf');
  }

  Future<Uint8List> gerarMovimentacaoPdf(String dataInicio, String dataFim) {
    final query = _query({'dataInicio': dataInicio, 'dataFim': dataFim});
    return ApiService.getBytes('$_path/movimentacao/pdf', query: query, accept: 'application/pdf');
  }

  Future<Uint8List> gerarLucroEsperadoPdf({String? usuario, String? dataInicio, String? dataFim}) {
    final query = _query({
      'usuario': usuario,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
    });
    return ApiService.getBytes('$_path/lucro-esperado/pdf', query: query, accept: 'application/pdf');
  }

  Future<LucroRealData> buscarLucroRealResumo(String dataInicio, String dataFim) async {
    final query = _query({
      'dataInicio': dataInicio,
      'dataFim': dataFim,
    });
    final data = await ApiService.getJson('$_path/lucro', query: query);
    if (data is Map<String, dynamic>) {
      return LucroRealData.fromJson(data);
    }
    throw Exception('Formato inesperado no resumo de lucro real');
  }

  Future<LucroEsperadoData> buscarLucroEsperadoResumo({String? usuario}) async {
    final query = _query({'usuario': usuario});
    final data = await ApiService.getJson('$_path/lucro-esperado', query: query);
    if (data is Map<String, dynamic>) {
      return LucroEsperadoData.fromJson(data);
    }
    throw Exception('Formato inesperado no lucro esperado');
  }

  Future<MovimentacaoData> buscarMovimentacao({String? dataInicio, String? dataFim}) async {
    final query = _query({
      'dataInicio': dataInicio,
      'dataFim': dataFim,
    });
    final data = await ApiService.getJson('$_path/movimentacao', query: query);
    if (data is Map<String, dynamic>) {
      return MovimentacaoData.fromJson(data);
    }
    throw Exception('Formato inesperado no resumo de movimentacao');
  }

  Map<String, String> _query(Map<String, String?> raw) {
    final q = <String, String>{};
    raw.forEach((key, value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty) q[key] = v;
    });
    return q;
  }
}

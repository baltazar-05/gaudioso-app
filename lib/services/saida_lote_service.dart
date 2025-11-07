import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:gaudioso_app/core/api_config.dart';
import '../models/lote_saida_resumo.dart';
import '../models/saida.dart';
import 'saida_service.dart';

class SaidaLoteService {
  static final _base = ApiConfig.endpoint('/api/saidas/lotes');

  Future<List<LoteSaidaResumo>> listar({DateTime? dia, DateTime? ini, DateTime? fim}) async {
    final params = <String, String>{};
    if (dia != null) {
      final y = dia.year.toString().padLeft(4, '0');
      final m = dia.month.toString().padLeft(2, '0');
      final d = dia.day.toString().padLeft(2, '0');
      params['dia'] = '$y-$m-$d';
    } else if (ini != null && fim != null) {
      // Normaliza para inicio do dia e fim do dia (inclusive)
      final i = DateTime(ini.year, ini.month, ini.day, 0, 0, 0);
      final f = DateTime(fim.year, fim.month, fim.day, 23, 59, 59, 999);
      params['ini'] = i.toIso8601String();
      params['fim'] = f.toIso8601String();
    }
    final url = params.isEmpty
        ? _base
        : '$_base?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => LoteSaidaResumo.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Erro ao listar lotes: HTTP ${res.statusCode} - ${res.body}');
  }

  Future<List<Saida>> itensDoLote(String numeroLote) async {
    // Endpoint preferencial
    var url = '$_base/${Uri.encodeComponent(numeroLote)}';
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Saida.fromJson(e)).toList();
    }
    // Fallback compatível
    url = ApiConfig.endpoint('/api/saidas?lote=${Uri.encodeQueryComponent(numeroLote)}');
    res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Saida.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar itens do lote: HTTP ${res.statusCode} - ${res.body}');
  }

  Future<void> renomear(String numeroAntigo, String numeroNovo) async {
    final url = '$_base/${Uri.encodeComponent(numeroAntigo)}';
    final res = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"novoNumeroLote": numeroNovo}),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Erro ao renomear lote: HTTP ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> excluir(String numeroLote) async {
    final url = '$_base/${Uri.encodeComponent(numeroLote)}';
    final res = await http.delete(Uri.parse(url));
    if (res.statusCode == 200 || res.statusCode == 204) return;
    // Fallback: excluir item a item quando o endpoint do lote falhar
    try {
      final itens = await itensDoLote(numeroLote);
      final saidaService = SaidaService();
      for (final s in itens) {
        if (s.id != null) {
          await saidaService.excluir(s.id!);
        }
      }
    } catch (e) {
      throw Exception('Erro ao excluir lote (fallback itens): $e | HTTP ${res.statusCode} - ${res.body}');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:gaudioso_app/core/api_config.dart';
import '../models/lote_entrada_resumo.dart';
import '../models/entrada.dart';
import 'entrada_service.dart';

class EntradaLoteService {
  static final _base = ApiConfig.endpoint('/api/entradas/lotes');

  Future<List<LoteEntradaResumo>> listar({DateTime? dia, DateTime? ini, DateTime? fim}) async {
    final params = <String, String>{};
    if (dia != null) {
      final y = dia.year.toString().padLeft(4, '0');
      final m = dia.month.toString().padLeft(2, '0');
      final d = dia.day.toString().padLeft(2, '0');
      params['dia'] = '$y-$m-$d';
    } else if (ini != null && fim != null) {
      final i = DateTime(ini.year, ini.month, ini.day, 0, 0, 0);
      final f = DateTime(fim.year, fim.month, fim.day, 23, 59, 59, 999);
      params['ini'] = i.toIso8601String();
      params['fim'] = f.toIso8601String();
    }
    final url = params.isEmpty
        ? _base
        : '$_base?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data.map((e) => LoteEntradaResumo.fromJson(e as Map<String, dynamic>)).toList();
      }
      // Fallback para agregar localmente quando o endpoint ainda não existe/está com erro
      return _listarFallback(dia: dia, ini: ini, fim: fim);
    } catch (_) {
      // Fallback em caso de exceção de rede
      return _listarFallback(dia: dia, ini: ini, fim: fim);
    }
  }

  Future<List<Entrada>> itensDoLote(String numeroLote) async {
    var url = '$_base/${Uri.encodeComponent(numeroLote)}';
    try {
      var res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data.map((e) => Entrada.fromJson(e)).toList();
      }
      url = ApiConfig.endpoint('/api/entradas?lote=${Uri.encodeQueryComponent(numeroLote)}');
      res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data.map((e) => Entrada.fromJson(e)).toList();
      }
    } catch (_) {
      // cai no fallback local
    }
    // Fallback local: lista todas as entradas e filtra pelo lote
    final todas = await EntradaService().listar();
    return todas.where((e) => (e.numeroLote ?? '').trim() == numeroLote).toList();
  }

  Future<void> renomear(String numeroAntigo, String numeroNovo) async {
    final url = '$_base/${Uri.encodeComponent(numeroAntigo)}';
    final res = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"novoNumeroLote": numeroNovo}),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Erro ao renomear lote (entradas): HTTP ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> excluir(String numeroLote) async {
    final url = '$_base/${Uri.encodeComponent(numeroLote)}';
    final res = await http.delete(Uri.parse(url));
    if (res.statusCode == 200 || res.statusCode == 204) return;
    // Fallback: excluir item a item
    try {
      final itens = await itensDoLote(numeroLote);
      final entradaService = EntradaService();
      for (final e in itens) {
        if (e.id != null) {
          await entradaService.excluir(e.id!);
        }
      }
    } catch (e) {
      throw Exception('Erro ao excluir lote (fallback itens - entradas): $e | HTTP ${res.statusCode} - ${res.body}');
    }
  }

  // -------------------- Helpers (fallback local) --------------------
  Future<List<LoteEntradaResumo>> _listarFallback({DateTime? dia, DateTime? ini, DateTime? fim}) async {
    final entradas = await EntradaService().listar();
    DateTime? parse(String s) {
      final t = s.trim();
      if (t.isEmpty) return null;
      return DateTime.tryParse(t) ?? DateTime.tryParse(t.replaceAll(' ', 'T'));
    }
    bool inRange(DateTime? d) {
      if (d == null) return false;
      if (dia != null) {
        final i = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
        final f = DateTime(dia.year, dia.month, dia.day, 23, 59, 59, 999);
        return !d.isBefore(i) && !d.isAfter(f);
      } else if (ini != null && fim != null) {
        final i = DateTime(ini.year, ini.month, ini.day, 0, 0, 0);
        final f = DateTime(fim.year, fim.month, fim.day, 23, 59, 59, 999);
        return !d.isBefore(i) && !d.isAfter(f);
      }
      return true; // sem filtro
    }

    final groups = <String, List<Entrada>>{};
    for (final e in entradas) {
      final lote = (e.numeroLote ?? '').trim();
      if (lote.isEmpty) continue; // só lotes
      final data = parse(e.data);
      if (!inRange(data)) continue;
      groups.putIfAbsent(lote, () => []).add(e);
    }

    final result = <LoteEntradaResumo>[];
    groups.forEach((lote, list) {
      final qtd = list.length;
      final peso = list.fold<double>(0, (acc, it) => acc + (it.peso));
      final valor = list.fold<double>(0, (acc, it) => acc + (it.peso * it.precoUnitario));
      DateTime? ultimo;
      for (final e in list) {
        final d = parse(e.data);
        if (d != null && (ultimo == null || d.isAfter(ultimo!))) ultimo = d;
      }
      result.add(LoteEntradaResumo(
        numeroLote: lote,
        qtd: qtd,
        pesoTotal: double.parse(peso.toStringAsFixed(3)),
        valorTotal: double.parse(valor.toStringAsFixed(2)),
        ultimoRegistro: ultimo,
      ));
    });

    // Ordena por último registro desc
    result.sort((a, b) {
      final ad = a.ultimoRegistro ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.ultimoRegistro ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return result;
  }
}

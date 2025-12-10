import 'package:gaudioso_app/services/api_service.dart';
import '../models/lote_entrada_resumo.dart';
import '../models/entrada.dart';
import 'entrada_service.dart';

class EntradaLoteService {
  static const _path = '/api/entradas/lotes';

  Future<List<LoteEntradaResumo>> listar({DateTime? dia, DateTime? ini, DateTime? fim}) async {
    final params = <String, String>{};
    if (dia != null) {
      params['dia'] = _dateOnly(dia);
    } else if (ini != null && fim != null) {
      params['ini'] = DateTime(ini.year, ini.month, ini.day, 0, 0, 0).toIso8601String();
      params['fim'] = DateTime(fim.year, fim.month, fim.day, 23, 59, 59, 999).toIso8601String();
    }
    try {
      final data = await ApiService.getJson(_path, query: params);
      if (data is List) {
        return data.map((e) => LoteEntradaResumo.fromJson(e as Map<String, dynamic>)).toList();
      }
      // formato inesperado cai no fallback local
      return _listarFallback(dia: dia, ini: ini, fim: fim);
    } catch (_) {
      // fallback local quando API falhar
      return _listarFallback(dia: dia, ini: ini, fim: fim);
    }
  }

  Future<List<Entrada>> itensDoLote(String numeroLote) async {
    // Lote local (gerado pelo fallback)?
    if (numeroLote.startsWith('local:ENT:')) {
      final parsed = _parseLocalKey(numeroLote);
      final todas = await EntradaService().listar();
      return todas.where((e) {
        final numLote = (e.numeroLote ?? '').trim();
        if (numLote.isNotEmpty) return false;
        final d = _parseDateTime(e.data);
        return d != null && _bucketMinute(d).isAtSameMomentAs(parsed.bucket) && e.idFornecedor == parsed.parceiroId;
      }).toList();
    }

    try {
      final data = await ApiService.getJson('$_path/${Uri.encodeComponent(numeroLote)}');
      if (data is List) {
        return data.map((e) => Entrada.fromJson(e)).toList();
      }
    } catch (_) {
      // tenta endpoint alternativo
    }

    try {
      final data = await ApiService.getJson('/api/entradas', query: {'lote': numeroLote});
      if (data is List) {
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
    if (numeroAntigo.startsWith('local:')) {
      throw Exception('Operacao indisponivel para lotes locais');
    }
    await ApiService.putJson(
      '$_path/${Uri.encodeComponent(numeroAntigo)}',
      {"novoNumeroLote": numeroNovo},
    );
  }

  Future<void> excluir(String numeroLote) async {
    if (numeroLote.startsWith('local:')) {
      throw Exception('Operacao indisponivel para lotes locais');
    }
    try {
      await ApiService.delete('$_path/${Uri.encodeComponent(numeroLote)}');
      return;
    } catch (_) {
      // Fallback: excluir item a item
    }
    try {
      final itens = await itensDoLote(numeroLote);
      final entradaService = EntradaService();
      for (final e in itens) {
        if (e.id != null) {
          await entradaService.excluir(e.id!);
        }
      }
    } catch (e) {
      throw Exception('Erro ao excluir lote (fallback itens - entradas): $e');
    }
  }

  // -------------------- Helpers (fallback local) --------------------
  Future<List<LoteEntradaResumo>> _listarFallback({DateTime? dia, DateTime? ini, DateTime? fim}) async {
    final entradas = await EntradaService().listar();
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

    // Agrupa por numeroLote quando existir; senão, por minuto + fornecedor (lote local)
    final groups = <String, List<Entrada>>{};
    for (final e in entradas) {
      final d = _parseDateTime(e.data);
      if (d == null) continue;
      if (!inRange(d)) continue;
      final numLote = (e.numeroLote ?? '').trim();
      final key = numLote.isNotEmpty
          ? numLote
          : _buildLocalKey(parceiroId: e.idFornecedor, bucket: _bucketMinute(d));
      groups.putIfAbsent(key, () => []).add(e);
    }

    final result = <LoteEntradaResumo>[];
    groups.forEach((key, list) {
      final qtd = list.length;
      final peso = list.fold<double>(0, (acc, it) => acc + (it.peso));
      final valor = list.fold<double>(0, (acc, it) => acc + (it.peso * it.precoUnitario));
      DateTime? ultimo;
      for (final e in list) {
        final d = _parseDateTime(e.data);
        if (d != null && (ultimo == null || d.isAfter(ultimo!))) ultimo = d;
      }
      result.add(LoteEntradaResumo(
        numeroLote: key,
        qtd: qtd,
        pesoTotal: double.parse(peso.toStringAsFixed(3)),
        valorTotal: double.parse(valor.toStringAsFixed(2)),
        ultimoRegistro: ultimo,
      ));
    });

    result.sort((a, b) {
      final ad = a.ultimoRegistro ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.ultimoRegistro ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return result;
  }

  String _dateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  // Helpers para lotes locais
  DateTime? _parseDateTime(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return DateTime.tryParse(t) ?? DateTime.tryParse(t.replaceAll(' ', 'T'));
  }

  DateTime _bucketMinute(DateTime d) => DateTime(d.year, d.month, d.day, d.hour, d.minute);

  String _buildLocalKey({required int parceiroId, required DateTime bucket}) {
    String two(int v) => v.toString().padLeft(2, '0');
    final ts = '${bucket.year}${two(bucket.month)}${two(bucket.day)}${two(bucket.hour)}${two(bucket.minute)}';
    return 'local:ENT:$ts:FOR$parceiroId';
  }

  _LocalKey _parseLocalKey(String key) {
    try {
      final parts = key.split(':');
      final ts = parts[2];
      final y = int.parse(ts.substring(0, 4));
      final m = int.parse(ts.substring(4, 6));
      final d = int.parse(ts.substring(6, 8));
      final hh = int.parse(ts.substring(8, 10));
      final mm = int.parse(ts.substring(10, 12));
      final parceiroId = int.parse(parts[3].replaceFirst('FOR', ''));
      return _LocalKey(DateTime(y, m, d, hh, mm), parceiroId);
    } catch (_) {
      return _LocalKey(DateTime.fromMillisecondsSinceEpoch(0), -1);
    }
  }
}

class _LocalKey {
  final DateTime bucket;
  final int parceiroId;
  _LocalKey(this.bucket, this.parceiroId);
}

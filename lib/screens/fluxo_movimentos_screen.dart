import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/entrada.dart';
import '../models/saida.dart';
import '../services/entrada_service.dart';
import '../services/saida_service.dart';
import '../services/fornecedor_service.dart';
import '../services/cliente_service.dart';
import 'forms/entrada_form_screen.dart';
import 'forms/saida_form_screen.dart';

class FluxoMovimentosScreen extends StatefulWidget {
  const FluxoMovimentosScreen({super.key});

  @override
  State<FluxoMovimentosScreen> createState() => _FluxoMovimentosScreenState();
}

class _FluxoMovimentosScreenState extends State<FluxoMovimentosScreen> {
  final _entradaService = EntradaService();
  final _saidaService = SaidaService();
  final _fornecedorService = FornecedorService();
  final _clienteService = ClienteService();

  bool _loading = true;
  String? _error;
  List<_GrupoMov> _grupos = [];
  Map<int, String> _fornecedorNomes = {};
  Map<int, String> _clienteNomes = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _fornecedorService.listar(),
        _clienteService.listar(),
      ]);
      final fornecedores = results[0] as List;
      final clientes = results[1] as List;
      _fornecedorNomes = { for (final f in fornecedores) if (f.id != null) f.id!: f.nome };
      _clienteNomes = { for (final c in clientes) if (c.id != null) c.id!: c.nome };
    } catch (_) {
      _fornecedorNomes = {};
      _clienteNomes = {};
    }
    try {
      final entradas = await _entradaService.listar();
      final saidas = await _saidaService.listar();
      final items = <_Movimento>[];
      for (final e in entradas) {
        items.add(_Movimento.entrada(
          entrada: e,
          data: _parseDateTime(e.data),
          peso: e.peso,
          materialId: e.idMaterial,
          parceiroId: e.idFornecedor,
          precoUnitario: e.precoUnitario,
        ));
      }
      for (final s in saidas) {
        items.add(_Movimento.saida(
          saida: s,
          data: _parseDateTime(s.data),
          peso: s.peso,
          materialId: s.idMaterial,
          parceiroId: s.idCliente,
          precoUnitario: s.precoUnitario,
        ));
      }
      // Agrupa por (tipo, parceiro, minuto)
      final grupos = <String, _GrupoMov>{};
      for (final it in items) {
        final bucket = DateTime(it.data.year, it.data.month, it.data.day, it.data.hour, it.data.minute);
        final key = '${it.tipo.name}|${it.parceiroId}|${bucket.toIso8601String()}';
        final parceiroNome = it.tipo == _Tipo.entrada
            ? (_fornecedorNomes[it.parceiroId] ?? 'Fornecedor #${it.parceiroId}')
            : (_clienteNomes[it.parceiroId] ?? 'Cliente #${it.parceiroId}');
        final g = grupos.putIfAbsent(key, () => _GrupoMov(
          tipo: it.tipo,
          parceiroId: it.parceiroId,
          parceiroNome: parceiroNome,
          bucket: bucket,
        ));
        g.add(it);
      }
      final listaGrupos = grupos.values.toList()..sort((a, b) => b.bucket.compareTo(a.bucket));
      setState(() { _grupos = listaGrupos; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  DateTime _parseDateTime(String data) {
    final raw = data.trim();
    if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    DateTime? parsed = DateTime.tryParse(raw);
    parsed ??= DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (parsed == null && raw.length == 10) {
      parsed = DateTime.tryParse('${raw}T00:00:00');
    }
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: _grupos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final g = _grupos[index];
              final isEntrada = g.tipo == _Tipo.entrada;
              final baseColor = isEntrada ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
              final icon = isEntrada ? LucideIcons.arrowDown : LucideIcons.arrowUp;
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(g.bucket.toLocal());
              final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.onSurface.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: baseColor, child: Icon(icon, color: Colors.white, size: 18)),
                  title: Text('${isEntrada ? 'Entrada' : 'Saída'} – ${g.parceiroNome}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('$dateStr  •  ${g.qtd} itens  •  ${g.pesoTotal.toStringAsFixed(2)} kg  •  ${currency.format(g.valorTotal)}'),
                  onTap: () async {
                    // Abre o primeiro item do grupo para edição
                    final first = g.itens.first;
                    if (isEntrada && first.entrada != null) {
                      final mudou = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EntradaFormScreen(entrada: first.entrada)),
                      );
                      if (mudou == true) _load();
                    } else if (!isEntrada && first.saida != null) {
                      final mudou = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SaidaFormScreen(saida: first.saida)),
                      );
                      if (mudou == true) _load();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _Tipo { entrada, saida }

class _Movimento {
  final _Tipo tipo;
  final DateTime data;
  final double peso;
  final int materialId;
  final int parceiroId;
  final double precoUnitario;
  final Entrada? entrada;
  final Saida? saida;

  _Movimento._({
    required this.tipo,
    required this.data,
    required this.peso,
    required this.materialId,
    required this.parceiroId,
    required this.precoUnitario,
    this.entrada,
    this.saida,
  });

  factory _Movimento.entrada({required Entrada entrada, required DateTime data, required double peso, required int materialId, required int parceiroId, required double precoUnitario}) {
    return _Movimento._(tipo: _Tipo.entrada, data: data, peso: peso, materialId: materialId, parceiroId: parceiroId, precoUnitario: precoUnitario, entrada: entrada);
  }
  factory _Movimento.saida({required Saida saida, required DateTime data, required double peso, required int materialId, required int parceiroId, required double precoUnitario}) {
    return _Movimento._(tipo: _Tipo.saida, data: data, peso: peso, materialId: materialId, parceiroId: parceiroId, precoUnitario: precoUnitario, saida: saida);
  }
}

class _GrupoMov {
  final _Tipo tipo;
  final int parceiroId;
  final String parceiroNome;
  final DateTime bucket;
  final List<_Movimento> itens = [];
  int get qtd => itens.length;
  double get pesoTotal => itens.fold(0, (sum, it) => sum + it.peso);
  double get valorTotal => itens.fold(0, (sum, it) => sum + (it.peso * it.precoUnitario));

  _GrupoMov({required this.tipo, required this.parceiroId, required this.parceiroNome, required this.bucket});

  void add(_Movimento m) { itens.add(m); }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/lote_entrada_resumo.dart';
import '../models/entrada.dart';
import '../services/entrada_lote_service.dart';
import '../services/material_service.dart';
import '../services/entrada_service.dart';
import 'forms/entrada_form_screen.dart';

class FluxoLotesEntradasScreen extends StatefulWidget {
  const FluxoLotesEntradasScreen({super.key});

  @override
  State<FluxoLotesEntradasScreen> createState() => _FluxoLotesEntradasScreenState();
}

class _FluxoLotesEntradasScreenState extends State<FluxoLotesEntradasScreen> {
  final _service = EntradaLoteService();
  final _materialService = MaterialService();
  final _entradaService = EntradaService();

  DateTime? inicio;
  DateTime? fim;
  bool carregando = false;
  String? erro;

  List<LoteEntradaResumo> lotes = [];
  final Map<String, List<Entrada>> itensPorLote = {};
  final Map<String, bool> carregandoItens = {};
  Map<int, String> materialNomes = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    inicio = DateTime(now.year, now.month, 1);
    fim = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _carregarMateriais().then((_) => _carregar());
  }

  Future<void> _carregarMateriais() async {
    try {
      final mats = await _materialService.listar();
      materialNomes = { for (final m in mats) if (m.id != null) m.id!: m.nome };
    } catch (_) {
      materialNomes = {};
    }
  }

  Future<void> _carregar() async {
    setState(() { carregando = true; erro = null; });
    try {
      List<LoteEntradaResumo> dados;
      if (inicio != null && fim != null) {
        dados = await _service.listar(ini: inicio, fim: fim);
      } else if (inicio != null) {
        dados = await _service.listar(dia: inicio);
      } else {
        dados = await _service.listar();
      }
      dados.sort((a,b){
        final ad = a.ultimoRegistro ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.ultimoRegistro ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
      setState(() => lotes = dados);
    } catch (e) {
      setState(() => erro = e.toString());
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<void> _carregarItens(String numeroLote) async {
    if (carregandoItens[numeroLote] == true) return;
    setState(() => carregandoItens[numeroLote] = true);
    try {
      final itens = await _service.itensDoLote(numeroLote);
      setState(() => itensPorLote[numeroLote] = itens);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar itens: $e')));
    } finally {
      setState(() => carregandoItens[numeroLote] = false);
    }
  }

  

  Future<void> _renomear(String numeroAtual) async {
    final ctrl = TextEditingController(text: numeroAtual);
    final novo = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renomear lote'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Novo numero do lote')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Salvar')),
        ],
      ),
    );
    if (novo == null || novo.isEmpty || novo == numeroAtual) return;
    try {
      await _service.renomear(numeroAtual, novo);
      setState(() {
        for (var i = 0; i < lotes.length; i++) {
          if (lotes[i].numeroLote == numeroAtual) {
            final l = lotes[i];
            lotes[i] = LoteEntradaResumo(
              numeroLote: novo,
              qtd: l.qtd,
              pesoTotal: l.pesoTotal,
              valorTotal: l.valorTotal,
              ultimoRegistro: l.ultimoRegistro,
            );
            break;
          }
        }
        if (itensPorLote.containsKey(numeroAtual)) {
          itensPorLote[novo] = itensPorLote.remove(numeroAtual)!;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lote renomeado')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _excluir(String numeroLote) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir lote'),
        content: Text('Tem certeza que deseja excluir o lote "$numeroLote"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.excluir(numeroLote);
      setState(() {
        lotes.removeWhere((l) => l.numeroLote == numeroLote);
        itensPorLote.remove(numeroLote);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lote excluido')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _selecionarData(bool isInicio) async {
    final base = isInicio ? (inicio ?? DateTime.now()) : (fim ?? inicio ?? DateTime.now());
    final selecionada = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (selecionada != null && mounted) {
      setState(() {
        if (isInicio) {
          inicio = DateTime(selecionada.year, selecionada.month, selecionada.day);
          if (fim != null && fim!.isBefore(inicio!)) fim = null;
        } else {
          fim = DateTime(selecionada.year, selecionada.month, selecionada.day, 23, 59, 59);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = scheme.surface;
    final accent = scheme.onSurface;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    String fmtDate(DateTime? d) => d == null ? '--' : DateFormat('dd/MM/yyyy').format(d);
    String fmtPeso(double v) => '${v.toStringAsFixed(2)} kg';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: accent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: const Text('Fluxo - Lotes de entradas'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selecionarData(true),
                      icon: Icon(Icons.date_range, color: accent),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: const BorderSide(color: Colors.black54),
                        backgroundColor: Colors.green.shade50,
                      ),
                      label: Text(inicio == null ? 'Data início' : fmtDate(inicio)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selecionarData(false),
                      icon: Icon(Icons.date_range, color: accent),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: const BorderSide(color: Colors.black54),
                        backgroundColor: Colors.green.shade50,
                      ),
                      label: Text(fim == null ? 'Data fim (opcional)' : fmtDate(fim)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: carregando ? null : _carregar,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ),
            ),
            if (erro != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(erro!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _carregar,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        itemCount: lotes.length,
                        itemBuilder: (_, i) {
                          final l = lotes[i];
                          final ultimo = l.ultimoRegistro == null
                              ? '--'
                              : DateFormat('dd/MM/yyyy HH:mm').format(l.ultimoRegistro!);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                splashColor: Colors.green.shade100.withValues(alpha: 0.3),
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                textColor: accent,
                                iconColor: accent,
                                collapsedIconColor: accent,
                                title: Text(
                                  l.numeroLote,
                                  style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                                subtitle: Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Text('Qtd: ${l.qtd}', style: TextStyle(color: accent.withValues(alpha: 0.87))),
                                    Text('Peso: ${fmtPeso(l.pesoTotal)}', style: TextStyle(color: accent.withValues(alpha: 0.87))),
                                    if (l.valorTotal != null)
                                      Text('Valor: ${currency.format(l.valorTotal)}', style: TextStyle(color: accent.withValues(alpha: 0.87))),
                                    Text('Entrada: $ultimo', style: TextStyle(color: accent.withValues(alpha: 0.87))),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  tooltip: 'Mais',
                                  onSelected: (v) {
                                    if (v == 'renomear') {
                                      _renomear(l.numeroLote);
                                    } else if (v == 'excluir') {
                                      _excluir(l.numeroLote);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'renomear', child: Text('Renomear lote')),
                                    PopupMenuItem(value: 'excluir', child: Text('Excluir lote')),
                                  ],
                                ),
                                onExpansionChanged: (open) {
                                  if (open && (itensPorLote[l.numeroLote] == null)) {
                                    _carregarItens(l.numeroLote);
                                  }
                                },
                                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                children: [
                                  if (carregandoItens[l.numeroLote] == true)
                                    const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Center(child: CircularProgressIndicator()),
                                    )
                                  else ..._buildItens(l.numeroLote, currency),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItens(String numeroLote, NumberFormat currency) {
    final itens = itensPorLote[numeroLote] ?? const <Entrada>[];
    if (itens.isEmpty) {
      return const [Padding(padding: EdgeInsets.all(8.0), child: Text('Nenhum item para este lote.'))];
    }
    return itens.map((e) {
      final mat = materialNomes[e.idMaterial] ?? 'Material ${e.idMaterial}';
      final valor = e.valorTotal ?? (e.peso * e.precoUnitario);
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: const Color(0xFF4CAF50), child: Icon(LucideIcons.recycle, color: Colors.white, size: 18)),
          title: Text(mat),
          subtitle: Text('Peso: ${e.peso.toStringAsFixed(2)} kg  •  Unit: ${currency.format(e.precoUnitario)}  •  Total: ${currency.format(valor)}'),
          onTap: () async {
            final mudou = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EntradaFormScreen(entrada: e)),
            );
            if (mudou == true) {
              await _carregarItens(numeroLote);
              await _carregar();
            }
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (e.id == null) return;
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Excluir item'),
                  content: const Text('Deseja remover este item do lote?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                  ],
                ),
              );
              if (ok == true) {
                await _entradaService.excluir(e.id!);
                await _carregarItens(numeroLote);
                await _carregar();
              }
            },
          ),
        ),
      );
    }).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/lote_entrada_resumo.dart';
import '../models/entrada.dart';
import '../models/material.dart' as mdl;
import '../models/fornecedor.dart';
import '../services/entrada_lote_service.dart';
import '../services/material_service.dart';
import '../services/entrada_service.dart';
import '../services/fornecedor_service.dart';
import 'forms/entrada_form_screen.dart';

class FluxoLotesEntradasScreen extends StatefulWidget {
  const FluxoLotesEntradasScreen({super.key});

  @override
  State<FluxoLotesEntradasScreen> createState() =>
      _FluxoLotesEntradasScreenState();
}

class _FluxoLotesEntradasScreenState extends State<FluxoLotesEntradasScreen> {
  final _service = EntradaLoteService();
  final _materialService = MaterialService();
  final _entradaService = EntradaService();
  final _fornecedorService = FornecedorService();

  DateTime? inicio;
  DateTime? fim;
  bool carregando = false;
  String? erro;

  List<LoteEntradaResumo> lotes = [];
  final Map<String, List<Entrada>> itensPorLote = {};
  final Map<String, bool> carregandoItens = {};
  Map<int, String> materialNomes = {};
  Map<int, String> fornecedorNomes = {};

  bool _isLocalLote(String n) => n.startsWith('local:');
  String _displayLote(String n) {
    if (!_isLocalLote(n)) return n;
    try {
      // local:ENT:yyyyMMddHHmm:FOR<id>
      final parts = n.split(':');
      final pidStr = parts[3].replaceFirst('FOR', '');
      final id = int.tryParse(pidStr);
      if (id != null) {
        return fornecedorNomes[id] ?? 'Fornecedor';
      }
    } catch (_) {}
    return 'Fornecedor';
  }

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
      final results = await Future.wait([
        _materialService.listar(),
        _fornecedorService.listar(),
      ]);
      final mats = results[0] as List<mdl.MaterialItem>;
      final fornecedores = results[1] as List<Fornecedor>;
      materialNomes = {
        for (final m in mats)
          if (m.id != null) m.id!: m.nome,
      };
      fornecedorNomes = {
        for (final f in fornecedores)
          if (f.id != null) f.id!: f.nome,
      };
    } catch (_) {
      materialNomes = {};
      fornecedorNomes = {};
    }
  }

  Future<void> _carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      List<LoteEntradaResumo> dados;
      if (inicio != null && fim != null) {
        dados = await _service.listar(ini: inicio, fim: fim);
      } else if (inicio != null) {
        dados = await _service.listar(dia: inicio);
      } else {
        dados = await _service.listar();
      }
      dados.sort((a, b) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar itens: $e')));
    } finally {
      setState(() => carregandoItens[numeroLote] = false);
    }
  }

  Future<void> _excluir(String numeroLote) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir lote'),
        content: Text('Tem certeza que deseja excluir o lote "$numeroLote"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lote excluido')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _selecionarData(bool isInicio) async {
    final base = isInicio
        ? (inicio ?? DateTime.now())
        : (fim ?? inicio ?? DateTime.now());
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
          inicio = DateTime(
            selecionada.year,
            selecionada.month,
            selecionada.day,
          );
          if (fim != null && fim!.isBefore(inicio!)) fim = null;
        } else {
          fim = DateTime(
            selecionada.year,
            selecionada.month,
            selecionada.day,
            23,
            59,
            59,
          );
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

    String fmtDate(DateTime? d) =>
        d == null ? '--' : DateFormat('dd/MM/yyyy').format(d);
    String fmtPeso(double v) => '${v.toStringAsFixed(2)} kg';

    return Scaffold(
      backgroundColor: bg,
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
                      icon: Icon(LucideIcons.calendar, color: accent),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: const BorderSide(color: Colors.black54),
                        backgroundColor: Colors.green.shade50,
                      ),
                      label: Text(
                        inicio == null ? 'Data início' : fmtDate(inicio),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selecionarData(false),
                      icon: Icon(LucideIcons.calendar, color: accent),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: const BorderSide(color: Colors.black54),
                        backgroundColor: Colors.green.shade50,
                      ),
                      label: Text(
                        fim == null ? 'Data fim (opcional)' : fmtDate(fim),
                      ),
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
                  icon: const Icon(LucideIcons.search),
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
                              : DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(l.ultimoRegistro!);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                splashColor: Colors.green.shade100.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                textColor: accent,
                                iconColor: accent,
                                collapsedIconColor: accent,
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  child: Icon(
                                    LucideIcons.arrowDown,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  _displayLote(l.numeroLote),
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      'Qtd: ${l.qtd}',
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.87),
                                      ),
                                    ),
                                    Text(
                                      'Peso: ${fmtPeso(l.pesoTotal)}',
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.87),
                                      ),
                                    ),
                                    if (l.valorTotal != null)
                                      Text(
                                        'Valor: ${currency.format(l.valorTotal)}',
                                        style: TextStyle(
                                          color: accent.withValues(alpha: 0.87),
                                        ),
                                      ),
                                    Text(
                                      'Entrada: $ultimo',
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.87),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Editar lote',
                                      icon: Icon(
                                        LucideIcons.pencil,
                                        color: accent,
                                      ),
                                      onPressed: _isLocalLote(l.numeroLote)
                                          ? null
                                          : () async {
                                              final mudou = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      _EditarLoteEntradaScreen(
                                                        numeroLote:
                                                            l.numeroLote,
                                                      ),
                                                ),
                                              );
                                              if (mudou == true) {
                                                await _carregarItens(
                                                  l.numeroLote,
                                                );
                                                await _carregar();
                                              }
                                            },
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      tooltip: 'Excluir lote',
                                      icon: const Icon(
                                        LucideIcons.trash2,
                                        color: Color(0xFFE53935),
                                      ),
                                      onPressed: _isLocalLote(l.numeroLote)
                                          ? null
                                          : () => _excluir(l.numeroLote),
                                    ),
                                  ],
                                ),
                                onExpansionChanged: (open) {
                                  if (open &&
                                      (itensPorLote[l.numeroLote] == null)) {
                                    _carregarItens(l.numeroLote);
                                  }
                                },
                                childrenPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                children: [
                                  if (carregandoItens[l.numeroLote] == true)
                                    const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else
                                    ..._buildItens(l.numeroLote, currency),
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
      return const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Nenhum item para este lote.'),
        ),
      ];
    }
    return itens.map((e) {
      final mat = materialNomes[e.idMaterial] ?? 'Material ${e.idMaterial}';
      final valor = e.valorTotal ?? (e.peso * e.precoUnitario);
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF4CAF50),
            child: Icon(LucideIcons.box, color: Colors.white, size: 18),
          ),
          title: Text(mat),
          subtitle: Text(
            'Peso: ${e.peso.toStringAsFixed(2)} kg  •  Unit: ${currency.format(e.precoUnitario)}  •  Total: ${currency.format(valor)}',
          ),
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
            icon: const Icon(LucideIcons.trash2),
            onPressed: () async {
              if (e.id == null) return;
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Excluir item'),
                  content: const Text('Deseja remover este item do lote?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir'),
                    ),
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

// ====================== Tela de edição de conteúdo do lote (Entradas) ======================
class _EditarLoteEntradaScreen extends StatefulWidget {
  final String numeroLote;
  const _EditarLoteEntradaScreen({required this.numeroLote});

  @override
  State<_EditarLoteEntradaScreen> createState() =>
      _EditarLoteEntradaScreenState();
}

class _EditarLoteEntradaScreenState extends State<_EditarLoteEntradaScreen> {
  final _service = EntradaLoteService();
  final _entradaService = EntradaService();
  final _materialService = MaterialService();
  final _fornecedorService = FornecedorService();

  bool carregando = true;
  bool mudou = false;
  String? erro;
  List<Entrada> itens = [];
  List<mdl.MaterialItem> materiais = [];
  List<Fornecedor> fornecedores = [];

  List<double> _parsePesos(String text) {
    final norm = text.replaceAll(',', '.');
    final parts = norm.split(RegExp(r"[+;,\s]+"));
    final out = <double>[];
    for (final p in parts) {
      final t = p.trim();
      if (t.isEmpty) continue;
      final v = double.tryParse(t);
      if (v != null && v > 0) out.add(v);
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final results = await Future.wait([
        _service.itensDoLote(widget.numeroLote),
        _materialService.listar(),
        _fornecedorService.listar(),
      ]);
      setState(() {
        itens = results[0] as List<Entrada>;
        materiais = (results[1] as List<mdl.MaterialItem>)
          ..sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
          );
        fornecedores = (results[2] as List<Fornecedor>)
          ..sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
          );
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  int? _loteFornecedorId() =>
      itens.isNotEmpty ? itens.first.idFornecedor : null;

  Future<void> _excluirItem(Entrada e) async {
    if (e.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir item'),
        content: const Text('Deseja remover este item do lote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _entradaService.excluir(e.id!);
      setState(() {
        itens.removeWhere((x) => x.id == e.id);
        mudou = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item excluido')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _editarItem(Entrada e) async {
    final materialAtual = materiais.firstWhere(
      (m) => m.id == e.idMaterial,
      orElse: () => materiais.first,
    );
    final initialPesos = (e.pesosJson.isNotEmpty)
        ? e.pesosJson.map((v) => v.toStringAsFixed(2)).join(' + ')
        : e.peso.toStringAsFixed(2);
    final pesoCtrl = TextEditingController(text: initialPesos);
    final precoCtrl = TextEditingController(
      text: e.precoUnitario.toStringAsFixed(2),
    );
    mdl.MaterialItem? matSel = materialAtual;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Editar item',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<mdl.MaterialItem>(
                  value: matSel,
                  items: materiais
                      .map(
                        (m) => DropdownMenuItem(value: m, child: Text(m.nome)),
                      )
                      .toList(),
                  onChanged: (v) => matSel = v,
                  decoration: const InputDecoration(labelText: 'Material'),
                ),
                TextFormField(
                  controller: pesoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Pesagens (kg)',
                    hintText: 'Informe as pesagens separadas por +',
                  ),
                ),
                TextFormField(
                  controller: precoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Preço unitário',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (ok != true) return;
    final pesos = _parsePesos(pesoCtrl.text);
    final preco =
        double.tryParse(precoCtrl.text.replaceAll(',', '.')) ?? e.precoUnitario;
    final pesosFinais = pesos.isNotEmpty
        ? pesos
        : (e.pesosJson.isNotEmpty
              ? List<double>.from(e.pesosJson)
              : <double>[e.peso]);
    final pesoTotal = pesosFinais.fold<double>(0, (sum, p) => sum + p);
    try {
      final atualizado = Entrada(
        id: e.id,
        idMaterial: matSel?.id ?? e.idMaterial,
        idFornecedor: e.idFornecedor,
        numeroLote: e.numeroLote,
        pesosJson: pesosFinais,
        precoUnitario: preco,
        qtdPesagens: null,
        peso: pesoTotal,
        valorTotal: null,
        data: e.data,
        registradoPor: e.registradoPor,
      );
      await _entradaService.atualizar(atualizado);
      await _load();
      mudou = true;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item atualizado')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _adicionarItem() async {
    mdl.MaterialItem? matSel = materiais.isNotEmpty ? materiais.first : null;
    final pesoCtrl = TextEditingController();
    final precoCtrl = TextEditingController(
      text: (matSel?.precoCompra ?? 0).toStringAsFixed(2),
    );
    Fornecedor? fornSel;
    final loteForn = _loteFornecedorId();
    if (loteForn != null) {
      try {
        fornSel = fornecedores.firstWhere((f) => f.id == loteForn);
      } catch (_) {}
    } else {
      fornSel = fornecedores.isNotEmpty ? fornecedores.first : null;
    }
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Adicionar item ao lote',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (loteForn == null)
                  DropdownButtonFormField<Fornecedor>(
                    value: fornSel,
                    items: fornecedores
                        .map(
                          (f) =>
                              DropdownMenuItem(value: f, child: Text(f.nome)),
                        )
                        .toList(),
                    onChanged: (v) => fornSel = v,
                    decoration: const InputDecoration(labelText: 'Fornecedor'),
                  ),
                DropdownButtonFormField<mdl.MaterialItem>(
                  value: matSel,
                  items: materiais
                      .map(
                        (m) => DropdownMenuItem(value: m, child: Text(m.nome)),
                      )
                      .toList(),
                  onChanged: (v) {
                    matSel = v;
                    precoCtrl.text = (v?.precoCompra ?? 0).toStringAsFixed(2);
                  },
                  decoration: const InputDecoration(labelText: 'Material'),
                ),
                TextFormField(
                  controller: pesoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Pesagens (kg)',
                    hintText: 'Informe as pesagens separadas por +',
                  ),
                ),
                TextFormField(
                  controller: precoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Preço unitário',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (ok != true) return;
    final pesos = _parsePesos(pesoCtrl.text);
    final pesoTotal = pesos.fold<double>(0, (sum, p) => sum + p);
    final preco =
        double.tryParse(precoCtrl.text.replaceAll(',', '.')) ??
        (matSel?.precoCompra ?? 0);
    final idFornecedor = loteForn ?? (fornSel?.id);
    if (matSel?.id == null ||
        idFornecedor == null ||
        pesos.isEmpty ||
        pesoTotal <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha os campos')));
      return;
    }
    try {
      final novo = Entrada(
        id: null,
        idMaterial: matSel!.id!,
        idFornecedor: idFornecedor,
        numeroLote: widget.numeroLote,
        pesosJson: pesos,
        precoUnitario: preco,
        qtdPesagens: null,
        peso: pesoTotal,
        valorTotal: null,
        data: DateTime.now().toIso8601String(),
        registradoPor: 0,
      );
      await _entradaService.adicionar(novo);
      await _load();
      mudou = true;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item adicionado')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context, mudou),
        ),
        title: Text('Lote ${widget.numeroLote}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: carregando ? null : _adicionarItem,
        child: const Icon(LucideIcons.plus),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(child: Text('Erro: $erro'))
          : itens.isEmpty
          ? const Center(child: Text('Sem itens. Use + para adicionar.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
              itemCount: itens.length,
              itemBuilder: (_, i) {
                final e = itens[i];
                final mat = materiais.firstWhere(
                  (m) => m.id == e.idMaterial,
                  orElse: () => mdl.MaterialItem(
                    id: e.idMaterial,
                    nome: 'Material ${e.idMaterial}',
                    precoCompra: e.precoUnitario,
                    precoVenda: e.precoUnitario,
                  ),
                );
                final valor = e.valorTotal ?? (e.peso * e.precoUnitario);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(mat.nome),
                    subtitle: Text(
                      'Peso: ${e.peso.toStringAsFixed(2)} kg  •  Unit: ${currency.format(e.precoUnitario)}  •  Total: ${currency.format(valor)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.pencil),
                          onPressed: () => _editarItem(e),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2),
                          onPressed: () => _excluirItem(e),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

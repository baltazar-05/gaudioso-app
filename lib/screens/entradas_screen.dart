import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/entrada.dart';
import '../models/material.dart';
import '../models/fornecedor.dart';
import '../services/entrada_service.dart';
import '../services/material_service.dart';
import '../services/fornecedor_service.dart';
import 'package:gaudioso_app/screens/forms/entrada_form_screen.dart';

class EntradasScreen extends StatefulWidget {
  const EntradasScreen({super.key});

  @override
  State<EntradasScreen> createState() => _EntradasScreenState();
}

class _EntradasScreenState extends State<EntradasScreen> {
  final service = EntradaService();
  final matService = MaterialService();
  final fornService = FornecedorService();
  final _buscaCtrl = TextEditingController();
  List<Entrada> entradas = [];
  Map<int, String> materialNomes = {};
  Map<int, double> materialPrecos = {};
  Map<int, String> fornecedorNomes = {};
  List<_GrupoEntrada> grupos = [];
  List<_GrupoEntrada> gruposFiltrados = [];
  bool carregando = true;

  TextStyle _poppins({Color? color, double? fontSize, FontWeight? fontWeight}) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return base.copyWith(
      color: color ?? Colors.black87,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
    );
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    try {
      // Busca entradas e catálogos para mapear nomes
      final results = await Future.wait([
        service.listar(),
        matService.listar(),
        fornService.listar(),
      ]);
      final data = results[0] as List<Entrada>;
      final mats = results[1] as List<MaterialItem>;
      final fors = results[2] as List<Fornecedor>;

      final mMap = <int, String>{
        for (final m in mats)
          if (m.id != null) m.id!: m.nome,
      };
      final mPrices = <int, double>{
        for (final m in mats)
          if (m.id != null) m.id!: m.precoCompra,
      };
      final fMap = <int, String>{
        for (final f in fors)
          if (f.id != null) f.id!: f.nome,
      };
      if (!mounted) return;
      setState(() {
        entradas = data;
        materialNomes = mMap;
        materialPrecos = mPrices;
        fornecedorNomes = fMap;
        grupos = _agrupar(data, mMap, mPrices, fMap);
        gruposFiltrados = _filtrarGrupos(_buscaCtrl.text, grupos);
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao carregar entradas: $e")));
    }
  }

  Future<void> _abrirFormulario({Entrada? e}) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntradaFormScreen(entrada: e)),
    );
    if (!mounted) return;
    if (mudou == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = scheme.surface;
    const textColor = Colors.black87;
    const iconColor = Colors.black87;
    final deleteColor = Colors.redAccent;
    final fabBg =
        Theme.of(context).floatingActionButtonTheme.backgroundColor ??
        scheme.tertiary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
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
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.arrowDownToLine, size: 22, color: iconColor),
            const SizedBox(width: 8),
            Text(
              'Entradas de Materiais',
              style: _poppins(color: textColor, fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (q) => setState(() {
                      gruposFiltrados = _filtrarGrupos(q, grupos);
                    }),
                    style: _poppins(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Buscar por material ou fornecedor',
                      hintStyle: _poppins(
                        color: textColor.withValues(alpha: 0.54),
                      ),
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        color: iconColor,
                      ),
                      filled: true,
                      fillColor: cardColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: textColor.withValues(alpha: 0.54),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: (entradas.isEmpty)
                      ? Center(
                          child: Text(
                            'Nenhuma entrada registrada',
                            style: _poppins(
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: carregar,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                            itemCount: gruposFiltrados.length,
                            itemBuilder: (_, i) {
                              final g = gruposFiltrados[i];
                              final fornNome =
                                  fornecedorNomes[g.idFornecedor] ??
                                  'Fornecedor ${g.idFornecedor}';
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ExpansionTile(
                                  iconColor: iconColor,
                                  collapsedIconColor: iconColor,
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    'Fornecedor: $fornNome',
                                    style: _poppins(color: textColor),
                                  ),
                                  subtitle: Text(
                                    'Data/hora: ${_formatDateTime(g.dataHora)}  |  Pesagens: ${g.itens.length}  |  Valor total: R\$ ${g.totalValor.toStringAsFixed(2)}',
                                    style: _poppins(
                                      color: textColor.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  children: [
                                    for (final e in g.itens)
                                      ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                        leading: _CircleIconButton(
                                          icon: LucideIcons.pencil,
                                          iconColor: iconColor,
                                          tooltip: 'Editar entrada',
                                          onTap: () => _abrirFormulario(e: e),
                                        ),
                                        title: Text(
                                          materialNomes[e.idMaterial] ??
                                              'Material ${e.idMaterial}',
                                          style: _poppins(color: textColor),
                                        ),
                                        subtitle: Text(
                                          'Peso: ${e.peso.toStringAsFixed(2)} kg  |  Valor: R\$ ${(((materialPrecos[e.idMaterial] ?? 0) * e.peso)).toStringAsFixed(2)}  |  Registrado em: ${_formatDateTime(_parseDateTime(e.data))}',
                                          style: _poppins(
                                            color: textColor.withValues(
                                              alpha: 0.75,
                                            ),
                                          ),
                                        ),
                                        trailing: _CircleIconButton(
                                          icon: LucideIcons.trash2,
                                          iconColor: deleteColor,
                                          tooltip: 'Excluir entrada',
                                          onTap: () async {
                                            try {
                                              await service.excluir(e.id!);
                                              if (!context.mounted) return;
                                              carregar();
                                            } catch (err) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Erro ao excluir: $err',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: fabBg,
        foregroundColor: textColor,
        child: const Icon(LucideIcons.arrowDownToLine),
      ),
    );
  }
}

extension _FiltroEntradas on _EntradasScreenState {
  List<_GrupoEntrada> _agrupar(
    List<Entrada> base,
    Map<int, String> mNames,
    Map<int, double> mPrices,
    Map<int, String> fNames,
  ) {
    final sorted = List<Entrada>.from(base);
    sorted.sort((a, b) {
      final ai = a.id ?? 0;
      final bi = b.id ?? 0;
      return ai.compareTo(bi);
    });

    final grupos = <_GrupoEntrada>[];
    _GrupoEntrada? atual;
    Entrada? prev;

    for (final e in sorted) {
      final currentDate = _parseDateTime(e.data);
      final previous = prev;
      final previousDate = previous != null
          ? _parseDateTime(previous.data)
          : null;
      final mustSplit =
          previous == null ||
          e.idFornecedor != previous.idFornecedor ||
          previousDate == null ||
          !_sameDay(currentDate, previousDate) ||
          ((e.id ?? 0) - (previous.id ?? 0)).abs() > 1;

      final previousGroup = atual;
      late final _GrupoEntrada grupoAtual;
      if (mustSplit || previousGroup == null) {
        final novo = _GrupoEntrada(
          data: e.data,
          dataHora: currentDate,
          idFornecedor: e.idFornecedor,
        );
        grupos.add(novo);
        atual = novo;
        grupoAtual = novo;
      } else {
        grupoAtual = previousGroup;
      }
      grupoAtual.itens.add(e);
      final preco = mPrices[e.idMaterial] ?? 0;
      grupoAtual.totalPeso += e.peso;
      grupoAtual.totalValor += preco * e.peso;
      prev = e;
    }

    grupos.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return grupos;
  }

  List<_GrupoEntrada> _filtrarGrupos(String q, List<_GrupoEntrada> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) return List<_GrupoEntrada>.from(base);
    bool match(_GrupoEntrada g) {
      final fornecedor = (fornecedorNomes[g.idFornecedor] ?? '').toLowerCase();
      if (fornecedor.contains(termo)) return true;
      for (final e in g.itens) {
        final mn = (materialNomes[e.idMaterial] ?? '').toLowerCase();
        if (mn.contains(termo)) return true;
      }
      return false;
    }

    return base.where(match).toList();
  }
}

class _GrupoEntrada {
  final String data;
  final DateTime dataHora;
  final int idFornecedor;
  final List<Entrada> itens = [];
  double totalPeso = 0;
  double totalValor = 0;

  _GrupoEntrada({
    required this.data,
    required this.dataHora,
    required this.idFornecedor,
  });
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final String? tooltip;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.black87,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = iconColor.withValues(alpha: 0.12);
    final button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        hoverColor: overlay,
        highlightColor: overlay,
        splashColor: overlay,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

extension _Fmt on _EntradasScreenState {
  DateTime _parseDateTime(String data) {
    final raw = data.trim();
    if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    DateTime? parsed;
    try {
      parsed = DateTime.parse(raw);
    } catch (_) {
      final normalized = raw.replaceAll(' ', 'T');
      try {
        parsed = DateTime.parse(normalized);
      } catch (_) {
        if (raw.length == 10) {
          try {
            parsed = DateTime.parse('${raw}T00:00:00');
          } catch (_) {}
        }
      }
    }
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateTime(DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
}


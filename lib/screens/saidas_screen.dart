import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/cliente.dart';
import '../models/material.dart';
import '../models/saida.dart';
import '../services/cliente_service.dart';
import '../services/material_service.dart';
import '../services/saida_service.dart';
import 'package:gaudioso_app/screens/forms/saida_form_screen.dart';

class SaidasScreen extends StatefulWidget {
  const SaidasScreen({super.key});

  @override
  State<SaidasScreen> createState() => _SaidasScreenState();
}

class _SaidasScreenState extends State<SaidasScreen> {
  final service = SaidaService();
  final matService = MaterialService();
  final clienteService = ClienteService();
  final _buscaCtrl = TextEditingController();

  List<Saida> saidas = [];
  Map<int, String> materialNomes = {};
  Map<int, double> materialPrecos = {};
  Map<int, String> clienteNomes = {};
  List<_GrupoSaida> grupos = [];
  List<_GrupoSaida> gruposFiltrados = [];
  bool carregando = true;

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
      final results = await Future.wait([
        service.listar(),
        matService.listar(),
        clienteService.listar(),
      ]);
      final data = results[0] as List<Saida>;
      final mats = results[1] as List<MaterialItem>;
      final clientes = results[2] as List<Cliente>;

      final mMap = <int, String>{
        for (final m in mats)
          if (m.id != null) m.id!: m.nome,
      };
      final mPrices = <int, double>{
        for (final m in mats)
          if (m.id != null) m.id!: m.precoVenda,
      };
      final cMap = <int, String>{
        for (final c in clientes)
          if (c.id != null) c.id!: c.nome,
      };

      if (!mounted) return;
      setState(() {
        saidas = data;
        materialNomes = mMap;
        materialPrecos = mPrices;
        clienteNomes = cMap;
        grupos = _agrupar(data, mPrices);
        gruposFiltrados = _filtrarGrupos(_buscaCtrl.text, grupos);
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar saidas: $e')),
      );
    }
  }

  Future<void> _abrirFormulario({Saida? s}) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SaidaFormScreen(saida: s)),
    );
    if (!mounted) return;
    if (mudou == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = scheme.surface;
    final Color accent = scheme.onSurface;
    final Color hintColor = accent.withValues(alpha: 0.54);
    final Color secondaryAccent = accent.withValues(alpha: 0.9);
    final Color tertiaryAccent = accent.withValues(alpha: 0.87);
    final Color fabBg = Theme.of(context).floatingActionButtonTheme.backgroundColor ?? scheme.tertiary;

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
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.arrowUpFromLine, size: 22, color: accent),
            const SizedBox(width: 8),
            Text(
              'Saidas de Materiais',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (q) => setState(() {
                      gruposFiltrados = _filtrarGrupos(q, grupos);
                    }),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent),
                    decoration: InputDecoration(
                      hintText: 'Buscar por material ou cliente',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: hintColor),
                      prefixIcon: Icon(LucideIcons.search, color: Colors.black87),
                      filled: true,
                      fillColor: cardColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: hintColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: saidas.isEmpty
                      ? Center(child: Text('Nenhuma saidaAda registrada', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent)))
                      : RefreshIndicator(
                          onRefresh: carregar,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            itemCount: gruposFiltrados.length,
                            itemBuilder: (_, i) {
                              final g = gruposFiltrados[i];
                              final clienteNome = clienteNomes[g.idCliente] ?? 'Cliente ${g.idCliente}';
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  title: Text(
                                    'Cliente: $clienteNome',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent),
                                  ),
                                  subtitle: Text(
                                    'Data/hora: ${_formatDateTime(g.dataHora)}  |  Pesagens: ${g.itens.length}  |  Valor total: R\$ ${g.totalValor.toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryAccent),
                                  ),
                                  children: [
                                    for (final s in g.itens)
                                      ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        leading: _CircleIconButton(
                                          icon: LucideIcons.pencil,
                                          iconColor: accent,
                                          tooltip: 'Editar saida',
                                          onTap: () => _abrirFormulario(s: s),
                                        ),
                                        title: Text(
                                          materialNomes[s.idMaterial] ?? 'Material ${s.idMaterial}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent),
                                        ),
                                        subtitle: Text(
                                          'Peso: ${s.peso.toStringAsFixed(2)} kg  |  Valor: R\$ ${((materialPrecos[s.idMaterial] ?? 0) * s.peso).toStringAsFixed(2)}  |  Registrado em: ${_formatDateTime(_parseDateTime(s.data))}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tertiaryAccent),
                                        ),
                                        trailing: _CircleIconButton(
                                          icon: LucideIcons.trash2,
                                          iconColor: Colors.redAccent,
                                          tooltip: 'Excluir saida',
                                          onTap: () async {
                                            try {
                                              await service.excluir(s.id!);
                                              if (!mounted) return;
                                              await carregar();
                                            } catch (err) {
                                              if (!mounted) return;
                                              final messenger = ScaffoldMessenger.of(this.context);
                                              messenger.showSnackBar(
                                                SnackBar(content: Text('Erro ao excluir: $err')),
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
        foregroundColor: Colors.black87,
        child: const Icon(LucideIcons.arrowUpFromLine, color: Colors.black87),
      ),
    );
  }
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

extension _FiltroSaidas on _SaidasScreenState {
  List<_GrupoSaida> _agrupar(List<Saida> base, Map<int, double> mPrices) {
    final sorted = List<Saida>.from(base);
    sorted.sort((a, b) {
      final ai = a.id ?? 0;
      final bi = b.id ?? 0;
      return ai.compareTo(bi);
    });

    final grupos = <_GrupoSaida>[];
    _GrupoSaida? atual;
    Saida? prev;

    for (final s in sorted) {
      final currentDate = _parseDateTime(s.data);
      final previous = prev;
      final previousDate = previous != null ? _parseDateTime(previous.data) : null;
      final mustSplit = previous == null ||
          s.idCliente != previous.idCliente ||
          previousDate == null ||
          !_sameDay(currentDate, previousDate) ||
          ((s.id ?? 0) - (previous.id ?? 0)).abs() > 1;

      final previousGroup = atual;
      late final _GrupoSaida grupoAtual;
      if (mustSplit || previousGroup == null) {
        final novo = _GrupoSaida(
          data: s.data,
          dataHora: currentDate,
          idCliente: s.idCliente,
        );
        grupos.add(novo);
        atual = novo;
        grupoAtual = novo;
      } else {
        grupoAtual = previousGroup;
      }

      grupoAtual.itens.add(s);
      final preco = mPrices[s.idMaterial] ?? 0;
      grupoAtual.totalPeso += s.peso;
      grupoAtual.totalValor += preco * s.peso;
      prev = s;
    }

    grupos.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return grupos;
  }

  List<_GrupoSaida> _filtrarGrupos(String q, List<_GrupoSaida> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) return List<_GrupoSaida>.from(base);

    bool match(_GrupoSaida g) {
      final cliente = (clienteNomes[g.idCliente] ?? '').toLowerCase();
      if (cliente.contains(termo)) return true;
      for (final s in g.itens) {
        final nomeMaterial = (materialNomes[s.idMaterial] ?? '').toLowerCase();
        if (nomeMaterial.contains(termo)) return true;
      }
      return false;
    }

    return base.where(match).toList();
  }

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

class _GrupoSaida {
  final String data;
  final DateTime dataHora;
  final int idCliente;
  final List<Saida> itens = [];
  double totalPeso = 0;
  double totalValor = 0;

  _GrupoSaida({
    required this.data,
    required this.dataHora,
    required this.idCliente,
  });
}

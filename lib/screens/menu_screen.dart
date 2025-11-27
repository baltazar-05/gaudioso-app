import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:gaudioso_app/services/auth_service.dart';
import 'package:gaudioso_app/services/entrada_service.dart';
import 'package:gaudioso_app/services/material_service.dart';
import 'package:gaudioso_app/services/cliente_service.dart';
import 'package:gaudioso_app/services/fornecedor_service.dart';
import 'package:gaudioso_app/services/saida_service.dart';
import 'package:gaudioso_app/models/entrada.dart';
import 'package:gaudioso_app/models/saida.dart';
import 'package:gaudioso_app/models/cliente.dart';
import 'package:gaudioso_app/models/fornecedor.dart';

import 'cadastros_screen.dart';
import 'estoque_screen.dart';
import 'forms/entrada_form_screen.dart';
import 'forms/saida_form_screen.dart';
import 'splash_screen.dart';
import 'materiais_screen.dart';
import 'profile/profile_screen.dart';
import 'relatorios_screen.dart';
import 'fluxo_lotes_screen.dart';

// Core brand colors (one-time constants)
const kText = Color(0xFF1F2937);
const kGreen = Color(0xFF4CAF50);
const kTeal = Color(0xFF00BFA6);
const kAmber = Color(0xFFFBC02D);
const kMint = Color(0xFF66BB6A);
const kDarkGreen = Color(0xFF2E7D32);
const kRed = Color(0xFFE53935);

class MenuScreen extends StatefulWidget {
  final String username;
  final int initialIndex;
  const MenuScreen({super.key, required this.username, this.initialIndex = 0});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _ResumoTab(username: widget.username),
      const FluxoLotesScreen(),
      const EstoqueScreen(),
      RelatoriosScreen(username: widget.username, hideBottomBar: true),
    ];

    return Scaffold(
      extendBody: true,
      drawer: _SideOptionsDrawer(username: widget.username),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _EcoBottomBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _EcoBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _EcoBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inactive = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final active = Theme.of(context).colorScheme.primary;
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(icon: Icons.home_outlined, label: 'Resumo', index: 0, active: active, inactive: inactive),
            _navItem(icon: LucideIcons.arrowDownUp, label: 'Fluxo', index: 1, active: active, inactive: inactive),
            _navItem(icon: LucideIcons.database, label: 'Estoque', index: 2, active: active, inactive: inactive),
            _navItem(icon: LucideIcons.chartBar, label: 'Relatorios', index: 3, active: active, inactive: inactive),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    required Color active,
    required Color inactive,
  }) {
    final selected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? active : inactive, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: selected ? active : inactive)),
          ],
        ),
      ),
    );
  }
}

class _ResumoTab extends StatefulWidget {
  final String username;
  const _ResumoTab({required this.username});

  @override
  State<_ResumoTab> createState() => _ResumoTabState();
}

class _ResumoTabState extends State<_ResumoTab> {
  bool _showEntradas = true;
  Timer? _timer;
  static const _toggleEvery = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_toggleEvery, (_) {
      if (!mounted) return;
      setState(() => _showEntradas = !_showEntradas);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime _parseDateTime(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      final m = RegExp(r"(\d{4})-(\d{2})-(\d{2})").firstMatch(s);
      if (m != null) {
        return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              ),
              // Texto fixo (substitui o antigo ticker)
              FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  EntradaService().listar(),
                  SaidaService().listar(),
                  ClienteService().listar(),
                  FornecedorService().listar(),
                ]),
                builder: (context, snap) {
                  final scheme = Theme.of(context).colorScheme;
                  final on = Colors.black;
                  String label = _showEntradas ? 'Ultima entrada' : 'Ultima saida';
                  String nome = '--';
                  String dataStr = '--';
                  String pesoStr = '--';
                  String valorStr = '--';
                  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

                  if (snap.hasData) {
                    final entradas = (snap.data![0] as List<Entrada>);
                    final saidas = (snap.data![1] as List<Saida>);
                    final clientes = (snap.data![2] as List<Cliente>);
                    final fornecedores = (snap.data![3] as List<Fornecedor>);

                    // Mapas de nomes
                    final cMap = {for (final c in clientes) if (c.id != null) c.id!: c.nome};
                    final fMap = {for (final f in fornecedores) if (f.id != null) f.id!: f.nome};

                    // Ãšltimos por data
                    Entrada? ultEntrada;
                    DateTime? dtE;
                    for (final e in entradas) {
                      final d = _parseDateTime(e.data).toLocal();
                      if (ultEntrada == null || d.isAfter(dtE!)) { ultEntrada = e; dtE = d; }
                    }
                    Saida? ultSaida;
                    DateTime? dtS;
                    for (final s in saidas) {
                      final d = _parseDateTime(s.data).toLocal();
                      if (ultSaida == null || d.isAfter(dtS!)) { ultSaida = s; dtS = d; }
                    }

                    if (_showEntradas && ultEntrada != null && dtE != null) {
                      label = 'Ultima entrada';
                      nome = fMap[ultEntrada.idFornecedor] ?? 'Fornecedor ${ultEntrada.idFornecedor}';
                      dataStr = DateFormat('dd/MM/yyyy HH:mm').format(dtE);
                      // soma do lote/momento: mesmo fornecedor e mesmo minuto
                      final b = DateTime(dtE.year, dtE.month, dtE.day, dtE.hour, dtE.minute);
                      double pesoTot = 0, valorTot = 0;
                      for (final e in entradas) {
                        final d = _parseDateTime(e.data).toLocal();
                        final bb = DateTime(d.year, d.month, d.day, d.hour, d.minute);
                        if (e.idFornecedor == ultEntrada.idFornecedor && bb == b) {
                          pesoTot += e.peso;
                          valorTot += (e.valorTotal ?? (e.peso * e.precoUnitario));
                        }
                      }
                      pesoStr = '${pesoTot.toStringAsFixed(2)} kg';
                      valorStr = currency.format(valorTot);
                    } else if (!_showEntradas && ultSaida != null && dtS != null) {
                      label = 'Ultima saida';
                      nome = cMap[ultSaida.idCliente] ?? 'Cliente ${ultSaida.idCliente}';
                      dataStr = DateFormat('dd/MM/yyyy HH:mm').format(dtS);
                      final b = DateTime(dtS.year, dtS.month, dtS.day, dtS.hour, dtS.minute);
                      double pesoTot = 0, valorTot = 0;
                      for (final s in saidas) {
                        final d = _parseDateTime(s.data).toLocal();
                        final bb = DateTime(d.year, d.month, d.day, d.hour, d.minute);
                        if (s.idCliente == ultSaida.idCliente && bb == b) {
                          pesoTot += s.peso;
                          valorTot += (s.valorTotal ?? (s.peso * s.precoUnitario));
                        }
                      }
                      pesoStr = '${pesoTot.toStringAsFixed(2)} kg';
                      valorStr = currency.format(valorTot);
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('$label:', style: TextStyle(color: on, fontWeight: FontWeight.w700)),
                            const Icon(Icons.person_outline, color: Colors.black, size: 16),
                            Text(nome, style: TextStyle(color: on, fontWeight: FontWeight.w600)),
                            const Icon(Icons.event, color: Colors.black, size: 16),
                            Text(dataStr, style: TextStyle(color: on)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.scale, color: Colors.black, size: 16),
                            Text(pesoStr, style: TextStyle(color: on)),
                            const Icon(Icons.attach_money, color: Colors.black, size: 16),
                            Text(valorStr, style: TextStyle(color: on)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  EntradaService().listar(),
                  SaidaService().listar(),
                ]),
                builder: (context, snap) {
                  double pesoEntradas = 0, valorEntradas = 0;
                  double pesoSaidas = 0, valorSaidas = 0;
                  if (snap.hasData) {
                    final hoje = DateTime.now();
                    final entradas = (snap.data![0] as List<Entrada>);
                    final saidas = (snap.data![1] as List<Saida>);
                    for (final e in entradas) {
                      final dt = _parseDateTime(e.data).toLocal();
                      if (_isSameDay(dt, hoje)) {
                        pesoEntradas += e.peso;
                        valorEntradas += (e.valorTotal ?? (e.peso * e.precoUnitario));
                      }
                    }
                    for (final s in saidas) {
                      final dt = _parseDateTime(s.data).toLocal();
                      if (_isSameDay(dt, hoje)) {
                        pesoSaidas += s.peso;
                        valorSaidas += (s.valorTotal ?? (s.peso * s.precoUnitario));
                      }
                    }
                  }
                  final carregando = snap.connectionState != ConnectionState.done;
                  final erro = snap.hasError;
                  final mostrandoEntradas = _showEntradas;
                  final pesoTxt = carregando
                      ? '...'
                      : (erro
                          ? '--'
                          : '${(mostrandoEntradas ? pesoEntradas : pesoSaidas).toStringAsFixed(2)} kg');
                  final valorTxt = carregando
                      ? '...'
                      : (erro
                          ? '--'
                          : currency.format(mostrandoEntradas ? valorEntradas : valorSaidas));
                  final pesoTitle = mostrandoEntradas ? 'Peso toatl hoje (Entradas)' : 'Peso total hoje (Saídas)';
                  final valorTitle = mostrandoEntradas ? 'Valor total hoje (Entradas)' : 'Valor Total hoje (Saídas)';
                  return Row(
                    children: [
                      Expanded(
                        child: _kpiCard(
                          context,
                          color: cs.primary,
                          title: pesoTitle,
                          value: pesoTxt,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _kpiCard(
                          context,
                          color: const Color(0xFFFBC02D),
                          title: valorTitle,
                          value: valorTxt,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: () {
                    final w = MediaQuery.of(context).size.width;
                    if (w <= 360) return 190.0; // telas bem pequenas
                    if (w <= 400) return 210.0;
                    return 240.0; // padrÃƒÂ£o
                  }(),
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: () {
                    final w = MediaQuery.of(context).size.width;
                    if (w <= 360) return 0.98; // cards um pouco mais altos
                    if (w <= 400) return 1.08;
                    return 1.18;
                  }(),
                ),
                itemBuilder: (context, i) {
                  final items = <Widget>[
                    GaudiosoActionCard(
                      icon: Icons.recycling,
                      title: 'Cadastrar\nMateriais',
                      subtitle: 'Novo item reciclavel',
                      color: kAmber,
                      onTap: () => Navigator.pushNamed(context, '/materiais'),
                    ),
                    GaudiosoActionCard(
                      icon: Icons.handshake,
                      title: 'Parceiros',
                      subtitle: 'Clientes e fornecedores',
                      color: kTeal,
                      onTap: () => Navigator.pushNamed(context, '/parceiros'),
                    ),
                    GaudiosoActionCard(
                      icon: Icons.download_rounded,
                      title: 'Registrar Entrada',
                      subtitle: 'Registrar compra, entrada no estoque',
                      color: kDarkGreen,
                      onTap: () => Navigator.pushNamed(context, '/entrada'),
                    ),
                    GaudiosoActionCard(
                      icon: Icons.upload_rounded,
                      title: 'Registrar Saída',
                      subtitle: 'Registrar venda, saída do estoque',
                      color: kRed,
                      onTap: () => Navigator.pushNamed(context, '/saida'),
                    ),
                  ];
                  return items[i];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(BuildContext context, {required Color color, required String title, required String value}) {
    final on = Colors.black;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              title,
              key: ValueKey<String>('title-'+title),
              style: TextStyle(color: on.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey<String>('value-'+value),
              style: TextStyle(color: on, fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsMenu extends StatelessWidget {
  final String username;
  const _OptionsMenu({required this.username});
  @override
  Widget build(BuildContext context) {
    // Deprecated: kept for reference but unused after drawer introduction
    return const SizedBox.shrink();
  }
}

class _SideOptionsDrawer extends StatelessWidget {
  final String username;
  const _SideOptionsDrawer({required this.username});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF66BB6A), Color.fromARGB(255, 245, 245, 245)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(radius: 24, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.black)),
                  const SizedBox(height: 8),
                  Text(username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text('Configurações'),
              subtitle: const Text('Em breve', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (ctx) => const SafeArea(
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Configurações (em breve)'),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: Colors.black),
              title: const Text('Modo escuro', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modo escuro: em breve')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black),
              title: const Text('Perfil', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(username: username)),
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1, color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sair', style: TextStyle(color: Colors.black)),
              onTap: () async {
                final navigator = Navigator.of(context);
                await AuthService().logout();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// New stylized action card
class GaudiosoActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const GaudiosoActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Stack(
          children: [
            // Top stripe
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
            ),
            // Light background gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      color.withOpacity(0.06),
                    ],
                  ),
                ),
              ),
            ),
            // Content (centered)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, size: 36, color: color),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 12,
                          color: kText.withOpacity(0.55),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovimentarTab2 extends StatefulWidget {
  const _MovimentarTab2();
  @override
  State<_MovimentarTab2> createState() => _MovimentarTab2State();
}

class _MovimentarTab2State extends State<_MovimentarTab2> {
  final _entradaService = EntradaService();
  final _saidaService = SaidaService();
  final _materialService = MaterialService();

  bool _loading = true;
  String? _error;
  List<_MovItem> _itens = [];
  Map<int, String> _materialNomes = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final materiais = await _materialService.listar();
      _materialNomes = {
        for (final m in materiais)
          if (m.id != null) m.id!: m.nome
      };
    } catch (_) {
      _materialNomes = {};
    }
    try {
      final entradas = await _entradaService.listar();
      final saidas = await _saidaService.listar();
      final items = <_MovItem>[];
      for (final e in entradas) {
        items.add(_MovItem(
          tipo: _MovTipo.entrada,
          data: _parseDateTime(e.data),
          peso: e.peso,
          materialId: e.idMaterial,
          entrada: e,
        ));
      }
      for (final s in saidas) {
        items.add(_MovItem(
          tipo: _MovTipo.saida,
          data: _parseDateTime(s.data),
          peso: s.peso,
          materialId: s.idMaterial,
          saida: s,
        ));
      }
      items.sort((a, b) => b.data.compareTo(a.data));
      setState(() {
        _itens = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Tentar novamente'),
            ),
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: _itens.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
          final item = _itens[index];
          final isEntrada = item.tipo == _MovTipo.entrada;
          final baseColor = isEntrada ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
          final tileColor = Colors.white;
          final icon = isEntrada ? LucideIcons.arrowDownToLine : LucideIcons.arrowUpFromLine;
          final mat = _materialNomes[item.materialId] ?? 'Material #${item.materialId}';
          final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(item.data.toLocal());
          return Container(
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: baseColor, child: Icon(icon, color: Colors.white, size: 18)),
              title: Text('$mat Ã¢â‚¬Â¢ ${item.peso.toStringAsFixed(2)} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(isEntrada ? 'Entrada - $dateStr' : 'SaÃƒÂ­da - $dateStr'),
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
}

enum _MovTipo { entrada, saida }

class _MovItem {
  final _MovTipo tipo;
  final DateTime data;
  final double peso;
  final int materialId;
  final Entrada? entrada;
  final Saida? saida;
  _MovItem({
    required this.tipo,
    required this.data,
    required this.peso,
    required this.materialId,
    this.entrada,
    this.saida,
  });
}

// _ActionData no longer needed with GaudiosoActionCard usage





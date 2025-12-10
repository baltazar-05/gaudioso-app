import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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

import 'entradas_screen.dart';
import 'estoque_screen.dart';
import 'splash_screen.dart';
import 'profile/profile_screen.dart';
import 'relatorios_screen.dart';
import 'fluxo_lotes_screen.dart';
import 'cadastros_inativos_screen.dart';
import 'saidas_screen.dart';
import 'user_control_screen.dart';
import 'help_center_sheet.dart';

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
  final String role;
  final int initialIndex;
  const MenuScreen({super.key, required this.username, required this.role, this.initialIndex = 0});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late int _index;
  late final bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.role.toLowerCase() == 'admin';
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _isAdmin
        ? <Widget>[
            _ResumoTab(username: widget.username, isAdmin: true),
            const FluxoLotesScreen(),
            const EstoqueScreen(),
            RelatoriosScreen(username: widget.username, role: widget.role, hideBottomBar: true),
          ]
        : <Widget>[
            _ResumoTab(username: widget.username, isAdmin: false),
            const EntradasScreen(),
            const SaidasScreen(),
          ];

    final safeIndex = _clampIndex(_index, pages.length);

    return Scaffold(
      extendBody: true,
      drawer: _SideOptionsDrawer(
        username: widget.username,
        role: widget.role,
        onNavigateTab: (i) => setState(() => _index = i),
      ),
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: _isAdmin
          ? _EcoBottomBar(
              currentIndex: safeIndex,
              onTap: (i) => setState(() => _index = i),
            )
          : _RestrictedBottomBar(
              currentIndex: safeIndex,
              onTap: (i) => setState(() => _index = i),
            ),
    );
  }

  int _clampIndex(int idx, int length) {
    if (length <= 0) return 0;
    if (idx < 0) return 0;
    if (idx >= length) return length - 1;
    return idx;
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

class _RestrictedBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _RestrictedBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inactive = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final active = Theme.of(context).colorScheme.primary;
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Inicio'},
      {'icon': Icons.download_rounded, 'label': 'Entradas'},
      {'icon': Icons.upload_rounded, 'label': 'Saidas'},
    ];
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              _navItem(
                icon: items[i]['icon'] as IconData,
                label: items[i]['label'] as String,
                index: i,
                active: active,
                inactive: inactive,
              ),
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
  final bool isAdmin;
  const _ResumoTab({required this.username, required this.isAdmin});

  @override
  State<_ResumoTab> createState() => _ResumoTabState();
}

class _ResumoTabState extends State<_ResumoTab> {
  bool _showEntradas = true;
  Timer? _timer;
  static const _toggleEvery = Duration(seconds: 5);
  late final Future<List<dynamic>> _headlineFuture;
  late final Future<List<dynamic>> _movimentosHojeFuture;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_toggleEvery, (_) {
      if (!mounted) return;
      setState(() => _showEntradas = !_showEntradas);
    });
    _headlineFuture = Future.wait([
      EntradaService().listar(),
      SaidaService().listar(),
      ClienteService().listar(),
      FornecedorService().listar(),
    ]);
    _movimentosHojeFuture = Future.wait([
      EntradaService().listar(),
      SaidaService().listar(),
    ]);
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

  void _openHelpCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: HelpCenterSheet(username: widget.username, isAdmin: widget.isAdmin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return LayoutBuilder(
      builder: (context, constraints) {
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
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openHelpCenter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: const Text('Ajuda'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Texto fixo (substitui o antigo ticker)
              FutureBuilder<List<dynamic>>(
                future: _headlineFuture,
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
                      color: scheme.onPrimary.withValues(alpha: 0.18),
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
                future: _movimentosHojeFuture,
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
                itemCount: widget.isAdmin ? 4 : 2,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: () {
                    final w = MediaQuery.of(context).size.width;
                    if (w <= 360) return 190.0;
                    if (w <= 400) return 210.0;
                    return 240.0;
                  }(),
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: () {
                    final w = MediaQuery.of(context).size.width;
                    if (w <= 360) return 0.98;
                    if (w <= 400) return 1.08;
                    return 1.18;
                  }(),
                ),
                itemBuilder: (context, i) {
                  final items = <Widget>[
                    if (widget.isAdmin)
                      GaudiosoActionCard(
                        icon: Icons.recycling,
                        title: 'Cadastrar\nMateriais',
                        subtitle: 'Novo item reciclavel',
                        color: kAmber,
                        onTap: () => Navigator.pushNamed(context, '/materiais'),
                      ),
                    if (widget.isAdmin)
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
                      title: 'Registrar Saida',
                      subtitle: 'Registrar venda, saida do estoque',
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
          ),
        );
      },
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
              key: ValueKey<String>('title-$title'),
              style: TextStyle(color: on.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey<String>('value-$value'),
              style: TextStyle(color: on, fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideOptionsDrawer extends StatefulWidget {
  final String username;
  final String role;
  final ValueChanged<int>? onNavigateTab;
  const _SideOptionsDrawer({required this.username, required this.role, this.onNavigateTab});

  @override
  State<_SideOptionsDrawer> createState() => _SideOptionsDrawerState();
}

class _SideOptionsDrawerState extends State<_SideOptionsDrawer> {
  late Future<File?> _avatarFuture;

  bool get _isAdmin => widget.role.toLowerCase() == 'admin';

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadAvatar();
  }

  String get _avatarFileName {
    final safe = widget.username.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return 'profile_avatar_$safe.png';
  }

  Future<File?> _loadAvatar() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_avatarFileName');
    if (await file.exists()) return file;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xDD66BB6A), Color(0xCC4CAF50)],
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
                    FutureBuilder<File?>(
                      future: _avatarFuture,
                      builder: (context, snap) {
                        final file = snap.data;
                        return CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          backgroundImage: file != null ? FileImage(file) : null,
                          child: file == null ? const Icon(Icons.person, color: Colors.black) : null,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(widget.username, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isAdmin ? const Color(0xFF2E7D32) : const Color(0xFF00BFA6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isAdmin ? 'Admin' : 'Funcionario',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isAdmin)
                    ListTile(
                      leading: const Icon(Icons.security, color: Colors.black),
                      title: const Text('Controle de Usuarios', style: TextStyle(color: Colors.black)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserControlScreen()),
                        );
                      },
                    ),
                  if (_isAdmin)
                    ListTile(
                      leading: const Icon(Icons.archive_outlined, color: Colors.black),
                      title: const Text('Cadastros inativados', style: TextStyle(color: Colors.black)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CadastrosInativosScreen()),
                        );
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('Configuracoes', style: TextStyle(color: Colors.black)),
                    subtitle: Text('Em breve', style: TextStyle(color: Colors.black54)),
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
                            title: Text('Configuracoes (em breve)'),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: Colors.black),
                    title: const Text('Perfil', style: TextStyle(color: Colors.black)),
                    onTap: () async {
                      Navigator.pop(context);
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileScreen(username: widget.username, role: widget.role)),
                      );
                      if (res is int && widget.onNavigateTab != null) {
                        widget.onNavigateTab!(res);
                      }
                      setState(() {
                        _avatarFuture = _loadAvatar();
                      });
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
        ),
      ),
    );
  }
}

class GaudiosoActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const GaudiosoActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      color.withValues(alpha: 0.06),
                    ],
                  ),
                ),
              ),
            ),
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
                        color: kText.withValues(alpha: 0.55),
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
              title: Text('$mat - ${item.peso.toStringAsFixed(2)} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(isEntrada ? 'Entrada - $dateStr' : 'Saida - $dateStr'),
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





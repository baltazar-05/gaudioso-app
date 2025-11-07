import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/material.dart';
import '../services/material_service.dart';
import 'material_form_screen.dart';
import 'package:gaudioso_app/screens/menu_screen.dart';
import '../services/auth_service.dart';

class MateriaisScreen extends StatefulWidget {
  const MateriaisScreen({super.key});

  @override
  State<MateriaisScreen> createState() => _MateriaisScreenState();
}

class _MateriaisScreenState extends State<MateriaisScreen> {
  final service = MaterialService();
  final _buscaCtrl = TextEditingController();
  List<MaterialItem> materiais = [];
  List<MaterialItem> filtrados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final data = await service.listar();
    data.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    setState(() {
      materiais = data;
      filtrados = _filtrar(_buscaCtrl.text, data);
      carregando = false;
    });
  }

  Future<void> _abrirFormulario({MaterialItem? item}) async {
    final mudou = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MaterialFormScreen(item: item),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (mudou == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = scheme.surface;
    final fabBg = Theme.of(context).floatingActionButtonTheme.backgroundColor ?? scheme.tertiary;
    final badgeColor = Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.recycle, size: 22, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              'Materiais',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (q) => setState(() {
                      filtrados = _filtrar(q, materiais);
                    }),
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome do material',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      prefixIcon: const Icon(LucideIcons.search, color: Colors.black87),
                      filled: true,
                      fillColor: cardColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: scheme.primary),
                      ),
                    ),
                  ),
                ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: carregar,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        itemCount: filtrados.length,
                        itemBuilder: (_, i) {
                          final m = filtrados[i];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.recycle,
                                    color: badgeColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.nome,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: Colors.black87, fontSize: 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Compra: R\$ ${m.precoCompra.toStringAsFixed(2)} | Venda: R\$ ${m.precoVenda.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(LucideIcons.pencil, color: Colors.black87),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        highlightColor: Colors.black12,
                                      ),
                                      onPressed: () => _abrirFormulario(item: m),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        highlightColor: Colors.redAccent.withValues(alpha: 0.12),
                                      ),
                                      onPressed: () async {
                                        await service.excluir(m.id!);
                                        if (!context.mounted) return;
                                        carregar();
                                      },
                                    ),
                                  ],
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
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      bottomNavigationBar: _shortcutBottomBar(context),
    );
  }

  Widget _shortcutBottomBar(BuildContext context) {
    final inactive = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    Future<void> go(int index) async {
      final user = await AuthService().currentUser();
      final display = (user?['nome'] ?? user?['username'] ?? '') as String;
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MenuScreen(username: display, initialIndex: index)),
        (route) => false,
      );
    }
    Widget navItem({required IconData icon, required String label, required int index}) {
      return GestureDetector(
        onTap: () => go(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: inactive, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, color: inactive)),
            ],
          ),
        ),
      );
    }
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(icon: Icons.home_outlined, label: 'Resumo', index: 0),
            navItem(icon: LucideIcons.arrowDownUp, label: 'Fluxo', index: 1),
            navItem(icon: LucideIcons.database, label: 'Estoque', index: 2),
            navItem(icon: LucideIcons.chartBar, label: 'Relatórios', index: 3),
          ],
        ),
      ),
    );
  }
}

extension _Filtro on _MateriaisScreenState {
  List<MaterialItem> _filtrar(String q, List<MaterialItem> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) {
      final copy = List<MaterialItem>.from(base);
      copy.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return copy;
    }
    final result = base.where((m) => m.nome.toLowerCase().contains(termo)).toList();
    result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return result;
  }
}















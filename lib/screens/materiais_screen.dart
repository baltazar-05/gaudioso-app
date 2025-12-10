import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/material.dart';
import '../services/material_service.dart';
import 'material_form_screen.dart';
import '../widgets/app_bottom_nav.dart';

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
    final data = await service.listar(ativo: true);
    final ativos = data
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    setState(() {
      materiais = ativos;
      filtrados = _filtrar(_buscaCtrl.text, ativos);
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
                                        bool salvando = false;
                                        final ok = await showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (ctx) {
                                            return StatefulBuilder(
                                              builder: (ctx, setDlg) {
                                                return AlertDialog(
                                                  title: const Text('Inativar material'),
                                                  content: Text('Deseja inativar ${m.nome}?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: salvando ? null : () => Navigator.pop(ctx, false),
                                                      child: const Text('Cancelar', style: TextStyle(color: Colors.black87)),
                                                    ),
                                                    FilledButton(
                                                      style: FilledButton.styleFrom(foregroundColor: Colors.black87),
                                                      onPressed: salvando
                                                          ? null
                                                          : () async {
                                                              setDlg(() => salvando = true);
                                                              try {
                                                                await service.inativar(m.id!);
                                                                if (mounted) Navigator.pop(ctx, true);
                                                              } catch (e) {
                                                                if (mounted) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(content: Text('Erro ao inativar: $e')),
                                                                  );
                                                                }
                                                                setDlg(() => salvando = false);
                                                              }
                                                            },
                                                      child: salvando
                                                          ? const SizedBox(
                                                              height: 18,
                                                              width: 18,
                                                              child: CircularProgressIndicator(strokeWidth: 2),
                                                            )
                                                          : const Text('Inativar'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                        if (ok == true && mounted) {
                                          await carregar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Material inativado')),
                                          );
                                        }
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
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















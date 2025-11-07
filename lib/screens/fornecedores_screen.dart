import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/fornecedor.dart';
import '../services/fornecedor_service.dart';
import 'fornecedor_form_screen.dart';

class FornecedoresScreen extends StatefulWidget {
  const FornecedoresScreen({super.key});

  @override
  State<FornecedoresScreen> createState() => _FornecedoresScreenState();
}

class _FornecedoresScreenState extends State<FornecedoresScreen> {
  final service = FornecedorService();
  final _buscaCtrl = TextEditingController();
  List<Fornecedor> fornecedores = [];
  List<Fornecedor> filtrados = [];
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
    final data = await service.listar();
    data.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    if (!mounted) return;
    setState(() {
      fornecedores = data;
      filtrados = _filtrar(_buscaCtrl.text, data);
      carregando = false;
    });
  }

  Future<void> _abrirFormulario({Fornecedor? f}) async {
    final mudou = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FornecedorFormScreen(fornecedor: f),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(anim),
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
    final card = scheme.surface;
    final accent = scheme.onSurface;
    const iconColor = Colors.black87;
    const deleteColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.users, color: Color.fromARGB(255, 0, 0, 0)),
            SizedBox(width: 8),
            Text(
              'Fornecedores',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        foregroundColor: Colors.white,
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
                      filtrados = _filtrar(q, fornecedores);
                    }),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome do fornecedor',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: accent.withValues(alpha: 0.54)),
                      prefixIcon: Icon(LucideIcons.search, color: iconColor),
                      filled: true,
                      fillColor: card,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: accent.withValues(alpha: 0.54),
                        ),
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
                    child: filtrados.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              _EmptyState(
                                icon: LucideIcons.user,
                                texto: 'Nenhum fornecedor encontrado',
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            itemCount: filtrados.length,
                            itemBuilder: (_, i) {
                              final f = filtrados[i];
                              final id = f.id ?? i;
                              return Card(
                                elevation: 1.5,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Hero(
                                    tag: 'fornecedor_$id',
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          LucideIcons.user,
                                          color: iconColor,
                                        ),
                                      ),
                                  ),
                                  title: Text(
                                    f.nome,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: accent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Wrap(
                                      spacing: 12,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        _IconText(
                                          icon: LucideIcons.idCard,
                                          text: f.documento,
                                          color: accent,
                                          iconColor: iconColor,
                                        ),
                                        _IconText(
                                          icon: LucideIcons.phone,
                                          text: f.telefone,
                                          color: accent,
                                          iconColor: iconColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(LucideIcons.pencil, color: iconColor),
                                        onPressed: () => _abrirFormulario(f: f),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(LucideIcons.trash2, color: deleteColor),
                                        onPressed: () async {
                                          await service.excluir(f.id!);
                                          if (!context.mounted) return;
                                          carregar();
                                        },
                                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor:
            Theme.of(context).floatingActionButtonTheme.backgroundColor ??
            scheme.tertiary,
        child: Icon(LucideIcons.plus, color: iconColor),
      ),
    );
  }
}

extension _FornecedorFiltro on _FornecedoresScreenState {
  List<Fornecedor> _filtrar(String q, List<Fornecedor> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) {
      final copy = List<Fornecedor>.from(base);
      copy.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return copy;
    }
    final result = base
        .where((f) => f.nome.toLowerCase().contains(termo))
        .toList();
    result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return result;
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color iconColor;

  const _IconText({
    required this.icon,
    required this.text,
    required this.color,
    this.iconColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: color.withValues(alpha: 0.87)),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _EmptyState({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.54);
    return Column(
      children: [
        Icon(icon, size: 48, color: Colors.black54),
        const SizedBox(height: 8),
        Text(
          texto,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

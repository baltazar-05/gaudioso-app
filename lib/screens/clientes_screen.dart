import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import 'package:gaudioso_app/screens/cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final service = ClienteService();
  final _buscaCtrl = TextEditingController();
  List<Cliente> clientes = [];
  List<Cliente> filtrados = [];
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
      const docGenerico = 'GEN-CLIENTE';
      final data = await service.listar(ativo: true);
      data.removeWhere((c) => c.documento == docGenerico);
      if (!mounted) return;
      data.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      setState(() {
        clientes = data;
        filtrados = _filtrar(_buscaCtrl.text, data);
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        carregando = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao carregar clientes: $e')));
    }
  }

  Future<void> _abrirFormulario({Cliente? c}) async {
    final mudou = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ClienteFormScreen(cliente: c),
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
    final card = scheme.surface;
    final accent = scheme.onSurface;
    const iconColor = Colors.black87;
    const deleteColor = Colors.redAccent;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.users, color: Color.fromARGB(255, 0, 0, 0)),
            SizedBox(width: 8),
            Text(
              'Clientes',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: TextField(
                      controller: _buscaCtrl,
                      onChanged: (q) => setState(() {
                        filtrados = _filtrar(q, clientes);
                      }),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nome do cliente',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: accent.withValues(alpha: 0.54)),
                        prefixIcon: Icon(LucideIcons.search, color: iconColor),
                        filled: true,
                        fillColor: card,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accent.withValues(alpha: 0.54)),
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
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: Center(
                                    child: Text(
                                      'Nenhum cliente encontrado',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: accent),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              itemCount: filtrados.length,
                              itemBuilder: (_, i) {
                                final c = filtrados[i];
                                final id = c.id ?? i;
                                final doc = c.documento.isNotEmpty
                                    ? c.documento
                                    : 'Sem documento';
                                final phone = c.telefone.isNotEmpty
                                    ? c.telefone
                                    : 'Sem telefone';
                                return Card(
                                  elevation: 1.5,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: card,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Hero(
                                      tag: 'cliente_$id',
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                        child: Icon(LucideIcons.user, color: iconColor),
                                      ),
                                    ),
                                    title: Text(
                                      c.nome,
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
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          _IconText(
                                            icon: LucideIcons.idCard,
                                            text: doc,
                                            color: accent,
                                            iconColor: iconColor,
                                          ),
                                          _IconText(
                                            icon: LucideIcons.phone,
                                            text: phone,
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
                                          icon: Icon(
                                            LucideIcons.pencil,
                                            color: iconColor,
                                          ),
                                          onPressed: () => _abrirFormulario(c: c),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(
                                            LucideIcons.trash2,
                                            color: deleteColor,
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
                                                      title: const Text('Inativar cliente'),
                                                    content: Text('Deseja inativar ${c.nome}?'),
                                                    actions: [
                                                      TextButton(
                                                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                                                        onPressed: salvando ? null : () => Navigator.pop(ctx, false),
                                                        child: const Text('Cancelar'),
                                                      ),
                                                      FilledButton(
                                                        style: FilledButton.styleFrom(foregroundColor: Colors.black),
                                                        onPressed: salvando
                                                            ? null
                                                            : () async {
                                                                setDlg(() => salvando = true);
                                                                try {
                                                                    await service.inativar(c.id!);
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
                                                const SnackBar(content: Text('Cliente inativado')),
                                              );
                                            }
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
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor ?? scheme.tertiary,
        child: Icon(LucideIcons.plus, color: Colors.black87),
      ),
    );
  }
}

extension _ClienteFiltro on _ClientesScreenState {
  List<Cliente> _filtrar(String q, List<Cliente> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) {
      final copy = List<Cliente>.from(base);
      copy.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return copy;
    }
    final result = base.where((c) => c.nome.toLowerCase().contains(termo)).toList();
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
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: color.withValues(alpha: 0.9), fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

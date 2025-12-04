import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/cliente.dart';
import '../services/cliente_service.dart';
import 'cliente_form_screen.dart';

class ClientesInativosScreen extends StatefulWidget {
  const ClientesInativosScreen({super.key});

  @override
  State<ClientesInativosScreen> createState() => _ClientesInativosScreenState();
}

class _ClientesInativosScreenState extends State<ClientesInativosScreen> {
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

  Future<void> carregar() async {
    final data = await service.listar(ativo: false);
    data.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    if (!mounted) return;
    setState(() {
      clientes = data;
      filtrados = _filtrar(_buscaCtrl.text, data);
      carregando = false;
    });
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
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
            Text('Clientes inativados', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
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
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: TextField(
                      controller: _buscaCtrl,
                      onChanged: (q) => setState(() => filtrados = _filtrar(q, clientes)),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nome do cliente',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent.withValues(alpha: 0.54)),
                        prefixIcon: const Icon(LucideIcons.search, color: iconColor),
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
                          ? ListView(children: const [
                              SizedBox(height: 80),
                              Center(child: Text('Nenhum cliente inativado')),
                            ])
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              itemCount: filtrados.length,
                              itemBuilder: (_, i) {
                                final c = filtrados[i];
                                final id = c.id ?? i;
                                final doc = c.documento.isNotEmpty ? c.documento : 'Sem documento';
                                final phone = c.telefone.isNotEmpty ? c.telefone : 'Sem telefone';
                                return Card(
                                  elevation: 1.5,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  color: card,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Hero(
                                      tag: 'cliente_inativo_$id',
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                        child: const Icon(LucideIcons.user, color: Colors.black87),
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
                                          _IconText(icon: LucideIcons.idCard, text: doc, color: accent),
                                          _IconText(icon: LucideIcons.phone, text: phone, color: accent),
                                        ],
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.pencil, color: Colors.black87),
                                          onPressed: () => _abrirFormulario(c: c),
                                        ),
                                        IconButton(
                                          icon: const Icon(LucideIcons.refreshCcw, color: Color(0xFF2E7D32)),
                                          onPressed: () async {
                                            bool salvando = false;
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (ctx) {
                                                return StatefulBuilder(
                                                  builder: (ctx, setDlg) {
                                                    return AlertDialog(
                                                      title: const Text('Reativar cliente'),
                                                      content: Text('Deseja reativar "${c.nome}"?'),
                                                      actions: [
                                                        TextButton(onPressed: salvando ? null : () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                                        FilledButton(
                                                          onPressed: salvando
                                                              ? null
                                                              : () async {
                                                                  setDlg(() => salvando = true);
                                                                  try {
                                                                    await service.reativar(c.id!);
                                                                    if (mounted) Navigator.pop(ctx, true);
                                                                  } catch (e) {
                                                                    if (mounted) {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao reativar: $e')));
                                                                    }
                                                                    setDlg(() => salvando = false);
                                                                  }
                                                                },
                                                          child: salvando
                                                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                                              : const Text('Reativar'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                            if (ok == true && mounted) {
                                              await carregar();
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente reativado')));
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
    );
  }

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

  const _IconText({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.withValues(alpha: 0.9))),
      ],
    );
  }
}

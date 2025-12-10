import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuariosInativosScreen extends StatefulWidget {
  const UsuariosInativosScreen({super.key});

  @override
  State<UsuariosInativosScreen> createState() => _UsuariosInativosScreenState();
}

class _UsuariosInativosScreenState extends State<UsuariosInativosScreen> {
  final _service = UsuarioService();
  final _buscaCtrl = TextEditingController();
  List<Usuario> usuarios = [];
  List<Usuario> filtrados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final data = await _service.listar(ativo: false);
    data.usuarios.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    if (!mounted) return;
    setState(() {
      usuarios = data.usuarios;
      filtrados = _filtrar(_buscaCtrl.text, data.usuarios);
      carregando = false;
    });
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final card = scheme.surface;
    final accent = scheme.onSurface;
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
            Icon(LucideIcons.userX, color: Colors.black),
            SizedBox(width: 8),
            Text('Usuarios inativados', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
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
                      onChanged: (q) => setState(() => filtrados = _filtrar(q, usuarios)),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nome ou username',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent.withValues(alpha: 0.54)),
                        prefixIcon: const Icon(LucideIcons.search, color: Colors.black87),
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
                              Center(child: Text('Nenhum usuario inativado')),
                            ])
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              itemCount: filtrados.length,
                              itemBuilder: (_, i) {
                                final u = filtrados[i];
                                return Card(
                                  elevation: 1.5,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  color: card,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: (u.isAdmin ? const Color(0xFF2E7D32) : const Color(0xFF00ACC1)).withValues(alpha: 0.14),
                                      child: Icon(u.isAdmin ? LucideIcons.shieldX : LucideIcons.userX, color: Colors.black87),
                                    ),
                                    title: Text(
                                      u.nome,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: accent,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(u.username, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent.withValues(alpha: 0.8))),
                                          const SizedBox(height: 6),
                                          _roleChip(u.role),
                                        ],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(LucideIcons.refreshCcw, color: Color(0xFF2E7D32)),
                                      onPressed: () => _confirmReativar(u),
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

  List<Usuario> _filtrar(String q, List<Usuario> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) {
      final copy = List<Usuario>.from(base);
      copy.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return copy;
    }
    final result = base.where((u) => u.nome.toLowerCase().contains(termo) || u.username.toLowerCase().contains(termo)).toList();
    result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return result;
  }

  Widget _roleChip(String role) {
    final isAdmin = role.toLowerCase() == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFF2E7D32).withValues(alpha: 0.14) : const Color(0xFF00BFA6).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAdmin ? const Color(0xFF2E7D32) : const Color(0xFF00BFA6)),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Funcionario',
        style: TextStyle(
          color: isAdmin ? const Color(0xFF2E7D32) : const Color(0xFF00BFA6),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _confirmReativar(Usuario user) async {
    bool salvando = false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlg) {
            return AlertDialog(
              title: const Text('Reativar usuario'),
              content: Text('Deseja reativar "${user.username}"?'),
              actions: [
                TextButton(onPressed: salvando ? null : () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                FilledButton(
                  onPressed: salvando
                      ? null
                      : () async {
                          setDlg(() => salvando = true);
                          try {
                            await _service.reativar(user.id);
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario reativado')));
    }
  }
}

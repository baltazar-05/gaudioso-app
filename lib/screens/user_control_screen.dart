import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';

class UserControlScreen extends StatefulWidget {
  const UserControlScreen({super.key});

  @override
  State<UserControlScreen> createState() => _UserControlScreenState();
}

class _UserControlScreenState extends State<UserControlScreen> {
  final _service = UsuarioService();
  final _auth = AuthService();
  UsuarioResumo? _resumo;
  bool _loading = true;
  String? _error;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final user = await _auth.currentUser();
    setState(() {
      _currentUserId = _extractId(user);
    });
    await _load();
  }

  int? _extractId(Map<String, dynamic>? json) {
    if (json == null) return null;
    final raw = json['id'] ?? json['userId'] ?? json['idUsuario'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.listar(ativo: true);
      if (!mounted) return;
      setState(() {
        _resumo = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Usuarios'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        backgroundColor: const Color(0xFF00BFA6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
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

    final data = _resumo;
    if (data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _buildResumoCard(data),
          const SizedBox(height: 12),
          if (data.usuarios.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Nenhum usuario ativo',
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final u in data.usuarios) _buildUserCard(u),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildResumoCard(UsuarioResumo resumo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Usuarios ativos: ${resumo.total}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Admins: ${resumo.admins}', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Funcionarios: ${resumo.funcionarios}', style: const TextStyle(color: Color(0xFF00ACC1), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildUserCard(Usuario u) {
    final isPrincipal = u.username.toLowerCase() == 'admin' || u.id == 1;
    final canAlterStatus = !isPrincipal && (_currentUserId == null ? true : _currentUserId != u.id);
    final avatarColor = u.isAdmin ? const Color(0xFF2E7D32) : const Color(0xFF00ACC1);
    final avatarIcon = u.isAdmin ? LucideIcons.shieldCheck : LucideIcons.userRound;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: avatarColor.withValues(alpha: 0.16),
          child: Icon(avatarIcon, color: avatarColor),
        ),
        title: Text(u.nome, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(u.username, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            _roleChip(u.role),
          ],
        ),
        trailing: isPrincipal
            ? const SizedBox(width: 1)
            : PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showRoleDialog(u);
                      break;
                    case 'inactivate':
                      _confirmInativar(u);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Editar permissao'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'inactivate',
                    enabled: canAlterStatus,
                    child: const Row(
                      children: [
                        Icon(Icons.pause_circle_outline, color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Inativar', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
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

  Future<void> _showRoleDialog(Usuario user) async {
    if (user.username.toLowerCase() == 'admin' || user.id == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Administrador principal nao pode ser alterado')),
      );
      return;
    }
    String selected = user.isAdmin ? 'admin' : 'funcionario';
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alterar permissao de ${user.username}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'admin', label: Text('Admin')),
                      ButtonSegment(value: 'funcionario', label: Text('Funcionario')),
                    ],
                    selected: {selected},
                    onSelectionChanged: (v) => setModal(() => selected = v.first),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _updateRole(user, selected);
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateRole(Usuario user, String role) async {
    try {
      await _service.alterarRole(user.id, role);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissao de ${user.username} atualizada para $role')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  Future<void> _confirmInativar(Usuario user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inativar usuario?'),
        content: Text('Deseja inativar ${user.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Inativar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.inativar(user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario ${user.username} inativado')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao inativar: $e')),
      );
    }
  }

  Future<bool> _showCreateConfirmDialog({
    required String username,
    required String nome,
    required String senha,
    required String role,
  }) async {
    bool saving = false;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) {
            return StatefulBuilder(
              builder: (dialogCtx, setDialog) {
                return AlertDialog(
                  title: const Text('Confirmar novo usuario'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usuario: $username'),
                      Text('Nome: $nome'),
                      Text('Permissao: ${role == 'admin' ? 'Admin' : 'Funcionario'}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: saving ? null : () => Navigator.pop(dialogCtx, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setDialog(() => saving = true);
                              try {
                                await _service.criar(username, senha, nome, role: role);
                                if (!mounted || !dialogCtx.mounted) return;
                                Navigator.pop(dialogCtx, true);
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao criar usuario: $e')),
                                );
                                setDialog(() => saving = false);
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;
  }

  Future<void> _openCreateDialog() async {
    final nomeCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final senhaCtrl = TextEditingController();
    final confirmaSenhaCtrl = TextEditingController();
    String role = 'funcionario';
    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final bottom = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Novo usuario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nomeCtrl,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: userCtrl,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: senhaCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Senha'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmaSenhaCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Repetir senha'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Permissao', style: TextStyle(fontWeight: FontWeight.w600)),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'funcionario', label: Text('Funcionario')),
                        ButtonSegment(value: 'admin', label: Text('Admin')),
                      ],
                      selected: {role},
                      onSelectionChanged: (v) => setModal(() => role = v.first),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: submitting
                          ? null
                          : () async {
                              if (userCtrl.text.trim().toLowerCase() == 'admin') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Username admin é reservado')),
                                );
                                return;
                              }
                              final nome = nomeCtrl.text.trim();
                              final user = userCtrl.text.trim();
                              final senha = senhaCtrl.text;
                              final confirmar = confirmaSenhaCtrl.text;
                              if (user.isEmpty || senha.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Preencha usuario e senha')),
                                );
                                return;
                              }
                              if (confirmar.isEmpty || confirmar != senha) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Senhas nao conferem')),
                                );
                                return;
                              }
                              setModal(() => submitting = true);
                              final created = await _showCreateConfirmDialog(
                                username: user,
                                nome: nome.isEmpty ? user : nome,
                                senha: senha,
                                role: role,
                              );
                              if (!mounted || !ctx.mounted) return;
                              if (created) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Usuario $user criado')),
                                );
                                await _load();
                              } else {
                                setModal(() => submitting = false);
                              }
                            },
                      icon: const Icon(Icons.check),
                      label: Text(submitting ? 'Salvando...' : 'Criar usuario'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

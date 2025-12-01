import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/usuario_service.dart';

const kText = Color(0xFF1F2937);
const kGreen = Color(0xFF4CAF50);
const kTeal = Color(0xFF00BFA6);
const kDarkGreen = Color(0xFF2E7D32);
const kRed = Color(0xFFE53935);

class ControleUsuariosScreen extends StatefulWidget {
  const ControleUsuariosScreen({super.key});

  @override
  State<ControleUsuariosScreen> createState() => _ControleUsuariosScreenState();
}

class _ControleUsuariosScreenState extends State<ControleUsuariosScreen> {
  final _usuarioService = UsuarioService();
  List<Map<String, dynamic>> usuarios = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    try {
      setState(() {
        _carregando = true;
        _erro = null;
      });
      final listaUsuarios = await _usuarioService.listar();
      setState(() {
        usuarios = listaUsuarios;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Controle de Usuários'),
          elevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: kText,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_erro != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Controle de Usuários'),
          elevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: kText,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.error_outline, size: 64, color: kRed),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Erro ao carregar usuários',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kRed),
                        ),
                        child: Text(
                          _erro ?? 'Erro desconhecido',
                          style: const TextStyle(fontSize: 14, color: kText),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _carregarUsuarios,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Usuários'),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: kText,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: usuarios.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum usuário cadastrado',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddUserDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Usuário'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _carregarUsuarios,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total de Usuários: ${usuarios.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Admins: ${usuarios.where((u) => u['role'] == 'admin').length}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: kDarkGreen,
                            ),
                          ),
                          Text(
                            'Funcionários: ${usuarios.where((u) => u['role'] != 'admin').length}',
                            style: const TextStyle(fontSize: 14, color: kTeal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...usuarios.map((usuario) {
                      final isAdmin = usuario['role'] == 'admin';
                      return _UsuarioCard(
                        usuario: usuario,
                        isAdmin: isAdmin,
                        onEditRole: () =>
                            _showEditRoleDialog(context, 0, usuario),
                        onDelete: () => _deletarUsuario(usuario['id']),
                      );
                    }).toList(),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: kGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditRoleDialog(
    BuildContext context,
    int index,
    Map<String, dynamic> usuario,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Alterar permissão de ${usuario['nome']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Admin'),
              value: 'admin',
              groupValue: usuario['role'],
              onChanged: (value) {
                _alterarPermissao(usuario['id'], 'admin');
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('Funcionário'),
              value: 'funcionario',
              groupValue: usuario['role'],
              onChanged: (value) {
                _alterarPermissao(usuario['id'], 'funcionario');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _alterarPermissao(int usuarioId, String novaPermissao) async {
    try {
      await _usuarioService.alterarPermissao(usuarioId, novaPermissao);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão alterada para $novaPermissao')),
        );
        _carregarUsuarios();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  Future<void> _deletarUsuario(int usuarioId) async {
    try {
      await _usuarioService.deletarUsuario(usuarioId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário deletado com sucesso')),
        );
        _carregarUsuarios();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  void _showAddUserDialog(BuildContext context) {
    final nomeController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    String selectedRole = 'funcionario';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Usuário'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Ex: João Silva',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Ex: joao.silva',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Ex: joao@example.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Mínimo 6 caracteres',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'funcionario',
                    child: Text('Funcionário'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) selectedRole = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Papel',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty &&
                  usernameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty &&
                  senhaController.text.isNotEmpty) {
                try {
                  await _usuarioService.criarUsuario(
                    nomeController.text,
                    usernameController.text,
                    senhaController.text,
                    selectedRole,
                  );
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Usuário ${nomeController.text} adicionado com sucesso',
                        ),
                      ),
                    );
                    _carregarUsuarios();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Erro: $e')));
                  }
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final bool isAdmin;
  final VoidCallback onEditRole;
  final VoidCallback onDelete;

  const _UsuarioCard({
    required this.usuario,
    required this.isAdmin,
    required this.onEditRole,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = isAdmin ? kDarkGreen : kTeal;
    final roleTxt = isAdmin ? 'Admin' : 'Funcionário';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
          child: Icon(
            isAdmin ? LucideIcons.shield : LucideIcons.user,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          usuario['nome'],
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              usuario['username'] ?? usuario['email'] ?? '--',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              usuario['email'] ?? '--',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                roleTxt,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: roleColor,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (ctx) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Editar permissão'),
                ],
              ),
              onTap: onEditRole,
            ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 18, color: kRed),
                  SizedBox(width: 8),
                  Text('Deletar', style: TextStyle(color: kRed)),
                ],
              ),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

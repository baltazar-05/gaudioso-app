import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'materiais_inativos_screen.dart';
import 'clientes_inativos_screen.dart';
import 'fornecedores_inativos_screen.dart';
import 'usuarios_inativos_screen.dart';

class CadastrosInativosScreen extends StatelessWidget {
  const CadastrosInativosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _InativoItem(
        icon: LucideIcons.archive,
        title: 'Materiais inativados',
        subtitle: 'Visualizar e reativar materiais',
        builder: (_) => const MateriaisInativosScreen(),
      ),
      _InativoItem(
        icon: LucideIcons.users,
        title: 'Clientes inativados',
        subtitle: 'Visualizar e reativar clientes',
        builder: (_) => const ClientesInativosScreen(),
      ),
      _InativoItem(
        icon: LucideIcons.usersRound,
        title: 'Fornecedores inativados',
        subtitle: 'Visualizar e reativar fornecedores',
        builder: (_) => const FornecedoresInativosScreen(),
      ),
      _InativoItem(
        icon: LucideIcons.userX,
        title: 'Usuarios inativados',
        subtitle: 'Visualizar e reativar usuarios',
        builder: (_) => const UsuariosInativosScreen(),
      ),
    ];
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

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
        title: const Text('Cadastros inativados', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final it = items[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: scheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  child: Icon(it.icon, color: Colors.black87),
                ),
                title: Text(it.title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                subtitle: Text(it.subtitle, style: const TextStyle(color: Colors.black54)),
                trailing: const Icon(Icons.chevron_right, color: Colors.black54),
                onTap: () {
                  Navigator.push(ctx, MaterialPageRoute(builder: it.builder));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InativoItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;
  _InativoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });
}

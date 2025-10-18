import 'package:flutter/material.dart';
import 'package:gaudioso_app/screens/login/login_screen.dart';
import 'package:gaudioso_app/services/auth_service.dart';
import 'materiais_screen.dart';
import 'cadastros_screen.dart';
import 'entradas_screen.dart';
import 'saidas_screen.dart';
import 'estoque_screen.dart';
import 'relatorios_screen.dart';

class MenuScreen extends StatelessWidget {
  final String userEmail;

  const MenuScreen({
    super.key,
    required this.userEmail,
  });

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.black),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade400,
      appBar: AppBar(
        title: const Text('Gaudioso Reciclagens'),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('usuário'),
              accountEmail: Text(userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
              decoration: const BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('Perfil', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Sair', style: TextStyle(color: Colors.black)),
              onTap: () {
                AuthService().logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Painel de Controle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  icon: Icons.inventory,
                  label: 'Cadastrar\nMateriais',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MateriaisScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.people,
                  label: 'Gerenciar\nParceiros',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CadastrosScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.arrow_downward,
                  label: 'Registrar\nEntrada',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EntradasScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.arrow_upward,
                  label: 'Registrar\nSaída',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SaidasScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.search,
                  label: 'Consultar\nEstoque',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EstoqueScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  icon: Icons.bar_chart,
                  label: 'Relatórios',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RelatoriosScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '© 2025 Gaudioso Reciclagens',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'fornecedores_screen.dart';
import 'clientes_screen.dart';

class CadastrosScreen extends StatelessWidget {
  const CadastrosScreen({super.key});

  Widget _buildCadastroButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final radius = BorderRadius.circular(26);
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Stack(
          children: [
            // Faixa superior
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
            ),
            // Gradiente leve no fundo
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      color.withValues(alpha: 0.06),
                    ],
                  ),
                ),
              ),
            ),
            // Conteúdo
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 36, color: Colors.black),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        centerTitle: true,
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
        title: Text(
          "Gerenciar Parceiros",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
        ),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Escolha um cadastro",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCadastroButton(
                  context,
                  icon: Icons.groups,
                  label: "Fornecedores",
                  color: const Color(0xFF00BFA6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FornecedoresScreen(),
                      ),
                    );
                  },
                ),
                _buildCadastroButton(
                  context,
                  icon: Icons.groups,
                  label: "Clientes",
                  color: const Color(0xFF00BFA6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientesScreen(), // 👈 chama CRUD de clientes
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}





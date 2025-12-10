import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../screens/menu_screen.dart';
import '../services/auth_service.dart';

/// Bottom navigation shared across the app.
/// - Admin: Resumo, Fluxo, Estoque, Relatorios.
/// - Funcionario: Inicio, Entradas, Saidas.
class AppBottomNav extends StatefulWidget {
  final int? currentIndex;
  final String? username;
  final String? role;
  const AppBottomNav({super.key, this.currentIndex, this.username, this.role});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  String? _username;
  String? _role;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.username == null || widget.role == null) {
      _bootstrapUser();
    } else {
      _username = widget.username;
      _role = widget.role;
    }
  }

  Future<void> _bootstrapUser() async {
    setState(() => _loading = true);
    final auth = AuthService();
    final user = await auth.currentUser();
    if (!mounted) return;
    setState(() {
      _username = (user?['username'] ?? '') as String?;
      _role = (user?['role'] ?? user?['perfil'] ?? 'admin') as String?;
      _loading = false;
    });
  }

  bool get _isAdmin => (_role ?? 'admin').toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final inactive = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final active = Theme.of(context).colorScheme.primary;
    final items = _isAdmin
        ? const [
            _NavData(icon: Icons.home_outlined, label: 'Resumo'),
            _NavData(icon: LucideIcons.arrowDownUp, label: 'Fluxo'),
            _NavData(icon: LucideIcons.database, label: 'Estoque'),
            _NavData(icon: LucideIcons.chartBar, label: 'Relatorios'),
          ]
        : const [
            _NavData(icon: Icons.home_outlined, label: 'Inicio'),
            _NavData(icon: Icons.download_rounded, label: 'Entradas'),
            _NavData(icon: Icons.upload_rounded, label: 'Saidas'),
          ];

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 64,
        child: _loading
            ? const Center(
                child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _NavItem(
                      icon: items[i].icon,
                      label: items[i].label,
                      index: i,
                      selected: widget.currentIndex == i,
                      active: active,
                      inactive: inactive,
                      onTap: () => _goTo(i),
                    ),
                ],
              ),
      ),
    );
  }

  void _goTo(int index) {
    if (_loading || _username == null || _role == null) return;
    if (widget.currentIndex != null && widget.currentIndex == index) return;
    final target = _resolveMenuIndex(_role!, index);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MenuScreen(
          username: _username!,
          role: _role!,
          initialIndex: target,
        ),
      ),
      (route) => false,
    );
  }

  int _resolveMenuIndex(String role, int requested) {
    if (role.toLowerCase() == 'admin') return requested;
    if (requested < 0) return 0;
    if (requested > 2) return 2;
    return requested;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final Color active;
  final Color inactive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.active,
    required this.inactive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? active : inactive, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: selected ? active : inactive)),
          ],
        ),
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final String label;
  const _NavData({required this.icon, required this.label});
}

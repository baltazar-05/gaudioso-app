import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'package:gaudioso_app/screens/login/login_screen.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _start();
  }

  Future<void> _start() async {
    _controller.forward();
    // Autenticação em paralelo à animação
    final user = await _auth.currentUser();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final destination = (user != null && user.isNotEmpty)
        ? MenuScreen(username: (user['nome'] ?? user['username'] ?? '') as String)
        : const LoginScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('♻️', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 72, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'Gaudioso Reciclagens',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.87),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

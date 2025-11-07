import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gaudioso_app/screens/menu_screen.dart';
import 'package:gaudioso_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = DraggableScrollableController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();

  @override
  void dispose() {
    _scroll.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isRegistering) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final loginId = _usernameCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    String? err;
    if (isRegistering) {
      if (_confirmCtrl.text != pwd) {
        err = 'As senhas não coincidem';
      } else {
        err = await _auth.register(loginId, pwd);
      }
    } else {
      err = await _auth.login(loginId, pwd);
    }
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final saved = await _auth.currentUser();
    if (!mounted) return;
    final displayName = (saved?['nome'] ?? saved?['username'] ?? loginId) as String;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MenuScreen(username: displayName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF18A558);
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildWelcomeHeader(),
          _buildSlideArea(),
          _buildBottomHandle(primaryGreen),
        ],
      ),
    );
  }

  Widget _buildBackground() => Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1BAA5F), Color(0xFF23B369)],
              ),
            ),
          ),
          Opacity(
            opacity: 0.18,
            child: Image.asset(
              'assets/Planeta.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      );

  Widget _buildWelcomeHeader() => Positioned(
        top: 110,
        left: 24,
        right: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá.',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Seja bem-vindo!',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildSlideArea() => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.16 + 16,
        left: 0,
        right: 0,
        child: Column(
          children: [
            Text(
              'Deslizar para acessar',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Icon(Icons.keyboard_arrow_up, size: 48, color: Colors.white),
          ],
        ),
      );

  Widget _buildBottomHandle(Color primaryGreen) => DraggableScrollableSheet(
        controller: _scroll,
        initialChildSize: 0.16,
        minChildSize: 0.16,
        maxChildSize: 0.17,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openFormModal(primaryGreen),
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < -6) _openFormModal(primaryGreen);
              },
              child: Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        },
      );

  void _openFormModal(Color primaryGreen) {
    final modalHeight = MediaQuery.of(context).size.height * 0.78;
    final mode = ValueNotifier<bool>(false); // false = login, true = cadastro

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) => SizedBox(
        height: modalHeight,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ValueListenableBuilder<bool>(
            valueListenable: mode,
            builder: (context, isRegistering, __) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: isRegistering
                            ? Column(
                                key: const ValueKey('register_title'),
                                children: [
                                  Text(
                                    'Cadastre-se para continuar',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              )
                            : Column(
                                key: const ValueKey('login_title'),
                                children: [
                                  Text(
                                    'Entre com sua conta',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isRegistering ? 'Usuário (novo)' : 'Usuário',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(color: Colors.black54),
                        ),
                      ),
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o usuário';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_.-]{3,}$')
                              .hasMatch(value.trim())) {
                            return 'Mín. 3 caracteres (letras/números)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Senha',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(color: Colors.black54),
                        ),
                      ),
                      TextFormField(
                        controller: _passwordCtrl,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite sua senha.';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter no mínimo 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: isRegistering
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Confirmar Senha',
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _confirmCtrl,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    obscureText: true,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (!isRegistering) return null;
                                      if (value == null || value.isEmpty) {
                                        return 'Confirme a senha';
                                      }
                                      if (value != _passwordCtrl.text) {
                                        return 'As senhas não coincidem';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Esqueceu a senha?',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(color: Color(0xFF18A558)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            key: ValueKey(isRegistering ? 'btn_reg' : 'btn_login'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _submit(isRegistering);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isRegistering ? 'Criar conta' : 'Acessar',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: () => mode.value = !mode.value,
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(color: Colors.black54),
                              ),
                              children: [
                                TextSpan(
                                  text: isRegistering
                                      ? 'Já possui conta? '
                                      : 'Não tem uma conta? ',
                                ),
                                TextSpan(
                                  text: isRegistering ? 'Login' : 'Registre-se',
                                  style: const TextStyle(
                                    color: Color(0xFF18A558),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}






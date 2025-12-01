import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:gaudioso_app/screens/login_screen.dart';
// import 'services/auth_service.dart'; // _AuthGate removed
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/materiais_screen.dart';
import 'screens/cadastros_screen.dart';
import 'screens/forms/entrada_form_screen.dart';
import 'screens/forms/saida_form_screen.dart';
import 'screens/controle_usuarios_screen.dart';

void main() {
  runApp(const GaudiosoApp());
}

class GaudiosoApp extends StatelessWidget {
  const GaudiosoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4CAF50); // Primária
    const secondaryColor = Color(0xFFA5D6A7); // Secundária (fundos)
    const neutralColor = Color(0xFFF5F5F5); // Neutra (cards/listas)
    const textColor = Color(0xFF212121); // Texto
    const highlightColor = Color(0xFF2E7D32); // Destaque (botões ativos)

    final scheme = ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: textColor,
      surface: neutralColor,
      onSurface: textColor,
      tertiary: highlightColor,
      onTertiary: Colors.white,
    );

    return MaterialApp(
      title: 'Gaudioso Reciclagens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: neutralColor,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: neutralColor,
          foregroundColor: textColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: neutralColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: textColor.withValues(alpha: 0.54)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: primaryColor, width: 1.2),
          ),
          hintStyle: TextStyle(color: textColor.withValues(alpha: 0.54)),
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      // ✅ Suporte a localização
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'), // português BR para o calendário
      ],
      routes: {
        '/materiais': (_) => const MateriaisScreen(),
        '/parceiros': (_) => const CadastrosScreen(),
        '/entrada': (_) => const EntradaFormScreen(),
        '/saida': (_) => const SaidaFormScreen(),
        '/controle-usuarios': (_) => const ControleUsuariosScreen(),
      },
      home: const SplashScreen(),
    );
  }
}

// _AuthGate removed; SplashScreen handles the bootstrap/login routing.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class CircuitoApp extends StatelessWidget {
  const CircuitoApp({super.key});

  // Visual no estilo das Human Interface Guidelines da Apple: fundo agrupado,
  // listas inset, títulos grandes e azul do sistema como cor de destaque.
  static ThemeData _tema(Brightness brilho) {
    final escuro = brilho == Brightness.dark;
    final fundo = escuro ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final azul = escuro ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final texto = escuro ? CupertinoColors.white : CupertinoColors.black;
    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      platform: TargetPlatform.iOS, // transições e rolagem do iOS
      scaffoldBackgroundColor: fundo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: azul,
        brightness: brilho,
        primary: azul,
        surface: fundo,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: Typography.blackCupertino
          .merge(escuro ? Typography.whiteCupertino : null)
          .apply(bodyColor: texto, displayColor: texto),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brilho,
        primaryColor: azul,
        primaryContrastingColor: CupertinoColors.white, // texto dos botões azuis
        scaffoldBackgroundColor: fundo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circuito de Descobertas',
      debugShowCheckedModeBanner: false,
      theme: _tema(Brightness.light),
      darkTheme: _tema(Brightness.dark),
      home: const HomeScreen(),
    );
  }
}

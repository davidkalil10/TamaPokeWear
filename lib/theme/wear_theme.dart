/// Tema AMOLED otimizado para Wear OS.
/// Fundo preto puro (economia de bateria em AMOLED),
/// cores vibrantes para contraste em tela pequena.
library;

import 'package:flutter/material.dart';

class WearTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFCB05),       // Amarelo Pokémon
      secondary: Color(0xFFE8503A),     // Vermelho fogo
      surface: Color(0xFF1A1A2E),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      error: Color(0xFFCF6679),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 12,
        color: Colors.white70,
      ),
      bodyMedium: TextStyle(
        fontSize: 11,
        color: Colors.white60,
      ),
      bodySmall: TextStyle(
        fontSize: 9,
        color: Colors.white54,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white70,
      size: 20,
    ),
    useMaterial3: true,
  );

  // Cores dos tipos Pokémon
  static Color typeColor(String type) {
    switch (type) {
      case 'fire': return const Color(0xFFE8503A);
      case 'water': return const Color(0xFF4F93C4);
      case 'grass': return const Color(0xFF3C8A4C);
      case 'electric': return const Color(0xFFB8960B);
      case 'ice': return const Color(0xFF4FB4C4);
      case 'fighting': return const Color(0xFFA5552D);
      case 'poison': return const Color(0xFF8A4F9E);
      case 'ground': return const Color(0xFFB08A3D);
      case 'psychic': return const Color(0xFFD4527E);
      case 'bug': return const Color(0xFF7A9A24);
      case 'rock': return const Color(0xFF93803D);
      case 'ghost': return const Color(0xFF6A5A9E);
      case 'dragon': return const Color(0xFF5A52C4);
      default: return const Color(0xFF8A8A6A); // normal
    }
  }

  // Cores das stat bars
  static const Color foodColor = Color(0xFFE8503A);
  static const Color joyColor = Color(0xFFFFCB05);
  static const Color energyColor = Color(0xFF4F93C4);
  static const Color hygieneColor = Color(0xFF3C8A4C);

  // Cor da berry por índice
  static Color berryColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFE8503A); // vermelha
      case 1: return const Color(0xFF4F93C4); // azul
      case 2: return const Color(0xFF3C8A4C); // verde
      default: return Colors.white;
    }
  }
}

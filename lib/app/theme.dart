import 'package:flutter/material.dart';

/// Charte d'identité visuelle officielle SŪRA (Version 2 - Septembre 2026)
/// Palette de couleurs et règles de typographie
class SuraTheme {
  // Couleurs principales
  static const Color tealPrimary = Color(0xFF0F6E6E); // --n (Teal profond)
  static const Color backgroundSand = Color(0xFFF7F7F5); // --s (Sable clair / blanc cassé)
  static const Color ink = Color(0xFF211C17); // --k (Encre texte)
  static const Color cardBg = Color(0xFFFFFFFF); // --card (Cartes blanches)
  static const Color borderLine = Color(0xFFE3E5E2); // --line (Bordure douce)
  static const Color slateMuted = Color(0xFF625B52); // --g (Gris neutre texte secondaire)
  static const Color softTeal = Color(0xFFDCEDEC); // --ti (Pastille / conteneur doux)

  // Couleurs fonctionnelles d'urgence (RÉSERVÉES STRICTEMENT AU TRIAGE - Règle de charte)
  static const Color triageHigh = Color(0xFFA6512F); // --a (Argile / Rouge brique)
  static const Color triageModerate = Color(0xFFC98A2C); // --am (Ambre)
  static const Color triageLow = Color(0xFF5F7A52); // --v (Vert sauge)

  // Pastilles d'urgence claires
  static const Color triageHighBg = Color(0xFFF1DCD2); // --ta
  static const Color triageModerateBg = Color(0xFFF3E3C2); // --tm
  static const Color triageLowBg = Color(0xFFDDE6D6); // --tv

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundSand,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: tealPrimary,
        onPrimary: Colors.white,
        secondary: softTeal,
        onSecondary: tealPrimary,
        error: ink, // Les erreurs techniques restent en encre, pas en rouge d'urgence
        onError: Colors.white,
        surface: cardBg,
        onSurface: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: tealPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderLine, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tealPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tealPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: tealPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

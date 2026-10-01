import 'package:flutter/material.dart';

import 'sura_colors.dart';

class SuraTheme {
  SuraTheme._();

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: SuraColors.teal,
      onPrimary: Colors.white,
      secondary: SuraColors.tealDark,
      onSecondary: Colors.white,
      error: SuraColors.ink,
      onError: Colors.white,
      surface: SuraColors.surface,
      onSurface: SuraColors.ink,
    );
    final radius = BorderRadius.circular(12);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c, width: w),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SuraColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: SuraColors.surface,
        foregroundColor: SuraColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: SuraColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SuraColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: SuraColors.teal,
          side: const BorderSide(color: SuraColors.teal, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SuraColors.teal,
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SuraColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: border(SuraColors.border),
        enabledBorder: border(SuraColors.border),
        focusedBorder: border(SuraColors.teal, 2),
        errorBorder: border(SuraColors.ink, 2),
        focusedErrorBorder: border(SuraColors.ink, 2),
        errorStyle: const TextStyle(
          color: SuraColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(color: SuraColors.border, space: 1),
    );
  }

  /// Chiffres alignés (identifiants, compteurs).
  static const tabular = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

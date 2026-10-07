import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tokens des maquettes V3 (teal #0F6E6E, fond #F7F7F5, urgence Argile/Ambre/Savane, erreur rouge).
class T {
  static const teal = Color(0xFF0F6E6E);
  static const tealDark = Color(0xFF0B5252);
  static const tealLight = Color(0xFF5CC4C0);
  static const bg = Color(0xFFF7F7F5);
  static const bgDark = Color(0xFF101A1A);
  static const cardDark = Color(0xFF182525);
  static const ink = Color(0xFF211C17);
  static const grey = Color(0xFF625B52);
  static const argile = Color(0xFFA6512F);
  static const ambre = Color(0xFFC98A2C);
  static const ambreDark = Color(0xFF855608);
  static const savane = Color(0xFF5F7A52);
  static const error = Color(0xFFB42318);
  static const errorLight = Color(0xFFF87171);
  static const infoBg = Color(0xFFDCEDEC);
  static const warnBg = Color(0xFFF3E3C2);
  static const errorBg = Color(0xFFFDECEA);
}

ThemeData suraTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(seedColor: T.teal, brightness: b).copyWith(
    primary: dark ? T.tealLight : T.teal,
    onPrimary: dark ? const Color(0xFF00201F) : Colors.white,
    error: dark ? T.errorLight : T.error,
    surface: dark ? T.cardDark : Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? T.bgDark : T.bg,
    // Police Inter : ajouter les fichiers dans assets/fonts et declarer fontFamily (voir README).
  );
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString('theme');
    if (v != null) {
      state = ThemeMode.values
          .firstWhere((m) => m.name == v, orElse: () => ThemeMode.system);
    }
  }

  Future<void> set(ThemeMode m) async {
    state = m;
    final p = await SharedPreferences.getInstance();
    await p.setString('theme', m.name);
  }

  void toggle(Brightness current) =>
      set(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

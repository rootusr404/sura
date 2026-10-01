import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Membre 4 (S-01) : initialisation Firebase ici, dans un try/catch.
  runApp(const ProviderScope(child: SuraApp()));
}

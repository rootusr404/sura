import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/sync/sync_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kUseFirebase) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // Drift est la source de verite : on desactive la persistance Firestore pour eviter une 2e file d'attente.
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: false);
  }
  runApp(const ProviderScope(child: SuraApp()));
}

class SuraApp extends ConsumerWidget {
  const SuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncAutoProvider);
    return MaterialApp.router(
      title: 'SŪRA',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: suraTheme(Brightness.light),
      darkTheme: suraTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
    );
  }
}

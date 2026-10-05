import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< Updated upstream
import 'app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Firebase initialisé');
  } catch (e) {
    debugPrint('Firebase indisponible : $e');
  }

  runApp(const ProviderScope(child: SuraApp()));
=======
import 'package:sura/app/theme.dart';
import 'package:sura/features/consultation/presentation/screens/consultation_flow_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SuraApp(),
    ),
  );
}

class SuraApp extends StatelessWidget {
  const SuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SŪRA — Assistant de consultation',
      debugShowCheckedModeBanner: false,
      theme: SuraTheme.themeData,
      home: const ConsultationFlowScreen(),
    );
  }
>>>>>>> Stashed changes
}

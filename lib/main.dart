import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/app/theme.dart';
import 'package:sura/features/consultation/presentation/screens/consultation_flow_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SuraApp()));
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
}

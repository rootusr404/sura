import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/core/theme/sura_theme.dart';
import 'router.dart';
import 'package:sura/features/sync/sync_providers.dart';

class SuraApp extends ConsumerWidget {
  const SuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncServiceProvider);
    return MaterialApp.router(
      title: 'SURA',
      debugShowCheckedModeBanner: false,
      theme: SuraTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

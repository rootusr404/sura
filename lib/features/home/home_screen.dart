import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/tiles.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../profile/profile_service.dart';
import '../sync/sync_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all =
        ref.watch(consultationsProvider(const ConsFilter())).value ?? [];
    final patients = ref.watch(allPatientsProvider).value ?? [];
    final online = ref.watch(onlineProvider).value ?? true;
    final fullName = (ref.watch(profileProvider).value?.fullName ?? '').trim();
    final greeting = fullName.isEmpty
        ? 'Bonjour'
        : 'Bonjour, ${fullName.split(RegExp(r'\s+')).first}';
    final now = DateTime.now();
    final drafts = all.where((c) => c.status == 'draft').toList();
    final saved = all.where((c) => c.status == 'saved').toList();
    final today = saved
        .where((c) =>
            c.createdAt.year == now.year &&
            c.createdAt.month == now.month &&
            c.createdAt.day == now.day)
        .length;
    final pending = saved.where((c) => c.syncStatus != 'synced').length;

    Widget stat(String value, String label, {VoidCallback? onTap}) => Expanded(
          child: SuraCard(
            onTap: onTap,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center),
            ]),
          ),
        );

    return Scaffold(
      appBar: suraAppBar(context, greeting,
          back: false, actions: const [ThemeToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (!online)
          const InfoBanner(
              '⊘ Hors ligne — vos données restent enregistrées sur cet appareil.',
              kind: BannerKind.warn)
        else
          const Padding(
              padding: EdgeInsets.only(bottom: 8), child: Text('● En ligne')),
        if (!kUseFirebase)
          const InfoBanner(
              'Mode démo : connexion et envoi simulés (kUseFirebase = false).',
              kind: BannerKind.warn),
        PrimaryButton('Nouvelle consultation',
            icon: Icons.add, onPressed: () => context.push('/consult/select')),
        if (drafts.isNotEmpty)
          SuraCard(
            onTap: () => context
                .push('/consult/${drafts.first.id}/${drafts.first.stage}'),
            child: const Row(children: [
              Expanded(
                  child: Text('Consultation en cours (brouillon)',
                      style: TextStyle(fontWeight: FontWeight.w800))),
              Text('Reprendre', style: TextStyle(fontWeight: FontWeight.w800)),
            ]),
          ),
        Row(children: [
          stat('${patients.length}', 'Patients'),
          const SizedBox(width: 8),
          stat('$today', 'Aujourd’hui'),
          const SizedBox(width: 8),
          stat('$pending', 'En attente', onTap: () => context.push('/sync')),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Consultations récentes',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          TextButton(
              onPressed: () => context.go('/patients'),
              child: const Text('Voir tout ›')),
        ]),
        if (saved.isEmpty)
          const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Aucune consultation enregistrée pour le moment.')),
        for (final c in saved.take(5)) ConsultationTile(c),
      ]),
    );
  }
}

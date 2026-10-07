import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../auth/auth_service.dart';
import '../consultation/cloud_stt.dart';
import '../profile/profile_screens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final pending =
        (ref.watch(consultationsProvider(const ConsFilter())).value ?? [])
            .where((c) => c.status == 'saved' && c.syncStatus != 'synced')
            .length;
    Widget row(IconData i, String t, {String? sub, VoidCallback? onTap}) =>
        SuraCard(
          onTap: onTap,
          child: Row(children: [
            Icon(i),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (sub != null)
                    Text(sub, style: const TextStyle(fontSize: 12)),
                ])),
            const Icon(Icons.chevron_right),
          ]),
        );
    return Scaffold(
      appBar: suraAppBar(context, 'Paramètres',
          back: false, actions: const [ThemeToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const ProfileCard(),
        const Text('Affichage', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('Système')),
            ButtonSegment(value: ThemeMode.light, label: Text('Clair')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Sombre')),
          ],
          selected: {mode},
          onSelectionChanged: (s) =>
              ref.read(themeModeProvider.notifier).set(s.first),
        ),
        const SizedBox(height: 14),
        const ConnectedModeCard(),
        row(Icons.sync, 'Synchronisation',
            sub: '$pending en attente', onTap: () => context.push('/sync')),
        row(Icons.lock_outline, 'Sécurité',
            sub: 'PIN et biométrie',
            onTap: () => context.push('/settings/security')),
        row(Icons.storage_outlined, 'Stockage hors ligne',
            sub: 'Données sur cet appareil',
            onTap: () => context.push('/settings/storage')),
        row(Icons.info_outline, 'À propos de SŪRA',
            sub: 'Version 0.1.0', onTap: () => context.push('/settings/about')),
        const SizedBox(height: 8),
        PrimaryButton('Verrouiller maintenant',
            icon: Icons.lock_outline,
            onPressed: () => ref.read(sessionProvider.notifier).lock()),
        SecondaryButton('Déconnexion', onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (d) => AlertDialog(
              title: const Text('Se déconnecter ?'),
              content: Text(pending > 0
                  ? '$pending consultation(s) ne sont pas encore envoyées. Elles restent chiffrées sur l’appareil, mais l’envoi automatique s’arrête.'
                  : 'Vous devrez vous reconnecter avec Internet.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(d, false),
                    child: const Text('Rester connecté')),
                TextButton(
                    onPressed: () => Navigator.pop(d, true),
                    child: const Text('Se déconnecter')),
              ],
            ),
          );
          if (ok == true) await ref.read(sessionProvider.notifier).logout();
        }),
      ]),
    );
  }
}

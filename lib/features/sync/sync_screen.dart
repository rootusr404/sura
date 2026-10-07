import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/format.dart';
import '../../core/widgets.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../auth/auth_service.dart';
import 'restore_service.dart';
import 'sync_service.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider).value ?? true;
    final saved =
        (ref.watch(consultationsProvider(const ConsFilter())).value ?? [])
            .where((c) => c.status == 'saved')
            .toList();
    final patients = (ref.watch(allPatientsProvider).value ?? const <Patient>[])
        .where((p) => p.syncStatus != 'synced')
        .length;
    final done = saved.where((c) => c.syncStatus == 'synced').length;
    final names = {
      for (final p in ref.watch(allPatientsProvider).value ?? const <Patient>[])
        p.id: '${p.firstName} ${p.familyName}'
    };

    return Scaffold(
      appBar: suraAppBar(context, 'Synchronisation'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        InfoBanner(
            online
                ? '● Connexion active.'
                : '⊘ Hors ligne : l’envoi reprendra automatiquement à la reconnexion.',
            kind: online ? BannerKind.info : BannerKind.warn),
        if (!kUseFirebase)
          const InfoBanner(
              'Mode démo : l’envoi est simulé (kUseFirebase = false).',
              kind: BannerKind.warn),
        SuraCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Progression',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              Text('$done / ${saved.length}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 6),
            LinearProgressIndicator(
                value: saved.isEmpty ? 0 : done / saved.length),
            if (patients > 0)
              Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('$patients patient(s) à envoyer')),
          ]),
        ),
        PrimaryButton('Synchroniser maintenant',
            icon: Icons.sync,
            onPressed: () => ref.read(syncServiceProvider).run()),
        SecondaryButton('Restaurer depuis le serveur', onPressed: () async {
          final msg = await restoreFromServer(
              ref.read(repoProvider), ref.read(authProvider).agentId);
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        }),
        if (saved.isEmpty) const Text('Aucune consultation enregistrée.'),
        for (final c in saved)
          SuraCard(
            color: c.syncStatus == 'error'
                ? Theme.of(context).colorScheme.errorContainer
                : null,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(names[c.patientId] ?? 'Patient',
                        style: const TextStyle(fontWeight: FontWeight.w800))),
                SyncChip(c.syncStatus),
              ]),
              Text(fmtWhen(c.createdAt), style: const TextStyle(fontSize: 12)),
              if (c.syncStatus == 'error') ...[
                Text(
                    'Envoi interrompu. Dossier conservé sur l’appareil. (${c.retryCount} tentative(s))'),
                const SizedBox(height: 6),
                SecondaryButton('Réessayer',
                    onPressed: () => ref.read(syncServiceProvider).run()),
              ],
            ]),
          ),
      ]),
    );
  }
}

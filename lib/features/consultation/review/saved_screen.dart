import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/status_chip.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';

/// U-03. Confirme la sauvegarde locale et montre l'état de synchronisation
/// en direct (R15).
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.saved,
    title: 'Sauvegarde',
    builder: (_, r) => _SavedBody(initial: r),
  );
}

class _SavedBody extends ConsumerWidget {
  const _SavedBody({required this.initial});
  final ConsultationRecord initial;

  static String _explain(SyncState state) => switch (state) {
    SyncState.synced => 'La consultation est aussi sauvegardée en ligne.',
    SyncState.syncing => 'Envoi en cours…',
    SyncState.error =>
      'L\'envoi a échoué. Vos données restent sur le téléphone et seront renvoyées.',
    SyncState.offline ||
    SyncState.pending => 'Elle sera envoyée dès que le réseau sera disponible.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref
        .watch(consultationRepositoryProvider)
        .watchById(initial.id);
    return StreamBuilder<ConsultationRecord?>(
      stream: stream,
      initialData: initial,
      builder: (context, snap) {
        final state = snap.data?.syncState ?? initial.syncState;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.check_circle_outline,
              size: 72,
              color: SuraColors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Consultation enregistrée sur ce téléphone',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Center(child: StatusChip(state: state)),
            const SizedBox(height: 12),
            Text(
              _explain(state),
              textAlign: TextAlign.center,
              style: const TextStyle(color: SuraColors.inkSoft, height: 1.4),
            ),
            const SizedBox(height: 32),
            SuraButton(
              label: 'Retour à l\'accueil',
              icon: Icons.home_outlined,
              onPressed: () => context.go('/home'),
            ),
          ],
        );
      },
    );
  }
}

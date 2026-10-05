import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/connectivity_provider.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/status_chip.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/domain/models/enums.dart';

final _patientCountProvider = StreamProvider<int>(
  (ref) => ref.watch(patientRepositoryProvider).watchAll().map((l) => l.length),
);

/// Consultations validées en attente d'envoi (les brouillons ne comptent pas).
final _pendingCountProvider = StreamProvider<int>(
  (ref) => ref
      .watch(consultationRepositoryProvider)
      .watchAll()
      .map(
        (l) => l
            .where(
              (c) =>
                  c.status == ConsultationStatus.saved &&
                  c.syncState == SyncState.pending,
            )
            .length,
      ),
);

final _draftCountProvider = StreamProvider<int>(
  (ref) => ref
      .watch(consultationRepositoryProvider)
      .watchAll()
      .map((l) => l.where((c) => c.status == ConsultationStatus.draft).length),
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value ?? true;
    final patients = ref.watch(_patientCountProvider).value ?? 0;
    final pending = ref.watch(_pendingCountProvider).value ?? 0;
    final drafts = ref.watch(_draftCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SŪRA'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusChip(
              state: online ? SyncState.synced : SyncState.offline,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _stat(Icons.people_outline, '$patients', 'Patients'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _stat(Icons.schedule, '$pending', 'À synchroniser'),
              ),
            ],
          ),
          if (drafts > 0) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.edit_note,
                  color: SuraColors.amberDark,
                ),
                title: Text(
                  '$drafts brouillon${drafts > 1 ? 's' : ''} en cours',
                ),
                subtitle: const Text(
                  'Ouvrez le dossier du patient pour reprendre.',
                ),
                onTap: () => context.go('/patients'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SuraButton(
            label: 'Nouvelle consultation',
            icon: Icons.mic,
            onPressed: () => context.push('/consultation/new'),
          ),
          const SizedBox(height: 12),
          SuraButton(
            label: 'Nouveau patient',
            icon: Icons.person_add_alt,
            kind: SuraButtonKind.secondary,
            onPressed: () => context.go('/patients/new'),
          ),
          const SizedBox(height: 12),
          SuraButton(
            label: 'Scanner un QR',
            icon: Icons.qr_code_scanner,
            kind: SuraButtonKind.secondary,
            onPressed: () => context.go('/patients/scan'),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: SuraColors.teal),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(label, style: const TextStyle(color: SuraColors.inkSoft)),
        ],
      ),
    ),
  );
}

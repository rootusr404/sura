import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/utils/text_utils.dart';
import 'package:sura/core/widgets/status_chip.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/core/widgets/urgency_badge.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'patient_providers.dart';

class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(patientProvider(patientId));
    return Scaffold(
      appBar: AppBar(title: const Text('Dossier patient')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur de lecture locale : $e')),
        data: (p) => p == null
            ? const Center(child: Text('Patient introuvable sur cet appareil.'))
            : _Body(patient: p),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.patient});
  final PatientRecord patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = patient;
    final history = ref.watch(patientConsultationsProvider(p.id));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    StatusChip(state: p.syncState),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${p.ageYears} ans · ${p.sex == 'F' ? 'Femme' : 'Homme'}',
                  style: const TextStyle(color: SuraColors.inkSoft),
                ),
                Text(
                  p.village,
                  style: const TextStyle(color: SuraColors.inkSoft),
                ),
                if (p.phone != null)
                  Text(
                    'Tél. ${p.phone}',
                    style: const TextStyle(color: SuraColors.inkSoft),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Identifiant SŪRA',
                  style: TextStyle(color: SuraColors.inkSoft),
                ),
                const SizedBox(height: 4),
                Text(
                  p.id,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 12),
                // R2 : le QR ne contient QUE l'identifiant, jamais de données médicales.
                Container(
                  color: Colors.white,
                  child: QrImageView(
                    data: p.id,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ce QR ne contient que l\'identifiant, aucune donnée médicale.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: SuraColors.inkSoft),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SuraButton(
          label: 'Nouvelle consultation',
          icon: Icons.mic,
          onPressed: () => context.push('/consultation/new?patientId=${p.id}'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Historique des consultations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur de lecture locale : $e'),
          data: (list) => list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Aucune consultation enregistrée.',
                    style: TextStyle(color: SuraColors.inkSoft),
                  ),
                )
              : Column(
                  children: [for (final c in list) _ConsultationRow(c: c)],
                ),
        ),
      ],
    );
  }
}

class _ConsultationRow extends StatelessWidget {
  const _ConsultationRow({required this.c});
  final ConsultationRecord c;

  @override
  Widget build(BuildContext context) {
    final saved = c.status == ConsultationStatus.saved;
    final level = c.urgencyFinal ?? c.urgencyProposal?.level;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          // Un brouillon se reprend là où il a été laissé.
          onTap: saved
              ? () => context.push('/consultation/${c.id}/view')
              : () => context.go('/consultation/${c.id}/${c.step}'),
          title: Text(formatDateTime(c.createdAt)),
          subtitle: Text(
            saved
                ? 'Enregistrée — toucher pour consulter'
                : 'Brouillon — toucher pour reprendre',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (level != null) UrgencyBadge(level: level),
              const SizedBox(width: 8),
              if (saved) StatusChip(state: c.syncState),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/utils/text_utils.dart';
import 'package:sura/core/widgets/inline_alert.dart';
import 'package:sura/core/widgets/status_chip.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/core/widgets/urgency_badge.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/features/consultation/flow/consultation_providers.dart';
import 'consultation_summary.dart';

final _consultationProvider =
    StreamProvider.family<ConsultationRecord?, String>(
      (ref, id) => ref.watch(consultationRepositoryProvider).watchById(id),
    );

/// Aperçu en LECTURE SEULE d'une consultation (enregistrée ou brouillon).
class ConsultationDetailScreen extends ConsumerWidget {
  const ConsultationDetailScreen({super.key, required this.consultationId});
  final String consultationId;

  void _back(BuildContext context, String? patientId) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(patientId == null ? '/home' : '/patients/$patientId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_consultationProvider(consultationId));
    final record = async.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _back(context, record?.patientId),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur de lecture locale : $e')),
        data: (r) => r == null
            ? const Center(
                child: Text('Consultation introuvable sur cet appareil.'),
              )
            : _Body(record: r, onBack: () => _back(context, r.patientId)),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.record, required this.onBack});
  final ConsultationRecord record;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = record;
    final patient = ref.watch(patientSummaryProvider(r.patientId)).value;
    final info = r.structured;
    final level = r.urgencyFinal ?? r.urgencyProposal?.level;
    final saved = r.status == ConsultationStatus.saved;
    final ticked = r.checklist.values.where((v) => v).length;

    Future<void> copy() async {
      final text = buildConsultationSummary(
        record: r,
        patientName: patient?.name ?? r.patientId,
        ageYears: patient?.context.ageYears ?? 0,
        sex: patient?.context.sex ?? 'M',
        village: patient?.village ?? '',
        patientId: r.patientId,
      );
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Résumé copié')));
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (!saved) ...[
          const InlineAlert(
            'Brouillon non terminé : ces informations sont incomplètes.',
          ),
          const SizedBox(height: 8),
          SuraButton(
            label: 'Reprendre la consultation',
            icon: Icons.play_arrow,
            onPressed: () => context.go('/consultation/${r.id}/${r.step}'),
          ),
          const SizedBox(height: 16),
        ],
        _Card(
          title: patient?.name ?? '…',
          trailing: saved ? StatusChip(state: r.syncState) : null,
          children: [
            Text(
              patient == null
                  ? ''
                  : '${patient.context.ageYears} ans · ${patient.context.sex == 'F' ? 'Femme' : 'Homme'}'
                        '${patient.village.isEmpty ? '' : ' · ${patient.village}'}',
              style: const TextStyle(color: SuraColors.inkSoft),
            ),
            Text(
              r.patientId,
              style: const TextStyle(color: SuraColors.inkSoft, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              '${saved ? 'Validée' : 'Commencée'} le ${formatDateTime(r.validatedAt ?? r.createdAt)}',
            ),
          ],
        ),
        if (level != null)
          _Card(
            title: 'Niveau d\'urgence',
            children: [
              UrgencyBadge(level: level, large: true),
              if (r.urgencyProposal != null &&
                  r.urgencyProposal!.level != level) ...[
                const SizedBox(height: 8),
                Text(
                  'Proposé : ${urgencyLabel(r.urgencyProposal!.level)} — modifié par l\'agent.'
                  '${(r.urgencyOverrideReason ?? '').isEmpty ? '' : '\nMotif : ${r.urgencyOverrideReason}'}',
                ),
              ],
              if ((r.urgencyProposal?.reasons ?? const <String>[])
                  .isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Raisons',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                for (final reason in r.urgencyProposal!.reasons)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: SuraColors.teal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: Text(reason)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        if (info != null)
          _Card(
            title: 'Informations',
            children: [
              _kv('Motif', info.chiefComplaint),
              _kv(
                'Symptômes',
                info.symptoms.isEmpty ? null : info.symptoms.join(', '),
              ),
              _kv('Durée', info.duration),
              _kv(
                'Température',
                info.temperatureC == null ? null : '${info.temperatureC} °C',
              ),
              _kv('Pouls', info.pulse?.toString()),
              _kv('Allergies', info.allergies),
              _kv('Médicaments', info.medications),
              _kv('Antécédents', info.history),
              _kv('Notes', info.notes),
            ],
          ),
        if (r.missing.isNotEmpty)
          _Card(
            title: 'Signalé comme manquant',
            children: [
              for (final m in r.missing)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('• ${m.label}'),
                ),
            ],
          ),
        if ((r.transcript ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ExpansionTile(
                title: const Text(
                  'Texte de la consultation',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                shape: const Border(),
                collapsedShape: const Border(),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(r.transcript!)],
              ),
            ),
          ),
        _Card(
          title: 'Consentement et validation',
          children: [
            _kv('Consentement', switch (r.consent) {
              ConsentStatus.granted =>
                'Accordé${r.consentAt == null ? '' : ' le ${formatDateTime(r.consentAt!)}'}',
              ConsentStatus.refused => 'Refusé (saisie manuelle)',
              null => null,
            }),
            if (saved)
              _kv(
                'Validation',
                '$ticked case${ticked > 1 ? 's' : ''} sur ${r.checklist.length} cochée${ticked > 1 ? 's' : ''}',
              ),
            if (saved && r.syncAttempts > 0)
              _kv('Tentatives d\'envoi', '${r.syncAttempts}'),
            if ((r.syncError ?? '').isNotEmpty)
              _kv('Dernière erreur', r.syncError),
          ],
        ),
        const SizedBox(height: 4),
        SuraButton(
          label: 'Copier le résumé',
          icon: Icons.copy,
          kind: SuraButtonKind.secondary,
          onPressed: copy,
        ),
        const SizedBox(height: 12),
        SuraButton(label: 'Retour au dossier du patient', onPressed: onBack),
      ],
    );
  }

  Widget _kv(String k, String? v) => (v == null || v.trim().isEmpty)
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  k,
                  style: const TextStyle(color: SuraColors.inkSoft),
                ),
              ),
              Expanded(child: Text(v)),
            ],
          ),
        );
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children, this.trailing});
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    ),
  );
}

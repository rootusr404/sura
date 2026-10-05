import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/core/widgets/urgency_badge.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';

/// U-03. Vue d'ensemble de la consultation, avec un lien « Modifier » par
/// section pour corriger avant de valider.
class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.recap,
    title: 'Récapitulatif',
    builder: (_, r) => _RecapBody(record: r),
  );
}

class _RecapBody extends StatelessWidget {
  const _RecapBody({required this.record});
  final ConsultationRecord record;

  @override
  Widget build(BuildContext context) {
    final info = record.structured ?? const StructuredInfo();
    final urgency = record.urgencyFinal ?? record.urgencyProposal?.level;
    final transcript = record.transcript;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section(
          title: 'Transcription',
          step: ConsultationStep.transcript,
          consultationId: record.id,
          child: Text(
            transcript == null || transcript.trim().isEmpty
                ? 'Aucune transcription.'
                : transcript,
          ),
        ),
        _Section(
          title: 'Informations structurées',
          step: ConsultationStep.structured,
          consultationId: record.id,
          child: _Fields(info: info),
        ),
        _Section(
          title: 'Informations manquantes',
          step: ConsultationStep.missing,
          consultationId: record.id,
          child: record.missing.isEmpty
              ? const Text('Rien ne semble manquer.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final m in record.missing) Text('• ${m.label}'),
                  ],
                ),
        ),
        _Section(
          title: 'Niveau d\'urgence',
          step: ConsultationStep.urgency,
          consultationId: record.id,
          child: urgency == null
              ? const Text('Non évalué.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UrgencyBadge(level: urgency),
                    if ((record.urgencyOverrideReason ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Modifié par l\'agent : ${record.urgencyOverrideReason}',
                        ),
                      ),
                    for (final reason
                        in record.urgencyProposal?.reasons ?? const <String>[])
                      Text('• $reason'),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        SuraButton(
          label: 'Continuer vers la validation',
          icon: Icons.arrow_forward,
          onPressed: () =>
              context.go(ConsultationStep.validate.path(record.id)),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.step,
    required this.consultationId,
    required this.child,
  });
  final String title;
  final ConsultationStep step;
  final String consultationId;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
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
              TextButton(
                onPressed: () => context.go(editPath(step, consultationId)),
                child: const Text('Modifier'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DefaultTextStyle.merge(
            style: const TextStyle(color: SuraColors.ink, height: 1.35),
            child: child,
          ),
        ],
      ),
    ),
  );
}

class _Fields extends StatelessWidget {
  const _Fields({required this.info});
  final StructuredInfo info;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String?)>[
      ('Motif', info.chiefComplaint),
      ('Symptômes', info.symptoms.isEmpty ? null : info.symptoms.join(', ')),
      ('Durée', info.duration),
      (
        'Température',
        info.temperatureC == null ? null : '${info.temperatureC} °C',
      ),
      ('Pouls', info.pulse == null ? null : '${info.pulse} /min'),
      ('Allergies', info.allergies),
      ('Médicaments', info.medications),
      ('Antécédents', info.history),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: (value == null || value.trim().isEmpty)
                        ? 'non renseigné'
                        : value,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

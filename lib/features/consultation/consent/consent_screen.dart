import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/features/consultation/flow/consultation_providers.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.consent,
    title: 'Consentement',
    builder: (_, r) => _ConsentBody(record: r),
  );
}

class _ConsentBody extends ConsumerStatefulWidget {
  const _ConsentBody({required this.record});
  final ConsultationRecord record;
  @override
  ConsumerState<_ConsentBody> createState() => _State();
}

class _State extends ConsumerState<_ConsentBody> {
  bool _busy = false;

  Future<void> _decide(ConsentStatus status) async {
    setState(() => _busy = true);
    final repo = ref.read(consultationRepositoryProvider);
    await repo.save(
      widget.record.copyWith(
        consent: status,
        consentAt: DateTime.now(), // horodaté (R3)
        step: ConsultationStep.record.name,
      ),
    );
    if (mounted) context.go(ConsultationStep.record.path(widget.record.id));
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref
        .watch(patientSummaryProvider(widget.record.patientId))
        .value;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline, color: SuraColors.teal),
            title: Text(
              patient?.name ?? '…',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              patient == null
                  ? ''
                  : '${patient.context.ageYears} ans · ${patient.village}',
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'À lire à voix haute au patient',
          style: TextStyle(
            color: SuraColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Je vais écrire ce que nous disons pour remplir votre dossier de santé. '
              'Vos informations restent confidentielles et sont gardées sur ce téléphone. '
              'Vous pouvez refuser, cela ne changera pas vos soins.\n\n'
              'Êtes-vous d\'accord ?',
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SuraButton(
          label: 'Le patient accepte',
          icon: Icons.check,
          loading: _busy,
          onPressed: () => _decide(ConsentStatus.granted),
        ),
        const SizedBox(height: 12),
        SuraButton(
          label: 'Le patient refuse',
          icon: Icons.close,
          kind: SuraButtonKind.destructive,
          onPressed: _busy ? null : () => _decide(ConsentStatus.refused),
        ),
        const SizedBox(height: 12),
        const Text(
          'En cas de refus, le refus est enregistré et vous pouvez continuer en saisissant '
          'vous-même vos notes. Rien n\'est enregistré en audio.',
          style: TextStyle(fontSize: 13, color: SuraColors.inkSoft),
        ),
      ],
    );
  }
}

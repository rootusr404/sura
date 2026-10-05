import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/inline_alert.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/core/widgets/urgency_badge.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/domain/models/urgency_proposal.dart';
import 'package:sura/features/consultation/flow/consultation_providers.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';
import 'package:sura/features/consultation/review/review_providers.dart';

/// U-02. Le système propose, l'agent décide (R7, R8) : le niveau peut être
/// modifié, à condition d'indiquer un motif.
class UrgencyScreen extends StatelessWidget {
  const UrgencyScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.urgency,
    title: 'Niveau d\'urgence',
    builder: (_, r) => _UrgencyBody(record: r),
  );
}

class _UrgencyBody extends ConsumerStatefulWidget {
  const _UrgencyBody({required this.record});
  final ConsultationRecord record;

  @override
  ConsumerState<_UrgencyBody> createState() => _UrgencyBodyState();
}

class _UrgencyBodyState extends ConsumerState<_UrgencyBody> {
  final _reason = TextEditingController();
  UrgencyProposal? _proposal;
  UrgencyLevel? _chosen;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reason.text = widget.record.urgencyOverrideReason ?? '';
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  bool get _changed => _chosen != null && _chosen != _proposal?.level;
  bool get _canContinue => !_changed || _reason.text.trim().isNotEmpty;

  Future<void> _continue() async {
    final proposal = _proposal!;
    setState(() => _busy = true);
    await ref
        .read(consultationRepositoryProvider)
        .save(
          widget.record.copyWith(
            urgencyProposal: proposal,
            urgencyFinal: _chosen ?? proposal.level,
            urgencyOverrideReason: _changed ? _reason.text.trim() : '',
            step: ConsultationStep.recap.name,
          ),
        );
    if (mounted) context.go(ConsultationStep.recap.path(widget.record.id));
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(patientSummaryProvider(widget.record.patientId));
    return patient.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: InlineAlert('Impossible de calculer le niveau d\'urgence.'),
      ),
      data: (p) {
        _proposal ??= ref
            .read(urgencyScorerProvider)
            .score(
              widget.record.structured ?? const StructuredInfo(),
              widget.record.transcript ?? '',
              p.context,
            );
        _chosen ??= widget.record.urgencyFinal ?? _proposal!.level;
        final proposal = _proposal!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Niveau proposé',
              style: TextStyle(
                color: SuraColors.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: UrgencyBadge(level: proposal.level, large: true),
            ),
            const SizedBox(height: 16),
            const Text(
              'Raisons',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            for (final reason in proposal.reasons)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(reason)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Votre décision',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cette proposition est une aide. C\'est vous qui décidez.',
              style: TextStyle(color: SuraColors.inkSoft),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final level in UrgencyLevel.values)
                  ChoiceChip(
                    showCheckmark: true,
                    selected: _chosen == level,
                    label: Text(switch (level) {
                      UrgencyLevel.high => 'Élevé',
                      UrgencyLevel.moderate => 'Modéré',
                      UrgencyLevel.low => 'Faible',
                    }),
                    onSelected: (_) => setState(() => _chosen = level),
                  ),
              ],
            ),
            if (_changed) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reason,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Motif du changement (obligatoire)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (!_canContinue)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: InlineAlert(
                    'Indiquez pourquoi vous changez le niveau proposé.',
                  ),
                ),
            ],
            const SizedBox(height: 24),
            SuraButton(
              label: 'Continuer',
              icon: Icons.arrow_forward,
              loading: _busy,
              onPressed: _canContinue ? _continue : null,
            ),
          ],
        );
      },
    );
  }
}

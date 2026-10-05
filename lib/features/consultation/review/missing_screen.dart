import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/inline_alert.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/domain/models/missing_item.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/features/consultation/flow/consultation_providers.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';
import 'package:sura/features/consultation/review/review_providers.dart';

/// U-01. Alertes, jamais blocage (R6) : « Continuer » est toujours disponible.
class MissingScreen extends StatelessWidget {
  const MissingScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.missing,
    title: 'Informations manquantes',
    builder: (_, r) => _MissingBody(record: r),
  );
}

class _MissingBody extends ConsumerStatefulWidget {
  const _MissingBody({required this.record});
  final ConsultationRecord record;

  @override
  ConsumerState<_MissingBody> createState() => _MissingBodyState();
}

class _MissingBodyState extends ConsumerState<_MissingBody> {
  bool _busy = false;

  Future<void> _continue(List<MissingItem> items) async {
    setState(() => _busy = true);
    await ref
        .read(consultationRepositoryProvider)
        .save(
          widget.record.copyWith(
            missing: items,
            step: ConsultationStep.urgency.name,
          ),
        );
    if (mounted) context.go(ConsultationStep.urgency.path(widget.record.id));
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(patientSummaryProvider(widget.record.patientId));
    return patient.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: InlineAlert('Impossible de vérifier les informations.'),
      ),
      data: (p) {
        final items = ref
            .read(missingInfoCheckerProvider)
            .check(
              widget.record.structured ?? const StructuredInfo(),
              p.context,
            );
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (items.isEmpty)
              const InlineAlert(
                'Rien ne semble manquer. Vous pouvez continuer.',
                isError: false,
              )
            else ...[
              const Text(
                'Ces informations semblent manquer. Vous pouvez les compléter '
                'en revenant à l\'étape précédente, ou continuer sans elles.',
                style: TextStyle(color: SuraColors.inkSoft, height: 1.4),
              ),
              const SizedBox(height: 12),
              for (final item in items)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: SuraColors.ink,
                    ),
                    title: Text(item.label),
                    subtitle: item.hint == null ? null : Text(item.hint!),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            SuraButton(
              label: 'Continuer',
              icon: Icons.arrow_forward,
              loading: _busy,
              onPressed: () => _continue(items),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/inline_alert.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_page.dart';
import 'package:sura/features/consultation/review/validation_checklist.dart';

/// U-03. Seul l'agent valide (R8) : les 5 cases doivent être cochées. La
/// sauvegarde locale précède toute synchronisation (R9).
class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPage(
    consultationId: consultationId,
    step: ConsultationStep.validate,
    title: 'Validation',
    builder: (_, r) => _ValidationBody(record: r),
  );
}

class _ValidationBody extends ConsumerStatefulWidget {
  const _ValidationBody({required this.record});
  final ConsultationRecord record;

  @override
  ConsumerState<_ValidationBody> createState() => _ValidationBodyState();
}

class _ValidationBodyState extends ConsumerState<_ValidationBody> {
  late final Map<String, bool> _checked = {...widget.record.checklist};
  bool _busy = false;
  String? _error;

  Future<void> _validate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(consultationRepositoryProvider);
      await repo.save(
        widget.record.copyWith(
          checklist: Map.of(_checked),
          step: ConsultationStep.saved.name,
        ),
      );
      await repo.markValidated(widget.record.id);
      if (mounted) context.go(ConsultationStep.saved.path(widget.record.id));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error =
            'La sauvegarde a échoué. Vos données restent sur le téléphone, réessayez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final complete = ValidationChecklist.isComplete(_checked);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Avant de valider, confirmez chaque point. L\'application ne valide '
          'jamais à votre place.',
          style: TextStyle(color: SuraColors.inkSoft, height: 1.4),
        ),
        const SizedBox(height: 12),
        for (final item in ValidationChecklist.items)
          Card(
            child: CheckboxListTile(
              value: _checked[item.code] ?? false,
              onChanged: _busy
                  ? null
                  : (v) => setState(() => _checked[item.code] = v ?? false),
              title: Text(item.label),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        const SizedBox(height: 12),
        if (!complete)
          InlineAlert(
            'Il reste ${ValidationChecklist.remaining(_checked).length} '
            'case(s) à cocher pour valider.',
            isError: false,
          ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          InlineAlert(_error!),
        ],
        const SizedBox(height: 16),
        SuraButton(
          label: 'Valider et sauvegarder',
          icon: Icons.verified_outlined,
          loading: _busy,
          onPressed: complete ? _validate : null,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'consultation_steps.dart';

/// Cadre commun des écrans du parcours : titre, progression, retour, « Quitter ».
/// Charge la consultation UNE fois (le brouillon est sauvegardé à chaque étape : R10).
/// Lien « Modifier » vers une étape, avec retour automatique au récapitulatif.
String editPath(ConsultationStep step, String consultationId) =>
    '${step.path(consultationId)}?from=recap';

class StepPage extends ConsumerStatefulWidget {
  const StepPage({
    super.key,
    required this.consultationId,
    required this.step,
    required this.title,
    required this.builder,
    this.fromRecap = false,
  });
  final String consultationId;
  final ConsultationStep step;
  final String title;
  final Widget Function(BuildContext context, ConsultationRecord record)
  builder;

  /// Ouvert depuis « Modifier » du récapitulatif : le retour ramène au récapitulatif.
  final bool fromRecap;

  @override
  ConsumerState<StepPage> createState() => _StepPageState();
}

class _StepPageState extends ConsumerState<StepPage> {
  late final Future<ConsultationRecord?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref
        .read(consultationRepositoryProvider)
        .getById(widget.consultationId);
  }

  void _back() {
    if (widget.fromRecap) {
      context.go(ConsultationStep.recap.path(widget.consultationId));
      return;
    }
    final prev = widget.step.previous;
    final home = prev == null || widget.step == ConsultationStep.saved;
    context.go(home ? '/home' : prev.path(widget.consultationId));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: widget.fromRecap
                ? 'Retour au récapitulatif'
                : 'Étape précédente',
            onPressed: _back,
          ),
          actions: [
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Quitter'),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (widget.step.index + 1) / ConsultationStep.values.length,
              minHeight: 4,
              backgroundColor: SuraColors.border,
            ),
          ),
        ),
        body: FutureBuilder<ConsultationRecord?>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final r = snap.data;
            if (r == null) {
              return const Center(child: Text('Consultation introuvable.'));
            }
            return SafeArea(child: widget.builder(context, r));
          },
        ),
      ),
    );
  }
}

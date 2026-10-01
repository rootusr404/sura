import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/widgets/dev_placeholder.dart';
import 'consultation_steps.dart';

/// Écran provisoire d'une étape : permet de traverser tout le parcours dès le jour 1.
class StepPlaceholder extends StatelessWidget {
  const StepPlaceholder({
    super.key,
    required this.step,
    required this.consultationId,
    required this.title,
    required this.task,
    required this.owner,
  });
  final ConsultationStep step;
  final String consultationId;
  final String title;
  final String task;
  final String owner;

  @override
  Widget build(BuildContext context) {
    final next = step.next;
    return DevPlaceholder(
      title: title,
      task: task,
      owner: owner,
      children: [
        FilledButton(
          onPressed: () =>
              context.go(next == null ? '/home' : next.path(consultationId)),
          child: Text(
            next == null ? 'Retour à l\'accueil' : 'Étape suivante (simulée)',
          ),
        ),
      ],
    );
  }
}

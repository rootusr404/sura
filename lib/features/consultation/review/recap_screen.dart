import 'package:flutter/material.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_placeholder.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPlaceholder(
    step: ConsultationStep.recap,
    consultationId: consultationId,
    title: 'Récapitulatif',
    task: 'U-03',
    owner: 'Membre 3',
  );
}

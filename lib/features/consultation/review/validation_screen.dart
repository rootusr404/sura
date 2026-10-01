import 'package:flutter/material.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_placeholder.dart';

class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPlaceholder(
    step: ConsultationStep.validate,
    consultationId: consultationId,
    title: 'Validation',
    task: 'U-03',
    owner: 'Membre 3',
  );
}

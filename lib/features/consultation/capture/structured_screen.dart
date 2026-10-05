import 'package:flutter/material.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_placeholder.dart';

class StructuredScreen extends StatelessWidget {
  const StructuredScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPlaceholder(
    step: ConsultationStep.structured,
    consultationId: consultationId,
    title: 'Informations structurées',
    task: 'C-04',
    owner: 'Membre 2',
  );
}

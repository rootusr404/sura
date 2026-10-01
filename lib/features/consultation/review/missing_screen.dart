import 'package:flutter/material.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_placeholder.dart';

class MissingScreen extends StatelessWidget {
  const MissingScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPlaceholder(
    step: ConsultationStep.missing,
    consultationId: consultationId,
    title: 'Informations manquantes',
    task: 'U-01',
    owner: 'Membre 3',
  );
}

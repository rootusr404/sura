import 'package:flutter/material.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_placeholder.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPlaceholder(
    step: ConsultationStep.consent,
    consultationId: consultationId,
    title: 'Consentement',
    task: 'F-07',
    owner: 'Membre 1',
  );
}

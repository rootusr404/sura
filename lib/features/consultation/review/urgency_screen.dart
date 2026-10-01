import 'package:flutter/material.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_placeholder.dart';

class UrgencyScreen extends StatelessWidget {
  const UrgencyScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPlaceholder(
    step: ConsultationStep.urgency,
    consultationId: consultationId,
    title: 'Niveau d\'urgence',
    task: 'U-02',
    owner: 'Membre 3',
  );
}

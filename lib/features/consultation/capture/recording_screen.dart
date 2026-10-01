import 'package:flutter/material.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_placeholder.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPlaceholder(
    step: ConsultationStep.record,
    consultationId: consultationId,
    title: 'Enregistrement',
    task: 'C-02',
    owner: 'Membre 2',
  );
}

import 'package:flutter/material.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/consultation/flow/step_placeholder.dart';

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context) => StepPlaceholder(
    step: ConsultationStep.transcript,
    consultationId: consultationId,
    title: 'Transcription',
    task: 'C-03',
    owner: 'Membre 2',
  );
}

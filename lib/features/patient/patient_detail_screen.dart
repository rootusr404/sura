import 'package:flutter/material.dart';
import 'package:sura/core/widgets/dev_placeholder.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key, required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) => DevPlaceholder(
    title: 'Dossier $patientId',
    task: 'F-06',
    owner: 'Membre 1',
  );
}

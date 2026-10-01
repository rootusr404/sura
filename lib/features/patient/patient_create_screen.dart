import 'package:flutter/material.dart';
import 'package:sura/core/widgets/dev_placeholder.dart';

class PatientCreateScreen extends StatelessWidget {
  const PatientCreateScreen({super.key});
  @override
  Widget build(BuildContext context) => const DevPlaceholder(
    title: 'Nouveau patient',
    task: 'F-04',
    owner: 'Membre 1',
  );
}

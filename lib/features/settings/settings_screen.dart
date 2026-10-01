import 'package:flutter/material.dart';
import 'package:sura/core/widgets/dev_placeholder.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const DevPlaceholder(
    title: 'Paramètres',
    task: 'S-06',
    owner: 'Membre 4',
  );
}

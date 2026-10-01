import 'package:flutter/material.dart';
import 'package:sura/core/widgets/dev_placeholder.dart';

class UnlockScreen extends StatelessWidget {
  const UnlockScreen({super.key});
  @override
  Widget build(BuildContext context) => const DevPlaceholder(
    title: 'Déverrouillage',
    task: 'S-03',
    owner: 'Membre 4',
  );
}

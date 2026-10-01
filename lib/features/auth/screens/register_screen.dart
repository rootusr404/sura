import 'package:flutter/material.dart';
import 'package:sura/core/widgets/dev_placeholder.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => const DevPlaceholder(
    title: 'Créer un compte',
    task: 'S-02',
    owner: 'Membre 4',
  );
}

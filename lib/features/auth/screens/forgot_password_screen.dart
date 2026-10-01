import 'package:flutter/material.dart';
import 'package:sura/core/widgets/dev_placeholder.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => const DevPlaceholder(
    title: 'Mot de passe oublié',
    task: 'S-02',
    owner: 'Membre 4',
  );
}

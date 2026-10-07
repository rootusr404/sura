import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/widgets.dart';
import 'auth_service.dart';
import 'validators.dart';

/// Mot de passe oublie (maquette 3) : Internet requis (R14).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});
  final String? initialEmail;
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotState();
}

class _ForgotState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  late final email = TextEditingController(text: widget.initialEmail ?? '');
  bool busy = false;
  bool sent = false;
  String? error;

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(authProvider)
          .resetPassword(email.text.trim())
          .timeout(const Duration(seconds: 20));
      if (mounted) setState(() => sent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'user-not-found') {
        setState(() => sent = true); // on ne revele pas si l'adresse existe
      } else {
        setState(() => error = switch (e.code) {
              'invalid-email' => 'Adresse e-mail invalide.',
              'network-request-failed' =>
                'Pas de connexion Internet : cette étape nécessite Internet.',
              'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
              _ => 'Envoi impossible (${e.code}).',
            });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => error = 'Délai dépassé : connexion trop lente.');
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => error = 'Envoi impossible. Vérifiez votre connexion. ($e)');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: suraAppBar(context, 'Mot de passe oublié'),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const SizedBox(height: 8),
            const Text('Réinitialiser votre mot de passe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
                'Saisissez l’adresse e-mail de votre compte. Vous recevrez un lien de réinitialisation.'),
            const SizedBox(height: 12),
            const InfoBanner(
                'Une connexion Internet est nécessaire pour cette étape.'),
            if (!kUseFirebase)
              const InfoBanner(
                  'Mode démonstration : aucun e-mail n’est réellement envoyé.',
                  kind: BannerKind.warn),
            if (sent) ...[
              const InfoBanner(
                  'Si un compte existe pour cette adresse, un lien vient d’être envoyé. Vérifiez vos e-mails (et les courriers indésirables).'),
              PrimaryButton('Retour à la connexion',
                  icon: Icons.login, onPressed: () => context.pop()),
            ] else ...[
              LabeledField(
                  label: 'Adresse e-mail',
                  controller: email,
                  hint: 'agent@exemple.org',
                  keyboard: TextInputType.emailAddress,
                  validator: emailValidator),
              if (error != null) InfoBanner(error!, kind: BannerKind.error),
              PrimaryButton(busy ? 'Envoi…' : 'Envoyer le lien',
                  icon: Icons.send, onPressed: busy ? null : _send),
            ],
          ]),
        ),
      );
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets.dart';
import '../profile/profile_model.dart';
import '../profile/profile_service.dart';
import 'auth_service.dart';
import 'validators.dart';

/// Inscription complete (maquette "Enrolement agent") : compte, identite, affectation, engagement.
/// Internet requis (R14). Le PIN est cree juste apres, sur l'ecran PIN.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  final region = TextEditingController();
  final post = TextEditingController();
  String role = '';
  bool accepted = false;
  bool showPass = false;
  bool roleError = false;
  bool consentError = false;
  bool busy = false;
  String? error;

  String _msg(String code) => switch (code) {
        'email-already-in-use' =>
          'Cette adresse e-mail est déjà utilisée. Connectez-vous.',
        'weak-password' => 'Mot de passe trop faible.',
        'invalid-email' => 'Adresse e-mail invalide.',
        'network-request-failed' =>
          'Pas de connexion Internet : l’inscription nécessite Internet.',
        _ => 'Création du compte impossible ($code).',
      };

  Future<void> _submit() async {
    final formOk = _form.currentState!.validate();
    setState(() {
      error = null;
      roleError = role.isEmpty;
      consentError = !accepted;
    });
    if (!formOk || role.isEmpty || !accepted) return;
    setState(() => busy = true);
    try {
      final a = ref.read(authProvider);
      await a.signUp(email.text.trim(), pass.text);
      final prof = AgentProfile(
        fullName: name.text.trim(),
        phone: phone.text.trim(),
        region: region.text.trim(),
        healthPost: post.text.trim(),
        role: role,
        email: email.text.trim(),
        consentAt: DateTime.now().toIso8601String(),
      );
      await ProfileService.save(a.agentId, prof);
      await ref
          .read(sessionProvider.notifier)
          .loggedIn(); // la redirection ouvre la creation du PIN
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = _msg(e.code));
    } catch (e) {
      if (mounted) {
        setState(() => error =
            'Création du compte impossible. Vérifiez votre connexion. ($e)');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _section(String n, String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(children: [
          CircleAvatar(
              radius: 11, child: Text(n, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: suraAppBar(context, 'Créer mon compte'),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const InfoBanner(
                'Connexion initiale requise : le réseau est nécessaire uniquement pour cet enregistrement. Ensuite, SŪRA fonctionne hors ligne avec votre PIN.'),
            _section('1', 'Compte'),
            LabeledField(
                label: 'Adresse e-mail',
                controller: email,
                hint: 'agent@exemple.org',
                keyboard: TextInputType.emailAddress,
                validator: emailValidator),
            LabeledField(
                label: 'Mot de passe (8 caractères minimum)',
                controller: pass,
                obscure: !showPass,
                validator: passwordValidator),
            LabeledField(
                label: 'Confirmer le mot de passe',
                controller: confirm,
                obscure: !showPass,
                validator: (v) => confirmValidator(v, pass.text)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => showPass = !showPass),
                icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                label: Text(showPass
                    ? 'Masquer les mots de passe'
                    : 'Afficher les mots de passe'),
              ),
            ),
            _section('2', 'Identité de l’agent'),
            LabeledField(
                label: 'Prénom et nom',
                controller: name,
                hint: 'ex : Aminata Diallo',
                validator: requiredField),
            LabeledField(
                label: 'Téléphone professionnel',
                controller: phone,
                hint: '+000 00 00 00 00',
                keyboard: TextInputType.phone,
                validator: phoneValidator),
            const InfoBanner(
                'Votre identifiant SŪRA sera attribué automatiquement à la création du compte.'),
            _section('3', 'Affectation sanitaire'),
            LabeledField(
                label: 'Région / district',
                controller: region,
                hint: 'ex : District A',
                validator: requiredField),
            LabeledField(
                label: 'Poste de santé',
                controller: post,
                hint: 'ex : Poste de santé A',
                validator: requiredField),
            const Text('Rôle clinique',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final r in AgentProfile.roles)
                ChoiceChip(
                    label: Text(r),
                    selected: role == r,
                    onSelected: (v) => setState(() => role = v ? r : '')),
            ]),
            if (roleError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('⚠ Choisissez votre rôle.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12)),
              ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: accepted,
              onChanged: (v) => setState(() => accepted = v ?? false),
              title: const Text(
                  'Je m’engage à respecter la confidentialité des données des patients conformément aux règles de mon établissement de santé.'),
            ),
            if (consentError)
              Text('⚠ L’engagement est requis pour créer le compte.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12)),
            const SizedBox(height: 12),
            if (error != null) InfoBanner(error!, kind: BannerKind.error),
            PrimaryButton(busy ? 'Création…' : 'Créer mon compte',
                icon: Icons.person_add_alt, onPressed: busy ? null : _submit),
          ]),
        ),
      );
}

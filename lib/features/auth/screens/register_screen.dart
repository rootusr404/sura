import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _region = TextEditingController();
  final _district = TextEditingController();
  final _healthPost = TextEditingController();
  final _clinicalRole = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _region.dispose();
    _district.dispose();
    _healthPost.dispose();
    _clinicalRole.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ref
          .read(firebaseAuthServiceProvider)
          .register(
            email: _email.text,
            password: _password.text,
            firstName: _firstName.text,
            lastName: _lastName.text,
            phone: _phone.text,
            region: _region.text,
            district: _district.text,
            healthPost: _healthPost.text,
            clinicalRole: _clinicalRole.text,
          );

      if (mounted) context.go('/pin-setup');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'email-already-in-use' => 'Cette adresse e-mail a déjà un compte.',
        'invalid-email' => 'Cette adresse e-mail est invalide.',
        'weak-password' => 'Choisis un mot de passe plus sécurisé.',
        'network-request-failed' => 'Une connexion Internet est nécessaire pour créer le compte.',
        _ => 'Inscription impossible. Vérifie les informations et réessaie.',
      };

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Le profil agent n’a pas pu être enregistré dans Firestore '
            '(${e.code}). Vérifie que Firestore est créé et que ses règles '
            'autorisent l’écriture du document agents/{uid}.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Une erreur est survenue. Réessaie.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: validator ?? _required,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription agent')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Identité', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _field(_firstName, 'Prénom'),
              _field(_lastName, 'Nom'),
              _field(_phone, 'Téléphone professionnel', keyboardType: TextInputType.phone),

              Text('Affectation', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _field(_region, 'Région'),
              _field(_district, 'District'),
              _field(_healthPost, 'Poste de santé'),
              _field(_clinicalRole, 'Rôle clinique'),

              Text('Compte', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _field(
                _email,
                'E-mail professionnel',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Saisis une adresse e-mail valide.';
                  }
                  return null;
                },
              ),
              _field(
                _password,
                'Mot de passe',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères.';
                  }
                  return null;
                },
              ),
              _field(
                _passwordConfirmation,
                'Confirmer le mot de passe',
                obscureText: true,
                validator: (value) {
                  if (value != _password.text) {
                    return 'Les mots de passe ne correspondent pas.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _register,
                  child: Text(_loading ? 'Création du compte…' : 'Continuer'),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Déjà inscrit ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

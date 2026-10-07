import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'auth_service.dart';
import 'biometric_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> _submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final a = ref.read(authProvider);
      await a.signIn(email.text.trim(), pass.text);
      await ref.read(sessionProvider.notifier).loggedIn();
    } catch (e) {
      if (mounted) {
        setState(() => error =
            'Connexion impossible. Vérifiez vos identifiants et Internet. ($e)');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                  color: T.teal,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.monitor_heart_outlined,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            const Text('SŪRA',
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.w800)),
                          ]),
                      const SizedBox(height: 6),
                      const Text('Documenter les soins, même sans Internet.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      LabeledField(
                          label: 'Adresse e-mail',
                          controller: email,
                          hint: 'agent@exemple.org',
                          keyboard: TextInputType.emailAddress),
                      LabeledField(
                          label: 'Mot de passe',
                          controller: pass,
                          obscure: true),
                      if (error != null)
                        InfoBanner(error!, kind: BannerKind.error),
                      const InfoBanner(
                          'Première connexion : Internet requis. Ensuite, SŪRA fonctionne hors ligne avec votre PIN.'),
                      PrimaryButton(busy ? 'Patientez…' : 'Se connecter',
                          onPressed: busy ? null : _submit),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text(
                            'Première utilisation ? Créer un compte'),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push('/forgot', extra: email.text.trim()),
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      );
}

/// PIN a 6 chiffres : creation (saisie 2 fois) puis deverrouillage. Biometrie : TODO (local_auth).
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});
  @override
  ConsumerState<PinScreen> createState() => _PinState();
}

class _PinState extends ConsumerState<PinScreen> {
  String pin = '';
  String? first;
  String msg = '';
  bool bio = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final b = ref.read(biometricProvider);
      if (!setup && await b.enabled() && await b.available()) {
        if (mounted) setState(() => bio = true);
        await _bio();
      }
    });
  }

  Future<void> _bio() async {
    final ok = await ref.read(biometricProvider).authenticate();
    if (ok && mounted) ref.read(sessionProvider.notifier).unlock();
  }

  bool get setup => !ref.read(sessionProvider).hasPin;

  Future<void> _tap(String d) async {
    if (pin.length >= 6) return;
    setState(() => pin += d);
    if (pin.length == 6) await _done();
  }

  Future<void> _done() async {
    final auth = ref.read(authProvider);
    final session = ref.read(sessionProvider.notifier);
    if (setup) {
      if (first == null) {
        setState(() {
          first = pin;
          pin = '';
          msg = 'Confirmez votre PIN';
        });
      } else if (first == pin) {
        await auth.setPin(pin);
        session.pinSet();
      } else {
        setState(() {
          first = null;
          pin = '';
          msg = 'Les PIN ne correspondent pas. Recommencez.';
        });
      }
      return;
    }
    final r = await auth.verifyPin(pin);
    if (r == PinResult.ok) {
      session.unlock();
    } else if (mounted) {
      setState(() {
        pin = '';
        msg = r == PinResult.locked
            ? 'Trop de tentatives. Réessayez dans un instant.'
            : 'PIN incorrect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return Scaffold(
      backgroundColor: T.tealDark,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('SŪRA',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                  setup
                      ? (first == null
                          ? 'Créez votre PIN à 6 chiffres'
                          : 'Confirmez votre PIN')
                      : 'Entrez votre PIN',
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < 6; i++)
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < pin.length ? Colors.white : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
              ]),
              SizedBox(
                  height: 22,
                  child:
                      Text(msg, style: const TextStyle(color: Colors.white70))),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final k in keys)
                    k.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.all(5),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white24,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => k == '⌫'
                                  ? setState(() => pin = pin.isEmpty
                                      ? ''
                                      : pin.substring(0, pin.length - 1))
                                  : _tap(k),
                              child: Text(k,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                ],
              ),
              if (bio)
                TextButton.icon(
                  onPressed: _bio,
                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                  label: const Text('Utiliser la biométrie',
                      style: TextStyle(color: Colors.white)),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

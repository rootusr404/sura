import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ref.read(pinServiceProvider).setPin(_pinController.text);

      if (mounted) context.go('/home');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Impossible d’enregistrer le PIN.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _pinField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
      validator:
          validator ??
          (value) => value == null || value.length != 6 ? 'Saisis exactement 6 chiffres.' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer votre PIN')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Ce PIN servira à déverrouiller SŪRA sur cet appareil. '
                'Il ne sera pas envoyé à Firebase.',
              ),
              const SizedBox(height: 24),
              _pinField(controller: _pinController, label: 'PIN à 6 chiffres'),
              const SizedBox(height: 16),
              _pinField(
                controller: _confirmationController,
                label: 'Confirmer le PIN',
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Saisis exactement 6 chiffres.';
                  }
                  if (value != _pinController.text) {
                    return 'Les deux PIN ne correspondent pas.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _savePin,
                  child: Text(_loading ? 'Enregistrement…' : 'Enregistrer le PIN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _pinController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_pinController.text.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saisis ton PIN à 6 chiffres.')));
      return;
    }

    setState(() => _loading = true);

    try {
      final service = ref.read(pinServiceProvider);
      final isCorrect = await service.verifyPin(_pinController.text);

      if (!mounted) return;

      if (isCorrect) {
        ref.read(pinSessionProvider).unlock();
        if (mounted) context.go('/home');
      } else {
        _pinController.clear();

        final remaining = await service.lockRemaining;
        final attempts = await service.failedAttempts;

        if (!mounted) return;

        final message = remaining != null
            ? 'Trop de tentatives. Réessaie dans ${remaining.inSeconds} secondes.'
            : 'PIN incorrect. Tentative $attempts sur 5.';

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Impossible de vérifier le PIN.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Déverrouiller SŪRA')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Saisis ton PIN pour accéder à l’application.'),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                onSubmitted: (_) => _unlock(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _unlock,
                  child: Text(_loading ? 'Vérification…' : 'Déverrouiller'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

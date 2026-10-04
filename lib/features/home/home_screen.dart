import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';
import 'package:sura/features/auth/providers/auth_providers.dart';

/// Menu de développement provisoire. Membre 1 (F-03) le remplace par l'accueil réel.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('SŪRA — menu de développement')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Démarrer une consultation (patient démo)'),
            subtitle: const Text('Traverse tout le parcours avec les fakes'),
            onTap: () async {
              final String? agentId = ref.read<String?>(currentAgentIdProvider);

              if (agentId == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Aucun agent connecté.')));
                return;
              }

              try {
                final c = await ref
                    .read(consultationRepositoryProvider)
                    .createDraft(patientId: 'SUR-DEMO-0001', agentId: agentId);

                if (!context.mounted) return;
                context.go(ConsultationStep.consent.path(c.id));
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Impossible de créer la consultation.')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Patients'),
            onTap: () => context.go('/patients'),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Nouveau patient'),
            onTap: () => context.go('/patients/new'),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scanner un QR'),
            onTap: () => context.go('/patients/scan'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () => context.go('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Connexion (écran)'),
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}

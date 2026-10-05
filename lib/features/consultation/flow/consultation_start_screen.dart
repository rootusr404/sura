import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/features/auth/providers/auth_providers.dart';
import 'package:sura/core/theme/sura_colors.dart';
import 'package:sura/core/widgets/sura_button.dart';
import 'package:sura/features/patient/patient_providers.dart';
import 'consultation_steps.dart';

/// /consultation/new[?patientId=…] : crée le brouillon, ou fait choisir un patient.
class ConsultationStartScreen extends ConsumerStatefulWidget {
  const ConsultationStartScreen({super.key, this.patientId});
  final String? patientId;
  @override
  ConsumerState<ConsultationStartScreen> createState() => _State();
}

class _State extends ConsumerState<ConsultationStartScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _start(widget.patientId!),
      );
    }
  }

  Future<void> _start(String patientId) async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    try {
      final agentId = ref.read(currentAgentIdProvider);
      if (agentId == null) throw StateError('Aucun agent connecté.');
      final c = await ref
          .read(consultationRepositoryProvider)
          .createDraft(patientId: patientId, agentId: agentId);
      if (mounted) context.go(ConsultationStep.consent.path(c.id));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de créer la consultation.')),
        );
        context.go('/patients');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patientId != null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final patients = ref.watch(filteredPatientsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quel patient ?'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Nom, village ou identifiant SUR-…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  ref.read(patientSearchQueryProvider.notifier).set(v),
            ),
          ),
          Expanded(
            child: patients.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erreur de lecture locale : $e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Aucun patient trouvé.',
                            style: TextStyle(color: SuraColors.inkSoft),
                          ),
                          const SizedBox(height: 16),
                          SuraButton(
                            label: 'Créer un patient',
                            icon: Icons.person_add_alt,
                            onPressed: () => context.go('/patients/new'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = list[i];
                    return Card(
                      child: ListTile(
                        enabled: !_busy,
                        title: Text('${p.firstName} ${p.lastName}'),
                        subtitle: Text(
                          '${p.ageYears} ans · ${p.village} · ${p.id}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _start(p.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

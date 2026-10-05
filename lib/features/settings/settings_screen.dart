import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/widgets/status_chip.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/features/auth/providers/auth_providers.dart';
import 'package:sura/features/sync/sync_providers.dart';

import 'settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _retrying = <String>{};
  bool _loggingOut = false;

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _retry(String id) async {
    setState(() => _retrying.add(id));
    try {
      await ref.read(syncServiceProvider).retry(id);
    } catch (_) {
      _message(
        'Impossible de relancer la synchronisation. Réessaie plus tard.',
      );
    } finally {
      if (mounted) setState(() => _retrying.remove(id));
    }
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      final agent = ref.read(settingsAgentIdProvider).asData?.value;
      if (agent == null) return;
      final remaining = ref.read(settingsSyncItemsProvider).asData?.value;
      if (remaining == null) {
        _message('Impossible de vérifier les données à synchroniser.');
        return;
      }
      if (remaining.count > 0) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Des données restent à synchroniser'),
            content: Text(
              '${remaining.count} élément(s) non synchronisé(s), y compris les brouillons. '
              'Les données locales ne seront pas supprimées. '
              'Pour reprendre leur synchronisation, reconnecte-toi avec le même compte.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
      }
      if (ref.read(settingsAgentIdProvider).asData?.value != agent) return;
      final logout = ref.read(settingsLogoutProvider);
      final pin = ref.read(pinSessionProvider);
      await logout();
      pin.lock();
      if (mounted) context.go('/login');
    } catch (_) {
      _message('Déconnexion impossible. Vérifie la connexion et réessaie.');
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Widget _item({
    required String id,
    required String title,
    required String description,
    required SyncState state,
    required int attempts,
    String? error,
    bool validated = true,
  }) {
    final busy = _retrying.contains(id);
    return Card(
      key: ValueKey('sync-item-$id'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(description),
            const SizedBox(height: 8),
            StatusChip(state: state),
            if (!validated)
              const Text('Brouillon : à valider avant synchronisation.'),
            if (attempts > 0) Text('Tentatives : $attempts'),
            if (error != null) Text(error),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: ValueKey('retry-$id'),
              onPressed:
                  busy ||
                      _loggingOut ||
                      state == SyncState.syncing ||
                      !validated
                  ? null
                  : () => _retry(id),
              icon: const Icon(Icons.refresh),
              label: Text(busy ? 'Réessai en cours…' : 'Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(settingsSyncItemsProvider);
    final agent = ref.watch(settingsAgentIdProvider);
    final overall = ref.watch(overallSyncStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Synchronisation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            overall.when(
              data: (state) => Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(state: state),
              ),
              loading: () =>
                  const Text('Lecture du statut de synchronisation…'),
              error: (_, _) =>
                  const Text('Statut de synchronisation indisponible.'),
            ),
            const SizedBox(height: 12),
            items.when(
              loading: () => const Text('Chargement des données locales…'),
              error: (_, _) =>
                  const Text('Impossible de lire les éléments à synchroniser.'),
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${data.count} élément(s) non synchronisé(s)'),
                  if (data.count == 0)
                    const Text('Aucun élément en attente pour ce compte.'),
                  if (data.patients.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Patients'),
                    ),
                  for (final p in data.patients)
                    _item(
                      id: p.id,
                      title: 'Patient — ${p.fullName}',
                      description: p.id,
                      state: p.syncState,
                      attempts: p.syncAttempts,
                      error: p.syncError,
                    ),
                  if (data.consultations.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Consultations'),
                    ),
                  for (final c in data.consultations)
                    _item(
                      id: c.id,
                      title: 'Consultation — ${c.id}',
                      description: 'Patient : ${c.patientId}',
                      state: c.syncState,
                      attempts: c.syncAttempts,
                      error: c.syncError,
                      validated:
                          c.status == ConsultationStatus.saved &&
                          c.validatedAt != null,
                    ),
                ],
              ),
            ),
            const Divider(height: 32),
            FilledButton.icon(
              onPressed: _loggingOut
                  ? null
                  : () {
                      ref.read(pinSessionProvider).lock();
                      context.go('/unlock');
                    },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Verrouiller maintenant'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('settings-logout'),
              onPressed:
                  _loggingOut ||
                      items.asData == null ||
                      agent.asData?.value == null
                  ? null
                  : _logout,
              icon: const Icon(Icons.logout),
              label: Text(_loggingOut ? 'Déconnexion…' : 'Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/tiles.dart';
import '../../core/widgets.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../domain/models.dart';
import '../auth/auth_service.dart';
import 'qr_widgets.dart';

String _newPatientId() {
  // Format SUR-AAAA-XXXXXXXX : suffixe de 8 caracteres (4 est trop court pour une generation hors ligne).
  final hex =
      const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase();
  return 'SUR-${DateTime.now().year}-$hex';
}

Future<void> startConsultation(
    BuildContext context, WidgetRef ref, String patientId) async {
  final id = await ref.read(consultationServiceProvider).start(patientId);
  if (context.mounted) context.push('/consult/$id/consent');
}

/// Onglet Patients : segments Patients | Consultations (decision V3).
class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});
  @override
  ConsumerState<PatientsScreen> createState() => _PatientsState();
}

class _PatientsState extends ConsumerState<PatientsScreen> {
  int tab = 0;
  String q = '';
  bool draftOnly = false;
  int? urgency;
  int days = 0; // 0 = toutes les periodes
  String? sync;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: suraAppBar(context, 'Patients', back: false, actions: [
        IconButton(
            icon: const Icon(Icons.person_add_alt),
            tooltip: 'Nouveau patient',
            onPressed: () => context.push('/patients/new')),
        const ThemeToggle(),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Patients')),
              ButtonSegment(value: 1, label: Text('Consultations')),
            ],
            selected: {tab},
            onSelectionChanged: (s) => setState(() => tab = s.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: tab == 0 ? 'Nom, identifiant…' : 'Patient…',
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        if (tab == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _openFilters,
                icon: const Icon(Icons.filter_list),
                label: Text(_activeFilters() == 0
                    ? 'Filtres'
                    : 'Filtres (${_activeFilters()})'),
              ),
            ),
          ),
        Expanded(child: tab == 0 ? _patients() : _consultations()),
      ]),
    );
  }

  int _activeFilters() =>
      (draftOnly ? 1 : 0) +
      (urgency != null ? 1 : 0) +
      (days != 0 ? 1 : 0) +
      (sync != null ? 1 : 0);

  Future<void> _openFilters() async {
    var d = days;
    var st = sync;
    var u = urgency;
    var dr = draftOnly;
    const syncKeys = <String?>[null, 'pending', 'synced', 'error'];
    const syncLabels = ['Tous', '○ En attente', '✓ Synchronisé', '⚠ Erreur'];
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filtres',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 18)),
                        TextButton(
                          onPressed: () => setM(() {
                            d = 0;
                            st = null;
                            u = null;
                            dr = false;
                          }),
                          child: const Text('Réinitialiser'),
                        ),
                      ]),
                  const Text('Période',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Wrap(spacing: 6, children: [
                    for (final e in const {
                      0: 'Toutes',
                      1: 'Aujourd’hui',
                      7: '7 jours',
                      30: '30 jours'
                    }.entries)
                      ChoiceChip(
                          label: Text(e.value),
                          selected: d == e.key,
                          onSelected: (_) => setM(() => d = e.key)),
                  ]),
                  const SizedBox(height: 8),
                  const Text('Urgence',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Wrap(spacing: 6, children: [
                    for (final x in Urgency.values)
                      ChoiceChip(
                        label: Text('${x.symbol} ${x.label}'),
                        selected: u == x.index,
                        onSelected: (v) => setM(() => u = v ? x.index : null),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  const Text('Statut de synchronisation',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Wrap(spacing: 6, children: [
                    for (var i = 0; i < syncKeys.length; i++)
                      ChoiceChip(
                          label: Text(syncLabels[i]),
                          selected: st == syncKeys[i],
                          onSelected: (_) => setM(() => st = syncKeys[i])),
                  ]),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Brouillons seulement'),
                    value: dr,
                    onChanged: (v) => setM(() => dr = v),
                  ),
                  PrimaryButton('Appliquer',
                      icon: Icons.check,
                      onPressed: () => Navigator.pop(ctx, true)),
                ]),
          ),
        ),
      ),
    );
    if (applied == true) {
      setState(() {
        days = d;
        sync = st;
        urgency = u;
        draftOnly = dr;
      });
    }
  }

  Widget _patients() {
    final list = ref.watch(patientsProvider(q));
    return list.when(
      loading: () => const LoadingView(),
      error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: InfoBanner('Erreur technique : $e', kind: BannerKind.error)),
      data: (ps) {
        if (ps.isEmpty) {
          return EmptyState(
            icon: Icons.groups_outlined,
            title: q.isEmpty
                ? 'Aucun patient sur cet appareil'
                : 'Aucun résultat pour « $q »',
            message: q.isEmpty
                ? 'Créez un patient ou scannez son carnet de santé.'
                : 'Vérifiez l’orthographe ou cherchez avec l’identifiant. La recherche porte sur les patients de cet appareil.',
            action: PrimaryButton('Créer un patient',
                icon: Icons.person_add_alt,
                onPressed: () => context.push('/patients/new')),
          );
        }
        return ListView(padding: const EdgeInsets.all(16), children: [
          for (final p in ps)
            SuraCard(
              onTap: () => context.push('/patients/${p.id}'),
              child: Row(children: [
                CircleAvatar(
                    child: Text(
                        '${p.firstName[0]}${p.familyName[0]}'.toUpperCase())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.firstName} ${p.familyName}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${p.id} · ${p.ageYears} ans',
                            style: const TextStyle(fontSize: 12)),
                      ]),
                ),
                SyncChip(p.syncStatus),
              ]),
            ),
        ]);
      },
    );
  }

  Widget _consultations() {
    final list = ref.watch(consultationsProvider(
        ConsFilter(draftOnly: draftOnly, urgency: urgency)));
    final names = {
      for (final p in ref.watch(allPatientsProvider).value ?? const <Patient>[])
        p.id: '${p.firstName} ${p.familyName}'.toLowerCase(),
    };
    return list.when(
      loading: () => const LoadingView(),
      error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: InfoBanner('Erreur technique : $e', kind: BannerKind.error)),
      data: (cs) {
        final n = DateTime.now();
        final since = days == 0
            ? null
            : (days == 1
                ? DateTime(n.year, n.month, n.day)
                : n.subtract(Duration(days: days)));
        final shown = cs.where((c) {
          if (q.trim().isNotEmpty &&
              !(names[c.patientId] ?? '').contains(q.trim().toLowerCase())) {
            return false;
          }
          if (since != null && c.createdAt.isBefore(since)) return false;
          if (sync != null && c.syncStatus != sync) return false;
          return true;
        }).toList();
        if (shown.isEmpty) {
          return const EmptyState(
            icon: Icons.assignment_outlined,
            title: 'Aucune consultation',
            message:
                'Vos consultations enregistrées apparaîtront ici (données présentes sur cet appareil).',
          );
        }
        return ListView(
            padding: const EdgeInsets.all(16),
            children: [for (final c in shown) ConsultationTile(c)]);
      },
    );
  }
}

class CreatePatientScreen extends ConsumerStatefulWidget {
  const CreatePatientScreen({super.key});
  @override
  ConsumerState<CreatePatientScreen> createState() => _CreatePatientState();
}

class _CreatePatientState extends ConsumerState<CreatePatientScreen> {
  final _form = GlobalKey<FormState>();
  final family = TextEditingController();
  final first = TextEditingController();
  final age = TextEditingController();
  final village = TextEditingController();
  late final String id = _newPatientId();
  String sex = 'F';

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? '⚠ Ce champ est requis.' : null;

  String? _age(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 0 || n > 120) {
      return '⚠ Saisissez un âge entre 0 et 120.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final now = DateTime.now();
    await ref.read(repoProvider).addPatient(PatientsCompanion.insert(
          id: id,
          familyName: family.text.trim(),
          firstName: first.text.trim(),
          ageYears: int.parse(age.text.trim()),
          ageRecordedAt: now,
          sex: sex,
          createdBy: ref.read(agentIdProvider),
          createdAt: now,
          village: Value(village.text.trim()),
        ));
    ref.read(syncServiceProvider).run();
    if (mounted) context.pushReplacement('/patients/$id');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: suraAppBar(context, 'Nouveau patient'),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Identifiant unique · 🔒 généré automatiquement',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            SuraCard(
                child: Text(id,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800))),
            LabeledField(
                label: 'Nom de famille',
                controller: family,
                hint: 'ex : Traoré',
                validator: _required),
            LabeledField(
                label: 'Prénom',
                controller: first,
                hint: 'ex : Adama',
                validator: _required),
            LabeledField(
                label: 'Âge (ans)',
                controller: age,
                hint: 'ex : 34',
                keyboard: TextInputType.number,
                validator: _age),
            const Text('Sexe biologique',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'F', label: Text('Femme')),
                ButtonSegment(value: 'M', label: Text('Homme')),
                ButtonSegment(value: 'O', label: Text('Autre')),
              ],
              selected: {sex},
              onSelectionChanged: (s) => setState(() => sex = s.first),
            ),
            const SizedBox(height: 12),
            LabeledField(
                label: 'Village / quartier',
                controller: village,
                hint: 'ex : Quartier Nord'),
            PrimaryButton('Créer le patient',
                icon: Icons.person_add_alt, onPressed: _save),
          ]),
        ),
      );
}

class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cons =
        ref.watch(consultationsProvider(ConsFilter(patientId: id))).value ?? [];
    return Scaffold(
      appBar: suraAppBar(context, 'Dossier patient'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        PatientHeader(id),
        PrimaryButton('Nouvelle consultation',
            icon: Icons.add,
            onPressed: () => startConsultation(context, ref, id)),
        Text('Consultations (${cons.length})',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        if (cons.isEmpty) const Text('Aucune consultation pour ce patient.'),
        for (final c in cons) ConsultationTile(c),
        const SizedBox(height: 8),
        SuraCard(
          child: Column(children: [
            const Text('QR du carnet de santé',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            PatientQr(id),
            const SizedBox(height: 6),
            const Text(
                'Identifiant opaque : aucune donnée médicale dans le QR.',
                style: TextStyle(fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

class IdentifyPatientScreen extends ConsumerStatefulWidget {
  const IdentifyPatientScreen({super.key});
  @override
  ConsumerState<IdentifyPatientScreen> createState() => _IdentifyState();
}

class _IdentifyState extends ConsumerState<IdentifyPatientScreen> {
  String q = '';

  Future<void> _openById(String raw) async {
    final id = raw.trim();
    if (id.isEmpty) return;
    final p = await ref.read(repoProvider).getPatient(id);
    if (!mounted) return;
    if (p != null) {
      await startConsultation(context, ref, p.id);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Patient inconnu sur cet appareil'),
        content: const Text(
            'Cet identifiant n’existe pas ici. Vérifiez la saisie, ou créez le patient. Hors ligne, un dossier présent seulement sur le serveur n’est pas accessible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d), child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Navigator.pop(d);
              context.push('/patients/new');
            },
            child: const Text('Créer un patient'),
          ),
        ],
      ),
    );
  }

  Future<void> _manual() async {
    final ctl = TextEditingController();
    final v = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Identifiant du patient'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'SUR-2026-XXXXXXXX'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d), child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(d, ctl.text),
              child: const Text('Rechercher')),
        ],
      ),
    );
    if (v != null) await _openById(v.toUpperCase());
  }

  Future<void> _scan() async {
    final code = await context.push<String>('/scan');
    if (code == null) return;
    if (code == '__manual__') {
      await _manual();
    } else {
      await _openById(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(patientsProvider(q)).value ?? [];
    return Scaffold(
      appBar: suraAppBar(context, 'Identifier le patient'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
          onChanged: (v) => setState(() => q = v),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Nom, identifiant…',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton('Scanner le QR du patient',
            icon: Icons.qr_code_scanner, onPressed: _scan),
        SecondaryButton('Saisir l’identifiant à la main', onPressed: _manual),
        const Text('Patients sur cet appareil',
            style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (list.isEmpty)
          const Text('Aucun résultat. Créez un nouveau patient.'),
        for (final p in list)
          SuraCard(
            onTap: () => startConsultation(context, ref, p.id),
            child: Row(children: [
              Expanded(
                  child: Text(
                      '${p.firstName} ${p.familyName} · ${p.ageYears} ans',
                      style: const TextStyle(fontWeight: FontWeight.w700))),
              const Icon(Icons.chevron_right),
            ]),
          ),
        SecondaryButton('Créer un nouveau patient',
            onPressed: () => context.push('/patients/new')),
      ]),
    );
  }
}

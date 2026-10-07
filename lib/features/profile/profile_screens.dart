import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../auth/auth_service.dart';
import '../auth/validators.dart';
import 'profile_model.dart';
import 'profile_service.dart';

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  return parts.take(2).map((e) => e[0]).join().toUpperCase();
}

/// Carte en haut de Parametres : ouvre le profil.
class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(agentIdProvider);
    final prof = ref.watch(profileProvider).value;
    final name = (prof?.fullName ?? '').trim();
    final role = prof?.role ?? '';
    return SuraCard(
      onTap: () => context.push('/settings/profile'),
      child: Row(children: [
        CircleAvatar(
            child: name.isEmpty
                ? const Icon(Icons.person_outline)
                : Text(_initials(name))),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.isEmpty ? 'Compléter mon profil' : name,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            Text('${agentCode(uid)}${role.isEmpty ? '' : ' · $role'}',
                style: const TextStyle(fontSize: 12)),
          ]),
        ),
        const Icon(Icons.chevron_right),
      ]),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(agentIdProvider);
    final prof = ref.watch(profileProvider).value ?? const AgentProfile();
    final cons =
        ref.watch(consultationsProvider(const ConsFilter())).value ?? [];
    final patients = ref.watch(allPatientsProvider).value ?? [];
    final saved = cons.where((c) => c.status == 'saved').toList();
    final pending = saved.where((c) => c.syncStatus != 'synced').length;
    final synced = saved.length - pending;

    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 120,
                child: Text(k,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
            Expanded(
              child: Text(v.trim().isEmpty ? 'Non renseigné' : v,
                  style: TextStyle(
                      fontStyle: v.trim().isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal)),
            ),
          ]),
        );
    Widget stat(String value, String label) => Expanded(
          child: SuraCard(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11)),
            ]),
          ),
        );

    return Scaffold(
      appBar: suraAppBar(context, 'Mon profil', actions: [
        IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier',
            onPressed: () => context.push('/settings/profile/edit')),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SuraCard(
          child: Row(children: [
            CircleAvatar(
              radius: 28,
              child: prof.fullName.trim().isEmpty
                  ? const Icon(Icons.person_outline)
                  : Text(_initials(prof.fullName),
                      style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        prof.fullName.trim().isEmpty
                            ? 'Profil à compléter'
                            : prof.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18)),
                    Text(agentCode(uid), style: const TextStyle(fontSize: 12)),
                    if (prof.role.isNotEmpty) Text(prof.role),
                  ]),
            ),
          ]),
        ),
        if (!prof.isComplete) ...[
          InfoBanner(
              'Profil complété à ${(prof.completion * 100).round()} %. Ajoutez les informations manquantes.',
              kind: BannerKind.warn),
          LinearProgressIndicator(value: prof.completion),
          const SizedBox(height: 12),
        ],
        SuraCard(
          child: Column(children: [
            line('Identifiant', '${agentCode(uid)} (automatique)'),
            line('Rôle', prof.role),
            line('Poste de santé', prof.healthPost),
            line('Région / district', prof.region),
            line('Téléphone', prof.phone),
            line('E-mail', prof.email),
          ]),
        ),
        Row(children: [
          stat('${saved.length}', 'Consultations'),
          const SizedBox(width: 8),
          stat('$pending', 'À synchroniser'),
        ]),
        Row(children: [
          stat('$synced', 'Envoyées'),
          const SizedBox(width: 8),
          stat('${patients.length}', 'Patients'),
        ]),
        if (prof.consentAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Engagement de confidentialité accepté le ${fmtDate(DateTime.tryParse(prof.consentAt!) ?? DateTime.now())}.',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        PrimaryButton('Modifier le profil',
            icon: Icons.edit_outlined,
            onPressed: () => context.push('/settings/profile/edit')),
      ]),
    );
  }
}

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(profileProvider).when(
            data: (p) => _EditForm(initial: p),
            loading: () => const Scaffold(body: LoadingView()),
            error: (e, _) => Scaffold(
              appBar: suraAppBar(context, 'Modifier le profil'),
              body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: InfoBanner('Erreur technique : $e',
                      kind: BannerKind.error)),
            ),
          );
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.initial});
  final AgentProfile initial;
  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.initial.fullName);
  late final phone = TextEditingController(text: widget.initial.phone);
  late final region = TextEditingController(text: widget.initial.region);
  late final post = TextEditingController(text: widget.initial.healthPost);
  late String role = widget.initial.role;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final uid = ref.read(agentIdProvider);
    final updated = AgentProfile(
      fullName: name.text.trim(),
      phone: phone.text.trim(),
      region: region.text.trim(),
      healthPost: post.text.trim(),
      role: role,
      email: widget.initial.email,
      consentAt: widget.initial.consentAt,
    );
    await ProfileService.save(uid, updated);
    ref.invalidate(profileProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Profil enregistré. Il sera envoyé dès que la connexion le permet.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(agentIdProvider);
    return Scaffold(
      appBar: suraAppBar(context, 'Modifier le profil'),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Identifiant · 🔒 automatique',
              style: TextStyle(fontWeight: FontWeight.w700)),
          SuraCard(
              child: Text(agentCode(uid),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800))),
          const Text('E-mail (non modifiable ici)',
              style: TextStyle(fontWeight: FontWeight.w700)),
          SuraCard(
              child: Text(
                  widget.initial.email.isEmpty ? '—' : widget.initial.email)),
          LabeledField(
              label: 'Prénom et nom',
              controller: name,
              hint: 'ex : Aminata Diallo',
              validator: requiredField),
          LabeledField(
              label: 'Téléphone professionnel',
              controller: phone,
              hint: '+000 00 00 00 00',
              keyboard: TextInputType.phone),
          LabeledField(
              label: 'Région / district',
              controller: region,
              hint: 'ex : District A'),
          LabeledField(
              label: 'Poste de santé',
              controller: post,
              hint: 'ex : Poste de santé A'),
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
          const SizedBox(height: 16),
          PrimaryButton('Enregistrer', icon: Icons.check, onPressed: _save),
        ]),
      ),
    );
  }
}

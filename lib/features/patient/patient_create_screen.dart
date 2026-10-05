import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/features/auth/providers/auth_providers.dart';
import '../../core/theme/sura_colors.dart';
import '../../core/widgets/inline_alert.dart';
import '../../core/widgets/sura_button.dart';

class PatientCreateScreen extends ConsumerStatefulWidget {
  const PatientCreateScreen({super.key});
  @override
  ConsumerState<PatientCreateScreen> createState() => _State();
}

class _State extends ConsumerState<PatientCreateScreen> {
  final _form = GlobalKey<FormState>();
  final _last = TextEditingController();
  final _first = TextEditingController();
  final _age = TextEditingController();
  final _village = TextEditingController();
  final _phone = TextEditingController();
  String? _sex;
  bool _sexError = false, _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_last, _first, _age, _village, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

  Future<void> _submit() async {
    final okForm = _form.currentState!.validate();
    setState(() => _sexError = _sex == null);
    if (!okForm || _sex == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final agentId = ref.read(currentAgentIdProvider);
      if (agentId == null) throw StateError('Aucun agent connecté.');
      final p = await ref
          .read(patientRepositoryProvider)
          .create(
            lastName: _last.text,
            firstName: _first.text,
            ageYears: int.parse(_age.text),
            sex: _sex!,
            village: _village.text,
            phone: _phone.text,
            agentId: agentId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient enregistré sur le téléphone : ${p.id}'),
        ),
      );
      context.pushReplacement('/patients/${p.id}');
    } catch (e) {
      if (mounted) setState(() => _error = 'Enregistrement impossible : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau patient')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const InlineAlert(
                  'Un identifiant SŪRA unique sera généré. Aucune connexion n\'est nécessaire.',
                  isError: false,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  InlineAlert(_error!),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _last,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: _required,
                ),
                gap,
                TextFormField(
                  controller: _first,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: _required,
                ),
                gap,
                TextFormField(
                  controller: _age,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Âge (en années)',
                    counterText: '',
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null) return 'Saisissez l\'âge';
                    if (n > 120) return 'Âge improbable (120 max)';
                    return null;
                  },
                ),
                gap,
                const Text(
                  'Sexe',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'F', label: Text('Femme')),
                    ButtonSegment(value: 'M', label: Text('Homme')),
                  ],
                  selected: _sex == null ? <String>{} : {_sex!},
                  onSelectionChanged: (s) =>
                      setState(() => _sex = s.isEmpty ? null : s.first),
                ),
                if (_sexError)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Choisissez le sexe',
                      style: TextStyle(
                        color: SuraColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                gap,
                TextFormField(
                  controller: _village,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Village / quartier',
                  ),
                  validator: _required,
                ),
                gap,
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone (facultatif)',
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return null;
                    final digits = t.replaceAll(RegExp(r'[^0-9]'), '');
                    return digits.length < 8 ? 'Numéro trop court' : null;
                  },
                ),
                const SizedBox(height: 24),
                SuraButton(
                  label: 'Enregistrer le patient',
                  loading: _busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/manual_entry.dart';
import '../../domain/models.dart';
import '../../domain/rules.dart';

/// Saisie manuelle propre : symptomes a cocher, duree chiffree, temperature, allergies/traitement en 2 touches,
/// avec une ESTIMATION EN DIRECT du niveau d'urgence (le niveau final se decide a l'etape Urgence).
class ManualEntryForm extends ConsumerStatefulWidget {
  const ManualEntryForm({super.key, required this.c});
  final Consultation c;
  @override
  ConsumerState<ManualEntryForm> createState() => _ManualState();
}

class _ManualState extends ConsumerState<ManualEntryForm> {
  late final ManualEntry init =
      ManualEntry.fromStructured(Structured.decode(widget.c.structuredJson));
  late final motif = TextEditingController(text: init.motif);
  late final other = TextEditingController(text: init.other);
  late final number = TextEditingController(text: init.durationNumber);
  late final temp = TextEditingController(text: init.temperature);
  late final aText = TextEditingController(text: init.allergyText);
  late final tText = TextEditingController(text: init.treatmentText);
  late final Set<String> selected = {...init.symptoms};
  late String unit = init.durationUnit;
  late int aMode = init.allergyMode;
  late int tMode = init.treatmentMode;

  @override
  void initState() {
    super.initState();
    for (final c in [motif, other, number, temp, aText, tText]) {
      c.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  ManualEntry get entry => ManualEntry(
        motif: motif.text,
        symptoms: selected,
        other: other.text,
        durationNumber: number.text,
        durationUnit: unit,
        temperature: temp.text,
        allergyMode: aMode,
        allergyText: aText.text,
        treatmentMode: tMode,
        treatmentText: tText.text,
      );

  Future<void> _next() async {
    final e = entry;
    if (e.temperatureInvalid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Température invalide : saisissez une valeur entre 30 et 45 °C, ou laissez vide.')));
      return;
    }
    final svc = ref.read(consultationServiceProvider);
    await svc.saveStructured(widget.c.id, e.toStructured());
    await svc.setStage(widget.c.id, 'missing');
    if (mounted) context.push('/consult/${widget.c.id}/missing');
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(t,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      );

  Widget _choices(int mode, void Function(int) set, String none,
      TextEditingController text, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, children: [
        ChoiceChip(
            label: Text(none),
            selected: mode == 1,
            onSelected: (v) => setState(() => set(v ? 1 : 0))),
        ChoiceChip(
            label: const Text('À préciser'),
            selected: mode == 2,
            onSelected: (v) => setState(() => set(v ? 2 : 0))),
      ]),
      if (mode == 2)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(
              controller: text,
              decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)))),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final patient = ref.watch(patientProvider(widget.c.patientId)).value;
    final res =
        UrgencyEngine.evaluate(e.toStructured(), ageYears: patient?.ageYears);
    return StepScaffold(
      consultationId: widget.c.id,
      stage: 'structured',
      title: 'Saisie manuelle',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SuraCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                  child: Text('Estimation provisoire de l’urgence',
                      style: TextStyle(fontWeight: FontWeight.w800))),
              UrgencyBadge(res.level),
            ]),
            const SizedBox(height: 4),
            Text(res.reasons.take(2).join(' · '),
                style: const TextStyle(fontSize: 12)),
            const Text(
                'Mise à jour en direct. Vous déciderez du niveau à l’étape Urgence.',
                style: TextStyle(fontSize: 11)),
          ]),
        ),
        _title('Symptômes'),
        Wrap(spacing: 6, runSpacing: 4, children: [
          for (final s in ManualEntry.knownSymptoms)
            FilterChip(
              label: Text(ManualEntry.dangerSymptoms.contains(s) ? '⚠ $s' : s),
              selected: selected.contains(s),
              onSelected: (v) =>
                  setState(() => v ? selected.add(s) : selected.remove(s)),
            ),
        ]),
        const SizedBox(height: 8),
        LabeledField(
            label: 'Autres symptômes (séparés par des virgules)',
            controller: other,
            hint: 'ex : mal de dos'),
        _title('Depuis combien de temps ?'),
        Row(children: [
          SizedBox(
            width: 90,
            child: TextField(
              controller: number,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  hintText: '3',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                for (final u in ManualEntry.units)
                  ButtonSegment(value: u, label: Text(u))
              ],
              selected: {unit},
              onSelectionChanged: (s) => setState(() => unit = s.first),
            ),
          ),
        ]),
        _title('Température'),
        TextField(
          controller: temp,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'ex : 38,5',
            suffixText: '°C',
            errorText: e.temperatureInvalid
                ? '⚠ Température invalide (30 à 45 °C).'
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        _title('Allergies connues'),
        _choices(aMode, (m) => aMode = m, 'Aucune connue', aText,
            'ex : pénicilline'),
        _title('Traitement en cours'),
        _choices(tMode, (m) => tMode = m, 'Aucun', tText, 'ex : paracétamol'),
        _title('Motif (facultatif)'),
        LabeledField(
            label: 'Si vide, le motif est déduit des symptômes et de la durée.',
            controller: motif,
            hint: 'ex : fièvre depuis 3 jours'),
      ]),
      bottom: [
        PrimaryButton('Vérifier les informations manquantes', onPressed: _next)
      ],
    );
  }
}

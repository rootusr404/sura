import 'models.dart';
import 'rules.dart';

/// Saisie manuelle structuree (Dart pur). Les choix de l'agent deviennent directement des libelles
/// canoniques : ils sont donc pris en compte par le moteur d'urgence, sans interpretation de texte.
class ManualEntry {
  const ManualEntry({
    this.motif = '',
    this.symptoms = const {},
    this.other = '',
    this.durationNumber = '',
    this.durationUnit = 'jours',
    this.temperature = '',
    this.allergyMode = 0,
    this.allergyText = '',
    this.treatmentMode = 0,
    this.treatmentText = '',
  });

  final String motif;
  final Set<String> symptoms;
  final String other;
  final String durationNumber;
  final String durationUnit; // jours | semaines | mois
  final String temperature;
  final int allergyMode; // 0 non renseigne, 1 aucune, 2 a preciser
  final String allergyText;
  final int treatmentMode; // 0 non renseigne, 1 aucun, 2 a preciser
  final String treatmentText;

  static const knownSymptoms = <String>[
    'Fièvre',
    'Toux',
    'Maux de tête',
    'Diarrhée',
    'Vomissements',
    'Nausées',
    'Douleur abdominale',
    'Fatigue',
    'Frissons',
    'Mal de gorge',
    'Éruption cutanée',
    'Convulsion',
    'Difficulté respiratoire',
  ];
  static const dangerSymptoms = <String>{
    'Convulsion',
    'Difficulté respiratoire'
  };
  static const units = <String>['jours', 'semaines', 'mois'];

  int? get durationCount {
    final n = int.tryParse(durationNumber.trim());
    return (n == null || n <= 0) ? null : n;
  }

  String? get duration {
    final n = durationCount;
    if (n == null) return null;
    final u = n == 1
        ? (durationUnit == 'jours'
            ? 'jour'
            : (durationUnit == 'semaines' ? 'semaine' : 'mois'))
        : durationUnit;
    return '$n $u';
  }

  int? get durationDays {
    final n = durationCount;
    if (n == null) return null;
    return durationUnit == 'semaines'
        ? n * 7
        : (durationUnit == 'mois' ? n * 30 : n);
  }

  double? get temp => temperature.trim().isEmpty
      ? null
      : Extractor.parseTemperature(temperature);
  bool get temperatureInvalid => temperature.trim().isNotEmpty && temp == null;

  String? get allergies => allergyMode == 1
      ? 'Aucune'
      : (allergyMode == 2 && allergyText.trim().isNotEmpty
          ? allergyText.trim()
          : null);
  String? get treatment => treatmentMode == 1
      ? 'Aucun'
      : (treatmentMode == 2 && treatmentText.trim().isNotEmpty
          ? treatmentText.trim()
          : null);

  Structured toStructured() {
    final list = <String>[];
    for (final s in knownSymptoms) {
      if (symptoms.contains(s)) list.add(s);
    }
    for (final y in Extractor.symptomsFromFields(other, '')) {
      if (!list.contains(y)) list.add(y);
    }
    final m = motif.trim();
    final d = duration;
    final motifFinal = m.isNotEmpty
        ? m
        : (list.isEmpty
            ? null
            : (d == null ? list.first : '${list.first} depuis $d'));
    return Structured(
      motif: motifFinal,
      symptoms: list,
      duration: d,
      durationDays: durationDays,
      temperature: temp,
      allergies: allergies,
      treatment: treatment,
    );
  }

  ManualEntry withMotif(String m) => ManualEntry(
        motif: m,
        symptoms: symptoms,
        other: other,
        durationNumber: durationNumber,
        durationUnit: durationUnit,
        temperature: temperature,
        allergyMode: allergyMode,
        allergyText: allergyText,
        treatmentMode: treatmentMode,
        treatmentText: treatmentText,
      );

  /// Reprise d'une saisie deja enregistree (retour en arriere dans le parcours).
  static ManualEntry fromStructured(Structured s) {
    final known = <String>{};
    final others = <String>[];
    for (final x in s.symptoms) {
      final match =
          Extractor.canonicalSymptoms(x).where(knownSymptoms.contains).toList();
      if (match.isEmpty) {
        others.add(x);
      } else {
        known.addAll(match);
      }
    }
    var number = '';
    var unit = 'jours';
    final m =
        RegExp(r'(\d+)\s*(jour|semaine|mois)').firstMatch(s.duration ?? '');
    if (m != null) {
      number = m.group(1)!;
      unit = m.group(2) == 'semaine'
          ? 'semaines'
          : (m.group(2) == 'mois' ? 'mois' : 'jours');
    }
    final a = s.allergies ?? '';
    final t = s.treatment ?? '';
    final base = ManualEntry(
      symptoms: known,
      other: others.join(', '),
      durationNumber: number,
      durationUnit: unit,
      temperature: s.temperature?.toString().replaceAll('.', ',') ?? '',
      allergyMode: a.isEmpty ? 0 : (a == 'Aucune' ? 1 : 2),
      allergyText: (a.isEmpty || a == 'Aucune') ? '' : a,
      treatmentMode: t.isEmpty ? 0 : (t == 'Aucun' ? 1 : 2),
      treatmentText: (t.isEmpty || t == 'Aucun') ? '' : t,
    );
    // Un motif genere automatiquement n'est pas restaure comme s'il avait ete tape.
    return s.motif == base.toStructured().motif
        ? base
        : base.withMotif(s.motif ?? '');
  }
}

import 'dart:convert';

/// Contrat de données partagé de la consultation (Section 6 du plan SŪRA)
/// Sortie de la transcription/structuration (Membre 2) -> Entrée du Triage & Checklist (Membre 3)
class ConsultationData {
  /// Motif principal : 'fever' | 'cough' | 'diarrhea' | 'pregnancy' | 'trauma' | 'other'
  final String chiefComplaint;

  /// Liste des symptômes observés ou déclarés
  final List<String> symptoms;

  /// Âge du patient en mois (utile pour pédiatrie PCIME)
  final int? ageMonths;

  /// Durée de la maladie en jours
  final int? durationDays;

  /// Température mesurée en degrés Celsius
  final double? temperatureC;

  /// Poids du patient en kilogrammes
  final double? weightKg;

  /// Fréquence respiratoire par minute
  final int? respiratoryRate;

  /// Pouls / Fréquence cardiaque en battements par minute
  final int? pulse;

  /// Statut de grossesse (femme enceinte)
  final bool? pregnant;

  /// Liste des allergies déclarées
  final List<String> allergies;

  /// Liste des médicaments pris actuellement
  final List<String> medications;

  /// Liste des antécédents médicaux pertinents
  final List<String> antecedents;

  /// Transcription brute ou texte saisi par l'agent
  final String rawTranscript;

  const ConsultationData({
    this.chiefComplaint = 'other',
    this.symptoms = const [],
    this.ageMonths,
    this.durationDays,
    this.temperatureC,
    this.weightKg,
    this.respiratoryRate,
    this.pulse,
    this.pregnant,
    this.allergies = const [],
    this.medications = const [],
    this.antecedents = const [],
    this.rawTranscript = '',
  });

  ConsultationData copyWith({
    String? chiefComplaint,
    List<String>? symptoms,
    int? ageMonths,
    int? durationDays,
    double? temperatureC,
    double? weightKg,
    int? respiratoryRate,
    int? pulse,
    bool? pregnant,
    List<String>? allergies,
    List<String>? medications,
    List<String>? antecedents,
    String? rawTranscript,
  }) {
    return ConsultationData(
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      symptoms: symptoms ?? List.unmodifiable(this.symptoms),
      ageMonths: ageMonths ?? this.ageMonths,
      durationDays: durationDays ?? this.durationDays,
      temperatureC: temperatureC ?? this.temperatureC,
      weightKg: weightKg ?? this.weightKg,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      pulse: pulse ?? this.pulse,
      pregnant: pregnant ?? this.pregnant,
      allergies: allergies ?? List.unmodifiable(this.allergies),
      medications: medications ?? List.unmodifiable(this.medications),
      antecedents: antecedents ?? List.unmodifiable(this.antecedents),
      rawTranscript: rawTranscript ?? this.rawTranscript,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chiefComplaint': chiefComplaint,
      'symptoms': symptoms,
      'ageMonths': ageMonths,
      'durationDays': durationDays,
      'temperatureC': temperatureC,
      'weightKg': weightKg,
      'respiratoryRate': respiratoryRate,
      'pulse': pulse,
      'pregnant': pregnant,
      'allergies': allergies,
      'medications': medications,
      'antecedents': antecedents,
      'rawTranscript': rawTranscript,
    };
  }

  factory ConsultationData.fromMap(Map<String, dynamic> map) {
    return ConsultationData(
      chiefComplaint: (map['chiefComplaint'] as String?) ?? 'other',
      symptoms: (map['symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      ageMonths: (map['ageMonths'] as num?)?.toInt(),
      durationDays: (map['durationDays'] as num?)?.toInt(),
      temperatureC: (map['temperatureC'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      respiratoryRate: (map['respiratoryRate'] as num?)?.toInt(),
      pulse: (map['pulse'] as num?)?.toInt(),
      pregnant: map['pregnant'] as bool?,
      allergies: (map['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      medications: (map['medications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      antecedents: (map['antecedents'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      rawTranscript: (map['rawTranscript'] as String?) ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ConsultationData.fromJson(String source) =>
      ConsultationData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ConsultationData(chiefComplaint: $chiefComplaint, symptoms: $symptoms, temp: $temperatureC, pulse: $pulse, durationDays: $durationDays, pregnant: $pregnant, allergies: $allergies, meds: $medications, antecedents: $antecedents)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConsultationData &&
        other.chiefComplaint == chiefComplaint &&
        _listEquals(other.symptoms, symptoms) &&
        other.ageMonths == ageMonths &&
        other.durationDays == durationDays &&
        other.temperatureC == temperatureC &&
        other.weightKg == weightKg &&
        other.respiratoryRate == respiratoryRate &&
        other.pulse == pulse &&
        other.pregnant == pregnant &&
        _listEquals(other.allergies, allergies) &&
        _listEquals(other.medications, medications) &&
        _listEquals(other.antecedents, antecedents) &&
        other.rawTranscript == rawTranscript;
  }

  @override
  int get hashCode {
    return Object.hash(
      chiefComplaint,
      Object.hashAll(symptoms),
      ageMonths,
      durationDays,
      temperatureC,
      weightKg,
      respiratoryRate,
      pulse,
      pregnant,
      Object.hashAll(allergies),
      Object.hashAll(medications),
      Object.hashAll(antecedents),
      rawTranscript,
    );
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

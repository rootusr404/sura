import 'dart:convert';

enum Urgency { faible, modere, eleve }

extension UrgencyX on Urgency {
  String get label => switch (this) {
        Urgency.faible => 'FAIBLE',
        Urgency.modere => 'MODÉRÉ',
        Urgency.eleve => 'ÉLEVÉ',
      };
  String get symbol => switch (this) {
        Urgency.faible => '■',
        Urgency.modere => '◆',
        Urgency.eleve => '▲',
      };
}

class UrgencyResult {
  const UrgencyResult(this.level, this.reasons);
  final Urgency level;
  final List<String> reasons;
}

/// Informations structurees d'une consultation (ecran 23 / saisie manuelle).
class Structured {
  const Structured({
    this.motif,
    this.symptoms = const [],
    this.duration,
    this.durationDays,
    this.temperature,
    this.allergies,
    this.treatment,
  });

  final String? motif;
  final List<String> symptoms;
  final String? duration;
  final int? durationDays;
  final double? temperature;
  final String? allergies;
  final String? treatment;

  Map<String, dynamic> toMap() => {
        'motif': motif,
        'symptoms': symptoms,
        'duration': duration,
        'durationDays': durationDays,
        'temperature': temperature,
        'allergies': allergies,
        'treatment': treatment,
      };

  String encode() => jsonEncode(toMap());

  static Structured fromMap(Map<String, dynamic> m) => Structured(
        motif: m['motif'] as String?,
        symptoms:
            ((m['symptoms'] as List?) ?? const []).map((e) => '$e').toList(),
        duration: m['duration'] as String?,
        durationDays: (m['durationDays'] as num?)?.toInt(),
        temperature: (m['temperature'] as num?)?.toDouble(),
        allergies: m['allergies'] as String?,
        treatment: m['treatment'] as String?,
      );

  static Structured decode(String? json) {
    if (json == null || json.isEmpty) return const Structured();
    return fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  bool get isEmpty =>
      motif == null &&
      symptoms.isEmpty &&
      duration == null &&
      temperature == null &&
      allergies == null &&
      treatment == null;
}

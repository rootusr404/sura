/// Informations extraites de la transcription (toutes modifiables par l'agent, R5).
/// Limite connue : copyWith ne permet pas de remettre un champ à null.
class StructuredInfo {
  const StructuredInfo({
    this.chiefComplaint,
    this.symptoms = const [],
    this.duration,
    this.temperatureC,
    this.pulse,
    this.allergies,
    this.medications,
    this.history,
    this.notes,
  });

  final String? chiefComplaint;
  final List<String> symptoms;
  final String? duration;
  final double? temperatureC;
  final int? pulse;
  final String? allergies;
  final String? medications;
  final String? history;
  final String? notes;

  StructuredInfo copyWith({
    String? chiefComplaint,
    List<String>? symptoms,
    String? duration,
    double? temperatureC,
    int? pulse,
    String? allergies,
    String? medications,
    String? history,
    String? notes,
  }) => StructuredInfo(
    chiefComplaint: chiefComplaint ?? this.chiefComplaint,
    symptoms: symptoms ?? this.symptoms,
    duration: duration ?? this.duration,
    temperatureC: temperatureC ?? this.temperatureC,
    pulse: pulse ?? this.pulse,
    allergies: allergies ?? this.allergies,
    medications: medications ?? this.medications,
    history: history ?? this.history,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'chiefComplaint': chiefComplaint,
    'symptoms': symptoms,
    'duration': duration,
    'temperatureC': temperatureC,
    'pulse': pulse,
    'allergies': allergies,
    'medications': medications,
    'history': history,
    'notes': notes,
  };

  factory StructuredInfo.fromJson(Map<String, dynamic> j) => StructuredInfo(
    chiefComplaint: j['chiefComplaint'] as String?,
    symptoms: (j['symptoms'] as List?)?.cast<String>() ?? const [],
    duration: j['duration'] as String?,
    temperatureC: (j['temperatureC'] as num?)?.toDouble(),
    pulse: (j['pulse'] as num?)?.toInt(),
    allergies: j['allergies'] as String?,
    medications: j['medications'] as String?,
    history: j['history'] as String?,
    notes: j['notes'] as String?,
  );
}

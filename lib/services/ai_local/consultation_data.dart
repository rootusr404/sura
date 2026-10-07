/// Résultat riche du moteur local d'extraction avant projection vers le modèle
/// partagé de l'application.
class ConsultationData {
  const ConsultationData({
    this.chiefComplaint = 'Autre',
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

  final String chiefComplaint;
  final List<String> symptoms;
  final int? ageMonths;
  final int? durationDays;
  final double? temperatureC;
  final double? weightKg;
  final int? respiratoryRate;
  final int? pulse;
  final bool? pregnant;
  final List<String> allergies;
  final List<String> medications;
  final List<String> antecedents;
  final String rawTranscript;
}

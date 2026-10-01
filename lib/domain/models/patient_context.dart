/// Contexte patient transmis aux règles (checklist, urgence).
class PatientContext {
  const PatientContext({required this.ageYears, required this.sex});
  final int ageYears;

  /// 'F' | 'M'
  final String sex;
}

import 'dart:convert';

/// Lecture tolerante des documents Firestore (Dart pur, testable). Un document incomplet est ignore (null).
DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
int? _int(dynamic v) => v is num ? v.toInt() : null;
String _str(dynamic v, [String d = '']) => v == null ? d : '$v';
String _json(dynamic v, String d) {
  if (v is String && v.isNotEmpty) return v;
  if (v is Map || v is List) return jsonEncode(v);
  return d;
}

class RestoredPatient {
  RestoredPatient({
    required this.id,
    required this.familyName,
    required this.firstName,
    required this.ageYears,
    required this.ageRecordedAt,
    required this.sex,
    required this.village,
    required this.createdBy,
    required this.createdAt,
  });
  final String id, familyName, firstName, sex, village, createdBy;
  final int ageYears;
  final DateTime ageRecordedAt, createdAt;

  static RestoredPatient? fromMap(Map<String, dynamic> m) {
    final id = _str(m['id']).trim();
    if (id.isEmpty) return null;
    final created = _date(m['createdAt']) ?? DateTime.now();
    return RestoredPatient(
      id: id,
      familyName: _str(m['familyName']),
      firstName: _str(m['firstName']),
      ageYears: _int(m['ageYears']) ?? 0,
      ageRecordedAt: _date(m['ageRecordedAt']) ?? created,
      sex: _str(m['sex'], 'O'),
      village: _str(m['village']),
      createdBy: _str(m['createdBy']),
      createdAt: created,
    );
  }
}

class RestoredConsultation {
  RestoredConsultation({
    required this.id,
    required this.patientId,
    required this.agentId,
    required this.mode,
    required this.consent,
    required this.consentAt,
    required this.transcript,
    required this.structuredJson,
    required this.urgencyProposed,
    required this.urgencyFinal,
    required this.reasonsJson,
    required this.validatedAt,
    required this.createdAt,
  });
  final String id, patientId, agentId, mode, structuredJson, reasonsJson;
  final String? consent, transcript;
  final DateTime? consentAt, validatedAt;
  final int? urgencyProposed, urgencyFinal;
  final DateTime createdAt;

  static RestoredConsultation? fromMap(Map<String, dynamic> m) {
    final id = _str(m['id']).trim();
    final patientId = _str(m['patientId']).trim();
    if (id.isEmpty || patientId.isEmpty) return null;
    final t = m['transcript'];
    return RestoredConsultation(
      id: id,
      patientId: patientId,
      agentId: _str(m['agentId']),
      mode: _str(m['mode'], 'voice'),
      consent: m['consent'] is String ? m['consent'] as String : null,
      consentAt: _date(m['consentAt']),
      transcript: t is String ? t : null,
      structuredJson: _json(m['structured'], '{}'),
      urgencyProposed: _int(m['urgencyProposed']),
      urgencyFinal: _int(m['urgencyFinal']),
      reasonsJson: _json(m['reasons'], '[]'),
      validatedAt: _date(m['validatedAt']),
      createdAt: _date(m['createdAt']) ?? DateTime.now(),
    );
  }
}

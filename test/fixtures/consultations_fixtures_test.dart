import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/models/patient_context.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/features/consultation/review/rule_missing_info_checker.dart';
import 'package:sura/features/consultation/review/rule_urgency_scorer.dart';

/// Vérifie les données de démonstration (D-03) contre les règles réelles :
/// si une règle change, ces scénarios le signalent.
void main() {
  final scenarios =
      (jsonDecode(File('test/fixtures/consultations.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>();

  StructuredInfo infoOf(Map<String, dynamic> e) => StructuredInfo(
    chiefComplaint: e['chiefComplaint'] as String?,
    symptoms: (e['symptoms'] as List).cast<String>(),
    duration: e['duration'] as String?,
    temperatureC: (e['temperatureC'] as num?)?.toDouble(),
    pulse: (e['pulse'] as num?)?.toInt(),
    allergies: e['allergies'] as String?,
    medications: e['medications'] as String?,
    history: e['history'] as String?,
  );

  PatientContext patientOf(Map<String, dynamic> p) =>
      PatientContext(ageYears: p['ageYears'] as int, sex: p['sex'] as String);

  test('3 scénarios aux identifiants uniques', () {
    expect(scenarios, hasLength(3));
    final ids = scenarios.map((s) => s['id']).toSet();
    expect(ids, hasLength(3));
  });

  test('un scénario par niveau d\'urgence', () {
    final levels = scenarios.map((s) => s['expected']['urgency']).toSet();
    expect(levels, {'low', 'moderate', 'high'});
  });

  for (final s in scenarios) {
    final id = s['id'] as String;
    final expected = s['expected'] as Map<String, dynamic>;
    final transcript = s['transcript'] as String;
    final patient = s['patient'] as Map<String, dynamic>;

    group(id, () {
      test('texte dicté de 8 à 12 phrases', () {
        final sentences = transcript
            .split(RegExp(r'[.!?]'))
            .where((p) => p.trim().isNotEmpty)
            .length;
        expect(sentences, inInclusiveRange(8, 12));
      });

      test('patient fictif sans donnée de contact', () {
        expect(patient['fictional'], isTrue);
        expect(patient.containsKey('phone'), isFalse);
      });

      test('la durée attendue apparaît dans le texte', () {
        final d = expected['durationContains'] as String;
        expect(transcript, contains(d));
      });

      test('informations manquantes attendues (U-01)', () {
        final codes = RuleMissingInfoChecker()
            .check(infoOf(expected), patientOf(patient))
            .map((m) => m.code)
            .toSet();
        expect(
          codes,
          (expected['missingCodes'] as List).cast<String>().toSet(),
        );
      });

      test('urgence attendue avec ses raisons (U-02)', () {
        final result = RuleUrgencyScorer().score(
          infoOf(expected),
          transcript,
          patientOf(patient),
        );
        expect(result.level.name, expected['urgency']);
        expect(
          result.reasons.any(
            (r) => r.contains(expected['urgencyReasonContains'] as String),
          ),
          isTrue,
          reason: 'raisons obtenues : ${result.reasons}',
        );
      });
    });
  }
}

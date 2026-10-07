import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/models/patient_context.dart';
import 'package:sura/features/consultation/review/rule_missing_info_checker.dart';
import 'package:sura/services/ai_local/information_extractor_adapter.dart';

void main() {
  final scenarios =
      (jsonDecode(File('test/fixtures/consultations.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>();
  const extractor = RuleBasedInformationExtractor();

  for (final scenario in scenarios) {
    final expected = scenario['expected'] as Map<String, dynamic>;
    final patient = scenario['patient'] as Map<String, dynamic>;
    test('${scenario['id']} : extraction C-04 conforme au scénario', () {
      final actual = extractor.extract(scenario['transcript'] as String);

      expect(actual.chiefComplaint, expected['chiefComplaint']);
      expect(actual.symptoms, expected['symptoms']);
      expect(actual.duration, expected['duration']);
      expect(actual.temperatureC, expected['temperatureC']);
      expect(actual.pulse, expected['pulse']);
      expect(actual.allergies, expected['allergies']);
      expect(actual.medications, expected['medications']);
      expect(actual.history, expected['history']);

      final missing = RuleMissingInfoChecker()
          .check(
            actual,
            PatientContext(
              ageYears: patient['ageYears'] as int,
              sex: patient['sex'] as String,
            ),
          )
          .map((item) => item.code)
          .toSet();
      expect(missing, (expected['missingCodes'] as List).toSet());
    });
  }

  test('texte vide ou incohérent ne fait jamais échouer l’adaptateur', () {
    expect(() => extractor.extract(''), returnsNormally);
    expect(() => extractor.extract('??? … 123'), returnsNormally);
  });
}

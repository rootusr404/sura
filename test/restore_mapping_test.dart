import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sura_app/features/sync/restore_mapping.dart';

void main() {
  test('patient : lecture complete', () {
    final p = RestoredPatient.fromMap({
      'id': 'SUR-2026-AB12CD34',
      'familyName': 'Traoré',
      'firstName': 'Adama',
      'ageYears': 34,
      'ageRecordedAt': '2026-10-01T10:00:00.000',
      'sex': 'F',
      'village': 'Quartier Nord',
      'createdBy': 'uid1',
      'createdAt': '2026-10-01T10:00:00.000',
    })!;
    expect(p.id, 'SUR-2026-AB12CD34');
    expect(p.ageYears, 34);
    expect(p.createdAt.year, 2026);
    expect(p.sex, 'F');
  });

  test('patient sans identifiant : ignore', () {
    expect(RestoredPatient.fromMap({'familyName': 'X'}), isNull);
    expect(RestoredPatient.fromMap({'id': '  '}), isNull);
  });

  test('patient : age decimal et valeurs manquantes tolerees', () {
    final p = RestoredPatient.fromMap({'id': 'A', 'ageYears': 34.0})!;
    expect(p.ageYears, 34);
    expect(p.sex, 'O');
    expect(p.village, '');
  });

  test('consultation : lecture complete', () {
    final c = RestoredConsultation.fromMap({
      'id': 'C1',
      'patientId': 'P1',
      'agentId': 'uid1',
      'mode': 'manual',
      'consent': 'refused',
      'consentAt': '2026-10-02T08:00:00.000',
      'structured': '{"motif":"Fièvre"}',
      'urgencyProposed': 1,
      'urgencyFinal': 2.0,
      'reasons': '["Fièvre à 39,4 °C"]',
      'validatedAt': '2026-10-02T08:30:00.000',
      'createdAt': '2026-10-02T08:00:00.000',
    })!;
    expect(c.mode, 'manual');
    expect(c.consent, 'refused');
    expect(c.urgencyFinal, 2);
    expect(c.structuredJson, contains('Fièvre'));
    expect(c.validatedAt!.minute, 30);
  });

  test('consultation sans patient ou sans id : ignoree', () {
    expect(RestoredConsultation.fromMap({'id': 'C1'}), isNull);
    expect(RestoredConsultation.fromMap({'patientId': 'P1'}), isNull);
  });

  test('consultation : valeurs par defaut', () {
    final c = RestoredConsultation.fromMap({'id': 'C1', 'patientId': 'P1'})!;
    expect(c.mode, 'voice');
    expect(c.structuredJson, '{}');
    expect(c.reasonsJson, '[]');
    expect(c.consent, isNull);
    expect(c.transcript, isNull);
  });

  test('consultation : structure donne sous forme de map', () {
    final c = RestoredConsultation.fromMap({
      'id': 'C1',
      'patientId': 'P1',
      'structured': {'motif': 'Toux'}
    })!;
    expect(jsonDecode(c.structuredJson)['motif'], 'Toux');
  });
}

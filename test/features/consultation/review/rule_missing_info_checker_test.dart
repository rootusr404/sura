import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/models/patient_context.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/features/consultation/review/rule_missing_info_checker.dart';

const _adult = PatientContext(ageYears: 30, sex: 'F');
const _child = PatientContext(ageYears: 3, sex: 'M');

const _complete = StructuredInfo(
  chiefComplaint: 'Fièvre',
  symptoms: ['fièvre', 'toux'],
  duration: '3 jours',
  temperatureC: 39,
  allergies: 'aucune',
  medications: 'paracétamol',
  history: 'aucun',
);

List<String> _codes(StructuredInfo info, [PatientContext p = _adult]) =>
    RuleMissingInfoChecker().check(info, p).map((e) => e.code).toList();

void main() {
  test('une fiche complète ne signale rien', () {
    expect(_codes(_complete), isEmpty);
  });

  test('une fiche vide signale motif, symptômes, durée, allergies, '
      'médicaments et antécédents', () {
    expect(
      _codes(const StructuredInfo()),
      containsAll([
        'chiefComplaint',
        'symptoms',
        'duration',
        'allergies',
        'medications',
        'history',
      ]),
    );
  });

  test('les champs blancs comptent comme manquants', () {
    final codes = _codes(_complete.copyWith(allergies: '   '));
    expect(codes, ['allergies']);
  });

  test('« aucune » est une réponse : les allergies ne sont pas manquantes', () {
    expect(_codes(_complete.copyWith(allergies: 'aucune')), isEmpty);
  });

  test('température et pouls restent facultatifs sans fièvre évoquée', () {
    const info = StructuredInfo(
      chiefComplaint: 'Toux',
      symptoms: ['toux'],
      duration: '3 jours',
      allergies: 'aucune',
      medications: 'aucun',
      history: 'aucun',
    );
    expect(_codes(info), isEmpty);
  });

  test('la température semble manquer quand une fièvre est évoquée', () {
    const info = StructuredInfo(
      chiefComplaint: 'Fièvre',
      symptoms: ['fièvre'],
      duration: '3 jours',
      allergies: 'aucune',
      medications: 'aucun',
      history: 'aucun',
    );
    expect(_codes(info), ['temperature']);
  });

  test('chez le jeune enfant, la température est toujours attendue, '
      'même sans fièvre évoquée', () {
    const info = StructuredInfo(
      chiefComplaint: 'Enfant abattu',
      symptoms: ['abattement'],
      duration: '1 jour',
      allergies: 'aucune',
      medications: 'aucun',
      history: 'aucun',
    );
    expect(_codes(info, _child), ['temperature']);
  });

  test('les libellés sont des constats, jamais des ordres (R6)', () {
    final items = RuleMissingInfoChecker().check(
      const StructuredInfo(),
      _adult,
    );
    expect(items, isNotEmpty);
    for (final item in items) {
      expect(item.label, startsWith('Cette information semble manquer'));
      expect(item.label.toLowerCase(), isNot(contains('vous devez')));
    }
  });

  test('les codes sont uniques et stables', () {
    final codes = _codes(const StructuredInfo());
    expect(codes.toSet().length, codes.length);
  });
}

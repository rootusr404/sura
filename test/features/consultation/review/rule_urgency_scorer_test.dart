import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/patient_context.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/domain/models/urgency_proposal.dart';
import 'package:sura/features/consultation/review/rule_urgency_scorer.dart';

const _adult = PatientContext(ageYears: 30, sex: 'F');
const _child = PatientContext(ageYears: 3, sex: 'M');

UrgencyProposal _score(
  String transcript, {
  StructuredInfo info = const StructuredInfo(),
  PatientContext patient = _adult,
}) => RuleUrgencyScorer().score(info, transcript, patient);

void main() {
  group('tableau de cas', () {
    final cases =
        <(String, String, StructuredInfo, PatientContext, UrgencyLevel)>[
          (
            'convulsions',
            'Mon fils a fait des convulsions ce matin.',
            const StructuredInfo(),
            _child,
            UrgencyLevel.high,
          ),
          (
            'difficulté respiratoire',
            'Elle a du mal à respirer depuis hier soir.',
            const StructuredInfo(),
            _adult,
            UrgencyLevel.high,
          ),
          (
            'perte de connaissance',
            'Il est tombé et a perdu connaissance quelques minutes.',
            const StructuredInfo(),
            _adult,
            UrgencyLevel.high,
          ),
          (
            'fièvre très élevée mesurée',
            'Il est brûlant.',
            const StructuredInfo(temperatureC: 40.5),
            _adult,
            UrgencyLevel.high,
          ),
          (
            'fièvre prolongée chez l\'enfant',
            'Il a de la fièvre depuis plusieurs jours.',
            const StructuredInfo(symptoms: ['fièvre'], duration: '4 jours'),
            _child,
            UrgencyLevel.high,
          ),
          (
            'fièvre prolongée chez l\'adulte',
            'Fièvre et courbatures.',
            const StructuredInfo(symptoms: ['fièvre'], duration: '4 jours'),
            _adult,
            UrgencyLevel.moderate,
          ),
          (
            'fièvre modérée récente',
            'Elle a de la fièvre depuis hier.',
            const StructuredInfo(
              symptoms: ['fièvre'],
              duration: '1 jour',
              temperatureC: 38.8,
            ),
            _adult,
            UrgencyLevel.moderate,
          ),
          (
            'rhume bénin',
            'Un petit rhume avec le nez qui coule.',
            const StructuredInfo(symptoms: ['rhume'], duration: '2 jours'),
            _adult,
            UrgencyLevel.low,
          ),
        ];

    for (final (name, text, info, patient, expected) in cases) {
      test(name, () {
        final result = _score(text, info: info, patient: patient);
        expect(result.level, expected);
        expect(result.reasons, isNotEmpty, reason: 'raisons affichées (R7)');
      });
    }
  });

  test('une négation n\'active pas le signe de gravité', () {
    final result = _score('Pas de convulsions, juste un peu de toux.');
    expect(result.level, UrgencyLevel.low);
  });

  test('un texte vide ne plante pas et reste faible avec une raison', () {
    final result = _score('');
    expect(result.level, UrgencyLevel.low);
    expect(result.reasons, isNotEmpty);
  });

  test('les accents et la casse ne changent pas le résultat', () {
    expect(_score('CONVULSIONS').level, UrgencyLevel.high);
    expect(_score('Difficulte respiratoire').level, UrgencyLevel.high);
  });

  test(
    'le niveau le plus grave l\'emporte et toutes les raisons sont listées',
    () {
      final result = _score(
        'Convulsions et fièvre depuis 4 jours.',
        info: const StructuredInfo(symptoms: ['fièvre'], duration: '4 jours'),
      );
      expect(result.level, UrgencyLevel.high);
      expect(result.reasons.length, greaterThanOrEqualTo(2));
    },
  );
}

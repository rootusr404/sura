import 'package:flutter_test/flutter_test.dart';
import 'package:sura_app/domain/models.dart';
import 'package:sura_app/domain/rules.dart';

void main() {
  group('Saisie manuelle : les symptomes tapes comptent', () {
    test('fievre tapee en minuscules + duree 3 jours => modere', () {
      final s = Structured(
          symptoms: Extractor.symptomsFromFields('fièvre, toux', ''),
          duration: '3 jours');
      final r = UrgencyEngine.evaluate(s);
      expect(r.level, Urgency.modere);
    });
    test('symptomes non canoniques bruts (ancien format) toujours compris', () {
      final r = UrgencyEngine.evaluate(
          const Structured(symptoms: ['fièvre'], duration: 'trois jours'));
      expect(r.level, Urgency.modere);
    });
    test('motif seul : fievre depuis 3 jours => modere', () {
      final r = UrgencyEngine.evaluate(
          const Structured(motif: 'fièvre depuis 3 jours'));
      expect(r.level, Urgency.modere);
    });
    test('convulsions tapees => eleve', () {
      expect(
          UrgencyEngine.evaluate(const Structured(symptoms: ['convulsions']))
              .level,
          Urgency.eleve);
    });
    test('difficulte a respirer tapee => eleve', () {
      expect(
          UrgencyEngine.evaluate(
              const Structured(symptoms: ['difficulté à respirer'])).level,
          Urgency.eleve);
    });
    test('toux seule => faible mais le symptome est mentionne', () {
      final r = UrgencyEngine.evaluate(const Structured(symptoms: ['toux']));
      expect(r.level, Urgency.faible);
      expect(r.reasons.any((x) => x.contains('Toux')), isTrue);
    });
    test('fievre 39,4 tapee a la main => modere avec raison', () {
      final r = UrgencyEngine.evaluate(Structured(
          symptoms: const ['Fièvre'],
          temperature: Extractor.parseTemperature('39,4 °C')));
      expect(r.level, Urgency.modere);
      expect(r.reasons.any((x) => x.contains('39,4')), isTrue);
    });
  });

  group('Normalisation et synonymes', () {
    test('normalizeText', () {
      expect(normalizeText('Fièvre À L’Hôpital'), 'fievre a l hopital');
    });
    test('elle tousse => Toux', () {
      expect(Extractor.canonicalSymptoms('elle tousse beaucoup'),
          contains('Toux'));
    });
    test('mal au ventre => Douleur abdominale', () {
      expect(Extractor.canonicalSymptoms('il a mal au ventre'),
          contains('Douleur abdominale'));
    });
    test('mal a la tete => Maux de tete', () {
      expect(Extractor.canonicalSymptoms("elle a mal à la tête"),
          contains('Maux de tête'));
    });
    test('il vomit => Vomissements', () {
      expect(Extractor.canonicalSymptoms('il vomit depuis ce matin'),
          contains('Vomissements'));
    });
    test('symptomsFromFields garde les symptomes inconnus', () {
      expect(Extractor.symptomsFromFields('fievre, mal de dos', ''),
          ['Fièvre', 'Mal de dos']);
    });
  });

  group('Durees et temperatures', () {
    test('durees en lettres', () {
      expect(Extractor.daysFromText('trois jours'), 3);
      expect(Extractor.daysFromText('une semaine'), 7);
      expect(Extractor.daysFromText('depuis hier'), 1);
      expect(Extractor.daysFromText('aucun jour'), isNull);
    });
    test('parseTemperature chiffres', () {
      expect(Extractor.parseTemperature('38,5 °C'), 38.5);
      expect(Extractor.parseTemperature('38.5'), 38.5);
      expect(Extractor.parseTemperature('12'), isNull);
      expect(Extractor.parseTemperature('50'), isNull);
    });
    test('parseTemperature lettres', () {
      expect(Extractor.parseTemperature('trente-huit et demi degrés'),
          closeTo(38.5, 0.01));
      expect(Extractor.parseTemperature('température trente neuf'),
          closeTo(39.0, 0.01));
    });
  });
}

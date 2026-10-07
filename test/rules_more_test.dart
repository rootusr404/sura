import 'package:flutter_test/flutter_test.dart';
import 'package:sura_app/domain/models.dart';
import 'package:sura_app/domain/rules.dart';

void main() {
  group('Extractor', () {
    test('duree en lettres : deux semaines = 14 jours', () {
      final s = Extractor.extract('Elle tousse depuis deux semaines.');
      expect(s.duration, '2 semaines');
      expect(s.durationDays, 14);
    });
    test('temperature hors plage ignoree', () {
      expect(Extractor.extract('Température 99 degrés').temperature, isNull);
    });
    test('respire mal => difficulte respiratoire', () {
      expect(Extractor.extract('Le bébé respire mal').symptoms,
          contains('Difficulté respiratoire'));
    });
    test('aucun traitement et pas d allergie', () {
      final s = Extractor.extract(
          "Pas d'allergie connue. Aucun traitement en cours.");
      expect(s.allergies, 'Aucune');
      expect(s.treatment, 'Aucun');
    });
    test('daysFromText', () {
      expect(Extractor.daysFromText('2 semaines'), 14);
      expect(Extractor.daysFromText('1 mois'), 30);
      expect(Extractor.daysFromText('5 jours'), 5);
      expect(Extractor.daysFromText(null), isNull);
      expect(Extractor.daysFromText('abc'), isNull);
    });
  });

  group('Structured', () {
    test('aller-retour JSON', () {
      const s = Structured(
          motif: 'Fièvre',
          symptoms: ['Fièvre', 'Toux'],
          temperature: 38.5,
          durationDays: 3);
      final r = Structured.decode(s.encode());
      expect(r.motif, 'Fièvre');
      expect(r.symptoms, ['Fièvre', 'Toux']);
      expect(r.temperature, 38.5);
      expect(r.durationDays, 3);
    });
    test('decode null ou vide', () {
      expect(Structured.decode(null).isEmpty, isTrue);
      expect(Structured.decode('').isEmpty, isTrue);
    });
  });

  group('MissingFinder', () {
    test('rien de manquant quand tout est renseigne', () {
      const s =
          Structured(temperature: 38, allergies: 'Aucune', treatment: 'Aucun');
      expect(MissingFinder.find(s), isEmpty);
    });
    test('tout manque sur un dossier vide', () {
      expect(MissingFinder.find(const Structured()),
          ['temperature', 'allergies', 'treatment']);
    });
  });

  group('UrgencyEngine (seuils de demonstration)', () {
    test('40,0 => eleve', () {
      expect(UrgencyEngine.evaluate(const Structured(temperature: 40)).level,
          Urgency.eleve);
    });
    test('38,5 => modere', () {
      expect(UrgencyEngine.evaluate(const Structured(temperature: 38.5)).level,
          Urgency.modere);
    });
    test('38,4 sans autre signe => faible', () {
      expect(UrgencyEngine.evaluate(const Structured(temperature: 38.4)).level,
          Urgency.faible);
    });
    test('enfant de 5 ans avec 39,5 => modere (pas eleve)', () {
      expect(
          UrgencyEngine.evaluate(const Structured(temperature: 39.5),
                  ageYears: 5)
              .level,
          Urgency.modere);
    });
    test('enfant de 4 ans avec 39 => eleve', () {
      expect(
          UrgencyEngine.evaluate(const Structured(temperature: 39), ageYears: 4)
              .level,
          Urgency.eleve);
    });
    test('difficulte respiratoire => eleve', () {
      expect(
          UrgencyEngine.evaluate(
              const Structured(symptoms: ['Difficulté respiratoire'])).level,
          Urgency.eleve);
    });
    test('fievre depuis 3 jours => modere avec raison', () {
      final r = UrgencyEngine.evaluate(const Structured(
          symptoms: ['Fièvre'], duration: '3 jours', durationDays: 3));
      expect(r.level, Urgency.modere);
      expect(r.reasons.any((x) => x.contains('depuis 3 jours')), isTrue);
    });
    test('le niveau le plus haut l emporte', () {
      final r = UrgencyEngine.evaluate(
          const Structured(temperature: 38.6, symptoms: ['Convulsion']));
      expect(r.level, Urgency.eleve);
    });
  });
}

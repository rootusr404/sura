import 'package:flutter_test/flutter_test.dart';
import 'package:sura_app/domain/models.dart';
import 'package:sura_app/domain/rules.dart';

void main() {
  const texte =
      'La patiente présente une fièvre persistante depuis trois jours, avec des maux de tête. '
      'Température 39,4 degrés.';

  test('extraction : symptomes, duree, temperature', () {
    final s = Extractor.extract(texte);
    expect(s.symptoms, containsAll(['Fièvre', 'Maux de tête']));
    expect(s.durationDays, 3);
    expect(s.temperature, 39.4);
    expect(s.motif, 'Fièvre depuis 3 jours');
  });

  test('extraction : texte vide ne plante pas', () {
    expect(Extractor.extract('').isEmpty, isTrue);
  });

  test('informations manquantes : alertes seulement', () {
    final m = MissingFinder.find(Extractor.extract(texte));
    expect(m, containsAll(['allergies', 'treatment']));
    expect(m.contains('temperature'), isFalse);
  });

  test('urgence moderee : fievre 39,4 et 3 jours', () {
    final r = UrgencyEngine.evaluate(Extractor.extract(texte), ageYears: 34);
    expect(r.level, Urgency.modere);
    expect(r.reasons, isNotEmpty);
  });

  test('urgence elevee : convulsion', () {
    final r =
        UrgencyEngine.evaluate(const Structured(symptoms: ['Convulsion']));
    expect(r.level, Urgency.eleve);
  });

  test('urgence elevee : enfant < 5 ans avec 39,5', () {
    final r = UrgencyEngine.evaluate(const Structured(temperature: 39.5),
        ageYears: 3);
    expect(r.level, Urgency.eleve);
  });

  test('urgence faible : aucun signe', () {
    final r = UrgencyEngine.evaluate(const Structured(symptoms: ['Fatigue']));
    expect(r.level, Urgency.faible);
  });
}

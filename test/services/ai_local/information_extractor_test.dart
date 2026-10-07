import 'package:flutter_test/flutter_test.dart';
import 'package:sura/core/models/consultation_data.dart';
import 'package:sura/services/ai_local/information_extractor.dart';

import '../../fixtures/clinical_transcripts.dart';

void main() {
  group('C-04 : InformationExtractor (Tests unitaires de structuration)', () {
    const extractor = InformationExtractor();

    test('1. Robustesse absolue : texte vide et espaces ne plantent jamais', () {
      final resEmpty = extractor.extract(ClinicalFixtures.emptyText);
      expect(resEmpty.chiefComplaint, equals('other'));
      expect(resEmpty.symptoms, isEmpty);
      expect(resEmpty.temperatureC, isNull);
      expect(resEmpty.durationDays, isNull);
      expect(resEmpty.rawTranscript, isEmpty);

      final resSpaces = extractor.extract(ClinicalFixtures.whitespaceOnly);
      expect(resSpaces.chiefComplaint, equals('other'));
      expect(resSpaces.symptoms, isEmpty);
      expect(resSpaces.temperatureC, isNull);

      final resNull = extractor.extract(null);
      expect(resNull.chiefComplaint, equals('other'));
      expect(resNull.symptoms, isEmpty);
    });

    test('2. Robustesse absolue : bruit et symboles aléatoires ne plantent jamais', () {
      final resNoise = extractor.extract(ClinicalFixtures.noiseAndGibberish);
      expect(resNoise.chiefComplaint, equals('other'));
      expect(resNoise.temperatureC, isNull);
      expect(resNoise.symptoms, isEmpty);
      expect(resNoise.rawTranscript, equals(ClinicalFixtures.noiseAndGibberish));
    });

    test('3. Fixture D-03 : Cas clinique Fatou Keïta (Fièvre, 3j, 39.4°C, allaitante)', () {
      final res = extractor.extract(ClinicalFixtures.d03FatouKeita);

      expect(res.chiefComplaint, equals('fever'));
      expect(res.durationDays, equals(3));
      expect(res.temperatureC, equals(39.4));
      expect(res.symptoms, contains('Fièvre'));
      expect(res.symptoms, contains('Maux de tête (céphalées)'));
      expect(res.symptoms, contains('Toux sèche'));
      expect(res.allergies, isEmpty); // Pas d'allergie connue
      expect(res.medications, contains('Paracétamol'));
      expect(res.antecedents, contains('Allaitement en cours'));
    });

    test('4. Fixture D-03 : Cas pédiatrique Amadou Sow (Danger PCIME, 4 ans, 40.1°C, 110 bpm)', () {
      final res = extractor.extract(ClinicalFixtures.d03AmadouSow);

      expect(res.chiefComplaint, equals('fever'));
      expect(res.ageMonths, equals(48)); // 4 ans -> 48 mois
      expect(res.durationDays, equals(2));
      expect(res.temperatureC, equals(40.1));
      expect(res.pulse, equals(110));
      expect(res.respiratoryRate, equals(34));
      expect(res.weightKg, equals(14.5));
      expect(res.symptoms, contains('Convulsions'));
      expect(res.symptoms, contains('Frissons'));
      expect(res.antecedents, contains('Drépanocytose'));
      expect(res.allergies, contains('Pénicilline'));
      expect(res.medications, isEmpty);
    });

    test('5. Fixture D-03 : Cas nourrisson diarrhée (11 mois, 48h, SRO, zinc, apyrétique)', () {
      final res = extractor.extract(ClinicalFixtures.d03NourrissonDiarrhee);

      expect(res.chiefComplaint, equals('diarrhea'));
      expect(res.ageMonths, equals(11));
      expect(res.durationDays, equals(2)); // 48 heures -> 2 jours
      expect(res.weightKg, equals(8.5));
      expect(res.temperatureC, equals(37.2));
      expect(res.symptoms, contains('Diarrhée'));
      expect(res.symptoms, contains('Vomissements'));
      expect(res.symptoms, isNot(contains('Fièvre'))); // Négation "Absence de fièvre"
      expect(res.medications, contains('SRO (Sels de réhydratation)'));
      expect(res.medications, contains('Zinc'));
    });

    test('6. Fixture D-03 : Femme enceinte et douleurs pelviennes', () {
      final res = extractor.extract(ClinicalFixtures.d03GrossesseDouleur);

      expect(res.chiefComplaint, equals('pregnancy'));
      expect(res.pregnant, isTrue);
      expect(res.temperatureC, equals(37.8));
      expect(res.pulse, equals(86));
      expect(res.durationDays, equals(1)); // "depuis ce matin"
      expect(res.symptoms, contains('Douleur pelvienne'));
    });

    test('7. Fixture Traumatisme / Accident', () {
      final res = extractor.extract(ClinicalFixtures.d03TraumatismeChute);

      expect(res.chiefComplaint, equals('trauma'));
      expect(res.symptoms, isNot(contains('Fièvre')));
    });

    test('8. Gestion rigoureuse des négations (pas de fausse détection)', () {
      final res = extractor.extract(ClinicalFixtures.negationOnly);

      expect(res.symptoms, isNot(contains('Fièvre')));
      expect(res.symptoms, isNot(contains('Toux')));
      expect(res.symptoms, isNot(contains('Diarrhée')));
      expect(res.allergies, isEmpty);
      expect(res.medications, isEmpty);
    });

    test('9. Sérialisation JSON aller-retour du modèle ConsultationData', () {
      final original = extractor.extract(ClinicalFixtures.d03FatouKeita);
      final jsonStr = original.toJson();
      final restored = ConsultationData.fromJson(jsonStr);

      expect(restored, equals(original));
      expect(restored.temperatureC, equals(39.4));
      expect(restored.chiefComplaint, equals('fever'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sura_app/domain/rules.dart';

void main() {
  // Vosk transcrit les nombres en toutes lettres : l'extraction doit les comprendre.
  test('trente-neuf degres => 39', () {
    expect(Extractor.extract('Elle a trente-neuf degrés de fièvre').temperature,
        closeTo(39.0, 0.01));
  });
  test('trente neuf virgule quatre degres => 39,4', () {
    expect(
        Extractor.extract('température trente neuf virgule quatre degrés')
            .temperature,
        closeTo(39.4, 0.01));
  });
  test('quarante degres => 40', () {
    expect(Extractor.extract('il a quarante degrés').temperature,
        closeTo(40.0, 0.01));
  });
  test('trente huit degres => 38', () {
    expect(Extractor.extract('trente huit degrés').temperature,
        closeTo(38.0, 0.01));
  });
  test('phrase complete type Vosk', () {
    final s = Extractor.extract(
        'la patiente a de la fièvre depuis trois jours elle a mal à la tête et elle tousse température trente neuf degrés');
    expect(s.durationDays, 3);
    expect(s.symptoms, contains('Fièvre'));
    expect(s.temperature, closeTo(39.0, 0.01));
  });
}

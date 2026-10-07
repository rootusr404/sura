import 'package:flutter_test/flutter_test.dart';
import 'package:sura_app/domain/manual_entry.dart';
import 'package:sura_app/domain/models.dart';
import 'package:sura_app/domain/rules.dart';

void main() {
  test('chips + duree + temperature => structure et motif auto', () {
    const e = ManualEntry(
        symptoms: {'Fièvre'},
        durationNumber: '3',
        durationUnit: 'jours',
        temperature: '38,6');
    final s = e.toStructured();
    expect(s.symptoms, ['Fièvre']);
    expect(s.durationDays, 3);
    expect(s.temperature, 38.6);
    expect(s.motif, 'Fièvre depuis 3 jours');
  });

  test('fievre cochee + 3 jours => urgence moderee', () {
    const e = ManualEntry(symptoms: {'Fièvre'}, durationNumber: '3');
    expect(UrgencyEngine.evaluate(e.toStructured()).level, Urgency.modere);
  });

  test('convulsion cochee => urgence elevee', () {
    const e = ManualEntry(symptoms: {'Convulsion'});
    expect(UrgencyEngine.evaluate(e.toStructured()).level, Urgency.eleve);
  });

  test('difficulte respiratoire cochee => urgence elevee', () {
    const e = ManualEntry(symptoms: {'Difficulté respiratoire'});
    expect(UrgencyEngine.evaluate(e.toStructured()).level, Urgency.eleve);
  });

  test('aucun symptome => faible', () {
    expect(UrgencyEngine.evaluate(const ManualEntry().toStructured()).level,
        Urgency.faible);
  });

  test('unite au singulier et conversion en jours', () {
    expect(
        const ManualEntry(durationNumber: '1', durationUnit: 'semaines')
            .duration,
        '1 semaine');
    expect(
        const ManualEntry(durationNumber: '1', durationUnit: 'semaines')
            .durationDays,
        7);
    expect(
        const ManualEntry(durationNumber: '2', durationUnit: 'mois')
            .durationDays,
        60);
  });

  test('temperature invalide detectee', () {
    expect(const ManualEntry(temperature: '99').temperatureInvalid, isTrue);
    expect(const ManualEntry(temperature: '38,5').temperatureInvalid, isFalse);
    expect(const ManualEntry(temperature: '').temperatureInvalid, isFalse);
  });

  test('allergies et traitement : modes', () {
    expect(const ManualEntry(allergyMode: 1).allergies, 'Aucune');
    expect(
        const ManualEntry(allergyMode: 2, allergyText: ' pénicilline ')
            .allergies,
        'pénicilline');
    expect(const ManualEntry(allergyMode: 2).allergies, isNull);
    expect(const ManualEntry(treatmentMode: 1).treatment, 'Aucun');
  });

  test('autres symptomes : canoniques sans doublon, inconnus conserves', () {
    const e = ManualEntry(symptoms: {'Toux'}, other: 'toux, mal de dos');
    expect(e.toStructured().symptoms, ['Toux', 'Mal de dos']);
  });

  test('aller-retour fromStructured', () {
    const e = ManualEntry(
        symptoms: {'Fièvre', 'Toux'},
        other: 'mal de dos',
        durationNumber: '5',
        durationUnit: 'jours',
        temperature: '39,2',
        allergyMode: 1,
        treatmentMode: 2,
        treatmentText: 'paracétamol');
    final r = ManualEntry.fromStructured(e.toStructured());
    expect(r.symptoms, {'Fièvre', 'Toux'});
    expect(r.other, 'Mal de dos');
    expect(r.durationNumber, '5');
    expect(r.temperature, '39,2');
    expect(r.allergyMode, 1);
    expect(r.treatmentMode, 2);
    expect(r.treatmentText, 'paracétamol');
    expect(r.motif, '');
  });
}

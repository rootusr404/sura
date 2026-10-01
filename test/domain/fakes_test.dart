import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/fakes/fake_services.dart';
import 'package:sura/domain/models/patient_context.dart';
import 'package:sura/features/consultation/flow/consultation_steps.dart';

void main() {
  const patient = PatientContext(ageYears: 30, sex: 'F');

  test('les fakes respectent les contrats', () async {
    final text = (await FakeTranscriptionService().transcribe('x.wav')).text;
    final info = FakeInformationExtractor().extract(text);
    expect(info.chiefComplaint, isNotNull);
    expect(
      FakeMissingInfoChecker().check(info, patient).map((m) => m.code),
      contains('allergies'),
    );
    expect(FakeUrgencyScorer().score(info, text, patient).reasons, isNotEmpty);
  });

  test(
    'le vérificateur ne signale plus les allergies une fois renseignées',
    () {
      final info = FakeInformationExtractor()
          .extract('')
          .copyWith(allergies: 'Pénicilline');
      expect(FakeMissingInfoChecker().check(info, patient), isEmpty);
    },
  );

  test('ConsultationStep : chemins et ordre', () {
    expect(ConsultationStep.consent.path('abc'), '/consultation/abc/consent');
    expect(ConsultationStep.consent.next, ConsultationStep.record);
    expect(ConsultationStep.saved.next, isNull);
    expect(ConsultationStep.consent.previous, isNull);
  });
}

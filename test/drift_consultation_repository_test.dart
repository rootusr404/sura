import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sura/core/db/app_database.dart';
import 'package:sura/core/db/drift_consultation_repository.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/missing_item.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/domain/models/urgency_proposal.dart';
import 'package:sura/core/db/drift_patient_repository.dart';

void main() {
  late AppDatabase db;
  late DriftConsultationRepository repo;
  late String patientId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftConsultationRepository(db);
    final p = await DriftPatientRepository(db).create(
      lastName: 'Test',
      firstName: 'Fatou',
      ageYears: 30,
      sex: 'F',
      village: 'Village A',
      agentId: 'agent-1',
    );
    patientId = p.id;
  });
  tearDown(() => db.close());

  test(
    'createDraft : brouillon à l\'étape consentement, en attente de synchro',
    () async {
      final c = await repo.createDraft(
        patientId: patientId,
        agentId: 'agent-1',
      );
      expect(c.status, ConsultationStatus.draft);
      expect(c.step, 'consent');
      expect(c.consent, isNull);
      expect(c.syncState, SyncState.pending);
      expect(c.missing, isEmpty);
    },
  );

  test(
    'save puis getById : tous les blocs survivent à l\'aller-retour',
    () async {
      final c = await repo.createDraft(
        patientId: patientId,
        agentId: 'agent-1',
      );
      await repo.save(
        c.copyWith(
          consent: ConsentStatus.granted,
          consentAt: DateTime(2026, 10, 2, 10),
          transcriptRaw: 'brut',
          transcriptEdited: 'corrigé',
          structured: const StructuredInfo(
            chiefComplaint: 'Fièvre',
            symptoms: ['Fièvre', 'Toux'],
            temperatureC: 39.5,
            pulse: 100,
          ),
          missing: const [
            MissingItem(
              code: 'allergies',
              label: 'Allergies ?',
              hint: 'Demander',
            ),
          ],
          urgencyProposal: const UrgencyProposal(
            level: UrgencyLevel.moderate,
            reasons: ['Fièvre à 39,5 °C'],
          ),
          urgencyFinal: UrgencyLevel.high,
          urgencyOverrideReason: 'Enfant fragile',
          checklist: const {'transcript': true, 'urgency': false},
          step: 'urgency',
        ),
      );
      final b = (await repo.getById(c.id))!;
      expect(b.consent, ConsentStatus.granted);
      expect(b.transcript, 'corrigé');
      expect(b.transcriptRaw, 'brut');
      expect(b.structured!.temperatureC, 39.5);
      expect(b.structured!.symptoms, ['Fièvre', 'Toux']);
      expect(b.missing.single.code, 'allergies');
      expect(b.urgencyProposal!.level, UrgencyLevel.moderate);
      expect(b.urgencyProposal!.reasons, ['Fièvre à 39,5 °C']);
      expect(b.urgencyFinal, UrgencyLevel.high);
      expect(b.urgencyOverrideReason, 'Enfant fragile');
      expect(b.checklist, {'transcript': true, 'urgency': false});
      expect(b.step, 'urgency');
    },
  );

  test('un motif de changement vide est enregistré comme absent', () async {
    final c = await repo.createDraft(patientId: patientId, agentId: 'agent-1');
    await repo.save(c.copyWith(urgencyOverrideReason: ''));
    expect((await repo.getById(c.id))!.urgencyOverrideReason, isNull);
  });

  test('markValidated : enregistrée, horodatée, à synchroniser (R9)', () async {
    final c = await repo.createDraft(patientId: patientId, agentId: 'agent-1');
    await repo.markValidated(c.id);
    final b = (await repo.getById(c.id))!;
    expect(b.status, ConsultationStatus.saved);
    expect(b.validatedAt, isNotNull);
    expect(b.syncState, SyncState.pending);
    expect(b.step, 'saved');
  });

  test(
    'watchByPatient : la plus récente d\'abord, même à la même seconde',
    () async {
      final a = await repo.createDraft(
        patientId: patientId,
        agentId: 'agent-1',
      );
      final b = await repo.createDraft(
        patientId: patientId,
        agentId: 'agent-1',
      );
      final list = await repo.watchByPatient(patientId).first;
      expect(list.map((c) => c.id), [b.id, a.id]);
    },
  );

  test('getById inconnu renvoie null', () async {
    expect(await repo.getById('inconnu'), isNull);
  });
}

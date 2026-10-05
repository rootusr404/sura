import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sura/core/db/app_database.dart';
import 'package:sura/core/db/drift_consultation_repository.dart';
import 'package:sura/core/db/drift_patient_repository.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/features/sync/repository_sync_service.dart';

class TestRemote implements SyncRemoteStore {
  bool failPatient = false;
  bool failConsultation = false;
  final sent = <String>[];
  @override
  Future<void> sendPatient(String agent, PatientRecord p) async {
    sent.add('p:${p.id}');
    if (failPatient) throw StateError('offline');
  }

  @override
  Future<void> sendConsultation(String agent, ConsultationRecord c) async {
    sent.add('c:${c.id}');
    if (failConsultation) throw StateError('offline');
  }
}

Future<PatientRecord> makePatient(DriftPatientRepository repo) => repo.create(
  lastName: 'Test',
  firstName: 'Awa',
  ageYears: 30,
  sex: 'F',
  village: 'Fictif',
  agentId: 'agent',
);

RepositorySyncService sync(AppDatabase db, TestRemote remote) =>
    RepositorySyncService(
      patients: DriftPatientRepository(db),
      consultations: DriftConsultationRepository(db),
      remote: remote,
      currentAgentId: () => 'agent',
      checkOnline: () async => true,
      baseRetryDelay: const Duration(minutes: 1),
    );

void main() {
  test(
    'Drift : états atomiques et accusé ancien refusé après une modification rapide',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final patients = DriftPatientRepository(db);
      final consultations = DriftConsultationRepository(db);
      final p = await makePatient(patients);
      expect(
        await patients.updateSyncState(
          p.id,
          SyncState.error,
          expectedUpdatedAt: p.updatedAt,
          attempts: 3,
          error: 'offline',
        ),
        isTrue,
      );
      expect(
        await patients.updateSyncState(
          p.id,
          SyncState.synced,
          expectedUpdatedAt: p.updatedAt.add(const Duration(milliseconds: 1)),
          attempts: 99,
        ),
        isFalse,
      );
      expect((await patients.getById(p.id))!.syncAttempts, 3);
      expect((await patients.getById(p.id))!.syncError, 'offline');
      expect(
        await patients.updateSyncState(
          p.id,
          SyncState.synced,
          expectedUpdatedAt: p.updatedAt,
        ),
        isTrue,
      );
      final patientDone = (await patients.getById(p.id))!;
      expect(patientDone.updatedAt, p.updatedAt);
      expect(patientDone.syncAttempts, 3);
      expect(patientDone.syncError, isNull);
      final draft = await consultations.createDraft(
        patientId: p.id,
        agentId: 'agent',
      );
      await consultations.markValidated(draft.id);
      final sent = (await consultations.getById(draft.id))!;
      await consultations.save(
        sent.copyWith(
          transcriptEdited: 'Correction',
          updatedAt: sent.updatedAt,
        ),
      );
      final edited = (await consultations.getById(sent.id))!;
      expect(edited.updatedAt.isAfter(sent.updatedAt), isTrue);
      expect(
        await consultations.updateSyncState(
          sent.id,
          SyncState.synced,
          expectedUpdatedAt: sent.updatedAt,
          attempts: 99,
        ),
        isFalse,
      );
      expect((await consultations.getById(sent.id))!.transcript, 'Correction');
      expect(
        (await consultations.getById(sent.id))!.syncState,
        SyncState.pending,
      );
      expect(
        await consultations.updateSyncState(
          sent.id,
          SyncState.error,
          expectedUpdatedAt: edited.updatedAt,
          attempts: 2,
          error: 'offline',
        ),
        isTrue,
      );
      expect(
        await consultations.updateSyncState(
          sent.id,
          SyncState.synced,
          expectedUpdatedAt: edited.updatedAt,
        ),
        isTrue,
      );
      final done = (await consultations.getById(sent.id))!;
      expect(done.updatedAt, edited.updatedAt);
      expect(done.syncAttempts, 2);
      expect(done.syncError, isNull);
    },
  );

  test(
    'SQLite : erreurs et tentatives survivent aux réouvertures, reprise ordonnée',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sura_drift_sync_',
      );
      final file = File('${directory.path}/sura.sqlite');
      var db = AppDatabase.forTesting(NativeDatabase(file));
      RepositorySyncService? service;
      addTearDown(() async {
        service?.dispose();
        await db.close();
        await directory.delete(recursive: true);
      });
      final patients = DriftPatientRepository(db);
      final consultations = DriftConsultationRepository(db);
      final p = await makePatient(patients);
      final draft = await consultations.createDraft(
        patientId: p.id,
        agentId: 'agent',
      );
      await consultations.save(draft.copyWith(transcriptEdited: 'Texte local'));
      await consultations.markValidated(draft.id);
      final firstRemote = TestRemote()..failPatient = true;
      service = sync(db, firstRemote);
      await service.syncPending();
      expect(firstRemote.sent, ['p:${p.id}']);
      service.dispose();
      await db.close();
      db = AppDatabase.forTesting(NativeDatabase(file));
      final restored = (await DriftPatientRepository(db).getById(p.id))!;
      expect(restored.syncState, SyncState.error);
      expect(restored.syncAttempts, 1);
      expect(restored.syncError, isNotNull);
      expect(
        (await DriftConsultationRepository(db).getById(draft.id))!.transcript,
        'Texte local',
      );
      final secondRemote = TestRemote()..failConsultation = true;
      service = sync(db, secondRemote);
      await service.retry(draft.id);
      expect(secondRemote.sent, ['p:${p.id}', 'c:${draft.id}']);
      service.dispose();
      await db.close();
      db = AppDatabase.forTesting(NativeDatabase(file));
      final failed = (await DriftConsultationRepository(db).getById(draft.id))!;
      expect(failed.syncState, SyncState.error);
      expect(failed.syncAttempts, 1);
      expect(failed.syncError, isNotNull);
      expect(failed.transcript, 'Texte local');
      final thirdRemote = TestRemote();
      service = sync(db, thirdRemote);
      await service.retry(draft.id);
      expect(thirdRemote.sent, ['c:${draft.id}']);
      service.dispose();
      await db.close();
      db = AppDatabase.forTesting(NativeDatabase(file));
      final done = (await DriftConsultationRepository(db).getById(draft.id))!;
      expect(done.syncState, SyncState.synced);
      expect(done.syncAttempts, 2);
      expect(done.syncError, isNull);
      expect(done.transcript, 'Texte local');
      expect((await DriftPatientRepository(db).getById(p.id))!.syncAttempts, 2);
    },
  );

  test(
    'migration v1 vers v2 conserve les patients et consultations existants',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sura_drift_migration_',
      );
      final file = File('${directory.path}/sura.sqlite');
      var db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(() async {
        await db.close();
        await directory.delete(recursive: true);
      });
      final p = await makePatient(DriftPatientRepository(db));
      final c = await DriftConsultationRepository(
        db,
      ).createDraft(patientId: p.id, agentId: 'agent');
      // Reconstitue le schéma v1 reçu dans la fusion, sans les deux colonnes.
      await db.customStatement(
        'ALTER TABLE patients DROP COLUMN sync_attempts',
      );
      await db.customStatement('ALTER TABLE patients DROP COLUMN sync_error');
      await db.customStatement('PRAGMA user_version = 1');
      await db.close();
      db = AppDatabase.forTesting(NativeDatabase(file));
      final restored = (await DriftPatientRepository(db).getById(p.id))!;
      expect(restored.fullName, p.fullName);
      expect(restored.syncAttempts, 0);
      expect(restored.syncError, isNull);
      expect(await DriftConsultationRepository(db).getById(c.id), isNotNull);
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
          'user_version',
        ),
        2,
      );
    },
  );
}

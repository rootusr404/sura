import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/fakes/in_memory_repositories.dart';
import 'package:sura/domain/models/enums.dart';

void main() {
  test(
    'création patient : identifiant SUR-XXXX-XXXX et statut pending',
    () async {
      final repo = InMemoryPatientRepository();
      final p = await repo.create(
        lastName: 'Test',
        firstName: 'Fatou',
        ageYears: 30,
        sex: 'F',
        village: 'Village X',
        agentId: 'a1',
      );
      expect(p.id, matches(RegExp(r'^SUR-[A-Z0-9]{4}-[A-Z0-9]{4}$')));
      expect(p.syncState, SyncState.pending);
      expect((await repo.getById(p.id))?.fullName, 'Fatou Test');
    },
  );

  test('recherche patient par nom, village et identifiant', () async {
    final repo = InMemoryPatientRepository.withDemoData();
    expect((await repo.search('awa')).length, 1);
    expect((await repo.search('village test b')).length, 1);
    expect((await repo.search('SUR-DEMO-0002')).length, 1);
    expect((await repo.search('')).length, 2);
    expect(await repo.search('zzz'), isEmpty);
  });

  test('consultation : brouillon, sauvegarde, validation', () async {
    final repo = InMemoryConsultationRepository();
    final c = await repo.createDraft(patientId: 'SUR-DEMO-0001', agentId: 'a1');
    expect(c.status, ConsultationStatus.draft);

    await repo.save(
      c.copyWith(
        consent: ConsentStatus.granted,
        transcriptEdited: 'texte corrigé',
      ),
    );
    final saved = await repo.getById(c.id);
    expect(saved?.consent, ConsentStatus.granted);
    expect(saved?.transcript, 'texte corrigé');

    await repo.markValidated(c.id);
    final done = await repo.getById(c.id);
    expect(done?.status, ConsultationStatus.saved);
    expect(done?.validatedAt, isNotNull);
    expect(done?.syncState, SyncState.pending);
  });

  test('watchById émet la valeur initiale puis les mises à jour', () async {
    final repo = InMemoryConsultationRepository();
    final c = await repo.createDraft(patientId: 'p', agentId: 'a');
    final events = <String>[];
    final sub = repo.watchById(c.id).listen((r) => events.add(r!.step));
    await Future<void>.delayed(Duration.zero);
    await repo.save(c.copyWith(step: 'record'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(events, ['consent', 'record']);
  });
  test('patient : état, tentatives et erreur modifiés atomiquement', () async {
    final repo = InMemoryPatientRepository();
    final p = await repo.create(
      lastName: 'Test',
      firstName: 'Awa',
      ageYears: 30,
      sex: 'F',
      village: 'Fictif',
      agentId: 'a1',
    );
    expect(
      await repo.updateSyncState(
        p.id,
        SyncState.error,
        expectedUpdatedAt: p.updatedAt,
        attempts: 3,
        error: 'Envoi interrompu',
      ),
      isTrue,
    );
    final failed = (await repo.getById(p.id))!;
    expect(failed.syncState, SyncState.error);
    expect(failed.syncAttempts, 3);
    expect(failed.syncError, 'Envoi interrompu');
    expect(
      await repo.updateSyncState(
        p.id,
        SyncState.synced,
        expectedUpdatedAt: p.updatedAt.add(const Duration(seconds: 1)),
        attempts: 99,
      ),
      isFalse,
    );
    expect(await repo.getById(p.id), same(failed));
    expect(
      await repo.updateSyncState(
        p.id,
        SyncState.synced,
        expectedUpdatedAt: p.updatedAt,
      ),
      isTrue,
    );
    final done = (await repo.getById(p.id))!;
    expect(done.syncState, SyncState.synced);
    expect(done.syncAttempts, 3);
    expect(done.syncError, isNull);
    expect(done.updatedAt, p.updatedAt);
    expect(done.fullName, p.fullName);
  });

  test(
    'consultation : version ancienne ne modifie aucune métadonnée',
    () async {
      final repo = InMemoryConsultationRepository();
      final c = await repo.createDraft(patientId: 'p', agentId: 'a1');
      expect(
        await repo.updateSyncState(
          c.id,
          SyncState.error,
          expectedUpdatedAt: c.updatedAt,
          attempts: 2,
          error: 'Envoi interrompu',
        ),
        isTrue,
      );
      final failed = (await repo.getById(c.id))!;
      expect(failed.syncState, SyncState.error);
      expect(failed.syncAttempts, 2);
      expect(failed.syncError, 'Envoi interrompu');
      expect(
        await repo.updateSyncState(
          c.id,
          SyncState.synced,
          expectedUpdatedAt: c.updatedAt.add(const Duration(seconds: 1)),
          attempts: 99,
        ),
        isFalse,
      );
      expect(await repo.getById(c.id), same(failed));
      expect(
        await repo.updateSyncState(
          c.id,
          SyncState.synced,
          expectedUpdatedAt: c.updatedAt,
        ),
        isTrue,
      );
      final done = (await repo.getById(c.id))!;
      expect(done.syncState, SyncState.synced);
      expect(done.syncAttempts, 2);
      expect(done.syncError, isNull);
      expect(done.updatedAt, c.updatedAt);
      expect(done.patientId, c.patientId);
    },
  );
}

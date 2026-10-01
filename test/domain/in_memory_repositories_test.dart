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
}

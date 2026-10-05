import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sura/domain/fakes/in_memory_repositories.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/features/sync/firestore_sync_remote_store.dart';
import 'package:sura/features/sync/repository_sync_service.dart';

class TestRemote implements SyncRemoteStore {
  final events = <String>[];
  bool failPatient = false;
  bool failConsultation = false;
  Future<void> Function(ConsultationRecord)? onConsultation;

  @override
  Future<void> sendPatient(String agentId, PatientRecord p) async {
    events.add('patient:${p.id}');
    if (failPatient) throw StateError('network');
  }

  @override
  Future<void> sendConsultation(String agentId, ConsultationRecord c) async {
    events.add('consultation:${c.id}');
    if (failConsultation) throw StateError('network');
    await onConsultation?.call(c);
  }
}

void main() {
  late InMemoryPatientRepository patients;
  late InMemoryConsultationRepository consultations;
  late TestRemote remote;
  late RepositorySyncService service;
  late bool online;
  late String? agent;
  late DateTime clock;

  Future<PatientRecord> patient({String owner = 'agent'}) => patients.create(
    lastName: 'Test',
    firstName: 'Awa',
    ageYears: 30,
    sex: 'F',
    village: 'Village fictif',
    agentId: owner,
  );

  Future<ConsultationRecord> saved(
    PatientRecord p, {
    String owner = 'agent',
  }) async {
    final draft = await consultations.createDraft(
      patientId: p.id,
      agentId: owner,
    );
    await consultations.markValidated(draft.id);
    return (await consultations.getById(draft.id))!;
  }

  setUp(() {
    patients = InMemoryPatientRepository();
    consultations = InMemoryConsultationRepository();
    remote = TestRemote();
    online = true;
    agent = 'agent';
    clock = DateTime.utc(2026, 10, 4);
    service = RepositorySyncService(
      patients: patients,
      consultations: consultations,
      remote: remote,
      currentAgentId: () => agent,
      checkOnline: () async => online,
      now: () => clock,
      baseRetryDelay: const Duration(hours: 1),
      maxRetryDelay: const Duration(hours: 4),
      sendTimeout: const Duration(milliseconds: 20),
    );
  });
  tearDown(() => service.dispose());

  test('patients avant consultations, états syncing puis synced', () async {
    final p = await patient();
    final c = await saved(p);
    final states = <SyncState>[];
    final sub = service.watchOverall().listen(states.add);
    await service.syncPending();
    await Future<void>.delayed(Duration.zero);
    expect(remote.events, ['patient:${p.id}', 'consultation:${c.id}']);
    expect((await patients.getById(p.id))!.syncState, SyncState.synced);
    final result = (await consultations.getById(c.id))!;
    expect(result.syncState, SyncState.synced);
    expect(result.syncAttempts, 1);
    expect(result.updatedAt, c.updatedAt);
    expect(
      states,
      containsAllInOrder([
        SyncState.offline,
        SyncState.syncing,
        SyncState.synced,
      ]),
    );
    await sub.cancel();
    await service.syncPending();
    expect(remote.events.length, 2); // Pas de doublon.
  });

  test(
    'patient en erreur bloque sa consultation; retry reprend les deux',
    () async {
      final p = await patient();
      final c = await saved(p);
      remote.failPatient = true;
      await service.syncPending();
      expect(remote.events, ['patient:${p.id}']);
      expect((await patients.getById(p.id))!.syncState, SyncState.error);
      expect((await consultations.getById(c.id))!.syncState, SyncState.error);
      remote.failPatient = false;
      await service.retry(c.id);
      expect(remote.events, [
        'patient:${p.id}',
        'patient:${p.id}',
        'consultation:${c.id}',
      ]);
      expect((await consultations.getById(c.id))!.syncError, isNull);
    },
  );

  test('hors ligne : aucune écriture distante, données conservées', () async {
    final p = await patient();
    final c = await saved(p);
    online = false;
    await service.syncPending();
    expect(remote.events, isEmpty);
    expect((await patients.getById(p.id))!.syncState, SyncState.pending);
    expect((await consultations.getById(c.id))!.syncState, SyncState.pending);
  });

  test('brouillons et données des autres agents exclus', () async {
    final own = await patient();
    final other = await patient(owner: 'other');
    await saved(other, owner: 'other');
    await consultations.createDraft(patientId: own.id, agentId: 'agent');
    await service.syncPending();
    expect(remote.events, ['patient:${own.id}']);
    agent = null;
    await service.syncPending();
    expect(remote.events.length, 1);
  });

  test(
    'coupure pendant envoi : erreur, réessai sans perte et erreur effacée',
    () async {
      final p = await patient();
      final c = await saved(p);
      remote.failConsultation = true;
      await service.syncPending();
      final failed = (await consultations.getById(c.id))!;
      expect(failed.syncState, SyncState.error);
      expect(failed.syncAttempts, 1);
      expect(failed.validatedAt, c.validatedAt);
      remote.failConsultation = false;
      await service.retry(c.id);
      final result = (await consultations.getById(c.id))!;
      expect(result.syncState, SyncState.synced);
      expect(result.syncAttempts, 2);
      expect(result.syncError, isNull);
      expect(remote.events.where((e) => e.startsWith('patient')).length, 1);
    },
  );

  test('réessai avec délai croissant et plafonné', () async {
    final p = await patient();
    remote.failPatient = true;
    await service.syncPending();
    await service.syncPending();
    expect(remote.events.length, 1);
    clock = clock.add(const Duration(hours: 1));
    await service.syncPending();
    expect(remote.events.length, 2);
    clock = clock.add(const Duration(hours: 1));
    await service.syncPending();
    expect(remote.events.length, 2);
    clock = clock.add(const Duration(hours: 1));
    await service.syncPending();
    expect(remote.events.length, 3);
    clock = clock.add(const Duration(hours: 4));
    await service.syncPending();
    expect(remote.events.length, 4);
    clock = clock.add(const Duration(hours: 4));
    await service.syncPending();
    expect(remote.events.length, 5);
    expect((await patients.getById(p.id))!.syncState, SyncState.error);
  });

  test(
    'version modifiée pendant envoi reste pending, sans écrasement',
    () async {
      final p = await patient();
      final c = await saved(p);
      remote.onConsultation = (sent) async {
        await consultations.save(
          sent.copyWith(
            transcriptEdited: 'Correction locale',
            updatedAt: sent.updatedAt.add(const Duration(seconds: 1)),
          ),
        );
      };
      await service.syncPending();
      final result = (await consultations.getById(c.id))!;
      expect(result.transcriptEdited, 'Correction locale');
      expect(result.syncState, SyncState.pending);
    },
  );

  test('reprise des états syncing laissés par un envoi interrompu', () async {
    final p = await patient();
    final c = await saved(p);
    await patients.updateSyncState(
      p.id,
      SyncState.syncing,
      expectedUpdatedAt: p.updatedAt,
    );
    await consultations.updateSyncState(
      c.id,
      SyncState.syncing,
      expectedUpdatedAt: c.updatedAt,
    );
    await service.syncPending();
    expect((await consultations.getById(c.id))!.syncState, SyncState.synced);
  });

  test('envoi bloqué expire; la consultation reste réessayable', () async {
    final p = await patient();
    final c = await saved(p);
    final blocked = Completer<void>();
    remote.onConsultation = (_) => blocked.future;
    await service.syncPending();
    expect((await consultations.getById(c.id))!.syncState, SyncState.error);
    blocked.complete();
    await Future<void>.delayed(Duration.zero);
    expect((await consultations.getById(c.id))!.syncState, SyncState.error);
  });

  test('appels concurrents partagent un seul envoi', () async {
    final p = await patient();
    await saved(p);
    await Future.wait([
      service.syncPending(),
      service.syncPending(),
      service.syncPending(),
    ]);
    expect(remote.events.length, 2);
  });

  test(
    'retour réseau et validation locale réveillent automatiquement la file',
    () async {
      final network = StreamController<bool>.broadcast();
      final auth = StreamController<String?>.broadcast();
      addTearDown(network.close);
      addTearDown(auth.close);
      online = false;
      final p = await patient();
      service.start(connectivity: network.stream, auth: auth.stream);
      await service.syncPending();
      expect(remote.events, isEmpty);
      final patientSynced = patients
          .watchById(p.id)
          .firstWhere((record) => record?.syncState == SyncState.synced);
      online = true;
      network.add(true);
      await patientSynced.timeout(const Duration(seconds: 2));
      expect((await patients.getById(p.id))!.syncState, SyncState.synced);
      final c = await saved(p);
      await consultations
          .watchById(c.id)
          .firstWhere((record) => record?.syncState == SyncState.synced)
          .timeout(const Duration(seconds: 2));
      expect((await consultations.getById(c.id))!.syncState, SyncState.synced);
    },
  );

  test('un patient seul en erreur peut être relancé par son ID', () async {
    final p = await patient();
    remote.failPatient = true;
    await service.syncPending();
    expect((await patients.getById(p.id))!.syncState, SyncState.error);
    expect((await patients.getById(p.id))!.syncAttempts, 1);
    expect((await patients.getById(p.id))!.syncError, isNotNull);
    remote.failPatient = false;
    await service.retry(p.id);
    expect(remote.events, ['patient:${p.id}', 'patient:${p.id}']);
    expect((await patients.getById(p.id))!.syncState, SyncState.synced);
    expect((await patients.getById(p.id))!.syncAttempts, 2);
    expect((await patients.getById(p.id))!.syncError, isNull);
  });

  test('statut saved sans horodatage de validation reste exclu', () async {
    final p = await patient();
    final c = await consultations.createDraft(
      patientId: p.id,
      agentId: 'agent',
    );
    await consultations.save(c.copyWith(status: ConsultationStatus.saved));
    await service.syncPending();
    expect(remote.events, ['patient:${p.id}']);
    expect((await consultations.getById(c.id))!.validatedAt, isNull);
  });

  test('le timer relance automatiquement un échec sans intervention', () async {
    service.dispose();
    service = RepositorySyncService(
      patients: patients,
      consultations: consultations,
      remote: remote,
      currentAgentId: () => agent,
      checkOnline: () async => online,
      baseRetryDelay: const Duration(milliseconds: 30),
      maxRetryDelay: const Duration(milliseconds: 120),
    );
    final p = await patient();
    remote.failPatient = true;
    await service.syncPending();
    expect((await patients.getById(p.id))!.syncState, SyncState.error);
    final synced = patients
        .watchById(p.id)
        .firstWhere((record) => record?.syncState == SyncState.synced);
    remote.failPatient = false;
    await synced.timeout(const Duration(seconds: 2));
    expect(remote.events.length, 2);
  });

  test('notifications réseau identiques ne contournent pas le délai', () async {
    final network = StreamController<bool>.broadcast();
    final auth = StreamController<String?>.broadcast();
    addTearDown(network.close);
    addTearDown(auth.close);
    remote.failPatient = true;
    await patient();
    service.start(connectivity: network.stream, auth: auth.stream);
    network.add(true);
    await Future<void>.delayed(Duration.zero);
    await service.syncPending();
    final attempts = remote.events.length;
    network.add(true);
    await Future<void>.delayed(Duration.zero);
    await service.syncPending();
    expect(remote.events.length, attempts);
  });
  test(
    'payloads explicites sans audio, chemin local ni état de file',
    () async {
      final p = await patient();
      final c = await saved(p);
      final data = consultationSyncData(c);
      expect(
        data.keys,
        unorderedEquals([
          'id',
          'patientId',
          'agentId',
          'status',
          'step',
          'consent',
          'consentAt',
          'transcriptRaw',
          'transcriptEdited',
          'structured',
          'missing',
          'urgencyProposal',
          'urgencyFinal',
          'urgencyOverrideReason',
          'checklist',
          'createdAt',
          'updatedAt',
          'validatedAt',
        ]),
      );
      expect(patientSyncData(p)['id'], p.id);
      expect(data['status'], 'saved');
    },
  );
}

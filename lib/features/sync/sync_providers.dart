import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/domain/contracts/sync_service.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';

import 'firestore_sync_remote_store.dart';
import 'repository_sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivity = Connectivity();
  // Firebase peut être indisponible au démarrage : le transport reste paresseux.
  final service = RepositorySyncService(
    patients: ref.watch(patientRepositoryProvider),
    consultations: ref.watch(consultationRepositoryProvider),
    remote: _FirebaseRemoteStore(),
    currentAgentId: () =>
        Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser?.uid,
    checkOnline: () async => _online(await connectivity.checkConnectivity()),
  );
  service.start(
    connectivity: connectivity.onConnectivityChanged.map(_online),
    auth: Firebase.apps.isEmpty
        ? const Stream<String?>.empty()
        : FirebaseAuth.instance.authStateChanges().map((user) => user?.uid),
  );
  ref.onDispose(service.dispose);
  return service;
});

bool _online(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);

class _FirebaseRemoteStore implements SyncRemoteStore {
  FirestoreSyncRemoteStore get _store =>
      FirestoreSyncRemoteStore(FirebaseFirestore.instance);

  @override
  Future<void> sendPatient(String agentId, PatientRecord patient) =>
      _store.sendPatient(agentId, patient);

  @override
  Future<void> sendConsultation(
    String agentId,
    ConsultationRecord consultation,
  ) => _store.sendConsultation(agentId, consultation);
}

final overallSyncStateProvider = StreamProvider<SyncState>(
  (ref) => ref.watch(syncServiceProvider).watchOverall(),
);

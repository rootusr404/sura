import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/transcription.dart';
import '../features/auth/auth_service.dart';
import '../features/consultation/consultation_service.dart';
import '../features/sync/sync_service.dart';
import 'database.dart';
import 'repository.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final repoProvider =
    Provider<SuraRepo>((ref) => SuraRepo(ref.watch(dbProvider)));

final allPatientsProvider = StreamProvider.autoDispose<List<Patient>>(
    (ref) => ref.watch(repoProvider).watchPatients(''));

final patientsProvider =
    StreamProvider.autoDispose.family<List<Patient>, String>(
  (ref, q) => ref.watch(repoProvider).watchPatients(q),
);

final patientProvider = FutureProvider.autoDispose.family<Patient?, String>(
  (ref, id) => ref.watch(repoProvider).getPatient(id),
);

final consultationsProvider =
    StreamProvider.autoDispose.family<List<Consultation>, ConsFilter>(
  (ref, f) => ref.watch(repoProvider).watchConsultations(f),
);

final consultationProvider =
    StreamProvider.autoDispose.family<Consultation?, String>(
  (ref, id) => ref.watch(repoProvider).watchConsultation(id),
);

final transcriptionProvider =
    Provider<TranscriptionService>((ref) => MockTranscriptionService());

final consultationServiceProvider = Provider<ConsultationService>((ref) {
  return ConsultationService(
      ref.watch(repoProvider), ref.watch(agentIdProvider));
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.watch(repoProvider), ref.watch(authProvider));
});

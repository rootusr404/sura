import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/features/auth/providers/auth_providers.dart';

final settingsAgentIdProvider = StreamProvider<String?>((ref) async* {
  final auth = ref.watch(firebaseAuthServiceProvider);
  yield auth.currentUser?.uid;
  yield* auth.authStateChanges.map((user) => user?.uid);
});

final settingsLogoutProvider = Provider<Future<void> Function()>(
  (ref) => ref.watch(firebaseAuthServiceProvider).logout,
);

final settingsPatientsProvider = StreamProvider<List<PatientRecord>>(
  (ref) => ref.watch(patientRepositoryProvider).watchAll(),
);
final settingsConsultationsProvider = StreamProvider<List<ConsultationRecord>>(
  (ref) => ref.watch(consultationRepositoryProvider).watchAll(),
);

class SettingsSyncItems {
  const SettingsSyncItems({
    required this.patients,
    required this.consultations,
  });
  final List<PatientRecord> patients;
  final List<ConsultationRecord> consultations;
  int get count => patients.length + consultations.length;

  factory SettingsSyncItems.forAgent(
    String? agent,
    List<PatientRecord> patients,
    List<ConsultationRecord> consultations,
  ) => SettingsSyncItems(
    patients: patients
        .where(
          (p) =>
              agent != null &&
              p.createdByAgentId == agent &&
              p.syncState != SyncState.synced,
        )
        .toList(),
    consultations: consultations
        .where(
          (c) =>
              agent != null &&
              c.agentId == agent &&
              c.syncState != SyncState.synced,
        )
        .toList(),
  );
}

final settingsSyncItemsProvider = Provider<AsyncValue<SettingsSyncItems>>((
  ref,
) {
  final agent = ref.watch(settingsAgentIdProvider);
  final patients = ref.watch(settingsPatientsProvider);
  final consultations = ref.watch(settingsConsultationsProvider);
  for (final value in <AsyncValue<Object?>>[agent, patients, consultations]) {
    if (value.hasError) return AsyncError(value.error!, value.stackTrace!);
    if (value.asData == null) return const AsyncLoading();
  }
  return AsyncData(
    SettingsSyncItems.forAgent(
      agent.asData!.value,
      patients.asData!.value,
      consultations.asData!.value,
    ),
  );
});

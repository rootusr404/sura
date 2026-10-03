import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/core/db/database_provider.dart';
import 'package:sura/core/db/drift_consultation_repository.dart';
import 'package:sura/core/db/drift_patient_repository.dart';
import 'package:sura/domain/contracts/consultation_repository.dart';
import 'package:sura/domain/contracts/patient_repository.dart';

// PROPRIÉTAIRE : Membre 1 (F-02). Implémentations Drift : les données survivent au redémarrage.
// Les fakes en mémoire restent disponibles (domain/fakes) pour les tests.
final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) => DriftPatientRepository(ref.watch(databaseProvider)),
);

final consultationRepositoryProvider = Provider<ConsultationRepository>(
  (ref) => DriftConsultationRepository(ref.watch(databaseProvider)),
);

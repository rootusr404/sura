import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/domain/contracts/consultation_repository.dart';
import 'package:sura/domain/contracts/patient_repository.dart';
import 'package:sura/domain/fakes/in_memory_repositories.dart';

// PROPRIÉTAIRE : Membre 1 (F-02). Remplacer par les implémentations Drift.
final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) => InMemoryPatientRepository.withDemoData(),
);

final consultationRepositoryProvider = Provider<ConsultationRepository>(
  (ref) => InMemoryConsultationRepository(),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/domain/models/patient_context.dart';

/// Ce dont le parcours de consultation a besoin à propos du patient.
class PatientSummary {
  const PatientSummary({
    required this.id,
    required this.name,
    required this.village,
    required this.context,
  });
  final String id;
  final String name;
  final String village;
  final PatientContext context;
}

/// Contexte patient pour les règles (checklist, urgence). Un patient introuvable ne doit
/// jamais bloquer une consultation : on retombe sur un contexte neutre.
final patientSummaryProvider = FutureProvider.family<PatientSummary, String>((
  ref,
  patientId,
) async {
  final p = await ref.watch(patientRepositoryProvider).getById(patientId);
  if (p == null) {
    return PatientSummary(
      id: patientId,
      name: 'Patient $patientId',
      village: '',
      context: const PatientContext(ageYears: 30, sex: 'M'),
    );
  }
  return PatientSummary(
    id: p.id,
    name: p.fullName,
    village: p.village,
    context: PatientContext(ageYears: p.ageYears, sex: p.sex),
  );
});

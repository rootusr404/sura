import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sura/core/db/repository_providers.dart';
import 'package:sura/core/utils/text_utils.dart';
import 'package:sura/domain/models/records.dart';

final patientsProvider = StreamProvider<List<PatientRecord>>(
  (ref) => ref.watch(patientRepositoryProvider).watchAll(),
);

class PatientSearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final patientSearchQueryProvider = NotifierProvider<PatientSearchQuery, String>(
  PatientSearchQuery.new,
);

/// Recherche sur nom, prénom, village et identifiant (sans accents ni casse).
final filteredPatientsProvider = Provider<AsyncValue<List<PatientRecord>>>((
  ref,
) {
  final q = normalizeText(ref.watch(patientSearchQueryProvider));
  return ref.watch(patientsProvider).whenData((list) {
    if (q.isEmpty) return list;
    return list
        .where(
          (p) => normalizeText(
            '${p.firstName} ${p.lastName} ${p.village} ${p.id}',
          ).contains(q),
        )
        .toList();
  });
});

final patientProvider = StreamProvider.family<PatientRecord?, String>(
  (ref, id) => ref.watch(patientRepositoryProvider).watchById(id),
);

final patientConsultationsProvider =
    StreamProvider.family<List<ConsultationRecord>, String>(
      (ref, id) => ref.watch(consultationRepositoryProvider).watchByPatient(id),
    );

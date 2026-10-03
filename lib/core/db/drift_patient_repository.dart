import 'package:drift/drift.dart';
import 'package:sura/core/db/app_database.dart';
import 'package:sura/core/utils/id_generator.dart';
import 'package:sura/core/utils/text_utils.dart';
import 'package:sura/domain/contracts/patient_repository.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';

/// Implémentation Drift du contrat PatientRepository (tâche F-02).
class DriftPatientRepository implements PatientRepository {
  DriftPatientRepository(this._db);
  final AppDatabase _db;

  // Drift stocke les dates à la seconde : rowid départage les égalités.
  static final _newestFirst = <OrderingTerm Function($PatientsTable)>[
    (p) => OrderingTerm.desc(p.createdAt),
    (p) => OrderingTerm(
      expression: const CustomExpression<int>('rowid'),
      mode: OrderingMode.desc,
    ),
  ];

  SimpleSelectStatement<$PatientsTable, Patient> _select() =>
      _db.select(_db.patients);

  @override
  Future<PatientRecord> create({
    required String lastName,
    required String firstName,
    required int ageYears,
    required String sex,
    required String village,
    String? phone,
    required String agentId,
  }) async {
    final now = DateTime.now();
    for (var i = 0; i < 5; i++) {
      final id = generatePatientId();
      if (await getById(id) != null) continue; // collision improbable
      await _db
          .into(_db.patients)
          .insert(
            PatientsCompanion.insert(
              id: id,
              lastName: lastName.trim(),
              firstName: firstName.trim(),
              ageYears: ageYears,
              ageRecordedAt: now,
              sex: sex,
              village: village.trim(),
              phone: Value(
                phone == null || phone.trim().isEmpty ? null : phone.trim(),
              ),
              createdByAgentId: agentId,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return (await getById(id))!;
    }
    throw StateError('Impossible de générer un identifiant unique.');
  }

  @override
  Future<PatientRecord?> getById(String id) async {
    final row = await (_select()..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Stream<PatientRecord?> watchById(String id) =>
      (_select()..where((p) => p.id.equals(id))).watchSingleOrNull().map(
        (r) => r == null ? null : _fromRow(r),
      );

  @override
  Stream<List<PatientRecord>> watchAll() => (_select()..orderBy(_newestFirst))
      .watch()
      .map((l) => l.map(_fromRow).toList());

  /// Recherche sans accents ni casse, sur nom, prénom, village et identifiant.
  @override
  Future<List<PatientRecord>> search(String query) async {
    final all = (await (_select()..orderBy(_newestFirst)).get())
        .map(_fromRow)
        .toList();
    final q = normalizeText(query);
    if (q.isEmpty) return all;
    return all
        .where(
          (p) => normalizeText(
            '${p.firstName} ${p.lastName} ${p.village} ${p.id}',
          ).contains(q),
        )
        .toList();
  }

  static PatientRecord _fromRow(Patient p) => PatientRecord(
    id: p.id,
    lastName: p.lastName,
    firstName: p.firstName,
    ageYears: p.ageYears,
    ageRecordedAt: p.ageRecordedAt,
    sex: p.sex,
    village: p.village,
    phone: p.phone,
    createdByAgentId: p.createdByAgentId,
    createdAt: p.createdAt,
    updatedAt: p.updatedAt,
    syncState: SyncStateX.fromDb(p.syncStatus),
  );
}

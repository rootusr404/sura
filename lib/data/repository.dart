import 'package:drift/drift.dart';

import 'database.dart';

class ConsFilter {
  const ConsFilter({this.patientId, this.draftOnly = false, this.urgency});
  final String? patientId;
  final bool draftOnly;
  final int? urgency;

  @override
  bool operator ==(Object other) =>
      other is ConsFilter &&
      other.patientId == patientId &&
      other.draftOnly == draftOnly &&
      other.urgency == urgency;

  @override
  int get hashCode => Object.hash(patientId, draftOnly, urgency);
}

class SuraRepo {
  SuraRepo(this.db);
  final AppDatabase db;

  // ---- Patients
  Stream<List<Patient>> watchPatients(String q) {
    final s = db.select(db.patients);
    final text = q.trim();
    if (text.isNotEmpty) {
      final like = '%$text%';
      s.where((p) =>
          p.familyName.like(like) | p.firstName.like(like) | p.id.like(like));
    }
    s.orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return s.watch();
  }

  Future<Patient?> getPatient(String id) =>
      (db.select(db.patients)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<void> addPatient(PatientsCompanion p) =>
      db.into(db.patients).insert(p);

  // ---- Consultations
  Stream<List<Consultation>> watchConsultations(ConsFilter f) {
    final s = db.select(db.consultations);
    s.where((c) {
      Expression<bool> e = const Constant(true);
      if (f.patientId != null) e = e & c.patientId.equals(f.patientId!);
      if (f.draftOnly) e = e & c.status.equals('draft');
      if (f.urgency != null) e = e & c.urgencyFinal.equals(f.urgency!);
      return e;
    });
    s.orderBy([(c) => OrderingTerm.desc(c.createdAt)]);
    return s.watch();
  }

  Stream<Consultation?> watchConsultation(String id) =>
      (db.select(db.consultations)..where((c) => c.id.equals(id)))
          .watchSingleOrNull();

  Future<Consultation?> getConsultation(String id) =>
      (db.select(db.consultations)..where((c) => c.id.equals(id)))
          .getSingleOrNull();

  Future<void> addConsultation(ConsultationsCompanion c) =>
      db.into(db.consultations).insert(c);

  Future<void> patchConsultation(String id, ConsultationsCompanion patch) =>
      (db.update(db.consultations)..where((c) => c.id.equals(id))).write(patch);

  Future<void> deleteConsultation(String id) =>
      (db.delete(db.consultations)..where((c) => c.id.equals(id))).go();

  /// Supprime uniquement les consultations DEJA synchronisees (jamais une consultation en attente : R10).
  Future<int> purgeSynced() => (db.delete(db.consultations)
        ..where(
            (c) => c.status.equals('saved') & c.syncStatus.equals('synced')))
      .go();

  // ---- Restauration depuis le serveur (n'ecrase jamais l'existant)
  Future<void> insertPatientIfMissing(PatientsCompanion p) =>
      db.into(db.patients).insert(p, mode: InsertMode.insertOrIgnore);

  Future<void> insertConsultationIfMissing(ConsultationsCompanion c) =>
      db.into(db.consultations).insert(c, mode: InsertMode.insertOrIgnore);

  Future<bool> isLocalEmpty() async {
    final p = await (db.select(db.patients)..limit(1)).get();
    final c = await (db.select(db.consultations)..limit(1)).get();
    return p.isEmpty && c.isEmpty;
  }

  // ---- Synchronisation (outbox)
  Future<List<Patient>> patientsToSync() => (db.select(db.patients)
        ..where((p) => p.syncStatus.equals('synced').not()))
      .get();

  Future<List<Consultation>> consultationsToSync() =>
      (db.select(db.consultations)
            ..where((c) =>
                c.status.equals('saved') & c.syncStatus.equals('synced').not()))
          .get();

  Future<void> setPatientSync(String id, String status, {String? error}) async {
    await (db.update(db.patients)..where((p) => p.id.equals(id))).write(
      PatientsCompanion(syncStatus: Value(status), lastError: Value(error)),
    );
    if (status == 'error') {
      await db.customUpdate(
        'UPDATE patients SET retry_count = retry_count + 1 WHERE id = ?',
        variables: [Variable.withString(id)],
        updates: {db.patients},
      );
    }
  }

  Future<void> setConsultationSync(String id, String status,
      {String? error}) async {
    await patchConsultation(
      id,
      ConsultationsCompanion(
        syncStatus: Value(status),
        lastError: Value(error),
        syncedAt: Value(status == 'synced' ? DateTime.now() : null),
      ),
    );
    if (status == 'error') {
      await db.customUpdate(
        'UPDATE consultations SET retry_count = retry_count + 1 WHERE id = ?',
        variables: [Variable.withString(id)],
        updates: {db.consultations},
      );
    }
  }
}

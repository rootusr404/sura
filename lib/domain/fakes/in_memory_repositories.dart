import 'dart:async';
import 'package:sura/core/utils/id_generator.dart';
import 'package:sura/domain/contracts/consultation_repository.dart';
import 'package:sura/domain/contracts/patient_repository.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/records.dart';

class _Changes {
  final _c = StreamController<void>.broadcast();
  void notify() => _c.add(null);
  Stream<R> watch<R>(R Function() read) => Stream<R>.multi((controller) {
    final subscription = _c.stream.listen((_) => controller.add(read()));
    controller.add(read());
    controller.onCancel = subscription.cancel;
  });
}

/// Implémentation mémoire : permet à tous de développer avant que Drift (F-02)
/// ne soit prêt. Les données disparaissent au redémarrage.
class InMemoryPatientRepository implements PatientRepository {
  InMemoryPatientRepository();

  /// Deux patients FICTIFS pour le développement.
  factory InMemoryPatientRepository.withDemoData() {
    final r = InMemoryPatientRepository();
    final now = DateTime.now();
    for (final p in [
      PatientRecord(
        id: 'SUR-DEMO-0001',
        lastName: 'Démo',
        firstName: 'Awa',
        ageYears: 34,
        ageRecordedAt: now,
        sex: 'F',
        village: 'Village Test A',
        createdByAgentId: 'dev-agent',
        createdAt: now,
        updatedAt: now,
      ),
      PatientRecord(
        id: 'SUR-DEMO-0002',
        lastName: 'Démo',
        firstName: 'Ibrahim',
        ageYears: 7,
        ageRecordedAt: now,
        sex: 'M',
        village: 'Village Test B',
        createdByAgentId: 'dev-agent',
        createdAt: now,
        updatedAt: now,
      ),
    ]) {
      r._items[p.id] = p;
    }
    return r;
  }

  final Map<String, PatientRecord> _items = {};
  final _changes = _Changes();

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
    final p = PatientRecord(
      id: generatePatientId(),
      lastName: lastName,
      firstName: firstName,
      ageYears: ageYears,
      ageRecordedAt: now,
      sex: sex,
      village: village,
      phone: phone,
      createdByAgentId: agentId,
      createdAt: now,
      updatedAt: now,
    );
    _items[p.id] = p;
    _changes.notify();
    return p;
  }

  @override
  Future<PatientRecord?> getById(String id) async => _items[id];

  @override
  Future<bool> updateSyncState(
    String id,
    SyncState state, {
    required DateTime expectedUpdatedAt,
    int? attempts,
    String? error,
  }) async {
    final record = _items[id];
    if (record == null || record.updatedAt != expectedUpdatedAt) return false;
    _items[id] = record.copyWith(
      syncState: state,
      syncAttempts: attempts,
      syncError: error,
      clearSyncError: error == null,
    );
    _changes.notify();
    return true;
  }

  @override
  Stream<PatientRecord?> watchById(String id) =>
      _changes.watch(() => _items[id]);

  @override
  Stream<List<PatientRecord>> watchAll() => _changes.watch(_sorted);

  List<PatientRecord> _sorted() {
    final l = _items.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  }

  @override
  Future<List<PatientRecord>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _sorted();
    return _sorted()
        .where(
          (p) =>
              p.fullName.toLowerCase().contains(q) ||
              p.village.toLowerCase().contains(q) ||
              p.id.toLowerCase().contains(q),
        )
        .toList();
  }
}

class InMemoryConsultationRepository implements ConsultationRepository {
  final Map<String, ConsultationRecord> _items = {};
  final _changes = _Changes();

  @override
  Future<ConsultationRecord> createDraft({
    required String patientId,
    required String agentId,
  }) async {
    final now = DateTime.now();
    final c = ConsultationRecord(
      id: generateUid(),
      patientId: patientId,
      agentId: agentId,
      createdAt: now,
      updatedAt: now,
    );
    _items[c.id] = c;
    _changes.notify();
    return c;
  }

  @override
  Future<ConsultationRecord?> getById(String id) async => _items[id];

  @override
  Stream<ConsultationRecord?> watchById(String id) =>
      _changes.watch(() => _items[id]);

  @override
  Stream<List<ConsultationRecord>> watchByPatient(String patientId) => _changes
      .watch(() => _all().where((c) => c.patientId == patientId).toList());

  @override
  Stream<List<ConsultationRecord>> watchAll() => _changes.watch(_all);

  List<ConsultationRecord> _all() {
    final l = _items.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  }

  @override
  Future<void> save(ConsultationRecord record) async {
    _items[record.id] = record.status == ConsultationStatus.saved
        ? record.copyWith(
            syncState: SyncState.pending,
            clearSyncError: true,
            updatedAt: record.updatedAt,
          )
        : record;
    _changes.notify();
  }

  @override
  Future<bool> updateSyncState(
    String id,
    SyncState state, {
    required DateTime expectedUpdatedAt,
    int? attempts,
    String? error,
  }) async {
    final record = _items[id];
    if (record == null || record.updatedAt != expectedUpdatedAt) return false;
    _items[id] = record.copyWith(
      syncState: state,
      syncAttempts: attempts,
      syncError: error,
      clearSyncError: error == null,
      updatedAt: record.updatedAt,
    );
    _changes.notify();
    return true;
  }

  @override
  Future<void> markValidated(String id) async {
    final c = _items[id];
    if (c == null) return;
    final now = DateTime.now();
    _items[id] = c.copyWith(
      status: ConsultationStatus.saved,
      validatedAt: now,
      syncState: SyncState.pending,
      updatedAt: now,
    );
    _changes.notify();
  }
}

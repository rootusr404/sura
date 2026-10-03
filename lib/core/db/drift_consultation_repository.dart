import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:sura/core/db/app_database.dart';
import 'package:sura/core/utils/id_generator.dart';
import 'package:sura/domain/contracts/consultation_repository.dart';
import 'package:sura/domain/models/enums.dart';
import 'package:sura/domain/models/missing_item.dart';
import 'package:sura/domain/models/records.dart';
import 'package:sura/domain/models/structured_info.dart';
import 'package:sura/domain/models/urgency_proposal.dart';

/// Implémentation Drift du contrat ConsultationRepository (tâche F-02, partie consultations).
/// Réutilisable telle quelle dans le dépôt d'équipe : même schéma, même contrat.
class DriftConsultationRepository implements ConsultationRepository {
  DriftConsultationRepository(this._db);
  final AppDatabase _db;

  // Drift stocke les dates à la seconde : rowid départage les égalités.
  static final _newestFirst = <OrderingTerm Function($ConsultationsTable)>[
    (c) => OrderingTerm.desc(c.createdAt),
    (c) => OrderingTerm(
      expression: const CustomExpression<int>('rowid'),
      mode: OrderingMode.desc,
    ),
  ];

  SimpleSelectStatement<$ConsultationsTable, Consultation> _select() =>
      _db.select(_db.consultations);

  @override
  Future<ConsultationRecord> createDraft({
    required String patientId,
    required String agentId,
  }) async {
    final now = DateTime.now();
    final id = generateUid();
    await _db
        .into(_db.consultations)
        .insert(
          ConsultationsCompanion.insert(
            id: id,
            patientId: patientId,
            agentId: agentId,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await getById(id))!;
  }

  @override
  Future<ConsultationRecord?> getById(String id) async {
    final row = await (_select()..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Stream<ConsultationRecord?> watchById(String id) =>
      (_select()..where((c) => c.id.equals(id))).watchSingleOrNull().map(
        (r) => r == null ? null : _fromRow(r),
      );

  @override
  Stream<List<ConsultationRecord>> watchByPatient(String patientId) =>
      (_select()
            ..where((c) => c.patientId.equals(patientId))
            ..orderBy(_newestFirst))
          .watch()
          .map((l) => l.map(_fromRow).toList());

  @override
  Stream<List<ConsultationRecord>> watchAll() =>
      (_select()..orderBy(_newestFirst)).watch().map(
        (l) => l.map(_fromRow).toList(),
      );

  @override
  Future<void> save(ConsultationRecord r) =>
      _db.into(_db.consultations).insertOnConflictUpdate(_toCompanion(r));

  @override
  Future<void> markValidated(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.consultations)..where((c) => c.id.equals(id))).write(
      ConsultationsCompanion(
        status: Value(ConsultationStatus.saved.name),
        currentStep: const Value('saved'),
        validatedAt: Value(now),
        syncStatus: Value(SyncState.pending.db),
        updatedAt: Value(now),
      ),
    );
  }

  // ---------------- mapping ----------------

  static T? _enum<T extends Enum>(List<T> values, String? name) {
    for (final e in values) {
      if (e.name == name) return e;
    }
    return null;
  }

  static ConsultationsCompanion _toCompanion(ConsultationRecord r) {
    final overrideReason = r.urgencyOverrideReason;
    return ConsultationsCompanion(
      id: Value(r.id),
      patientId: Value(r.patientId),
      agentId: Value(r.agentId),
      status: Value(r.status.name),
      currentStep: Value(r.step),
      consentStatus: Value(r.consent?.name),
      consentAt: Value(r.consentAt),
      transcriptRaw: Value(r.transcriptRaw),
      transcriptEdited: Value(r.transcriptEdited),
      structuredJson: Value(
        r.structured == null ? null : jsonEncode(r.structured!.toJson()),
      ),
      missingJson: Value(jsonEncode(r.missing.map((m) => m.toJson()).toList())),
      urgencyProposed: Value(r.urgencyProposal?.level.name),
      urgencyReasonsJson: Value(
        r.urgencyProposal == null
            ? null
            : jsonEncode(r.urgencyProposal!.reasons),
      ),
      urgencyFinal: Value(r.urgencyFinal?.name),
      urgencyOverrideReason: Value(
        overrideReason == null || overrideReason.isEmpty
            ? null
            : overrideReason,
      ),
      checklistJson: Value(jsonEncode(r.checklist)),
      syncStatus: Value(r.syncState.db),
      syncAttempts: Value(r.syncAttempts),
      syncError: Value(r.syncError),
      createdAt: Value(r.createdAt),
      updatedAt: Value(r.updatedAt),
      validatedAt: Value(r.validatedAt),
    );
  }

  static ConsultationRecord _fromRow(Consultation c) {
    final level = _enum(UrgencyLevel.values, c.urgencyProposed);
    return ConsultationRecord(
      id: c.id,
      patientId: c.patientId,
      agentId: c.agentId,
      status:
          _enum(ConsultationStatus.values, c.status) ??
          ConsultationStatus.draft,
      step: c.currentStep,
      consent: _enum(ConsentStatus.values, c.consentStatus),
      consentAt: c.consentAt,
      transcriptRaw: c.transcriptRaw,
      transcriptEdited: c.transcriptEdited,
      structured: c.structuredJson == null
          ? null
          : StructuredInfo.fromJson(
              jsonDecode(c.structuredJson!) as Map<String, dynamic>,
            ),
      missing: c.missingJson == null
          ? const []
          : (jsonDecode(c.missingJson!) as List)
                .map((e) => MissingItem.fromJson(e as Map<String, dynamic>))
                .toList(),
      urgencyProposal: level == null
          ? null
          : UrgencyProposal(
              level: level,
              reasons: c.urgencyReasonsJson == null
                  ? const []
                  : (jsonDecode(c.urgencyReasonsJson!) as List).cast<String>(),
            ),
      urgencyFinal: _enum(UrgencyLevel.values, c.urgencyFinal),
      urgencyOverrideReason: c.urgencyOverrideReason,
      checklist: c.checklistJson == null
          ? const {}
          : (jsonDecode(c.checklistJson!) as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v as bool),
            ),
      syncState: SyncStateX.fromDb(c.syncStatus),
      syncAttempts: c.syncAttempts,
      syncError: c.syncError,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      validatedAt: c.validatedAt,
    );
  }
}

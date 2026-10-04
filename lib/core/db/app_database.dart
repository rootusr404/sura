import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Profil de l'agent de santé (un seul par appareil en pratique).
class Agents extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get healthPost => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get agentCode => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Patients extends Table {
  /// Format SUR-XXXX-XXXX
  TextColumn get id => text()();
  TextColumn get lastName => text()();
  TextColumn get firstName => text()();
  IntColumn get ageYears => integer()();
  DateTimeColumn get ageRecordedAt => dateTime()();
  TextColumn get sex => text()(); // 'F' | 'M'
  TextColumn get village => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get createdByAgentId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Une consultation. Les blocs structurés sont stockés en JSON pour garder
/// le schéma stable pendant le développement rapide du MVP.
class Consultations extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get agentId => text()();

  /// 'draft' | 'saved'
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get currentStep => text().withDefault(const Constant('consent'))();

  /// 'granted' | 'refused'
  TextColumn get consentStatus => text().nullable()();
  DateTimeColumn get consentAt => dateTime().nullable()();

  TextColumn get transcriptRaw => text().nullable()();
  TextColumn get transcriptEdited => text().nullable()();
  TextColumn get structuredJson => text().nullable()();
  TextColumn get missingJson => text().nullable()();

  /// 'high' | 'moderate' | 'low'
  TextColumn get urgencyProposed => text().nullable()();
  TextColumn get urgencyReasonsJson => text().nullable()();
  TextColumn get urgencyFinal => text().nullable()();
  TextColumn get urgencyOverrideReason => text().nullable()();
  TextColumn get checklistJson => text().nullable()();

  /// 'pending' | 'syncing' | 'synced' | 'error'
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();
  TextColumn get syncError => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get validatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Agents, Patients, Consultations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'sura'));

  /// Pour les tests (base en mémoire).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(patients, patients.syncAttempts);
        await m.addColumn(patients, patients.syncError);
      }
    },
  );
}

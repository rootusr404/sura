import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Source de verite locale (decision : Drift). Les colonnes syncStatus/retryCount/lastError
/// font office d'outbox : pending -> syncing -> synced | error.
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get familyName => text()();
  TextColumn get firstName => text()();
  IntColumn get ageYears => integer()();
  DateTimeColumn get ageRecordedAt => dateTime()();
  TextColumn get sex => text()();
  TextColumn get village => text().withDefault(const Constant(''))();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Consultations extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get agentId => text()();
  TextColumn get mode =>
      text().withDefault(const Constant('voice'))(); // voice | manual
  TextColumn get stage => text().withDefault(const Constant('consent'))();
  TextColumn get consent => text().nullable()(); // granted | refused
  DateTimeColumn get consentAt => dateTime().nullable()();
  TextColumn get transcript => text().nullable()();
  TextColumn get structuredJson => text().withDefault(const Constant('{}'))();
  TextColumn get missingJson => text().withDefault(const Constant('[]'))();
  IntColumn get urgencyProposed => integer().nullable()(); // index de Urgency
  IntColumn get urgencyFinal => integer().nullable()();
  TextColumn get reasonsJson => text().withDefault(const Constant('[]'))();
  TextColumn get status =>
      text().withDefault(const Constant('draft'))(); // draft | saved
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get validatedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Patients, Consultations])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'sura'));

  @override
  int get schemaVersion => 1;

  // CHIFFREMENT (AES-256, decision d'equipe) : a activer en J3-J4 avec sqlcipher_flutter_libs.
  // Remplacer l'executeur par defaut par un executeur SQLCipher ouvert avec une cle stockee dans
  // flutter_secure_storage (voir la documentation Drift "Encryption"). A tester sur telephone reel.
}

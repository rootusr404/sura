// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _familyNameMeta =
      const VerificationMeta('familyName');
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
      'family_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageYearsMeta =
      const VerificationMeta('ageYears');
  @override
  late final GeneratedColumn<int> ageYears = GeneratedColumn<int>(
      'age_years', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ageRecordedAtMeta =
      const VerificationMeta('ageRecordedAt');
  @override
  late final GeneratedColumn<DateTime> ageRecordedAt =
      GeneratedColumn<DateTime>('age_recorded_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _villageMeta =
      const VerificationMeta('village');
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
      'village', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        familyName,
        firstName,
        ageYears,
        ageRecordedAt,
        sex,
        village,
        createdBy,
        createdAt,
        syncStatus,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(Insertable<Patient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_name')) {
      context.handle(
          _familyNameMeta,
          familyName.isAcceptableOrUnknown(
              data['family_name']!, _familyNameMeta));
    } else if (isInserting) {
      context.missing(_familyNameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('age_years')) {
      context.handle(_ageYearsMeta,
          ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta));
    } else if (isInserting) {
      context.missing(_ageYearsMeta);
    }
    if (data.containsKey('age_recorded_at')) {
      context.handle(
          _ageRecordedAtMeta,
          ageRecordedAt.isAcceptableOrUnknown(
              data['age_recorded_at']!, _ageRecordedAtMeta));
    } else if (isInserting) {
      context.missing(_ageRecordedAtMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('village')) {
      context.handle(_villageMeta,
          village.isAcceptableOrUnknown(data['village']!, _villageMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      familyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family_name'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      ageYears: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age_years'])!,
      ageRecordedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}age_recorded_at'])!,
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
      village: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}village'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final String id;
  final String familyName;
  final String firstName;
  final int ageYears;
  final DateTime ageRecordedAt;
  final String sex;
  final String village;
  final String createdBy;
  final DateTime createdAt;
  final String syncStatus;
  final int retryCount;
  final String? lastError;
  const Patient(
      {required this.id,
      required this.familyName,
      required this.firstName,
      required this.ageYears,
      required this.ageRecordedAt,
      required this.sex,
      required this.village,
      required this.createdBy,
      required this.createdAt,
      required this.syncStatus,
      required this.retryCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_name'] = Variable<String>(familyName);
    map['first_name'] = Variable<String>(firstName);
    map['age_years'] = Variable<int>(ageYears);
    map['age_recorded_at'] = Variable<DateTime>(ageRecordedAt);
    map['sex'] = Variable<String>(sex);
    map['village'] = Variable<String>(village);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      familyName: Value(familyName),
      firstName: Value(firstName),
      ageYears: Value(ageYears),
      ageRecordedAt: Value(ageRecordedAt),
      sex: Value(sex),
      village: Value(village),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      familyName: serializer.fromJson<String>(json['familyName']),
      firstName: serializer.fromJson<String>(json['firstName']),
      ageYears: serializer.fromJson<int>(json['ageYears']),
      ageRecordedAt: serializer.fromJson<DateTime>(json['ageRecordedAt']),
      sex: serializer.fromJson<String>(json['sex']),
      village: serializer.fromJson<String>(json['village']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyName': serializer.toJson<String>(familyName),
      'firstName': serializer.toJson<String>(firstName),
      'ageYears': serializer.toJson<int>(ageYears),
      'ageRecordedAt': serializer.toJson<DateTime>(ageRecordedAt),
      'sex': serializer.toJson<String>(sex),
      'village': serializer.toJson<String>(village),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  Patient copyWith(
          {String? id,
          String? familyName,
          String? firstName,
          int? ageYears,
          DateTime? ageRecordedAt,
          String? sex,
          String? village,
          String? createdBy,
          DateTime? createdAt,
          String? syncStatus,
          int? retryCount,
          Value<String?> lastError = const Value.absent()}) =>
      Patient(
        id: id ?? this.id,
        familyName: familyName ?? this.familyName,
        firstName: firstName ?? this.firstName,
        ageYears: ageYears ?? this.ageYears,
        ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
        sex: sex ?? this.sex,
        village: village ?? this.village,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      familyName:
          data.familyName.present ? data.familyName.value : this.familyName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      ageRecordedAt: data.ageRecordedAt.present
          ? data.ageRecordedAt.value
          : this.ageRecordedAt,
      sex: data.sex.present ? data.sex.value : this.sex,
      village: data.village.present ? data.village.value : this.village,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('familyName: $familyName, ')
          ..write('firstName: $firstName, ')
          ..write('ageYears: $ageYears, ')
          ..write('ageRecordedAt: $ageRecordedAt, ')
          ..write('sex: $sex, ')
          ..write('village: $village, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      familyName,
      firstName,
      ageYears,
      ageRecordedAt,
      sex,
      village,
      createdBy,
      createdAt,
      syncStatus,
      retryCount,
      lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.familyName == this.familyName &&
          other.firstName == this.firstName &&
          other.ageYears == this.ageYears &&
          other.ageRecordedAt == this.ageRecordedAt &&
          other.sex == this.sex &&
          other.village == this.village &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String> familyName;
  final Value<String> firstName;
  final Value<int> ageYears;
  final Value<DateTime> ageRecordedAt;
  final Value<String> sex;
  final Value<String> village;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.familyName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.ageRecordedAt = const Value.absent(),
    this.sex = const Value.absent(),
    this.village = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String familyName,
    required String firstName,
    required int ageYears,
    required DateTime ageRecordedAt,
    required String sex,
    this.village = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        familyName = Value(familyName),
        firstName = Value(firstName),
        ageYears = Value(ageYears),
        ageRecordedAt = Value(ageRecordedAt),
        sex = Value(sex),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? familyName,
    Expression<String>? firstName,
    Expression<int>? ageYears,
    Expression<DateTime>? ageRecordedAt,
    Expression<String>? sex,
    Expression<String>? village,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyName != null) 'family_name': familyName,
      if (firstName != null) 'first_name': firstName,
      if (ageYears != null) 'age_years': ageYears,
      if (ageRecordedAt != null) 'age_recorded_at': ageRecordedAt,
      if (sex != null) 'sex': sex,
      if (village != null) 'village': village,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? familyName,
      Value<String>? firstName,
      Value<int>? ageYears,
      Value<DateTime>? ageRecordedAt,
      Value<String>? sex,
      Value<String>? village,
      Value<String>? createdBy,
      Value<DateTime>? createdAt,
      Value<String>? syncStatus,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return PatientsCompanion(
      id: id ?? this.id,
      familyName: familyName ?? this.familyName,
      firstName: firstName ?? this.firstName,
      ageYears: ageYears ?? this.ageYears,
      ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
      sex: sex ?? this.sex,
      village: village ?? this.village,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyName.present) {
      map['family_name'] = Variable<String>(familyName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (ageYears.present) {
      map['age_years'] = Variable<int>(ageYears.value);
    }
    if (ageRecordedAt.present) {
      map['age_recorded_at'] = Variable<DateTime>(ageRecordedAt.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('familyName: $familyName, ')
          ..write('firstName: $firstName, ')
          ..write('ageYears: $ageYears, ')
          ..write('ageRecordedAt: $ageRecordedAt, ')
          ..write('sex: $sex, ')
          ..write('village: $village, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsultationsTable extends Consultations
    with TableInfo<$ConsultationsTable, Consultation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsultationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _agentIdMeta =
      const VerificationMeta('agentId');
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
      'agent_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('voice'));
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
      'stage', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('consent'));
  static const VerificationMeta _consentMeta =
      const VerificationMeta('consent');
  @override
  late final GeneratedColumn<String> consent = GeneratedColumn<String>(
      'consent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _consentAtMeta =
      const VerificationMeta('consentAt');
  @override
  late final GeneratedColumn<DateTime> consentAt = GeneratedColumn<DateTime>(
      'consent_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _transcriptMeta =
      const VerificationMeta('transcript');
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
      'transcript', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _structuredJsonMeta =
      const VerificationMeta('structuredJson');
  @override
  late final GeneratedColumn<String> structuredJson = GeneratedColumn<String>(
      'structured_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _missingJsonMeta =
      const VerificationMeta('missingJson');
  @override
  late final GeneratedColumn<String> missingJson = GeneratedColumn<String>(
      'missing_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _urgencyProposedMeta =
      const VerificationMeta('urgencyProposed');
  @override
  late final GeneratedColumn<int> urgencyProposed = GeneratedColumn<int>(
      'urgency_proposed', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _urgencyFinalMeta =
      const VerificationMeta('urgencyFinal');
  @override
  late final GeneratedColumn<int> urgencyFinal = GeneratedColumn<int>(
      'urgency_final', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _reasonsJsonMeta =
      const VerificationMeta('reasonsJson');
  @override
  late final GeneratedColumn<String> reasonsJson = GeneratedColumn<String>(
      'reasons_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _validatedAtMeta =
      const VerificationMeta('validatedAt');
  @override
  late final GeneratedColumn<DateTime> validatedAt = GeneratedColumn<DateTime>(
      'validated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        patientId,
        agentId,
        mode,
        stage,
        consent,
        consentAt,
        transcript,
        structuredJson,
        missingJson,
        urgencyProposed,
        urgencyFinal,
        reasonsJson,
        status,
        createdAt,
        validatedAt,
        syncStatus,
        retryCount,
        lastError,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consultations';
  @override
  VerificationContext validateIntegrity(Insertable<Consultation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('agent_id')) {
      context.handle(_agentIdMeta,
          agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta));
    } else if (isInserting) {
      context.missing(_agentIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    }
    if (data.containsKey('stage')) {
      context.handle(
          _stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    }
    if (data.containsKey('consent')) {
      context.handle(_consentMeta,
          consent.isAcceptableOrUnknown(data['consent']!, _consentMeta));
    }
    if (data.containsKey('consent_at')) {
      context.handle(_consentAtMeta,
          consentAt.isAcceptableOrUnknown(data['consent_at']!, _consentAtMeta));
    }
    if (data.containsKey('transcript')) {
      context.handle(
          _transcriptMeta,
          transcript.isAcceptableOrUnknown(
              data['transcript']!, _transcriptMeta));
    }
    if (data.containsKey('structured_json')) {
      context.handle(
          _structuredJsonMeta,
          structuredJson.isAcceptableOrUnknown(
              data['structured_json']!, _structuredJsonMeta));
    }
    if (data.containsKey('missing_json')) {
      context.handle(
          _missingJsonMeta,
          missingJson.isAcceptableOrUnknown(
              data['missing_json']!, _missingJsonMeta));
    }
    if (data.containsKey('urgency_proposed')) {
      context.handle(
          _urgencyProposedMeta,
          urgencyProposed.isAcceptableOrUnknown(
              data['urgency_proposed']!, _urgencyProposedMeta));
    }
    if (data.containsKey('urgency_final')) {
      context.handle(
          _urgencyFinalMeta,
          urgencyFinal.isAcceptableOrUnknown(
              data['urgency_final']!, _urgencyFinalMeta));
    }
    if (data.containsKey('reasons_json')) {
      context.handle(
          _reasonsJsonMeta,
          reasonsJson.isAcceptableOrUnknown(
              data['reasons_json']!, _reasonsJsonMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('validated_at')) {
      context.handle(
          _validatedAtMeta,
          validatedAt.isAcceptableOrUnknown(
              data['validated_at']!, _validatedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Consultation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Consultation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      agentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_id'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      stage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stage'])!,
      consent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}consent']),
      consentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}consent_at']),
      transcript: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transcript']),
      structuredJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}structured_json'])!,
      missingJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}missing_json'])!,
      urgencyProposed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}urgency_proposed']),
      urgencyFinal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}urgency_final']),
      reasonsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reasons_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      validatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}validated_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $ConsultationsTable createAlias(String alias) {
    return $ConsultationsTable(attachedDatabase, alias);
  }
}

class Consultation extends DataClass implements Insertable<Consultation> {
  final String id;
  final String patientId;
  final String agentId;
  final String mode;
  final String stage;
  final String? consent;
  final DateTime? consentAt;
  final String? transcript;
  final String structuredJson;
  final String missingJson;
  final int? urgencyProposed;
  final int? urgencyFinal;
  final String reasonsJson;
  final String status;
  final DateTime createdAt;
  final DateTime? validatedAt;
  final String syncStatus;
  final int retryCount;
  final String? lastError;
  final DateTime? syncedAt;
  const Consultation(
      {required this.id,
      required this.patientId,
      required this.agentId,
      required this.mode,
      required this.stage,
      this.consent,
      this.consentAt,
      this.transcript,
      required this.structuredJson,
      required this.missingJson,
      this.urgencyProposed,
      this.urgencyFinal,
      required this.reasonsJson,
      required this.status,
      required this.createdAt,
      this.validatedAt,
      required this.syncStatus,
      required this.retryCount,
      this.lastError,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['agent_id'] = Variable<String>(agentId);
    map['mode'] = Variable<String>(mode);
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || consent != null) {
      map['consent'] = Variable<String>(consent);
    }
    if (!nullToAbsent || consentAt != null) {
      map['consent_at'] = Variable<DateTime>(consentAt);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    map['structured_json'] = Variable<String>(structuredJson);
    map['missing_json'] = Variable<String>(missingJson);
    if (!nullToAbsent || urgencyProposed != null) {
      map['urgency_proposed'] = Variable<int>(urgencyProposed);
    }
    if (!nullToAbsent || urgencyFinal != null) {
      map['urgency_final'] = Variable<int>(urgencyFinal);
    }
    map['reasons_json'] = Variable<String>(reasonsJson);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || validatedAt != null) {
      map['validated_at'] = Variable<DateTime>(validatedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ConsultationsCompanion toCompanion(bool nullToAbsent) {
    return ConsultationsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      agentId: Value(agentId),
      mode: Value(mode),
      stage: Value(stage),
      consent: consent == null && nullToAbsent
          ? const Value.absent()
          : Value(consent),
      consentAt: consentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(consentAt),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      structuredJson: Value(structuredJson),
      missingJson: Value(missingJson),
      urgencyProposed: urgencyProposed == null && nullToAbsent
          ? const Value.absent()
          : Value(urgencyProposed),
      urgencyFinal: urgencyFinal == null && nullToAbsent
          ? const Value.absent()
          : Value(urgencyFinal),
      reasonsJson: Value(reasonsJson),
      status: Value(status),
      createdAt: Value(createdAt),
      validatedAt: validatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(validatedAt),
      syncStatus: Value(syncStatus),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory Consultation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Consultation(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      agentId: serializer.fromJson<String>(json['agentId']),
      mode: serializer.fromJson<String>(json['mode']),
      stage: serializer.fromJson<String>(json['stage']),
      consent: serializer.fromJson<String?>(json['consent']),
      consentAt: serializer.fromJson<DateTime?>(json['consentAt']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      structuredJson: serializer.fromJson<String>(json['structuredJson']),
      missingJson: serializer.fromJson<String>(json['missingJson']),
      urgencyProposed: serializer.fromJson<int?>(json['urgencyProposed']),
      urgencyFinal: serializer.fromJson<int?>(json['urgencyFinal']),
      reasonsJson: serializer.fromJson<String>(json['reasonsJson']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      validatedAt: serializer.fromJson<DateTime?>(json['validatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'agentId': serializer.toJson<String>(agentId),
      'mode': serializer.toJson<String>(mode),
      'stage': serializer.toJson<String>(stage),
      'consent': serializer.toJson<String?>(consent),
      'consentAt': serializer.toJson<DateTime?>(consentAt),
      'transcript': serializer.toJson<String?>(transcript),
      'structuredJson': serializer.toJson<String>(structuredJson),
      'missingJson': serializer.toJson<String>(missingJson),
      'urgencyProposed': serializer.toJson<int?>(urgencyProposed),
      'urgencyFinal': serializer.toJson<int?>(urgencyFinal),
      'reasonsJson': serializer.toJson<String>(reasonsJson),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'validatedAt': serializer.toJson<DateTime?>(validatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  Consultation copyWith(
          {String? id,
          String? patientId,
          String? agentId,
          String? mode,
          String? stage,
          Value<String?> consent = const Value.absent(),
          Value<DateTime?> consentAt = const Value.absent(),
          Value<String?> transcript = const Value.absent(),
          String? structuredJson,
          String? missingJson,
          Value<int?> urgencyProposed = const Value.absent(),
          Value<int?> urgencyFinal = const Value.absent(),
          String? reasonsJson,
          String? status,
          DateTime? createdAt,
          Value<DateTime?> validatedAt = const Value.absent(),
          String? syncStatus,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      Consultation(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        agentId: agentId ?? this.agentId,
        mode: mode ?? this.mode,
        stage: stage ?? this.stage,
        consent: consent.present ? consent.value : this.consent,
        consentAt: consentAt.present ? consentAt.value : this.consentAt,
        transcript: transcript.present ? transcript.value : this.transcript,
        structuredJson: structuredJson ?? this.structuredJson,
        missingJson: missingJson ?? this.missingJson,
        urgencyProposed: urgencyProposed.present
            ? urgencyProposed.value
            : this.urgencyProposed,
        urgencyFinal:
            urgencyFinal.present ? urgencyFinal.value : this.urgencyFinal,
        reasonsJson: reasonsJson ?? this.reasonsJson,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        validatedAt: validatedAt.present ? validatedAt.value : this.validatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  Consultation copyWithCompanion(ConsultationsCompanion data) {
    return Consultation(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      mode: data.mode.present ? data.mode.value : this.mode,
      stage: data.stage.present ? data.stage.value : this.stage,
      consent: data.consent.present ? data.consent.value : this.consent,
      consentAt: data.consentAt.present ? data.consentAt.value : this.consentAt,
      transcript:
          data.transcript.present ? data.transcript.value : this.transcript,
      structuredJson: data.structuredJson.present
          ? data.structuredJson.value
          : this.structuredJson,
      missingJson:
          data.missingJson.present ? data.missingJson.value : this.missingJson,
      urgencyProposed: data.urgencyProposed.present
          ? data.urgencyProposed.value
          : this.urgencyProposed,
      urgencyFinal: data.urgencyFinal.present
          ? data.urgencyFinal.value
          : this.urgencyFinal,
      reasonsJson:
          data.reasonsJson.present ? data.reasonsJson.value : this.reasonsJson,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      validatedAt:
          data.validatedAt.present ? data.validatedAt.value : this.validatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Consultation(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('agentId: $agentId, ')
          ..write('mode: $mode, ')
          ..write('stage: $stage, ')
          ..write('consent: $consent, ')
          ..write('consentAt: $consentAt, ')
          ..write('transcript: $transcript, ')
          ..write('structuredJson: $structuredJson, ')
          ..write('missingJson: $missingJson, ')
          ..write('urgencyProposed: $urgencyProposed, ')
          ..write('urgencyFinal: $urgencyFinal, ')
          ..write('reasonsJson: $reasonsJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('validatedAt: $validatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      patientId,
      agentId,
      mode,
      stage,
      consent,
      consentAt,
      transcript,
      structuredJson,
      missingJson,
      urgencyProposed,
      urgencyFinal,
      reasonsJson,
      status,
      createdAt,
      validatedAt,
      syncStatus,
      retryCount,
      lastError,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Consultation &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.agentId == this.agentId &&
          other.mode == this.mode &&
          other.stage == this.stage &&
          other.consent == this.consent &&
          other.consentAt == this.consentAt &&
          other.transcript == this.transcript &&
          other.structuredJson == this.structuredJson &&
          other.missingJson == this.missingJson &&
          other.urgencyProposed == this.urgencyProposed &&
          other.urgencyFinal == this.urgencyFinal &&
          other.reasonsJson == this.reasonsJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.validatedAt == this.validatedAt &&
          other.syncStatus == this.syncStatus &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.syncedAt == this.syncedAt);
}

class ConsultationsCompanion extends UpdateCompanion<Consultation> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> agentId;
  final Value<String> mode;
  final Value<String> stage;
  final Value<String?> consent;
  final Value<DateTime?> consentAt;
  final Value<String?> transcript;
  final Value<String> structuredJson;
  final Value<String> missingJson;
  final Value<int?> urgencyProposed;
  final Value<int?> urgencyFinal;
  final Value<String> reasonsJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> validatedAt;
  final Value<String> syncStatus;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ConsultationsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.agentId = const Value.absent(),
    this.mode = const Value.absent(),
    this.stage = const Value.absent(),
    this.consent = const Value.absent(),
    this.consentAt = const Value.absent(),
    this.transcript = const Value.absent(),
    this.structuredJson = const Value.absent(),
    this.missingJson = const Value.absent(),
    this.urgencyProposed = const Value.absent(),
    this.urgencyFinal = const Value.absent(),
    this.reasonsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.validatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsultationsCompanion.insert({
    required String id,
    required String patientId,
    required String agentId,
    this.mode = const Value.absent(),
    this.stage = const Value.absent(),
    this.consent = const Value.absent(),
    this.consentAt = const Value.absent(),
    this.transcript = const Value.absent(),
    this.structuredJson = const Value.absent(),
    this.missingJson = const Value.absent(),
    this.urgencyProposed = const Value.absent(),
    this.urgencyFinal = const Value.absent(),
    this.reasonsJson = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.validatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        patientId = Value(patientId),
        agentId = Value(agentId),
        createdAt = Value(createdAt);
  static Insertable<Consultation> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? agentId,
    Expression<String>? mode,
    Expression<String>? stage,
    Expression<String>? consent,
    Expression<DateTime>? consentAt,
    Expression<String>? transcript,
    Expression<String>? structuredJson,
    Expression<String>? missingJson,
    Expression<int>? urgencyProposed,
    Expression<int>? urgencyFinal,
    Expression<String>? reasonsJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? validatedAt,
    Expression<String>? syncStatus,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (agentId != null) 'agent_id': agentId,
      if (mode != null) 'mode': mode,
      if (stage != null) 'stage': stage,
      if (consent != null) 'consent': consent,
      if (consentAt != null) 'consent_at': consentAt,
      if (transcript != null) 'transcript': transcript,
      if (structuredJson != null) 'structured_json': structuredJson,
      if (missingJson != null) 'missing_json': missingJson,
      if (urgencyProposed != null) 'urgency_proposed': urgencyProposed,
      if (urgencyFinal != null) 'urgency_final': urgencyFinal,
      if (reasonsJson != null) 'reasons_json': reasonsJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (validatedAt != null) 'validated_at': validatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsultationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? patientId,
      Value<String>? agentId,
      Value<String>? mode,
      Value<String>? stage,
      Value<String?>? consent,
      Value<DateTime?>? consentAt,
      Value<String?>? transcript,
      Value<String>? structuredJson,
      Value<String>? missingJson,
      Value<int?>? urgencyProposed,
      Value<int?>? urgencyFinal,
      Value<String>? reasonsJson,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime?>? validatedAt,
      Value<String>? syncStatus,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<DateTime?>? syncedAt,
      Value<int>? rowid}) {
    return ConsultationsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      agentId: agentId ?? this.agentId,
      mode: mode ?? this.mode,
      stage: stage ?? this.stage,
      consent: consent ?? this.consent,
      consentAt: consentAt ?? this.consentAt,
      transcript: transcript ?? this.transcript,
      structuredJson: structuredJson ?? this.structuredJson,
      missingJson: missingJson ?? this.missingJson,
      urgencyProposed: urgencyProposed ?? this.urgencyProposed,
      urgencyFinal: urgencyFinal ?? this.urgencyFinal,
      reasonsJson: reasonsJson ?? this.reasonsJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      validatedAt: validatedAt ?? this.validatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (consent.present) {
      map['consent'] = Variable<String>(consent.value);
    }
    if (consentAt.present) {
      map['consent_at'] = Variable<DateTime>(consentAt.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (structuredJson.present) {
      map['structured_json'] = Variable<String>(structuredJson.value);
    }
    if (missingJson.present) {
      map['missing_json'] = Variable<String>(missingJson.value);
    }
    if (urgencyProposed.present) {
      map['urgency_proposed'] = Variable<int>(urgencyProposed.value);
    }
    if (urgencyFinal.present) {
      map['urgency_final'] = Variable<int>(urgencyFinal.value);
    }
    if (reasonsJson.present) {
      map['reasons_json'] = Variable<String>(reasonsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (validatedAt.present) {
      map['validated_at'] = Variable<DateTime>(validatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsultationsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('agentId: $agentId, ')
          ..write('mode: $mode, ')
          ..write('stage: $stage, ')
          ..write('consent: $consent, ')
          ..write('consentAt: $consentAt, ')
          ..write('transcript: $transcript, ')
          ..write('structuredJson: $structuredJson, ')
          ..write('missingJson: $missingJson, ')
          ..write('urgencyProposed: $urgencyProposed, ')
          ..write('urgencyFinal: $urgencyFinal, ')
          ..write('reasonsJson: $reasonsJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('validatedAt: $validatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $ConsultationsTable consultations = $ConsultationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [patients, consultations];
}

typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  required String familyName,
  required String firstName,
  required int ageYears,
  required DateTime ageRecordedAt,
  required String sex,
  Value<String> village,
  required String createdBy,
  required DateTime createdAt,
  Value<String> syncStatus,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<String> familyName,
  Value<String> firstName,
  Value<int> ageYears,
  Value<DateTime> ageRecordedAt,
  Value<String> sex,
  Value<String> village,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ageYears => $composableBuilder(
      column: $table.ageYears, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get ageRecordedAt => $composableBuilder(
      column: $table.ageRecordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get village => $composableBuilder(
      column: $table.village, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ageYears => $composableBuilder(
      column: $table.ageYears, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get ageRecordedAt => $composableBuilder(
      column: $table.ageRecordedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get village => $composableBuilder(
      column: $table.village, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<int> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<DateTime> get ageRecordedAt => $composableBuilder(
      column: $table.ageRecordedAt, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PatientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatientsTable,
    Patient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (Patient, BaseReferences<_$AppDatabase, $PatientsTable, Patient>),
    Patient,
    PrefetchHooks Function()> {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> familyName = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<int> ageYears = const Value.absent(),
            Value<DateTime> ageRecordedAt = const Value.absent(),
            Value<String> sex = const Value.absent(),
            Value<String> village = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion(
            id: id,
            familyName: familyName,
            firstName: firstName,
            ageYears: ageYears,
            ageRecordedAt: ageRecordedAt,
            sex: sex,
            village: village,
            createdBy: createdBy,
            createdAt: createdAt,
            syncStatus: syncStatus,
            retryCount: retryCount,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String familyName,
            required String firstName,
            required int ageYears,
            required DateTime ageRecordedAt,
            required String sex,
            Value<String> village = const Value.absent(),
            required String createdBy,
            required DateTime createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion.insert(
            id: id,
            familyName: familyName,
            firstName: firstName,
            ageYears: ageYears,
            ageRecordedAt: ageRecordedAt,
            sex: sex,
            village: village,
            createdBy: createdBy,
            createdAt: createdAt,
            syncStatus: syncStatus,
            retryCount: retryCount,
            lastError: lastError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PatientsTable, Patient>(table),
                    BaseReferences<_$AppDatabase, $PatientsTable, Patient>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PatientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatientsTable,
    Patient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (Patient, BaseReferences<_$AppDatabase, $PatientsTable, Patient>),
    Patient,
    PrefetchHooks Function()>;
typedef $$ConsultationsTableCreateCompanionBuilder = ConsultationsCompanion
    Function({
  required String id,
  required String patientId,
  required String agentId,
  Value<String> mode,
  Value<String> stage,
  Value<String?> consent,
  Value<DateTime?> consentAt,
  Value<String?> transcript,
  Value<String> structuredJson,
  Value<String> missingJson,
  Value<int?> urgencyProposed,
  Value<int?> urgencyFinal,
  Value<String> reasonsJson,
  Value<String> status,
  required DateTime createdAt,
  Value<DateTime?> validatedAt,
  Value<String> syncStatus,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$ConsultationsTableUpdateCompanionBuilder = ConsultationsCompanion
    Function({
  Value<String> id,
  Value<String> patientId,
  Value<String> agentId,
  Value<String> mode,
  Value<String> stage,
  Value<String?> consent,
  Value<DateTime?> consentAt,
  Value<String?> transcript,
  Value<String> structuredJson,
  Value<String> missingJson,
  Value<int?> urgencyProposed,
  Value<int?> urgencyFinal,
  Value<String> reasonsJson,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime?> validatedAt,
  Value<String> syncStatus,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$ConsultationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConsultationsTable> {
  $$ConsultationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get consent => $composableBuilder(
      column: $table.consent, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get consentAt => $composableBuilder(
      column: $table.consentAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get structuredJson => $composableBuilder(
      column: $table.structuredJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get missingJson => $composableBuilder(
      column: $table.missingJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get urgencyProposed => $composableBuilder(
      column: $table.urgencyProposed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get urgencyFinal => $composableBuilder(
      column: $table.urgencyFinal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reasonsJson => $composableBuilder(
      column: $table.reasonsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get validatedAt => $composableBuilder(
      column: $table.validatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$ConsultationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsultationsTable> {
  $$ConsultationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get consent => $composableBuilder(
      column: $table.consent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get consentAt => $composableBuilder(
      column: $table.consentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get structuredJson => $composableBuilder(
      column: $table.structuredJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get missingJson => $composableBuilder(
      column: $table.missingJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get urgencyProposed => $composableBuilder(
      column: $table.urgencyProposed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get urgencyFinal => $composableBuilder(
      column: $table.urgencyFinal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reasonsJson => $composableBuilder(
      column: $table.reasonsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get validatedAt => $composableBuilder(
      column: $table.validatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$ConsultationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsultationsTable> {
  $$ConsultationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get consent =>
      $composableBuilder(column: $table.consent, builder: (column) => column);

  GeneratedColumn<DateTime> get consentAt =>
      $composableBuilder(column: $table.consentAt, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => column);

  GeneratedColumn<String> get structuredJson => $composableBuilder(
      column: $table.structuredJson, builder: (column) => column);

  GeneratedColumn<String> get missingJson => $composableBuilder(
      column: $table.missingJson, builder: (column) => column);

  GeneratedColumn<int> get urgencyProposed => $composableBuilder(
      column: $table.urgencyProposed, builder: (column) => column);

  GeneratedColumn<int> get urgencyFinal => $composableBuilder(
      column: $table.urgencyFinal, builder: (column) => column);

  GeneratedColumn<String> get reasonsJson => $composableBuilder(
      column: $table.reasonsJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get validatedAt => $composableBuilder(
      column: $table.validatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ConsultationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConsultationsTable,
    Consultation,
    $$ConsultationsTableFilterComposer,
    $$ConsultationsTableOrderingComposer,
    $$ConsultationsTableAnnotationComposer,
    $$ConsultationsTableCreateCompanionBuilder,
    $$ConsultationsTableUpdateCompanionBuilder,
    (
      Consultation,
      BaseReferences<_$AppDatabase, $ConsultationsTable, Consultation>
    ),
    Consultation,
    PrefetchHooks Function()> {
  $$ConsultationsTableTableManager(_$AppDatabase db, $ConsultationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsultationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsultationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsultationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> agentId = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<String?> consent = const Value.absent(),
            Value<DateTime?> consentAt = const Value.absent(),
            Value<String?> transcript = const Value.absent(),
            Value<String> structuredJson = const Value.absent(),
            Value<String> missingJson = const Value.absent(),
            Value<int?> urgencyProposed = const Value.absent(),
            Value<int?> urgencyFinal = const Value.absent(),
            Value<String> reasonsJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> validatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConsultationsCompanion(
            id: id,
            patientId: patientId,
            agentId: agentId,
            mode: mode,
            stage: stage,
            consent: consent,
            consentAt: consentAt,
            transcript: transcript,
            structuredJson: structuredJson,
            missingJson: missingJson,
            urgencyProposed: urgencyProposed,
            urgencyFinal: urgencyFinal,
            reasonsJson: reasonsJson,
            status: status,
            createdAt: createdAt,
            validatedAt: validatedAt,
            syncStatus: syncStatus,
            retryCount: retryCount,
            lastError: lastError,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String patientId,
            required String agentId,
            Value<String> mode = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<String?> consent = const Value.absent(),
            Value<DateTime?> consentAt = const Value.absent(),
            Value<String?> transcript = const Value.absent(),
            Value<String> structuredJson = const Value.absent(),
            Value<String> missingJson = const Value.absent(),
            Value<int?> urgencyProposed = const Value.absent(),
            Value<int?> urgencyFinal = const Value.absent(),
            Value<String> reasonsJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> validatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConsultationsCompanion.insert(
            id: id,
            patientId: patientId,
            agentId: agentId,
            mode: mode,
            stage: stage,
            consent: consent,
            consentAt: consentAt,
            transcript: transcript,
            structuredJson: structuredJson,
            missingJson: missingJson,
            urgencyProposed: urgencyProposed,
            urgencyFinal: urgencyFinal,
            reasonsJson: reasonsJson,
            status: status,
            createdAt: createdAt,
            validatedAt: validatedAt,
            syncStatus: syncStatus,
            retryCount: retryCount,
            lastError: lastError,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ConsultationsTable, Consultation>(table),
                    BaseReferences<_$AppDatabase, $ConsultationsTable,
                        Consultation>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConsultationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConsultationsTable,
    Consultation,
    $$ConsultationsTableFilterComposer,
    $$ConsultationsTableOrderingComposer,
    $$ConsultationsTableAnnotationComposer,
    $$ConsultationsTableCreateCompanionBuilder,
    $$ConsultationsTableUpdateCompanionBuilder,
    (
      Consultation,
      BaseReferences<_$AppDatabase, $ConsultationsTable, Consultation>
    ),
    Consultation,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$ConsultationsTableTableManager get consultations =>
      $$ConsultationsTableTableManager(_db, _db.consultations);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AgentsTable extends Agents with TableInfo<$AgentsTable, Agent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _healthPostMeta = const VerificationMeta(
    'healthPost',
  );
  @override
  late final GeneratedColumn<String> healthPost = GeneratedColumn<String>(
    'health_post',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agentCodeMeta = const VerificationMeta(
    'agentCode',
  );
  @override
  late final GeneratedColumn<String> agentCode = GeneratedColumn<String>(
    'agent_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    firstName,
    lastName,
    phone,
    district,
    healthPost,
    role,
    agentCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Agent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('health_post')) {
      context.handle(
        _healthPostMeta,
        healthPost.isAcceptableOrUnknown(data['health_post']!, _healthPostMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('agent_code')) {
      context.handle(
        _agentCodeMeta,
        agentCode.isAcceptableOrUnknown(data['agent_code']!, _agentCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_agentCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Agent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Agent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      healthPost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}health_post'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      agentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AgentsTable createAlias(String alias) {
    return $AgentsTable(attachedDatabase, alias);
  }
}

class Agent extends DataClass implements Insertable<Agent> {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? district;
  final String? healthPost;
  final String? role;
  final String agentCode;
  final DateTime createdAt;
  const Agent({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.district,
    this.healthPost,
    this.role,
    required this.agentCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || healthPost != null) {
      map['health_post'] = Variable<String>(healthPost);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['agent_code'] = Variable<String>(agentCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AgentsCompanion toCompanion(bool nullToAbsent) {
    return AgentsCompanion(
      id: Value(id),
      email: Value(email),
      firstName: Value(firstName),
      lastName: Value(lastName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      healthPost: healthPost == null && nullToAbsent
          ? const Value.absent()
          : Value(healthPost),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      agentCode: Value(agentCode),
      createdAt: Value(createdAt),
    );
  }

  factory Agent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Agent(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      phone: serializer.fromJson<String?>(json['phone']),
      district: serializer.fromJson<String?>(json['district']),
      healthPost: serializer.fromJson<String?>(json['healthPost']),
      role: serializer.fromJson<String?>(json['role']),
      agentCode: serializer.fromJson<String>(json['agentCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'phone': serializer.toJson<String?>(phone),
      'district': serializer.toJson<String?>(district),
      'healthPost': serializer.toJson<String?>(healthPost),
      'role': serializer.toJson<String?>(role),
      'agentCode': serializer.toJson<String>(agentCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Agent copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    Value<String?> phone = const Value.absent(),
    Value<String?> district = const Value.absent(),
    Value<String?> healthPost = const Value.absent(),
    Value<String?> role = const Value.absent(),
    String? agentCode,
    DateTime? createdAt,
  }) => Agent(
    id: id ?? this.id,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone.present ? phone.value : this.phone,
    district: district.present ? district.value : this.district,
    healthPost: healthPost.present ? healthPost.value : this.healthPost,
    role: role.present ? role.value : this.role,
    agentCode: agentCode ?? this.agentCode,
    createdAt: createdAt ?? this.createdAt,
  );
  Agent copyWithCompanion(AgentsCompanion data) {
    return Agent(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      phone: data.phone.present ? data.phone.value : this.phone,
      district: data.district.present ? data.district.value : this.district,
      healthPost: data.healthPost.present
          ? data.healthPost.value
          : this.healthPost,
      role: data.role.present ? data.role.value : this.role,
      agentCode: data.agentCode.present ? data.agentCode.value : this.agentCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Agent(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('district: $district, ')
          ..write('healthPost: $healthPost, ')
          ..write('role: $role, ')
          ..write('agentCode: $agentCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    firstName,
    lastName,
    phone,
    district,
    healthPost,
    role,
    agentCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Agent &&
          other.id == this.id &&
          other.email == this.email &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.phone == this.phone &&
          other.district == this.district &&
          other.healthPost == this.healthPost &&
          other.role == this.role &&
          other.agentCode == this.agentCode &&
          other.createdAt == this.createdAt);
}

class AgentsCompanion extends UpdateCompanion<Agent> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> phone;
  final Value<String?> district;
  final Value<String?> healthPost;
  final Value<String?> role;
  final Value<String> agentCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AgentsCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.district = const Value.absent(),
    this.healthPost = const Value.absent(),
    this.role = const Value.absent(),
    this.agentCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentsCompanion.insert({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    this.phone = const Value.absent(),
    this.district = const Value.absent(),
    this.healthPost = const Value.absent(),
    this.role = const Value.absent(),
    required String agentCode,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       firstName = Value(firstName),
       lastName = Value(lastName),
       agentCode = Value(agentCode),
       createdAt = Value(createdAt);
  static Insertable<Agent> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? phone,
    Expression<String>? district,
    Expression<String>? healthPost,
    Expression<String>? role,
    Expression<String>? agentCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (district != null) 'district': district,
      if (healthPost != null) 'health_post': healthPost,
      if (role != null) 'role': role,
      if (agentCode != null) 'agent_code': agentCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentsCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String?>? phone,
    Value<String?>? district,
    Value<String?>? healthPost,
    Value<String?>? role,
    Value<String>? agentCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AgentsCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      district: district ?? this.district,
      healthPost: healthPost ?? this.healthPost,
      role: role ?? this.role,
      agentCode: agentCode ?? this.agentCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (healthPost.present) {
      map['health_post'] = Variable<String>(healthPost.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (agentCode.present) {
      map['agent_code'] = Variable<String>(agentCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentsCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('district: $district, ')
          ..write('healthPost: $healthPost, ')
          ..write('role: $role, ')
          ..write('agentCode: $agentCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageYearsMeta = const VerificationMeta(
    'ageYears',
  );
  @override
  late final GeneratedColumn<int> ageYears = GeneratedColumn<int>(
    'age_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageRecordedAtMeta = const VerificationMeta(
    'ageRecordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> ageRecordedAt =
      GeneratedColumn<DateTime>(
        'age_recorded_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageMeta = const VerificationMeta(
    'village',
  );
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByAgentIdMeta = const VerificationMeta(
    'createdByAgentId',
  );
  @override
  late final GeneratedColumn<String> createdByAgentId = GeneratedColumn<String>(
    'created_by_agent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastName,
    firstName,
    ageYears,
    ageRecordedAt,
    sex,
    village,
    phone,
    createdByAgentId,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Patient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('age_years')) {
      context.handle(
        _ageYearsMeta,
        ageYears.isAcceptableOrUnknown(data['age_years']!, _ageYearsMeta),
      );
    } else if (isInserting) {
      context.missing(_ageYearsMeta);
    }
    if (data.containsKey('age_recorded_at')) {
      context.handle(
        _ageRecordedAtMeta,
        ageRecordedAt.isAcceptableOrUnknown(
          data['age_recorded_at']!,
          _ageRecordedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ageRecordedAtMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('village')) {
      context.handle(
        _villageMeta,
        village.isAcceptableOrUnknown(data['village']!, _villageMeta),
      );
    } else if (isInserting) {
      context.missing(_villageMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('created_by_agent_id')) {
      context.handle(
        _createdByAgentIdMeta,
        createdByAgentId.isAcceptableOrUnknown(
          data['created_by_agent_id']!,
          _createdByAgentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByAgentIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      ageYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_years'],
      )!,
      ageRecordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}age_recorded_at'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      village: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      createdByAgentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_agent_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  /// Format SUR-XXXX-XXXX
  final String id;
  final String lastName;
  final String firstName;
  final int ageYears;
  final DateTime ageRecordedAt;
  final String sex;
  final String village;
  final String? phone;
  final String createdByAgentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Patient({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.ageYears,
    required this.ageRecordedAt,
    required this.sex,
    required this.village,
    this.phone,
    required this.createdByAgentId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['last_name'] = Variable<String>(lastName);
    map['first_name'] = Variable<String>(firstName);
    map['age_years'] = Variable<int>(ageYears);
    map['age_recorded_at'] = Variable<DateTime>(ageRecordedAt);
    map['sex'] = Variable<String>(sex);
    map['village'] = Variable<String>(village);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['created_by_agent_id'] = Variable<String>(createdByAgentId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      lastName: Value(lastName),
      firstName: Value(firstName),
      ageYears: Value(ageYears),
      ageRecordedAt: Value(ageRecordedAt),
      sex: Value(sex),
      village: Value(village),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      createdByAgentId: Value(createdByAgentId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Patient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      lastName: serializer.fromJson<String>(json['lastName']),
      firstName: serializer.fromJson<String>(json['firstName']),
      ageYears: serializer.fromJson<int>(json['ageYears']),
      ageRecordedAt: serializer.fromJson<DateTime>(json['ageRecordedAt']),
      sex: serializer.fromJson<String>(json['sex']),
      village: serializer.fromJson<String>(json['village']),
      phone: serializer.fromJson<String?>(json['phone']),
      createdByAgentId: serializer.fromJson<String>(json['createdByAgentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastName': serializer.toJson<String>(lastName),
      'firstName': serializer.toJson<String>(firstName),
      'ageYears': serializer.toJson<int>(ageYears),
      'ageRecordedAt': serializer.toJson<DateTime>(ageRecordedAt),
      'sex': serializer.toJson<String>(sex),
      'village': serializer.toJson<String>(village),
      'phone': serializer.toJson<String?>(phone),
      'createdByAgentId': serializer.toJson<String>(createdByAgentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Patient copyWith({
    String? id,
    String? lastName,
    String? firstName,
    int? ageYears,
    DateTime? ageRecordedAt,
    String? sex,
    String? village,
    Value<String?> phone = const Value.absent(),
    String? createdByAgentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => Patient(
    id: id ?? this.id,
    lastName: lastName ?? this.lastName,
    firstName: firstName ?? this.firstName,
    ageYears: ageYears ?? this.ageYears,
    ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
    sex: sex ?? this.sex,
    village: village ?? this.village,
    phone: phone.present ? phone.value : this.phone,
    createdByAgentId: createdByAgentId ?? this.createdByAgentId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      ageYears: data.ageYears.present ? data.ageYears.value : this.ageYears,
      ageRecordedAt: data.ageRecordedAt.present
          ? data.ageRecordedAt.value
          : this.ageRecordedAt,
      sex: data.sex.present ? data.sex.value : this.sex,
      village: data.village.present ? data.village.value : this.village,
      phone: data.phone.present ? data.phone.value : this.phone,
      createdByAgentId: data.createdByAgentId.present
          ? data.createdByAgentId.value
          : this.createdByAgentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('firstName: $firstName, ')
          ..write('ageYears: $ageYears, ')
          ..write('ageRecordedAt: $ageRecordedAt, ')
          ..write('sex: $sex, ')
          ..write('village: $village, ')
          ..write('phone: $phone, ')
          ..write('createdByAgentId: $createdByAgentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastName,
    firstName,
    ageYears,
    ageRecordedAt,
    sex,
    village,
    phone,
    createdByAgentId,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.lastName == this.lastName &&
          other.firstName == this.firstName &&
          other.ageYears == this.ageYears &&
          other.ageRecordedAt == this.ageRecordedAt &&
          other.sex == this.sex &&
          other.village == this.village &&
          other.phone == this.phone &&
          other.createdByAgentId == this.createdByAgentId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String> lastName;
  final Value<String> firstName;
  final Value<int> ageYears;
  final Value<DateTime> ageRecordedAt;
  final Value<String> sex;
  final Value<String> village;
  final Value<String?> phone;
  final Value<String> createdByAgentId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.lastName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.ageYears = const Value.absent(),
    this.ageRecordedAt = const Value.absent(),
    this.sex = const Value.absent(),
    this.village = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdByAgentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String lastName,
    required String firstName,
    required int ageYears,
    required DateTime ageRecordedAt,
    required String sex,
    required String village,
    this.phone = const Value.absent(),
    required String createdByAgentId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lastName = Value(lastName),
       firstName = Value(firstName),
       ageYears = Value(ageYears),
       ageRecordedAt = Value(ageRecordedAt),
       sex = Value(sex),
       village = Value(village),
       createdByAgentId = Value(createdByAgentId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? lastName,
    Expression<String>? firstName,
    Expression<int>? ageYears,
    Expression<DateTime>? ageRecordedAt,
    Expression<String>? sex,
    Expression<String>? village,
    Expression<String>? phone,
    Expression<String>? createdByAgentId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastName != null) 'last_name': lastName,
      if (firstName != null) 'first_name': firstName,
      if (ageYears != null) 'age_years': ageYears,
      if (ageRecordedAt != null) 'age_recorded_at': ageRecordedAt,
      if (sex != null) 'sex': sex,
      if (village != null) 'village': village,
      if (phone != null) 'phone': phone,
      if (createdByAgentId != null) 'created_by_agent_id': createdByAgentId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<String>? lastName,
    Value<String>? firstName,
    Value<int>? ageYears,
    Value<DateTime>? ageRecordedAt,
    Value<String>? sex,
    Value<String>? village,
    Value<String?>? phone,
    Value<String>? createdByAgentId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      ageYears: ageYears ?? this.ageYears,
      ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
      sex: sex ?? this.sex,
      village: village ?? this.village,
      phone: phone ?? this.phone,
      createdByAgentId: createdByAgentId ?? this.createdByAgentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
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
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (createdByAgentId.present) {
      map['created_by_agent_id'] = Variable<String>(createdByAgentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
          ..write('lastName: $lastName, ')
          ..write('firstName: $firstName, ')
          ..write('ageYears: $ageYears, ')
          ..write('ageRecordedAt: $ageRecordedAt, ')
          ..write('sex: $sex, ')
          ..write('village: $village, ')
          ..write('phone: $phone, ')
          ..write('createdByAgentId: $createdByAgentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _agentIdMeta = const VerificationMeta(
    'agentId',
  );
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
    'agent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _currentStepMeta = const VerificationMeta(
    'currentStep',
  );
  @override
  late final GeneratedColumn<String> currentStep = GeneratedColumn<String>(
    'current_step',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('consent'),
  );
  static const VerificationMeta _consentStatusMeta = const VerificationMeta(
    'consentStatus',
  );
  @override
  late final GeneratedColumn<String> consentStatus = GeneratedColumn<String>(
    'consent_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consentAtMeta = const VerificationMeta(
    'consentAt',
  );
  @override
  late final GeneratedColumn<DateTime> consentAt = GeneratedColumn<DateTime>(
    'consent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptRawMeta = const VerificationMeta(
    'transcriptRaw',
  );
  @override
  late final GeneratedColumn<String> transcriptRaw = GeneratedColumn<String>(
    'transcript_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptEditedMeta = const VerificationMeta(
    'transcriptEdited',
  );
  @override
  late final GeneratedColumn<String> transcriptEdited = GeneratedColumn<String>(
    'transcript_edited',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _structuredJsonMeta = const VerificationMeta(
    'structuredJson',
  );
  @override
  late final GeneratedColumn<String> structuredJson = GeneratedColumn<String>(
    'structured_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _missingJsonMeta = const VerificationMeta(
    'missingJson',
  );
  @override
  late final GeneratedColumn<String> missingJson = GeneratedColumn<String>(
    'missing_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urgencyProposedMeta = const VerificationMeta(
    'urgencyProposed',
  );
  @override
  late final GeneratedColumn<String> urgencyProposed = GeneratedColumn<String>(
    'urgency_proposed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urgencyReasonsJsonMeta =
      const VerificationMeta('urgencyReasonsJson');
  @override
  late final GeneratedColumn<String> urgencyReasonsJson =
      GeneratedColumn<String>(
        'urgency_reasons_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _urgencyFinalMeta = const VerificationMeta(
    'urgencyFinal',
  );
  @override
  late final GeneratedColumn<String> urgencyFinal = GeneratedColumn<String>(
    'urgency_final',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urgencyOverrideReasonMeta =
      const VerificationMeta('urgencyOverrideReason');
  @override
  late final GeneratedColumn<String> urgencyOverrideReason =
      GeneratedColumn<String>(
        'urgency_override_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _checklistJsonMeta = const VerificationMeta(
    'checklistJson',
  );
  @override
  late final GeneratedColumn<String> checklistJson = GeneratedColumn<String>(
    'checklist_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncAttemptsMeta = const VerificationMeta(
    'syncAttempts',
  );
  @override
  late final GeneratedColumn<int> syncAttempts = GeneratedColumn<int>(
    'sync_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validatedAtMeta = const VerificationMeta(
    'validatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> validatedAt = GeneratedColumn<DateTime>(
    'validated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    agentId,
    status,
    currentStep,
    consentStatus,
    consentAt,
    transcriptRaw,
    transcriptEdited,
    structuredJson,
    missingJson,
    urgencyProposed,
    urgencyReasonsJson,
    urgencyFinal,
    urgencyOverrideReason,
    checklistJson,
    syncStatus,
    syncAttempts,
    syncError,
    createdAt,
    updatedAt,
    validatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consultations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Consultation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('agent_id')) {
      context.handle(
        _agentIdMeta,
        agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_agentIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('current_step')) {
      context.handle(
        _currentStepMeta,
        currentStep.isAcceptableOrUnknown(
          data['current_step']!,
          _currentStepMeta,
        ),
      );
    }
    if (data.containsKey('consent_status')) {
      context.handle(
        _consentStatusMeta,
        consentStatus.isAcceptableOrUnknown(
          data['consent_status']!,
          _consentStatusMeta,
        ),
      );
    }
    if (data.containsKey('consent_at')) {
      context.handle(
        _consentAtMeta,
        consentAt.isAcceptableOrUnknown(data['consent_at']!, _consentAtMeta),
      );
    }
    if (data.containsKey('transcript_raw')) {
      context.handle(
        _transcriptRawMeta,
        transcriptRaw.isAcceptableOrUnknown(
          data['transcript_raw']!,
          _transcriptRawMeta,
        ),
      );
    }
    if (data.containsKey('transcript_edited')) {
      context.handle(
        _transcriptEditedMeta,
        transcriptEdited.isAcceptableOrUnknown(
          data['transcript_edited']!,
          _transcriptEditedMeta,
        ),
      );
    }
    if (data.containsKey('structured_json')) {
      context.handle(
        _structuredJsonMeta,
        structuredJson.isAcceptableOrUnknown(
          data['structured_json']!,
          _structuredJsonMeta,
        ),
      );
    }
    if (data.containsKey('missing_json')) {
      context.handle(
        _missingJsonMeta,
        missingJson.isAcceptableOrUnknown(
          data['missing_json']!,
          _missingJsonMeta,
        ),
      );
    }
    if (data.containsKey('urgency_proposed')) {
      context.handle(
        _urgencyProposedMeta,
        urgencyProposed.isAcceptableOrUnknown(
          data['urgency_proposed']!,
          _urgencyProposedMeta,
        ),
      );
    }
    if (data.containsKey('urgency_reasons_json')) {
      context.handle(
        _urgencyReasonsJsonMeta,
        urgencyReasonsJson.isAcceptableOrUnknown(
          data['urgency_reasons_json']!,
          _urgencyReasonsJsonMeta,
        ),
      );
    }
    if (data.containsKey('urgency_final')) {
      context.handle(
        _urgencyFinalMeta,
        urgencyFinal.isAcceptableOrUnknown(
          data['urgency_final']!,
          _urgencyFinalMeta,
        ),
      );
    }
    if (data.containsKey('urgency_override_reason')) {
      context.handle(
        _urgencyOverrideReasonMeta,
        urgencyOverrideReason.isAcceptableOrUnknown(
          data['urgency_override_reason']!,
          _urgencyOverrideReasonMeta,
        ),
      );
    }
    if (data.containsKey('checklist_json')) {
      context.handle(
        _checklistJsonMeta,
        checklistJson.isAcceptableOrUnknown(
          data['checklist_json']!,
          _checklistJsonMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_attempts')) {
      context.handle(
        _syncAttemptsMeta,
        syncAttempts.isAcceptableOrUnknown(
          data['sync_attempts']!,
          _syncAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('validated_at')) {
      context.handle(
        _validatedAtMeta,
        validatedAt.isAcceptableOrUnknown(
          data['validated_at']!,
          _validatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Consultation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Consultation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      agentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      currentStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_step'],
      )!,
      consentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consent_status'],
      ),
      consentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}consent_at'],
      ),
      transcriptRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript_raw'],
      ),
      transcriptEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript_edited'],
      ),
      structuredJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structured_json'],
      ),
      missingJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}missing_json'],
      ),
      urgencyProposed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urgency_proposed'],
      ),
      urgencyReasonsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urgency_reasons_json'],
      ),
      urgencyFinal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urgency_final'],
      ),
      urgencyOverrideReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}urgency_override_reason'],
      ),
      checklistJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checklist_json'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_attempts'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      validatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}validated_at'],
      ),
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

  /// 'draft' | 'saved'
  final String status;
  final String currentStep;

  /// 'granted' | 'refused'
  final String? consentStatus;
  final DateTime? consentAt;
  final String? transcriptRaw;
  final String? transcriptEdited;
  final String? structuredJson;
  final String? missingJson;

  /// 'high' | 'moderate' | 'low'
  final String? urgencyProposed;
  final String? urgencyReasonsJson;
  final String? urgencyFinal;
  final String? urgencyOverrideReason;
  final String? checklistJson;

  /// 'pending' | 'syncing' | 'synced' | 'error'
  final String syncStatus;
  final int syncAttempts;
  final String? syncError;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? validatedAt;
  const Consultation({
    required this.id,
    required this.patientId,
    required this.agentId,
    required this.status,
    required this.currentStep,
    this.consentStatus,
    this.consentAt,
    this.transcriptRaw,
    this.transcriptEdited,
    this.structuredJson,
    this.missingJson,
    this.urgencyProposed,
    this.urgencyReasonsJson,
    this.urgencyFinal,
    this.urgencyOverrideReason,
    this.checklistJson,
    required this.syncStatus,
    required this.syncAttempts,
    this.syncError,
    required this.createdAt,
    required this.updatedAt,
    this.validatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['agent_id'] = Variable<String>(agentId);
    map['status'] = Variable<String>(status);
    map['current_step'] = Variable<String>(currentStep);
    if (!nullToAbsent || consentStatus != null) {
      map['consent_status'] = Variable<String>(consentStatus);
    }
    if (!nullToAbsent || consentAt != null) {
      map['consent_at'] = Variable<DateTime>(consentAt);
    }
    if (!nullToAbsent || transcriptRaw != null) {
      map['transcript_raw'] = Variable<String>(transcriptRaw);
    }
    if (!nullToAbsent || transcriptEdited != null) {
      map['transcript_edited'] = Variable<String>(transcriptEdited);
    }
    if (!nullToAbsent || structuredJson != null) {
      map['structured_json'] = Variable<String>(structuredJson);
    }
    if (!nullToAbsent || missingJson != null) {
      map['missing_json'] = Variable<String>(missingJson);
    }
    if (!nullToAbsent || urgencyProposed != null) {
      map['urgency_proposed'] = Variable<String>(urgencyProposed);
    }
    if (!nullToAbsent || urgencyReasonsJson != null) {
      map['urgency_reasons_json'] = Variable<String>(urgencyReasonsJson);
    }
    if (!nullToAbsent || urgencyFinal != null) {
      map['urgency_final'] = Variable<String>(urgencyFinal);
    }
    if (!nullToAbsent || urgencyOverrideReason != null) {
      map['urgency_override_reason'] = Variable<String>(urgencyOverrideReason);
    }
    if (!nullToAbsent || checklistJson != null) {
      map['checklist_json'] = Variable<String>(checklistJson);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_attempts'] = Variable<int>(syncAttempts);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || validatedAt != null) {
      map['validated_at'] = Variable<DateTime>(validatedAt);
    }
    return map;
  }

  ConsultationsCompanion toCompanion(bool nullToAbsent) {
    return ConsultationsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      agentId: Value(agentId),
      status: Value(status),
      currentStep: Value(currentStep),
      consentStatus: consentStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(consentStatus),
      consentAt: consentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(consentAt),
      transcriptRaw: transcriptRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(transcriptRaw),
      transcriptEdited: transcriptEdited == null && nullToAbsent
          ? const Value.absent()
          : Value(transcriptEdited),
      structuredJson: structuredJson == null && nullToAbsent
          ? const Value.absent()
          : Value(structuredJson),
      missingJson: missingJson == null && nullToAbsent
          ? const Value.absent()
          : Value(missingJson),
      urgencyProposed: urgencyProposed == null && nullToAbsent
          ? const Value.absent()
          : Value(urgencyProposed),
      urgencyReasonsJson: urgencyReasonsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(urgencyReasonsJson),
      urgencyFinal: urgencyFinal == null && nullToAbsent
          ? const Value.absent()
          : Value(urgencyFinal),
      urgencyOverrideReason: urgencyOverrideReason == null && nullToAbsent
          ? const Value.absent()
          : Value(urgencyOverrideReason),
      checklistJson: checklistJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistJson),
      syncStatus: Value(syncStatus),
      syncAttempts: Value(syncAttempts),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      validatedAt: validatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(validatedAt),
    );
  }

  factory Consultation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Consultation(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      agentId: serializer.fromJson<String>(json['agentId']),
      status: serializer.fromJson<String>(json['status']),
      currentStep: serializer.fromJson<String>(json['currentStep']),
      consentStatus: serializer.fromJson<String?>(json['consentStatus']),
      consentAt: serializer.fromJson<DateTime?>(json['consentAt']),
      transcriptRaw: serializer.fromJson<String?>(json['transcriptRaw']),
      transcriptEdited: serializer.fromJson<String?>(json['transcriptEdited']),
      structuredJson: serializer.fromJson<String?>(json['structuredJson']),
      missingJson: serializer.fromJson<String?>(json['missingJson']),
      urgencyProposed: serializer.fromJson<String?>(json['urgencyProposed']),
      urgencyReasonsJson: serializer.fromJson<String?>(
        json['urgencyReasonsJson'],
      ),
      urgencyFinal: serializer.fromJson<String?>(json['urgencyFinal']),
      urgencyOverrideReason: serializer.fromJson<String?>(
        json['urgencyOverrideReason'],
      ),
      checklistJson: serializer.fromJson<String?>(json['checklistJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncAttempts: serializer.fromJson<int>(json['syncAttempts']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      validatedAt: serializer.fromJson<DateTime?>(json['validatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'agentId': serializer.toJson<String>(agentId),
      'status': serializer.toJson<String>(status),
      'currentStep': serializer.toJson<String>(currentStep),
      'consentStatus': serializer.toJson<String?>(consentStatus),
      'consentAt': serializer.toJson<DateTime?>(consentAt),
      'transcriptRaw': serializer.toJson<String?>(transcriptRaw),
      'transcriptEdited': serializer.toJson<String?>(transcriptEdited),
      'structuredJson': serializer.toJson<String?>(structuredJson),
      'missingJson': serializer.toJson<String?>(missingJson),
      'urgencyProposed': serializer.toJson<String?>(urgencyProposed),
      'urgencyReasonsJson': serializer.toJson<String?>(urgencyReasonsJson),
      'urgencyFinal': serializer.toJson<String?>(urgencyFinal),
      'urgencyOverrideReason': serializer.toJson<String?>(
        urgencyOverrideReason,
      ),
      'checklistJson': serializer.toJson<String?>(checklistJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncAttempts': serializer.toJson<int>(syncAttempts),
      'syncError': serializer.toJson<String?>(syncError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'validatedAt': serializer.toJson<DateTime?>(validatedAt),
    };
  }

  Consultation copyWith({
    String? id,
    String? patientId,
    String? agentId,
    String? status,
    String? currentStep,
    Value<String?> consentStatus = const Value.absent(),
    Value<DateTime?> consentAt = const Value.absent(),
    Value<String?> transcriptRaw = const Value.absent(),
    Value<String?> transcriptEdited = const Value.absent(),
    Value<String?> structuredJson = const Value.absent(),
    Value<String?> missingJson = const Value.absent(),
    Value<String?> urgencyProposed = const Value.absent(),
    Value<String?> urgencyReasonsJson = const Value.absent(),
    Value<String?> urgencyFinal = const Value.absent(),
    Value<String?> urgencyOverrideReason = const Value.absent(),
    Value<String?> checklistJson = const Value.absent(),
    String? syncStatus,
    int? syncAttempts,
    Value<String?> syncError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> validatedAt = const Value.absent(),
  }) => Consultation(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    agentId: agentId ?? this.agentId,
    status: status ?? this.status,
    currentStep: currentStep ?? this.currentStep,
    consentStatus: consentStatus.present
        ? consentStatus.value
        : this.consentStatus,
    consentAt: consentAt.present ? consentAt.value : this.consentAt,
    transcriptRaw: transcriptRaw.present
        ? transcriptRaw.value
        : this.transcriptRaw,
    transcriptEdited: transcriptEdited.present
        ? transcriptEdited.value
        : this.transcriptEdited,
    structuredJson: structuredJson.present
        ? structuredJson.value
        : this.structuredJson,
    missingJson: missingJson.present ? missingJson.value : this.missingJson,
    urgencyProposed: urgencyProposed.present
        ? urgencyProposed.value
        : this.urgencyProposed,
    urgencyReasonsJson: urgencyReasonsJson.present
        ? urgencyReasonsJson.value
        : this.urgencyReasonsJson,
    urgencyFinal: urgencyFinal.present ? urgencyFinal.value : this.urgencyFinal,
    urgencyOverrideReason: urgencyOverrideReason.present
        ? urgencyOverrideReason.value
        : this.urgencyOverrideReason,
    checklistJson: checklistJson.present
        ? checklistJson.value
        : this.checklistJson,
    syncStatus: syncStatus ?? this.syncStatus,
    syncAttempts: syncAttempts ?? this.syncAttempts,
    syncError: syncError.present ? syncError.value : this.syncError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    validatedAt: validatedAt.present ? validatedAt.value : this.validatedAt,
  );
  Consultation copyWithCompanion(ConsultationsCompanion data) {
    return Consultation(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      status: data.status.present ? data.status.value : this.status,
      currentStep: data.currentStep.present
          ? data.currentStep.value
          : this.currentStep,
      consentStatus: data.consentStatus.present
          ? data.consentStatus.value
          : this.consentStatus,
      consentAt: data.consentAt.present ? data.consentAt.value : this.consentAt,
      transcriptRaw: data.transcriptRaw.present
          ? data.transcriptRaw.value
          : this.transcriptRaw,
      transcriptEdited: data.transcriptEdited.present
          ? data.transcriptEdited.value
          : this.transcriptEdited,
      structuredJson: data.structuredJson.present
          ? data.structuredJson.value
          : this.structuredJson,
      missingJson: data.missingJson.present
          ? data.missingJson.value
          : this.missingJson,
      urgencyProposed: data.urgencyProposed.present
          ? data.urgencyProposed.value
          : this.urgencyProposed,
      urgencyReasonsJson: data.urgencyReasonsJson.present
          ? data.urgencyReasonsJson.value
          : this.urgencyReasonsJson,
      urgencyFinal: data.urgencyFinal.present
          ? data.urgencyFinal.value
          : this.urgencyFinal,
      urgencyOverrideReason: data.urgencyOverrideReason.present
          ? data.urgencyOverrideReason.value
          : this.urgencyOverrideReason,
      checklistJson: data.checklistJson.present
          ? data.checklistJson.value
          : this.checklistJson,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncAttempts: data.syncAttempts.present
          ? data.syncAttempts.value
          : this.syncAttempts,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      validatedAt: data.validatedAt.present
          ? data.validatedAt.value
          : this.validatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Consultation(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('agentId: $agentId, ')
          ..write('status: $status, ')
          ..write('currentStep: $currentStep, ')
          ..write('consentStatus: $consentStatus, ')
          ..write('consentAt: $consentAt, ')
          ..write('transcriptRaw: $transcriptRaw, ')
          ..write('transcriptEdited: $transcriptEdited, ')
          ..write('structuredJson: $structuredJson, ')
          ..write('missingJson: $missingJson, ')
          ..write('urgencyProposed: $urgencyProposed, ')
          ..write('urgencyReasonsJson: $urgencyReasonsJson, ')
          ..write('urgencyFinal: $urgencyFinal, ')
          ..write('urgencyOverrideReason: $urgencyOverrideReason, ')
          ..write('checklistJson: $checklistJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncAttempts: $syncAttempts, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('validatedAt: $validatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    patientId,
    agentId,
    status,
    currentStep,
    consentStatus,
    consentAt,
    transcriptRaw,
    transcriptEdited,
    structuredJson,
    missingJson,
    urgencyProposed,
    urgencyReasonsJson,
    urgencyFinal,
    urgencyOverrideReason,
    checklistJson,
    syncStatus,
    syncAttempts,
    syncError,
    createdAt,
    updatedAt,
    validatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Consultation &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.agentId == this.agentId &&
          other.status == this.status &&
          other.currentStep == this.currentStep &&
          other.consentStatus == this.consentStatus &&
          other.consentAt == this.consentAt &&
          other.transcriptRaw == this.transcriptRaw &&
          other.transcriptEdited == this.transcriptEdited &&
          other.structuredJson == this.structuredJson &&
          other.missingJson == this.missingJson &&
          other.urgencyProposed == this.urgencyProposed &&
          other.urgencyReasonsJson == this.urgencyReasonsJson &&
          other.urgencyFinal == this.urgencyFinal &&
          other.urgencyOverrideReason == this.urgencyOverrideReason &&
          other.checklistJson == this.checklistJson &&
          other.syncStatus == this.syncStatus &&
          other.syncAttempts == this.syncAttempts &&
          other.syncError == this.syncError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.validatedAt == this.validatedAt);
}

class ConsultationsCompanion extends UpdateCompanion<Consultation> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> agentId;
  final Value<String> status;
  final Value<String> currentStep;
  final Value<String?> consentStatus;
  final Value<DateTime?> consentAt;
  final Value<String?> transcriptRaw;
  final Value<String?> transcriptEdited;
  final Value<String?> structuredJson;
  final Value<String?> missingJson;
  final Value<String?> urgencyProposed;
  final Value<String?> urgencyReasonsJson;
  final Value<String?> urgencyFinal;
  final Value<String?> urgencyOverrideReason;
  final Value<String?> checklistJson;
  final Value<String> syncStatus;
  final Value<int> syncAttempts;
  final Value<String?> syncError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> validatedAt;
  final Value<int> rowid;
  const ConsultationsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.agentId = const Value.absent(),
    this.status = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.consentStatus = const Value.absent(),
    this.consentAt = const Value.absent(),
    this.transcriptRaw = const Value.absent(),
    this.transcriptEdited = const Value.absent(),
    this.structuredJson = const Value.absent(),
    this.missingJson = const Value.absent(),
    this.urgencyProposed = const Value.absent(),
    this.urgencyReasonsJson = const Value.absent(),
    this.urgencyFinal = const Value.absent(),
    this.urgencyOverrideReason = const Value.absent(),
    this.checklistJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncAttempts = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.validatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsultationsCompanion.insert({
    required String id,
    required String patientId,
    required String agentId,
    this.status = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.consentStatus = const Value.absent(),
    this.consentAt = const Value.absent(),
    this.transcriptRaw = const Value.absent(),
    this.transcriptEdited = const Value.absent(),
    this.structuredJson = const Value.absent(),
    this.missingJson = const Value.absent(),
    this.urgencyProposed = const Value.absent(),
    this.urgencyReasonsJson = const Value.absent(),
    this.urgencyFinal = const Value.absent(),
    this.urgencyOverrideReason = const Value.absent(),
    this.checklistJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncAttempts = const Value.absent(),
    this.syncError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.validatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       agentId = Value(agentId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Consultation> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? agentId,
    Expression<String>? status,
    Expression<String>? currentStep,
    Expression<String>? consentStatus,
    Expression<DateTime>? consentAt,
    Expression<String>? transcriptRaw,
    Expression<String>? transcriptEdited,
    Expression<String>? structuredJson,
    Expression<String>? missingJson,
    Expression<String>? urgencyProposed,
    Expression<String>? urgencyReasonsJson,
    Expression<String>? urgencyFinal,
    Expression<String>? urgencyOverrideReason,
    Expression<String>? checklistJson,
    Expression<String>? syncStatus,
    Expression<int>? syncAttempts,
    Expression<String>? syncError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? validatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (agentId != null) 'agent_id': agentId,
      if (status != null) 'status': status,
      if (currentStep != null) 'current_step': currentStep,
      if (consentStatus != null) 'consent_status': consentStatus,
      if (consentAt != null) 'consent_at': consentAt,
      if (transcriptRaw != null) 'transcript_raw': transcriptRaw,
      if (transcriptEdited != null) 'transcript_edited': transcriptEdited,
      if (structuredJson != null) 'structured_json': structuredJson,
      if (missingJson != null) 'missing_json': missingJson,
      if (urgencyProposed != null) 'urgency_proposed': urgencyProposed,
      if (urgencyReasonsJson != null)
        'urgency_reasons_json': urgencyReasonsJson,
      if (urgencyFinal != null) 'urgency_final': urgencyFinal,
      if (urgencyOverrideReason != null)
        'urgency_override_reason': urgencyOverrideReason,
      if (checklistJson != null) 'checklist_json': checklistJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncAttempts != null) 'sync_attempts': syncAttempts,
      if (syncError != null) 'sync_error': syncError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (validatedAt != null) 'validated_at': validatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsultationsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? agentId,
    Value<String>? status,
    Value<String>? currentStep,
    Value<String?>? consentStatus,
    Value<DateTime?>? consentAt,
    Value<String?>? transcriptRaw,
    Value<String?>? transcriptEdited,
    Value<String?>? structuredJson,
    Value<String?>? missingJson,
    Value<String?>? urgencyProposed,
    Value<String?>? urgencyReasonsJson,
    Value<String?>? urgencyFinal,
    Value<String?>? urgencyOverrideReason,
    Value<String?>? checklistJson,
    Value<String>? syncStatus,
    Value<int>? syncAttempts,
    Value<String?>? syncError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? validatedAt,
    Value<int>? rowid,
  }) {
    return ConsultationsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      consentStatus: consentStatus ?? this.consentStatus,
      consentAt: consentAt ?? this.consentAt,
      transcriptRaw: transcriptRaw ?? this.transcriptRaw,
      transcriptEdited: transcriptEdited ?? this.transcriptEdited,
      structuredJson: structuredJson ?? this.structuredJson,
      missingJson: missingJson ?? this.missingJson,
      urgencyProposed: urgencyProposed ?? this.urgencyProposed,
      urgencyReasonsJson: urgencyReasonsJson ?? this.urgencyReasonsJson,
      urgencyFinal: urgencyFinal ?? this.urgencyFinal,
      urgencyOverrideReason:
          urgencyOverrideReason ?? this.urgencyOverrideReason,
      checklistJson: checklistJson ?? this.checklistJson,
      syncStatus: syncStatus ?? this.syncStatus,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      syncError: syncError ?? this.syncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      validatedAt: validatedAt ?? this.validatedAt,
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
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentStep.present) {
      map['current_step'] = Variable<String>(currentStep.value);
    }
    if (consentStatus.present) {
      map['consent_status'] = Variable<String>(consentStatus.value);
    }
    if (consentAt.present) {
      map['consent_at'] = Variable<DateTime>(consentAt.value);
    }
    if (transcriptRaw.present) {
      map['transcript_raw'] = Variable<String>(transcriptRaw.value);
    }
    if (transcriptEdited.present) {
      map['transcript_edited'] = Variable<String>(transcriptEdited.value);
    }
    if (structuredJson.present) {
      map['structured_json'] = Variable<String>(structuredJson.value);
    }
    if (missingJson.present) {
      map['missing_json'] = Variable<String>(missingJson.value);
    }
    if (urgencyProposed.present) {
      map['urgency_proposed'] = Variable<String>(urgencyProposed.value);
    }
    if (urgencyReasonsJson.present) {
      map['urgency_reasons_json'] = Variable<String>(urgencyReasonsJson.value);
    }
    if (urgencyFinal.present) {
      map['urgency_final'] = Variable<String>(urgencyFinal.value);
    }
    if (urgencyOverrideReason.present) {
      map['urgency_override_reason'] = Variable<String>(
        urgencyOverrideReason.value,
      );
    }
    if (checklistJson.present) {
      map['checklist_json'] = Variable<String>(checklistJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncAttempts.present) {
      map['sync_attempts'] = Variable<int>(syncAttempts.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (validatedAt.present) {
      map['validated_at'] = Variable<DateTime>(validatedAt.value);
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
          ..write('status: $status, ')
          ..write('currentStep: $currentStep, ')
          ..write('consentStatus: $consentStatus, ')
          ..write('consentAt: $consentAt, ')
          ..write('transcriptRaw: $transcriptRaw, ')
          ..write('transcriptEdited: $transcriptEdited, ')
          ..write('structuredJson: $structuredJson, ')
          ..write('missingJson: $missingJson, ')
          ..write('urgencyProposed: $urgencyProposed, ')
          ..write('urgencyReasonsJson: $urgencyReasonsJson, ')
          ..write('urgencyFinal: $urgencyFinal, ')
          ..write('urgencyOverrideReason: $urgencyOverrideReason, ')
          ..write('checklistJson: $checklistJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncAttempts: $syncAttempts, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('validatedAt: $validatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AgentsTable agents = $AgentsTable(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $ConsultationsTable consultations = $ConsultationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    agents,
    patients,
    consultations,
  ];
}

typedef $$AgentsTableCreateCompanionBuilder =
    AgentsCompanion Function({
      required String id,
      required String email,
      required String firstName,
      required String lastName,
      Value<String?> phone,
      Value<String?> district,
      Value<String?> healthPost,
      Value<String?> role,
      required String agentCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AgentsTableUpdateCompanionBuilder =
    AgentsCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> firstName,
      Value<String> lastName,
      Value<String?> phone,
      Value<String?> district,
      Value<String?> healthPost,
      Value<String?> role,
      Value<String> agentCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AgentsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentsTable> {
  $$AgentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get healthPost => $composableBuilder(
    column: $table.healthPost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentCode => $composableBuilder(
    column: $table.agentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AgentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentsTable> {
  $$AgentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get healthPost => $composableBuilder(
    column: $table.healthPost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentCode => $composableBuilder(
    column: $table.agentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentsTable> {
  $$AgentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get healthPost => $composableBuilder(
    column: $table.healthPost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get agentCode =>
      $composableBuilder(column: $table.agentCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AgentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AgentsTable,
          Agent,
          $$AgentsTableFilterComposer,
          $$AgentsTableOrderingComposer,
          $$AgentsTableAnnotationComposer,
          $$AgentsTableCreateCompanionBuilder,
          $$AgentsTableUpdateCompanionBuilder,
          (Agent, BaseReferences<_$AppDatabase, $AgentsTable, Agent>),
          Agent,
          PrefetchHooks Function()
        > {
  $$AgentsTableTableManager(_$AppDatabase db, $AgentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> healthPost = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String> agentCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentsCompanion(
                id: id,
                email: email,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                district: district,
                healthPost: healthPost,
                role: role,
                agentCode: agentCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String firstName,
                required String lastName,
                Value<String?> phone = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> healthPost = const Value.absent(),
                Value<String?> role = const Value.absent(),
                required String agentCode,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AgentsCompanion.insert(
                id: id,
                email: email,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                district: district,
                healthPost: healthPost,
                role: role,
                agentCode: agentCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AgentsTable, Agent>(table),
                  BaseReferences<_$AppDatabase, $AgentsTable, Agent>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AgentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AgentsTable,
      Agent,
      $$AgentsTableFilterComposer,
      $$AgentsTableOrderingComposer,
      $$AgentsTableAnnotationComposer,
      $$AgentsTableCreateCompanionBuilder,
      $$AgentsTableUpdateCompanionBuilder,
      (Agent, BaseReferences<_$AppDatabase, $AgentsTable, Agent>),
      Agent,
      PrefetchHooks Function()
    >;
typedef $$PatientsTableCreateCompanionBuilder =
    PatientsCompanion Function({
      required String id,
      required String lastName,
      required String firstName,
      required int ageYears,
      required DateTime ageRecordedAt,
      required String sex,
      required String village,
      Value<String?> phone,
      required String createdByAgentId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$PatientsTableUpdateCompanionBuilder =
    PatientsCompanion Function({
      Value<String> id,
      Value<String> lastName,
      Value<String> firstName,
      Value<int> ageYears,
      Value<DateTime> ageRecordedAt,
      Value<String> sex,
      Value<String> village,
      Value<String?> phone,
      Value<String> createdByAgentId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$PatientsTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTable, Patient> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ConsultationsTable, List<Consultation>>
  _consultationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.consultations,
    aliasName: 'patients__id__consultations__patient_id',
  );

  $$ConsultationsTableProcessedTableManager get consultationsRefs {
    final manager = $$ConsultationsTableTableManager(
      $_db,
      $_db.consultations,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_consultationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ageRecordedAt => $composableBuilder(
    column: $table.ageRecordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByAgentId => $composableBuilder(
    column: $table.createdByAgentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> consultationsRefs(
    Expression<bool> Function($$ConsultationsTableFilterComposer f) f,
  ) {
    final $$ConsultationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableFilterComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageYears => $composableBuilder(
    column: $table.ageYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ageRecordedAt => $composableBuilder(
    column: $table.ageRecordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByAgentId => $composableBuilder(
    column: $table.createdByAgentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<int> get ageYears =>
      $composableBuilder(column: $table.ageYears, builder: (column) => column);

  GeneratedColumn<DateTime> get ageRecordedAt => $composableBuilder(
    column: $table.ageRecordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get createdByAgentId => $composableBuilder(
    column: $table.createdByAgentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  Expression<T> consultationsRefs<T extends Object>(
    Expression<T> Function($$ConsultationsTableAnnotationComposer a) f,
  ) {
    final $$ConsultationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.consultations,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsultationsTableAnnotationComposer(
            $db: $db,
            $table: $db.consultations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          Patient,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (Patient, $$PatientsTableReferences),
          Patient,
          PrefetchHooks Function({bool consultationsRefs})
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<int> ageYears = const Value.absent(),
                Value<DateTime> ageRecordedAt = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<String> village = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> createdByAgentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                lastName: lastName,
                firstName: firstName,
                ageYears: ageYears,
                ageRecordedAt: ageRecordedAt,
                sex: sex,
                village: village,
                phone: phone,
                createdByAgentId: createdByAgentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lastName,
                required String firstName,
                required int ageYears,
                required DateTime ageRecordedAt,
                required String sex,
                required String village,
                Value<String?> phone = const Value.absent(),
                required String createdByAgentId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                lastName: lastName,
                firstName: firstName,
                ageYears: ageYears,
                ageRecordedAt: ageRecordedAt,
                sex: sex,
                village: village,
                phone: phone,
                createdByAgentId: createdByAgentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PatientsTable, Patient>(table),
                  $$PatientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({consultationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (consultationsRefs) db.consultations,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (consultationsRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      Consultation
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._consultationsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PatientsTableReferences(
                        db,
                        table,
                        p0,
                      ).consultationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.patientId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      Patient,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (Patient, $$PatientsTableReferences),
      Patient,
      PrefetchHooks Function({bool consultationsRefs})
    >;
typedef $$ConsultationsTableCreateCompanionBuilder =
    ConsultationsCompanion Function({
      required String id,
      required String patientId,
      required String agentId,
      Value<String> status,
      Value<String> currentStep,
      Value<String?> consentStatus,
      Value<DateTime?> consentAt,
      Value<String?> transcriptRaw,
      Value<String?> transcriptEdited,
      Value<String?> structuredJson,
      Value<String?> missingJson,
      Value<String?> urgencyProposed,
      Value<String?> urgencyReasonsJson,
      Value<String?> urgencyFinal,
      Value<String?> urgencyOverrideReason,
      Value<String?> checklistJson,
      Value<String> syncStatus,
      Value<int> syncAttempts,
      Value<String?> syncError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> validatedAt,
      Value<int> rowid,
    });
typedef $$ConsultationsTableUpdateCompanionBuilder =
    ConsultationsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> agentId,
      Value<String> status,
      Value<String> currentStep,
      Value<String?> consentStatus,
      Value<DateTime?> consentAt,
      Value<String?> transcriptRaw,
      Value<String?> transcriptEdited,
      Value<String?> structuredJson,
      Value<String?> missingJson,
      Value<String?> urgencyProposed,
      Value<String?> urgencyReasonsJson,
      Value<String?> urgencyFinal,
      Value<String?> urgencyOverrideReason,
      Value<String?> checklistJson,
      Value<String> syncStatus,
      Value<int> syncAttempts,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> validatedAt,
      Value<int> rowid,
    });

final class $$ConsultationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConsultationsTable, Consultation> {
  $$ConsultationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('consultations__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentId => $composableBuilder(
    column: $table.agentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consentStatus => $composableBuilder(
    column: $table.consentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get consentAt => $composableBuilder(
    column: $table.consentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptRaw => $composableBuilder(
    column: $table.transcriptRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptEdited => $composableBuilder(
    column: $table.transcriptEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structuredJson => $composableBuilder(
    column: $table.structuredJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missingJson => $composableBuilder(
    column: $table.missingJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urgencyProposed => $composableBuilder(
    column: $table.urgencyProposed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urgencyReasonsJson => $composableBuilder(
    column: $table.urgencyReasonsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urgencyFinal => $composableBuilder(
    column: $table.urgencyFinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urgencyOverrideReason => $composableBuilder(
    column: $table.urgencyOverrideReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncAttempts => $composableBuilder(
    column: $table.syncAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get validatedAt => $composableBuilder(
    column: $table.validatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentId => $composableBuilder(
    column: $table.agentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consentStatus => $composableBuilder(
    column: $table.consentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get consentAt => $composableBuilder(
    column: $table.consentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptRaw => $composableBuilder(
    column: $table.transcriptRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptEdited => $composableBuilder(
    column: $table.transcriptEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structuredJson => $composableBuilder(
    column: $table.structuredJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missingJson => $composableBuilder(
    column: $table.missingJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urgencyProposed => $composableBuilder(
    column: $table.urgencyProposed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urgencyReasonsJson => $composableBuilder(
    column: $table.urgencyReasonsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urgencyFinal => $composableBuilder(
    column: $table.urgencyFinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urgencyOverrideReason => $composableBuilder(
    column: $table.urgencyOverrideReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncAttempts => $composableBuilder(
    column: $table.syncAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get validatedAt => $composableBuilder(
    column: $table.validatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consentStatus => $composableBuilder(
    column: $table.consentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get consentAt =>
      $composableBuilder(column: $table.consentAt, builder: (column) => column);

  GeneratedColumn<String> get transcriptRaw => $composableBuilder(
    column: $table.transcriptRaw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcriptEdited => $composableBuilder(
    column: $table.transcriptEdited,
    builder: (column) => column,
  );

  GeneratedColumn<String> get structuredJson => $composableBuilder(
    column: $table.structuredJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get missingJson => $composableBuilder(
    column: $table.missingJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urgencyProposed => $composableBuilder(
    column: $table.urgencyProposed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urgencyReasonsJson => $composableBuilder(
    column: $table.urgencyReasonsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urgencyFinal => $composableBuilder(
    column: $table.urgencyFinal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get urgencyOverrideReason => $composableBuilder(
    column: $table.urgencyOverrideReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncAttempts => $composableBuilder(
    column: $table.syncAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get validatedAt => $composableBuilder(
    column: $table.validatedAt,
    builder: (column) => column,
  );

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConsultationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsultationsTable,
          Consultation,
          $$ConsultationsTableFilterComposer,
          $$ConsultationsTableOrderingComposer,
          $$ConsultationsTableAnnotationComposer,
          $$ConsultationsTableCreateCompanionBuilder,
          $$ConsultationsTableUpdateCompanionBuilder,
          (Consultation, $$ConsultationsTableReferences),
          Consultation,
          PrefetchHooks Function({bool patientId})
        > {
  $$ConsultationsTableTableManager(_$AppDatabase db, $ConsultationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsultationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsultationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsultationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> agentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> currentStep = const Value.absent(),
                Value<String?> consentStatus = const Value.absent(),
                Value<DateTime?> consentAt = const Value.absent(),
                Value<String?> transcriptRaw = const Value.absent(),
                Value<String?> transcriptEdited = const Value.absent(),
                Value<String?> structuredJson = const Value.absent(),
                Value<String?> missingJson = const Value.absent(),
                Value<String?> urgencyProposed = const Value.absent(),
                Value<String?> urgencyReasonsJson = const Value.absent(),
                Value<String?> urgencyFinal = const Value.absent(),
                Value<String?> urgencyOverrideReason = const Value.absent(),
                Value<String?> checklistJson = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncAttempts = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> validatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsultationsCompanion(
                id: id,
                patientId: patientId,
                agentId: agentId,
                status: status,
                currentStep: currentStep,
                consentStatus: consentStatus,
                consentAt: consentAt,
                transcriptRaw: transcriptRaw,
                transcriptEdited: transcriptEdited,
                structuredJson: structuredJson,
                missingJson: missingJson,
                urgencyProposed: urgencyProposed,
                urgencyReasonsJson: urgencyReasonsJson,
                urgencyFinal: urgencyFinal,
                urgencyOverrideReason: urgencyOverrideReason,
                checklistJson: checklistJson,
                syncStatus: syncStatus,
                syncAttempts: syncAttempts,
                syncError: syncError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                validatedAt: validatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String agentId,
                Value<String> status = const Value.absent(),
                Value<String> currentStep = const Value.absent(),
                Value<String?> consentStatus = const Value.absent(),
                Value<DateTime?> consentAt = const Value.absent(),
                Value<String?> transcriptRaw = const Value.absent(),
                Value<String?> transcriptEdited = const Value.absent(),
                Value<String?> structuredJson = const Value.absent(),
                Value<String?> missingJson = const Value.absent(),
                Value<String?> urgencyProposed = const Value.absent(),
                Value<String?> urgencyReasonsJson = const Value.absent(),
                Value<String?> urgencyFinal = const Value.absent(),
                Value<String?> urgencyOverrideReason = const Value.absent(),
                Value<String?> checklistJson = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncAttempts = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> validatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsultationsCompanion.insert(
                id: id,
                patientId: patientId,
                agentId: agentId,
                status: status,
                currentStep: currentStep,
                consentStatus: consentStatus,
                consentAt: consentAt,
                transcriptRaw: transcriptRaw,
                transcriptEdited: transcriptEdited,
                structuredJson: structuredJson,
                missingJson: missingJson,
                urgencyProposed: urgencyProposed,
                urgencyReasonsJson: urgencyReasonsJson,
                urgencyFinal: urgencyFinal,
                urgencyOverrideReason: urgencyOverrideReason,
                checklistJson: checklistJson,
                syncStatus: syncStatus,
                syncAttempts: syncAttempts,
                syncError: syncError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                validatedAt: validatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConsultationsTable, Consultation>(table),
                  $$ConsultationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable: $$ConsultationsTableReferences
                                    ._patientIdTable(db),
                                referencedColumn: $$ConsultationsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConsultationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsultationsTable,
      Consultation,
      $$ConsultationsTableFilterComposer,
      $$ConsultationsTableOrderingComposer,
      $$ConsultationsTableAnnotationComposer,
      $$ConsultationsTableCreateCompanionBuilder,
      $$ConsultationsTableUpdateCompanionBuilder,
      (Consultation, $$ConsultationsTableReferences),
      Consultation,
      PrefetchHooks Function({bool patientId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AgentsTableTableManager get agents =>
      $$AgentsTableTableManager(_db, _db.agents);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$ConsultationsTableTableManager get consultations =>
      $$ConsultationsTableTableManager(_db, _db.consultations);
}

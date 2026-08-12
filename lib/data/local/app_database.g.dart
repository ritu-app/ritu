// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
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
  static const VerificationMeta _onboardingCompletedAtMeta =
      const VerificationMeta('onboardingCompletedAt');
  @override
  late final GeneratedColumn<DateTime> onboardingCompletedAt =
      GeneratedColumn<DateTime>(
        'onboarding_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _typicalPeriodDaysMeta = const VerificationMeta(
    'typicalPeriodDays',
  );
  @override
  late final GeneratedColumn<int> typicalPeriodDays = GeneratedColumn<int>(
    'typical_period_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    createdAt,
    onboardingCompletedAt,
    typicalPeriodDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('onboarding_completed_at')) {
      context.handle(
        _onboardingCompletedAtMeta,
        onboardingCompletedAt.isAcceptableOrUnknown(
          data['onboarding_completed_at']!,
          _onboardingCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('typical_period_days')) {
      context.handle(
        _typicalPeriodDaysMeta,
        typicalPeriodDays.isAcceptableOrUnknown(
          data['typical_period_days']!,
          _typicalPeriodDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      onboardingCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}onboarding_completed_at'],
      ),
      typicalPeriodDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}typical_period_days'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final String displayName;
  final DateTime createdAt;
  final DateTime? onboardingCompletedAt;

  /// Typical bleed length in days (e.g. 3, 5, 7). Null means "Varies".
  final int? typicalPeriodDays;
  const ProfileRow({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.onboardingCompletedAt,
    this.typicalPeriodDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] = Variable<DateTime>(
        onboardingCompletedAt,
      );
    }
    if (!nullToAbsent || typicalPeriodDays != null) {
      map['typical_period_days'] = Variable<int>(typicalPeriodDays);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
      typicalPeriodDays: typicalPeriodDays == null && nullToAbsent
          ? const Value.absent()
          : Value(typicalPeriodDays),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      onboardingCompletedAt: serializer.fromJson<DateTime?>(
        json['onboardingCompletedAt'],
      ),
      typicalPeriodDays: serializer.fromJson<int?>(json['typicalPeriodDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'onboardingCompletedAt': serializer.toJson<DateTime?>(
        onboardingCompletedAt,
      ),
      'typicalPeriodDays': serializer.toJson<int?>(typicalPeriodDays),
    };
  }

  ProfileRow copyWith({
    int? id,
    String? displayName,
    DateTime? createdAt,
    Value<DateTime?> onboardingCompletedAt = const Value.absent(),
    Value<int?> typicalPeriodDays = const Value.absent(),
  }) => ProfileRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt ?? this.createdAt,
    onboardingCompletedAt: onboardingCompletedAt.present
        ? onboardingCompletedAt.value
        : this.onboardingCompletedAt,
    typicalPeriodDays: typicalPeriodDays.present
        ? typicalPeriodDays.value
        : this.typicalPeriodDays,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
      typicalPeriodDays: data.typicalPeriodDays.present
          ? data.typicalPeriodDays.value
          : this.typicalPeriodDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('typicalPeriodDays: $typicalPeriodDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    createdAt,
    onboardingCompletedAt,
    typicalPeriodDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.onboardingCompletedAt == this.onboardingCompletedAt &&
          other.typicalPeriodDays == this.typicalPeriodDays);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime?> onboardingCompletedAt;
  final Value<int?> typicalPeriodDays;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.typicalPeriodDays = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required DateTime createdAt,
    this.onboardingCompletedAt = const Value.absent(),
    this.typicalPeriodDays = const Value.absent(),
  }) : displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? onboardingCompletedAt,
    Expression<int>? typicalPeriodDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (typicalPeriodDays != null) 'typical_period_days': typicalPeriodDays,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<DateTime>? createdAt,
    Value<DateTime?>? onboardingCompletedAt,
    Value<int?>? typicalPeriodDays,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      typicalPeriodDays: typicalPeriodDays ?? this.typicalPeriodDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] = Variable<DateTime>(
        onboardingCompletedAt.value,
      );
    }
    if (typicalPeriodDays.present) {
      map['typical_period_days'] = Variable<int>(typicalPeriodDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('typicalPeriodDays: $typicalPeriodDays')
          ..write(')'))
        .toString();
  }
}

class $PeriodLogsTable extends PeriodLogs
    with TableInfo<$PeriodLogsTable, PeriodLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedOnMeta = const VerificationMeta(
    'startedOn',
  );
  @override
  late final GeneratedColumn<DateTime> startedOn = GeneratedColumn<DateTime>(
    'started_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedOnMeta = const VerificationMeta(
    'endedOn',
  );
  @override
  late final GeneratedColumn<DateTime> endedOn = GeneratedColumn<DateTime>(
    'ended_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startSourceMeta = const VerificationMeta(
    'startSource',
  );
  @override
  late final GeneratedColumn<String> startSource = GeneratedColumn<String>(
    'start_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(PeriodStartSources.periodHistory),
  );
  static const VerificationMeta _startConfidenceMeta = const VerificationMeta(
    'startConfidence',
  );
  @override
  late final GeneratedColumn<String> startConfidence = GeneratedColumn<String>(
    'start_confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(PeriodStartConfidence.manual),
  );
  static const VerificationMeta _endStatusMeta = const VerificationMeta(
    'endStatus',
  );
  @override
  late final GeneratedColumn<String> endStatus = GeneratedColumn<String>(
    'end_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(PeriodEndStatus.unknown),
  );
  static const VerificationMeta _endSourceMeta = const VerificationMeta(
    'endSource',
  );
  @override
  late final GeneratedColumn<String> endSource = GeneratedColumn<String>(
    'end_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endConfidenceMeta = const VerificationMeta(
    'endConfidence',
  );
  @override
  late final GeneratedColumn<String> endConfidence = GeneratedColumn<String>(
    'end_confidence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roughDurationBucketMeta =
      const VerificationMeta('roughDurationBucket');
  @override
  late final GeneratedColumn<String> roughDurationBucket =
      GeneratedColumn<String>(
        'rough_duration_bucket',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedOn,
    endedOn,
    source,
    startSource,
    startConfidence,
    endStatus,
    endSource,
    endConfidence,
    roughDurationBucket,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_on')) {
      context.handle(
        _startedOnMeta,
        startedOn.isAcceptableOrUnknown(data['started_on']!, _startedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startedOnMeta);
    }
    if (data.containsKey('ended_on')) {
      context.handle(
        _endedOnMeta,
        endedOn.isAcceptableOrUnknown(data['ended_on']!, _endedOnMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('start_source')) {
      context.handle(
        _startSourceMeta,
        startSource.isAcceptableOrUnknown(
          data['start_source']!,
          _startSourceMeta,
        ),
      );
    }
    if (data.containsKey('start_confidence')) {
      context.handle(
        _startConfidenceMeta,
        startConfidence.isAcceptableOrUnknown(
          data['start_confidence']!,
          _startConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('end_status')) {
      context.handle(
        _endStatusMeta,
        endStatus.isAcceptableOrUnknown(data['end_status']!, _endStatusMeta),
      );
    }
    if (data.containsKey('end_source')) {
      context.handle(
        _endSourceMeta,
        endSource.isAcceptableOrUnknown(data['end_source']!, _endSourceMeta),
      );
    }
    if (data.containsKey('end_confidence')) {
      context.handle(
        _endConfidenceMeta,
        endConfidence.isAcceptableOrUnknown(
          data['end_confidence']!,
          _endConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('rough_duration_bucket')) {
      context.handle(
        _roughDurationBucketMeta,
        roughDurationBucket.isAcceptableOrUnknown(
          data['rough_duration_bucket']!,
          _roughDurationBucketMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {startedOn},
  ];
  @override
  PeriodLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_on'],
      )!,
      endedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_on'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      startSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_source'],
      )!,
      startConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_confidence'],
      )!,
      endStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_status'],
      )!,
      endSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_source'],
      ),
      endConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_confidence'],
      ),
      roughDurationBucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rough_duration_bucket'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PeriodLogsTable createAlias(String alias) {
    return $PeriodLogsTable(attachedDatabase, alias);
  }
}

class PeriodLogRow extends DataClass implements Insertable<PeriodLogRow> {
  final int id;

  /// Calendar date the period started (time component ignored).
  final DateTime startedOn;

  /// Inclusive last bleed day. Null = unknown / still open.
  final DateTime? endedOn;

  /// Legacy provenance: onboarding_last, onboarding_past, calendar, settings,
  /// manual.
  final String source;
  final String startSource;
  final String startConfidence;
  final String endStatus;
  final String? endSource;
  final String? endConfidence;
  final String? roughDurationBucket;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PeriodLogRow({
    required this.id,
    required this.startedOn,
    this.endedOn,
    required this.source,
    required this.startSource,
    required this.startConfidence,
    required this.endStatus,
    this.endSource,
    this.endConfidence,
    this.roughDurationBucket,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_on'] = Variable<DateTime>(startedOn);
    if (!nullToAbsent || endedOn != null) {
      map['ended_on'] = Variable<DateTime>(endedOn);
    }
    map['source'] = Variable<String>(source);
    map['start_source'] = Variable<String>(startSource);
    map['start_confidence'] = Variable<String>(startConfidence);
    map['end_status'] = Variable<String>(endStatus);
    if (!nullToAbsent || endSource != null) {
      map['end_source'] = Variable<String>(endSource);
    }
    if (!nullToAbsent || endConfidence != null) {
      map['end_confidence'] = Variable<String>(endConfidence);
    }
    if (!nullToAbsent || roughDurationBucket != null) {
      map['rough_duration_bucket'] = Variable<String>(roughDurationBucket);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PeriodLogsCompanion toCompanion(bool nullToAbsent) {
    return PeriodLogsCompanion(
      id: Value(id),
      startedOn: Value(startedOn),
      endedOn: endedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endedOn),
      source: Value(source),
      startSource: Value(startSource),
      startConfidence: Value(startConfidence),
      endStatus: Value(endStatus),
      endSource: endSource == null && nullToAbsent
          ? const Value.absent()
          : Value(endSource),
      endConfidence: endConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(endConfidence),
      roughDurationBucket: roughDurationBucket == null && nullToAbsent
          ? const Value.absent()
          : Value(roughDurationBucket),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PeriodLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodLogRow(
      id: serializer.fromJson<int>(json['id']),
      startedOn: serializer.fromJson<DateTime>(json['startedOn']),
      endedOn: serializer.fromJson<DateTime?>(json['endedOn']),
      source: serializer.fromJson<String>(json['source']),
      startSource: serializer.fromJson<String>(json['startSource']),
      startConfidence: serializer.fromJson<String>(json['startConfidence']),
      endStatus: serializer.fromJson<String>(json['endStatus']),
      endSource: serializer.fromJson<String?>(json['endSource']),
      endConfidence: serializer.fromJson<String?>(json['endConfidence']),
      roughDurationBucket: serializer.fromJson<String?>(
        json['roughDurationBucket'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedOn': serializer.toJson<DateTime>(startedOn),
      'endedOn': serializer.toJson<DateTime?>(endedOn),
      'source': serializer.toJson<String>(source),
      'startSource': serializer.toJson<String>(startSource),
      'startConfidence': serializer.toJson<String>(startConfidence),
      'endStatus': serializer.toJson<String>(endStatus),
      'endSource': serializer.toJson<String?>(endSource),
      'endConfidence': serializer.toJson<String?>(endConfidence),
      'roughDurationBucket': serializer.toJson<String?>(roughDurationBucket),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PeriodLogRow copyWith({
    int? id,
    DateTime? startedOn,
    Value<DateTime?> endedOn = const Value.absent(),
    String? source,
    String? startSource,
    String? startConfidence,
    String? endStatus,
    Value<String?> endSource = const Value.absent(),
    Value<String?> endConfidence = const Value.absent(),
    Value<String?> roughDurationBucket = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PeriodLogRow(
    id: id ?? this.id,
    startedOn: startedOn ?? this.startedOn,
    endedOn: endedOn.present ? endedOn.value : this.endedOn,
    source: source ?? this.source,
    startSource: startSource ?? this.startSource,
    startConfidence: startConfidence ?? this.startConfidence,
    endStatus: endStatus ?? this.endStatus,
    endSource: endSource.present ? endSource.value : this.endSource,
    endConfidence: endConfidence.present
        ? endConfidence.value
        : this.endConfidence,
    roughDurationBucket: roughDurationBucket.present
        ? roughDurationBucket.value
        : this.roughDurationBucket,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PeriodLogRow copyWithCompanion(PeriodLogsCompanion data) {
    return PeriodLogRow(
      id: data.id.present ? data.id.value : this.id,
      startedOn: data.startedOn.present ? data.startedOn.value : this.startedOn,
      endedOn: data.endedOn.present ? data.endedOn.value : this.endedOn,
      source: data.source.present ? data.source.value : this.source,
      startSource: data.startSource.present
          ? data.startSource.value
          : this.startSource,
      startConfidence: data.startConfidence.present
          ? data.startConfidence.value
          : this.startConfidence,
      endStatus: data.endStatus.present ? data.endStatus.value : this.endStatus,
      endSource: data.endSource.present ? data.endSource.value : this.endSource,
      endConfidence: data.endConfidence.present
          ? data.endConfidence.value
          : this.endConfidence,
      roughDurationBucket: data.roughDurationBucket.present
          ? data.roughDurationBucket.value
          : this.roughDurationBucket,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodLogRow(')
          ..write('id: $id, ')
          ..write('startedOn: $startedOn, ')
          ..write('endedOn: $endedOn, ')
          ..write('source: $source, ')
          ..write('startSource: $startSource, ')
          ..write('startConfidence: $startConfidence, ')
          ..write('endStatus: $endStatus, ')
          ..write('endSource: $endSource, ')
          ..write('endConfidence: $endConfidence, ')
          ..write('roughDurationBucket: $roughDurationBucket, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedOn,
    endedOn,
    source,
    startSource,
    startConfidence,
    endStatus,
    endSource,
    endConfidence,
    roughDurationBucket,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodLogRow &&
          other.id == this.id &&
          other.startedOn == this.startedOn &&
          other.endedOn == this.endedOn &&
          other.source == this.source &&
          other.startSource == this.startSource &&
          other.startConfidence == this.startConfidence &&
          other.endStatus == this.endStatus &&
          other.endSource == this.endSource &&
          other.endConfidence == this.endConfidence &&
          other.roughDurationBucket == this.roughDurationBucket &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PeriodLogsCompanion extends UpdateCompanion<PeriodLogRow> {
  final Value<int> id;
  final Value<DateTime> startedOn;
  final Value<DateTime?> endedOn;
  final Value<String> source;
  final Value<String> startSource;
  final Value<String> startConfidence;
  final Value<String> endStatus;
  final Value<String?> endSource;
  final Value<String?> endConfidence;
  final Value<String?> roughDurationBucket;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PeriodLogsCompanion({
    this.id = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.endedOn = const Value.absent(),
    this.source = const Value.absent(),
    this.startSource = const Value.absent(),
    this.startConfidence = const Value.absent(),
    this.endStatus = const Value.absent(),
    this.endSource = const Value.absent(),
    this.endConfidence = const Value.absent(),
    this.roughDurationBucket = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PeriodLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedOn,
    this.endedOn = const Value.absent(),
    required String source,
    this.startSource = const Value.absent(),
    this.startConfidence = const Value.absent(),
    this.endStatus = const Value.absent(),
    this.endSource = const Value.absent(),
    this.endConfidence = const Value.absent(),
    this.roughDurationBucket = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : startedOn = Value(startedOn),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PeriodLogRow> custom({
    Expression<int>? id,
    Expression<DateTime>? startedOn,
    Expression<DateTime>? endedOn,
    Expression<String>? source,
    Expression<String>? startSource,
    Expression<String>? startConfidence,
    Expression<String>? endStatus,
    Expression<String>? endSource,
    Expression<String>? endConfidence,
    Expression<String>? roughDurationBucket,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedOn != null) 'started_on': startedOn,
      if (endedOn != null) 'ended_on': endedOn,
      if (source != null) 'source': source,
      if (startSource != null) 'start_source': startSource,
      if (startConfidence != null) 'start_confidence': startConfidence,
      if (endStatus != null) 'end_status': endStatus,
      if (endSource != null) 'end_source': endSource,
      if (endConfidence != null) 'end_confidence': endConfidence,
      if (roughDurationBucket != null)
        'rough_duration_bucket': roughDurationBucket,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PeriodLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedOn,
    Value<DateTime?>? endedOn,
    Value<String>? source,
    Value<String>? startSource,
    Value<String>? startConfidence,
    Value<String>? endStatus,
    Value<String?>? endSource,
    Value<String?>? endConfidence,
    Value<String?>? roughDurationBucket,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PeriodLogsCompanion(
      id: id ?? this.id,
      startedOn: startedOn ?? this.startedOn,
      endedOn: endedOn ?? this.endedOn,
      source: source ?? this.source,
      startSource: startSource ?? this.startSource,
      startConfidence: startConfidence ?? this.startConfidence,
      endStatus: endStatus ?? this.endStatus,
      endSource: endSource ?? this.endSource,
      endConfidence: endConfidence ?? this.endConfidence,
      roughDurationBucket: roughDurationBucket ?? this.roughDurationBucket,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedOn.present) {
      map['started_on'] = Variable<DateTime>(startedOn.value);
    }
    if (endedOn.present) {
      map['ended_on'] = Variable<DateTime>(endedOn.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (startSource.present) {
      map['start_source'] = Variable<String>(startSource.value);
    }
    if (startConfidence.present) {
      map['start_confidence'] = Variable<String>(startConfidence.value);
    }
    if (endStatus.present) {
      map['end_status'] = Variable<String>(endStatus.value);
    }
    if (endSource.present) {
      map['end_source'] = Variable<String>(endSource.value);
    }
    if (endConfidence.present) {
      map['end_confidence'] = Variable<String>(endConfidence.value);
    }
    if (roughDurationBucket.present) {
      map['rough_duration_bucket'] = Variable<String>(
        roughDurationBucket.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodLogsCompanion(')
          ..write('id: $id, ')
          ..write('startedOn: $startedOn, ')
          ..write('endedOn: $endedOn, ')
          ..write('source: $source, ')
          ..write('startSource: $startSource, ')
          ..write('startConfidence: $startConfidence, ')
          ..write('endStatus: $endStatus, ')
          ..write('endSource: $endSource, ')
          ..write('endConfidence: $endConfidence, ')
          ..write('roughDurationBucket: $roughDurationBucket, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PeriodEndPromptsTable extends PeriodEndPrompts
    with TableInfo<$PeriodEndPromptsTable, PeriodEndPromptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodEndPromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _periodLogIdMeta = const VerificationMeta(
    'periodLogId',
  );
  @override
  late final GeneratedColumn<int> periodLogId = GeneratedColumn<int>(
    'period_log_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shownOnMeta = const VerificationMeta(
    'shownOn',
  );
  @override
  late final GeneratedColumn<DateTime> shownOn = GeneratedColumn<DateTime>(
    'shown_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseMeta = const VerificationMeta(
    'response',
  );
  @override
  late final GeneratedColumn<String> response = GeneratedColumn<String>(
    'response',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _respondedOnMeta = const VerificationMeta(
    'respondedOn',
  );
  @override
  late final GeneratedColumn<DateTime> respondedOn = GeneratedColumn<DateTime>(
    'responded_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    periodLogId,
    shownOn,
    response,
    respondedOn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_end_prompts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodEndPromptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_log_id')) {
      context.handle(
        _periodLogIdMeta,
        periodLogId.isAcceptableOrUnknown(
          data['period_log_id']!,
          _periodLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodLogIdMeta);
    }
    if (data.containsKey('shown_on')) {
      context.handle(
        _shownOnMeta,
        shownOn.isAcceptableOrUnknown(data['shown_on']!, _shownOnMeta),
      );
    } else if (isInserting) {
      context.missing(_shownOnMeta);
    }
    if (data.containsKey('response')) {
      context.handle(
        _responseMeta,
        response.isAcceptableOrUnknown(data['response']!, _responseMeta),
      );
    }
    if (data.containsKey('responded_on')) {
      context.handle(
        _respondedOnMeta,
        respondedOn.isAcceptableOrUnknown(
          data['responded_on']!,
          _respondedOnMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeriodEndPromptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodEndPromptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      periodLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_log_id'],
      )!,
      shownOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shown_on'],
      )!,
      response: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response'],
      ),
      respondedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}responded_on'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PeriodEndPromptsTable createAlias(String alias) {
    return $PeriodEndPromptsTable(attachedDatabase, alias);
  }
}

class PeriodEndPromptRow extends DataClass
    implements Insertable<PeriodEndPromptRow> {
  final int id;
  final int periodLogId;
  final DateTime shownOn;

  /// `still_going`, `ended`, or `dismissed`.
  final String? response;
  final DateTime? respondedOn;
  final DateTime createdAt;
  const PeriodEndPromptRow({
    required this.id,
    required this.periodLogId,
    required this.shownOn,
    this.response,
    this.respondedOn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_log_id'] = Variable<int>(periodLogId);
    map['shown_on'] = Variable<DateTime>(shownOn);
    if (!nullToAbsent || response != null) {
      map['response'] = Variable<String>(response);
    }
    if (!nullToAbsent || respondedOn != null) {
      map['responded_on'] = Variable<DateTime>(respondedOn);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PeriodEndPromptsCompanion toCompanion(bool nullToAbsent) {
    return PeriodEndPromptsCompanion(
      id: Value(id),
      periodLogId: Value(periodLogId),
      shownOn: Value(shownOn),
      response: response == null && nullToAbsent
          ? const Value.absent()
          : Value(response),
      respondedOn: respondedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(respondedOn),
      createdAt: Value(createdAt),
    );
  }

  factory PeriodEndPromptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodEndPromptRow(
      id: serializer.fromJson<int>(json['id']),
      periodLogId: serializer.fromJson<int>(json['periodLogId']),
      shownOn: serializer.fromJson<DateTime>(json['shownOn']),
      response: serializer.fromJson<String?>(json['response']),
      respondedOn: serializer.fromJson<DateTime?>(json['respondedOn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodLogId': serializer.toJson<int>(periodLogId),
      'shownOn': serializer.toJson<DateTime>(shownOn),
      'response': serializer.toJson<String?>(response),
      'respondedOn': serializer.toJson<DateTime?>(respondedOn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PeriodEndPromptRow copyWith({
    int? id,
    int? periodLogId,
    DateTime? shownOn,
    Value<String?> response = const Value.absent(),
    Value<DateTime?> respondedOn = const Value.absent(),
    DateTime? createdAt,
  }) => PeriodEndPromptRow(
    id: id ?? this.id,
    periodLogId: periodLogId ?? this.periodLogId,
    shownOn: shownOn ?? this.shownOn,
    response: response.present ? response.value : this.response,
    respondedOn: respondedOn.present ? respondedOn.value : this.respondedOn,
    createdAt: createdAt ?? this.createdAt,
  );
  PeriodEndPromptRow copyWithCompanion(PeriodEndPromptsCompanion data) {
    return PeriodEndPromptRow(
      id: data.id.present ? data.id.value : this.id,
      periodLogId: data.periodLogId.present
          ? data.periodLogId.value
          : this.periodLogId,
      shownOn: data.shownOn.present ? data.shownOn.value : this.shownOn,
      response: data.response.present ? data.response.value : this.response,
      respondedOn: data.respondedOn.present
          ? data.respondedOn.value
          : this.respondedOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodEndPromptRow(')
          ..write('id: $id, ')
          ..write('periodLogId: $periodLogId, ')
          ..write('shownOn: $shownOn, ')
          ..write('response: $response, ')
          ..write('respondedOn: $respondedOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, periodLogId, shownOn, response, respondedOn, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodEndPromptRow &&
          other.id == this.id &&
          other.periodLogId == this.periodLogId &&
          other.shownOn == this.shownOn &&
          other.response == this.response &&
          other.respondedOn == this.respondedOn &&
          other.createdAt == this.createdAt);
}

class PeriodEndPromptsCompanion extends UpdateCompanion<PeriodEndPromptRow> {
  final Value<int> id;
  final Value<int> periodLogId;
  final Value<DateTime> shownOn;
  final Value<String?> response;
  final Value<DateTime?> respondedOn;
  final Value<DateTime> createdAt;
  const PeriodEndPromptsCompanion({
    this.id = const Value.absent(),
    this.periodLogId = const Value.absent(),
    this.shownOn = const Value.absent(),
    this.response = const Value.absent(),
    this.respondedOn = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PeriodEndPromptsCompanion.insert({
    this.id = const Value.absent(),
    required int periodLogId,
    required DateTime shownOn,
    this.response = const Value.absent(),
    this.respondedOn = const Value.absent(),
    required DateTime createdAt,
  }) : periodLogId = Value(periodLogId),
       shownOn = Value(shownOn),
       createdAt = Value(createdAt);
  static Insertable<PeriodEndPromptRow> custom({
    Expression<int>? id,
    Expression<int>? periodLogId,
    Expression<DateTime>? shownOn,
    Expression<String>? response,
    Expression<DateTime>? respondedOn,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodLogId != null) 'period_log_id': periodLogId,
      if (shownOn != null) 'shown_on': shownOn,
      if (response != null) 'response': response,
      if (respondedOn != null) 'responded_on': respondedOn,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PeriodEndPromptsCompanion copyWith({
    Value<int>? id,
    Value<int>? periodLogId,
    Value<DateTime>? shownOn,
    Value<String?>? response,
    Value<DateTime?>? respondedOn,
    Value<DateTime>? createdAt,
  }) {
    return PeriodEndPromptsCompanion(
      id: id ?? this.id,
      periodLogId: periodLogId ?? this.periodLogId,
      shownOn: shownOn ?? this.shownOn,
      response: response ?? this.response,
      respondedOn: respondedOn ?? this.respondedOn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodLogId.present) {
      map['period_log_id'] = Variable<int>(periodLogId.value);
    }
    if (shownOn.present) {
      map['shown_on'] = Variable<DateTime>(shownOn.value);
    }
    if (response.present) {
      map['response'] = Variable<String>(response.value);
    }
    if (respondedOn.present) {
      map['responded_on'] = Variable<DateTime>(respondedOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodEndPromptsCompanion(')
          ..write('id: $id, ')
          ..write('periodLogId: $periodLogId, ')
          ..write('shownOn: $shownOn, ')
          ..write('response: $response, ')
          ..write('respondedOn: $respondedOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CustomSymptomsTable extends CustomSymptoms
    with TableInfo<$CustomSymptomsTable, CustomSymptomRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomSymptomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
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
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_symptoms';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomSymptomRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  CustomSymptomRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomSymptomRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomSymptomsTable createAlias(String alias) {
    return $CustomSymptomsTable(attachedDatabase, alias);
  }
}

class CustomSymptomRow extends DataClass
    implements Insertable<CustomSymptomRow> {
  final int id;
  final String name;
  final DateTime createdAt;
  const CustomSymptomRow({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomSymptomsCompanion toCompanion(bool nullToAbsent) {
    return CustomSymptomsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory CustomSymptomRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomSymptomRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomSymptomRow copyWith({int? id, String? name, DateTime? createdAt}) =>
      CustomSymptomRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  CustomSymptomRow copyWithCompanion(CustomSymptomsCompanion data) {
    return CustomSymptomRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomSymptomRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomSymptomRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class CustomSymptomsCompanion extends UpdateCompanion<CustomSymptomRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const CustomSymptomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomSymptomsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CustomSymptomRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomSymptomsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return CustomSymptomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomSymptomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyLogsTable extends DailyLogs
    with TableInfo<$DailyLogsTable, DailyLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _loggedOnMeta = const VerificationMeta(
    'loggedOn',
  );
  @override
  late final GeneratedColumn<DateTime> loggedOn = GeneratedColumn<DateTime>(
    'logged_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flowIntensityMeta = const VerificationMeta(
    'flowIntensity',
  );
  @override
  late final GeneratedColumn<String> flowIntensity = GeneratedColumn<String>(
    'flow_intensity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _crampIntensityMeta = const VerificationMeta(
    'crampIntensity',
  );
  @override
  late final GeneratedColumn<int> crampIntensity = GeneratedColumn<int>(
    'cramp_intensity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodsMeta = const VerificationMeta('moods');
  @override
  late final GeneratedColumn<String> moods = GeneratedColumn<String>(
    'moods',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyLevelMeta = const VerificationMeta(
    'energyLevel',
  );
  @override
  late final GeneratedColumn<String> energyLevel = GeneratedColumn<String>(
    'energy_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<String> sleepQuality = GeneratedColumn<String>(
    'sleep_quality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wellbeingMeta = const VerificationMeta(
    'wellbeing',
  );
  @override
  late final GeneratedColumn<int> wellbeing = GeneratedColumn<int>(
    'wellbeing',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    loggedOn,
    flowIntensity,
    crampIntensity,
    moods,
    energyLevel,
    sleepQuality,
    wellbeing,
    symptoms,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('logged_on')) {
      context.handle(
        _loggedOnMeta,
        loggedOn.isAcceptableOrUnknown(data['logged_on']!, _loggedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedOnMeta);
    }
    if (data.containsKey('flow_intensity')) {
      context.handle(
        _flowIntensityMeta,
        flowIntensity.isAcceptableOrUnknown(
          data['flow_intensity']!,
          _flowIntensityMeta,
        ),
      );
    }
    if (data.containsKey('cramp_intensity')) {
      context.handle(
        _crampIntensityMeta,
        crampIntensity.isAcceptableOrUnknown(
          data['cramp_intensity']!,
          _crampIntensityMeta,
        ),
      );
    }
    if (data.containsKey('moods')) {
      context.handle(
        _moodsMeta,
        moods.isAcceptableOrUnknown(data['moods']!, _moodsMeta),
      );
    }
    if (data.containsKey('energy_level')) {
      context.handle(
        _energyLevelMeta,
        energyLevel.isAcceptableOrUnknown(
          data['energy_level']!,
          _energyLevelMeta,
        ),
      );
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    }
    if (data.containsKey('wellbeing')) {
      context.handle(
        _wellbeingMeta,
        wellbeing.isAcceptableOrUnknown(data['wellbeing']!, _wellbeingMeta),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {loggedOn},
  ];
  @override
  DailyLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      loggedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_on'],
      )!,
      flowIntensity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flow_intensity'],
      ),
      crampIntensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cramp_intensity'],
      ),
      moods: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moods'],
      ),
      energyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}energy_level'],
      ),
      sleepQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sleep_quality'],
      ),
      wellbeing: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wellbeing'],
      ),
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }
}

class DailyLogRow extends DataClass implements Insertable<DailyLogRow> {
  final int id;

  /// Calendar date the entry is for (time component ignored).
  final DateTime loggedOn;

  /// none / spotting / light / medium / heavy. Null = not answered.
  final String? flowIntensity;

  /// 0-10 slider value. Null = not answered.
  final int? crampIntensity;

  /// JSON-encoded list of selected mood labels.
  final String? moods;
  final String? energyLevel;
  final String? sleepQuality;

  /// 0-10 slider value. Null = not answered.
  final int? wellbeing;

  /// JSON-encoded list of selected body signal labels (preset + custom).
  final String? symptoms;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyLogRow({
    required this.id,
    required this.loggedOn,
    this.flowIntensity,
    this.crampIntensity,
    this.moods,
    this.energyLevel,
    this.sleepQuality,
    this.wellbeing,
    this.symptoms,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['logged_on'] = Variable<DateTime>(loggedOn);
    if (!nullToAbsent || flowIntensity != null) {
      map['flow_intensity'] = Variable<String>(flowIntensity);
    }
    if (!nullToAbsent || crampIntensity != null) {
      map['cramp_intensity'] = Variable<int>(crampIntensity);
    }
    if (!nullToAbsent || moods != null) {
      map['moods'] = Variable<String>(moods);
    }
    if (!nullToAbsent || energyLevel != null) {
      map['energy_level'] = Variable<String>(energyLevel);
    }
    if (!nullToAbsent || sleepQuality != null) {
      map['sleep_quality'] = Variable<String>(sleepQuality);
    }
    if (!nullToAbsent || wellbeing != null) {
      map['wellbeing'] = Variable<int>(wellbeing);
    }
    if (!nullToAbsent || symptoms != null) {
      map['symptoms'] = Variable<String>(symptoms);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      id: Value(id),
      loggedOn: Value(loggedOn),
      flowIntensity: flowIntensity == null && nullToAbsent
          ? const Value.absent()
          : Value(flowIntensity),
      crampIntensity: crampIntensity == null && nullToAbsent
          ? const Value.absent()
          : Value(crampIntensity),
      moods: moods == null && nullToAbsent
          ? const Value.absent()
          : Value(moods),
      energyLevel: energyLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(energyLevel),
      sleepQuality: sleepQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepQuality),
      wellbeing: wellbeing == null && nullToAbsent
          ? const Value.absent()
          : Value(wellbeing),
      symptoms: symptoms == null && nullToAbsent
          ? const Value.absent()
          : Value(symptoms),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLogRow(
      id: serializer.fromJson<int>(json['id']),
      loggedOn: serializer.fromJson<DateTime>(json['loggedOn']),
      flowIntensity: serializer.fromJson<String?>(json['flowIntensity']),
      crampIntensity: serializer.fromJson<int?>(json['crampIntensity']),
      moods: serializer.fromJson<String?>(json['moods']),
      energyLevel: serializer.fromJson<String?>(json['energyLevel']),
      sleepQuality: serializer.fromJson<String?>(json['sleepQuality']),
      wellbeing: serializer.fromJson<int?>(json['wellbeing']),
      symptoms: serializer.fromJson<String?>(json['symptoms']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'loggedOn': serializer.toJson<DateTime>(loggedOn),
      'flowIntensity': serializer.toJson<String?>(flowIntensity),
      'crampIntensity': serializer.toJson<int?>(crampIntensity),
      'moods': serializer.toJson<String?>(moods),
      'energyLevel': serializer.toJson<String?>(energyLevel),
      'sleepQuality': serializer.toJson<String?>(sleepQuality),
      'wellbeing': serializer.toJson<int?>(wellbeing),
      'symptoms': serializer.toJson<String?>(symptoms),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyLogRow copyWith({
    int? id,
    DateTime? loggedOn,
    Value<String?> flowIntensity = const Value.absent(),
    Value<int?> crampIntensity = const Value.absent(),
    Value<String?> moods = const Value.absent(),
    Value<String?> energyLevel = const Value.absent(),
    Value<String?> sleepQuality = const Value.absent(),
    Value<int?> wellbeing = const Value.absent(),
    Value<String?> symptoms = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyLogRow(
    id: id ?? this.id,
    loggedOn: loggedOn ?? this.loggedOn,
    flowIntensity: flowIntensity.present
        ? flowIntensity.value
        : this.flowIntensity,
    crampIntensity: crampIntensity.present
        ? crampIntensity.value
        : this.crampIntensity,
    moods: moods.present ? moods.value : this.moods,
    energyLevel: energyLevel.present ? energyLevel.value : this.energyLevel,
    sleepQuality: sleepQuality.present ? sleepQuality.value : this.sleepQuality,
    wellbeing: wellbeing.present ? wellbeing.value : this.wellbeing,
    symptoms: symptoms.present ? symptoms.value : this.symptoms,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyLogRow copyWithCompanion(DailyLogsCompanion data) {
    return DailyLogRow(
      id: data.id.present ? data.id.value : this.id,
      loggedOn: data.loggedOn.present ? data.loggedOn.value : this.loggedOn,
      flowIntensity: data.flowIntensity.present
          ? data.flowIntensity.value
          : this.flowIntensity,
      crampIntensity: data.crampIntensity.present
          ? data.crampIntensity.value
          : this.crampIntensity,
      moods: data.moods.present ? data.moods.value : this.moods,
      energyLevel: data.energyLevel.present
          ? data.energyLevel.value
          : this.energyLevel,
      sleepQuality: data.sleepQuality.present
          ? data.sleepQuality.value
          : this.sleepQuality,
      wellbeing: data.wellbeing.present ? data.wellbeing.value : this.wellbeing,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogRow(')
          ..write('id: $id, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('flowIntensity: $flowIntensity, ')
          ..write('crampIntensity: $crampIntensity, ')
          ..write('moods: $moods, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('wellbeing: $wellbeing, ')
          ..write('symptoms: $symptoms, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    loggedOn,
    flowIntensity,
    crampIntensity,
    moods,
    energyLevel,
    sleepQuality,
    wellbeing,
    symptoms,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLogRow &&
          other.id == this.id &&
          other.loggedOn == this.loggedOn &&
          other.flowIntensity == this.flowIntensity &&
          other.crampIntensity == this.crampIntensity &&
          other.moods == this.moods &&
          other.energyLevel == this.energyLevel &&
          other.sleepQuality == this.sleepQuality &&
          other.wellbeing == this.wellbeing &&
          other.symptoms == this.symptoms &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLogRow> {
  final Value<int> id;
  final Value<DateTime> loggedOn;
  final Value<String?> flowIntensity;
  final Value<int?> crampIntensity;
  final Value<String?> moods;
  final Value<String?> energyLevel;
  final Value<String?> sleepQuality;
  final Value<int?> wellbeing;
  final Value<String?> symptoms;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DailyLogsCompanion({
    this.id = const Value.absent(),
    this.loggedOn = const Value.absent(),
    this.flowIntensity = const Value.absent(),
    this.crampIntensity = const Value.absent(),
    this.moods = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.wellbeing = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime loggedOn,
    this.flowIntensity = const Value.absent(),
    this.crampIntensity = const Value.absent(),
    this.moods = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.wellbeing = const Value.absent(),
    this.symptoms = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : loggedOn = Value(loggedOn),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DailyLogRow> custom({
    Expression<int>? id,
    Expression<DateTime>? loggedOn,
    Expression<String>? flowIntensity,
    Expression<int>? crampIntensity,
    Expression<String>? moods,
    Expression<String>? energyLevel,
    Expression<String>? sleepQuality,
    Expression<int>? wellbeing,
    Expression<String>? symptoms,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loggedOn != null) 'logged_on': loggedOn,
      if (flowIntensity != null) 'flow_intensity': flowIntensity,
      if (crampIntensity != null) 'cramp_intensity': crampIntensity,
      if (moods != null) 'moods': moods,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (wellbeing != null) 'wellbeing': wellbeing,
      if (symptoms != null) 'symptoms': symptoms,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? loggedOn,
    Value<String?>? flowIntensity,
    Value<int?>? crampIntensity,
    Value<String?>? moods,
    Value<String?>? energyLevel,
    Value<String?>? sleepQuality,
    Value<int?>? wellbeing,
    Value<String?>? symptoms,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DailyLogsCompanion(
      id: id ?? this.id,
      loggedOn: loggedOn ?? this.loggedOn,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      crampIntensity: crampIntensity ?? this.crampIntensity,
      moods: moods ?? this.moods,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      wellbeing: wellbeing ?? this.wellbeing,
      symptoms: symptoms ?? this.symptoms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (loggedOn.present) {
      map['logged_on'] = Variable<DateTime>(loggedOn.value);
    }
    if (flowIntensity.present) {
      map['flow_intensity'] = Variable<String>(flowIntensity.value);
    }
    if (crampIntensity.present) {
      map['cramp_intensity'] = Variable<int>(crampIntensity.value);
    }
    if (moods.present) {
      map['moods'] = Variable<String>(moods.value);
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<String>(energyLevel.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<String>(sleepQuality.value);
    }
    if (wellbeing.present) {
      map['wellbeing'] = Variable<int>(wellbeing.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('id: $id, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('flowIntensity: $flowIntensity, ')
          ..write('crampIntensity: $crampIntensity, ')
          ..write('moods: $moods, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('wellbeing: $wellbeing, ')
          ..write('symptoms: $symptoms, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _loggedOnMeta = const VerificationMeta(
    'loggedOn',
  );
  @override
  late final GeneratedColumn<DateTime> loggedOn = GeneratedColumn<DateTime>(
    'logged_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    loggedOn,
    body,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('logged_on')) {
      context.handle(
        _loggedOnMeta,
        loggedOn.isAcceptableOrUnknown(data['logged_on']!, _loggedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedOnMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {loggedOn},
  ];
  @override
  JournalEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      loggedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_on'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntryRow extends DataClass implements Insertable<JournalEntryRow> {
  final int id;

  /// Calendar date the reflection is for (time component ignored).
  final DateTime loggedOn;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  const JournalEntryRow({
    required this.id,
    required this.loggedOn,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['logged_on'] = Variable<DateTime>(loggedOn);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      loggedOn: Value(loggedOn),
      body: Value(body),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JournalEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntryRow(
      id: serializer.fromJson<int>(json['id']),
      loggedOn: serializer.fromJson<DateTime>(json['loggedOn']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'loggedOn': serializer.toJson<DateTime>(loggedOn),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JournalEntryRow copyWith({
    int? id,
    DateTime? loggedOn,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => JournalEntryRow(
    id: id ?? this.id,
    loggedOn: loggedOn ?? this.loggedOn,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JournalEntryRow copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntryRow(
      id: data.id.present ? data.id.value : this.id,
      loggedOn: data.loggedOn.present ? data.loggedOn.value : this.loggedOn,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntryRow(')
          ..write('id: $id, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, loggedOn, body, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntryRow &&
          other.id == this.id &&
          other.loggedOn == this.loggedOn &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntryRow> {
  final Value<int> id;
  final Value<DateTime> loggedOn;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.loggedOn = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime loggedOn,
    required String body,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : loggedOn = Value(loggedOn),
       body = Value(body),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JournalEntryRow> custom({
    Expression<int>? id,
    Expression<DateTime>? loggedOn,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loggedOn != null) 'logged_on': loggedOn,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? loggedOn,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      loggedOn: loggedOn ?? this.loggedOn,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (loggedOn.present) {
      map['logged_on'] = Variable<DateTime>(loggedOn.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $PeriodLogsTable periodLogs = $PeriodLogsTable(this);
  late final $PeriodEndPromptsTable periodEndPrompts = $PeriodEndPromptsTable(
    this,
  );
  late final $CustomSymptomsTable customSymptoms = $CustomSymptomsTable(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    periodLogs,
    periodEndPrompts,
    customSymptoms,
    dailyLogs,
    journalEntries,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String displayName,
      required DateTime createdAt,
      Value<DateTime?> onboardingCompletedAt,
      Value<int?> typicalPeriodDays,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<DateTime> createdAt,
      Value<DateTime?> onboardingCompletedAt,
      Value<int?> typicalPeriodDays,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get typicalPeriodDays => $composableBuilder(
    column: $table.typicalPeriodDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get typicalPeriodDays => $composableBuilder(
    column: $table.typicalPeriodDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get typicalPeriodDays => $composableBuilder(
    column: $table.typicalPeriodDays,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> onboardingCompletedAt = const Value.absent(),
                Value<int?> typicalPeriodDays = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                onboardingCompletedAt: onboardingCompletedAt,
                typicalPeriodDays: typicalPeriodDays,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required DateTime createdAt,
                Value<DateTime?> onboardingCompletedAt = const Value.absent(),
                Value<int?> typicalPeriodDays = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                onboardingCompletedAt: onboardingCompletedAt,
                typicalPeriodDays: typicalPeriodDays,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$PeriodLogsTableCreateCompanionBuilder =
    PeriodLogsCompanion Function({
      Value<int> id,
      required DateTime startedOn,
      Value<DateTime?> endedOn,
      required String source,
      Value<String> startSource,
      Value<String> startConfidence,
      Value<String> endStatus,
      Value<String?> endSource,
      Value<String?> endConfidence,
      Value<String?> roughDurationBucket,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PeriodLogsTableUpdateCompanionBuilder =
    PeriodLogsCompanion Function({
      Value<int> id,
      Value<DateTime> startedOn,
      Value<DateTime?> endedOn,
      Value<String> source,
      Value<String> startSource,
      Value<String> startConfidence,
      Value<String> endStatus,
      Value<String?> endSource,
      Value<String?> endConfidence,
      Value<String?> roughDurationBucket,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$PeriodLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodLogsTable> {
  $$PeriodLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedOn => $composableBuilder(
    column: $table.endedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startSource => $composableBuilder(
    column: $table.startSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startConfidence => $composableBuilder(
    column: $table.startConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endStatus => $composableBuilder(
    column: $table.endStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endSource => $composableBuilder(
    column: $table.endSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endConfidence => $composableBuilder(
    column: $table.endConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roughDurationBucket => $composableBuilder(
    column: $table.roughDurationBucket,
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
}

class $$PeriodLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodLogsTable> {
  $$PeriodLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedOn => $composableBuilder(
    column: $table.endedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startSource => $composableBuilder(
    column: $table.startSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startConfidence => $composableBuilder(
    column: $table.startConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endStatus => $composableBuilder(
    column: $table.endStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endSource => $composableBuilder(
    column: $table.endSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endConfidence => $composableBuilder(
    column: $table.endConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roughDurationBucket => $composableBuilder(
    column: $table.roughDurationBucket,
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
}

class $$PeriodLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodLogsTable> {
  $$PeriodLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedOn =>
      $composableBuilder(column: $table.startedOn, builder: (column) => column);

  GeneratedColumn<DateTime> get endedOn =>
      $composableBuilder(column: $table.endedOn, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get startSource => $composableBuilder(
    column: $table.startSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startConfidence => $composableBuilder(
    column: $table.startConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endStatus =>
      $composableBuilder(column: $table.endStatus, builder: (column) => column);

  GeneratedColumn<String> get endSource =>
      $composableBuilder(column: $table.endSource, builder: (column) => column);

  GeneratedColumn<String> get endConfidence => $composableBuilder(
    column: $table.endConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roughDurationBucket => $composableBuilder(
    column: $table.roughDurationBucket,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PeriodLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodLogsTable,
          PeriodLogRow,
          $$PeriodLogsTableFilterComposer,
          $$PeriodLogsTableOrderingComposer,
          $$PeriodLogsTableAnnotationComposer,
          $$PeriodLogsTableCreateCompanionBuilder,
          $$PeriodLogsTableUpdateCompanionBuilder,
          (
            PeriodLogRow,
            BaseReferences<_$AppDatabase, $PeriodLogsTable, PeriodLogRow>,
          ),
          PeriodLogRow,
          PrefetchHooks Function()
        > {
  $$PeriodLogsTableTableManager(_$AppDatabase db, $PeriodLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedOn = const Value.absent(),
                Value<DateTime?> endedOn = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> startSource = const Value.absent(),
                Value<String> startConfidence = const Value.absent(),
                Value<String> endStatus = const Value.absent(),
                Value<String?> endSource = const Value.absent(),
                Value<String?> endConfidence = const Value.absent(),
                Value<String?> roughDurationBucket = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PeriodLogsCompanion(
                id: id,
                startedOn: startedOn,
                endedOn: endedOn,
                source: source,
                startSource: startSource,
                startConfidence: startConfidence,
                endStatus: endStatus,
                endSource: endSource,
                endConfidence: endConfidence,
                roughDurationBucket: roughDurationBucket,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedOn,
                Value<DateTime?> endedOn = const Value.absent(),
                required String source,
                Value<String> startSource = const Value.absent(),
                Value<String> startConfidence = const Value.absent(),
                Value<String> endStatus = const Value.absent(),
                Value<String?> endSource = const Value.absent(),
                Value<String?> endConfidence = const Value.absent(),
                Value<String?> roughDurationBucket = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PeriodLogsCompanion.insert(
                id: id,
                startedOn: startedOn,
                endedOn: endedOn,
                source: source,
                startSource: startSource,
                startConfidence: startConfidence,
                endStatus: endStatus,
                endSource: endSource,
                endConfidence: endConfidence,
                roughDurationBucket: roughDurationBucket,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeriodLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodLogsTable,
      PeriodLogRow,
      $$PeriodLogsTableFilterComposer,
      $$PeriodLogsTableOrderingComposer,
      $$PeriodLogsTableAnnotationComposer,
      $$PeriodLogsTableCreateCompanionBuilder,
      $$PeriodLogsTableUpdateCompanionBuilder,
      (
        PeriodLogRow,
        BaseReferences<_$AppDatabase, $PeriodLogsTable, PeriodLogRow>,
      ),
      PeriodLogRow,
      PrefetchHooks Function()
    >;
typedef $$PeriodEndPromptsTableCreateCompanionBuilder =
    PeriodEndPromptsCompanion Function({
      Value<int> id,
      required int periodLogId,
      required DateTime shownOn,
      Value<String?> response,
      Value<DateTime?> respondedOn,
      required DateTime createdAt,
    });
typedef $$PeriodEndPromptsTableUpdateCompanionBuilder =
    PeriodEndPromptsCompanion Function({
      Value<int> id,
      Value<int> periodLogId,
      Value<DateTime> shownOn,
      Value<String?> response,
      Value<DateTime?> respondedOn,
      Value<DateTime> createdAt,
    });

class $$PeriodEndPromptsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodEndPromptsTable> {
  $$PeriodEndPromptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodLogId => $composableBuilder(
    column: $table.periodLogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shownOn => $composableBuilder(
    column: $table.shownOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get response => $composableBuilder(
    column: $table.response,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get respondedOn => $composableBuilder(
    column: $table.respondedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeriodEndPromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodEndPromptsTable> {
  $$PeriodEndPromptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodLogId => $composableBuilder(
    column: $table.periodLogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shownOn => $composableBuilder(
    column: $table.shownOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get response => $composableBuilder(
    column: $table.response,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get respondedOn => $composableBuilder(
    column: $table.respondedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeriodEndPromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodEndPromptsTable> {
  $$PeriodEndPromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get periodLogId => $composableBuilder(
    column: $table.periodLogId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get shownOn =>
      $composableBuilder(column: $table.shownOn, builder: (column) => column);

  GeneratedColumn<String> get response =>
      $composableBuilder(column: $table.response, builder: (column) => column);

  GeneratedColumn<DateTime> get respondedOn => $composableBuilder(
    column: $table.respondedOn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PeriodEndPromptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodEndPromptsTable,
          PeriodEndPromptRow,
          $$PeriodEndPromptsTableFilterComposer,
          $$PeriodEndPromptsTableOrderingComposer,
          $$PeriodEndPromptsTableAnnotationComposer,
          $$PeriodEndPromptsTableCreateCompanionBuilder,
          $$PeriodEndPromptsTableUpdateCompanionBuilder,
          (
            PeriodEndPromptRow,
            BaseReferences<
              _$AppDatabase,
              $PeriodEndPromptsTable,
              PeriodEndPromptRow
            >,
          ),
          PeriodEndPromptRow,
          PrefetchHooks Function()
        > {
  $$PeriodEndPromptsTableTableManager(
    _$AppDatabase db,
    $PeriodEndPromptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodEndPromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodEndPromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodEndPromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> periodLogId = const Value.absent(),
                Value<DateTime> shownOn = const Value.absent(),
                Value<String?> response = const Value.absent(),
                Value<DateTime?> respondedOn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PeriodEndPromptsCompanion(
                id: id,
                periodLogId: periodLogId,
                shownOn: shownOn,
                response: response,
                respondedOn: respondedOn,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int periodLogId,
                required DateTime shownOn,
                Value<String?> response = const Value.absent(),
                Value<DateTime?> respondedOn = const Value.absent(),
                required DateTime createdAt,
              }) => PeriodEndPromptsCompanion.insert(
                id: id,
                periodLogId: periodLogId,
                shownOn: shownOn,
                response: response,
                respondedOn: respondedOn,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeriodEndPromptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodEndPromptsTable,
      PeriodEndPromptRow,
      $$PeriodEndPromptsTableFilterComposer,
      $$PeriodEndPromptsTableOrderingComposer,
      $$PeriodEndPromptsTableAnnotationComposer,
      $$PeriodEndPromptsTableCreateCompanionBuilder,
      $$PeriodEndPromptsTableUpdateCompanionBuilder,
      (
        PeriodEndPromptRow,
        BaseReferences<
          _$AppDatabase,
          $PeriodEndPromptsTable,
          PeriodEndPromptRow
        >,
      ),
      PeriodEndPromptRow,
      PrefetchHooks Function()
    >;
typedef $$CustomSymptomsTableCreateCompanionBuilder =
    CustomSymptomsCompanion Function({
      Value<int> id,
      required String name,
      required DateTime createdAt,
    });
typedef $$CustomSymptomsTableUpdateCompanionBuilder =
    CustomSymptomsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

class $$CustomSymptomsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomSymptomsTable> {
  $$CustomSymptomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomSymptomsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomSymptomsTable> {
  $$CustomSymptomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomSymptomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomSymptomsTable> {
  $$CustomSymptomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomSymptomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomSymptomsTable,
          CustomSymptomRow,
          $$CustomSymptomsTableFilterComposer,
          $$CustomSymptomsTableOrderingComposer,
          $$CustomSymptomsTableAnnotationComposer,
          $$CustomSymptomsTableCreateCompanionBuilder,
          $$CustomSymptomsTableUpdateCompanionBuilder,
          (
            CustomSymptomRow,
            BaseReferences<
              _$AppDatabase,
              $CustomSymptomsTable,
              CustomSymptomRow
            >,
          ),
          CustomSymptomRow,
          PrefetchHooks Function()
        > {
  $$CustomSymptomsTableTableManager(
    _$AppDatabase db,
    $CustomSymptomsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomSymptomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomSymptomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomSymptomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomSymptomsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime createdAt,
              }) => CustomSymptomsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomSymptomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomSymptomsTable,
      CustomSymptomRow,
      $$CustomSymptomsTableFilterComposer,
      $$CustomSymptomsTableOrderingComposer,
      $$CustomSymptomsTableAnnotationComposer,
      $$CustomSymptomsTableCreateCompanionBuilder,
      $$CustomSymptomsTableUpdateCompanionBuilder,
      (
        CustomSymptomRow,
        BaseReferences<_$AppDatabase, $CustomSymptomsTable, CustomSymptomRow>,
      ),
      CustomSymptomRow,
      PrefetchHooks Function()
    >;
typedef $$DailyLogsTableCreateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<int> id,
      required DateTime loggedOn,
      Value<String?> flowIntensity,
      Value<int?> crampIntensity,
      Value<String?> moods,
      Value<String?> energyLevel,
      Value<String?> sleepQuality,
      Value<int?> wellbeing,
      Value<String?> symptoms,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DailyLogsTableUpdateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<int> id,
      Value<DateTime> loggedOn,
      Value<String?> flowIntensity,
      Value<int?> crampIntensity,
      Value<String?> moods,
      Value<String?> energyLevel,
      Value<String?> sleepQuality,
      Value<int?> wellbeing,
      Value<String?> symptoms,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DailyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flowIntensity => $composableBuilder(
    column: $table.flowIntensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get crampIntensity => $composableBuilder(
    column: $table.crampIntensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moods => $composableBuilder(
    column: $table.moods,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wellbeing => $composableBuilder(
    column: $table.wellbeing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
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
}

class $$DailyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flowIntensity => $composableBuilder(
    column: $table.flowIntensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get crampIntensity => $composableBuilder(
    column: $table.crampIntensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moods => $composableBuilder(
    column: $table.moods,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wellbeing => $composableBuilder(
    column: $table.wellbeing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
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
}

class $$DailyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedOn =>
      $composableBuilder(column: $table.loggedOn, builder: (column) => column);

  GeneratedColumn<String> get flowIntensity => $composableBuilder(
    column: $table.flowIntensity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get crampIntensity => $composableBuilder(
    column: $table.crampIntensity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moods =>
      $composableBuilder(column: $table.moods, builder: (column) => column);

  GeneratedColumn<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wellbeing =>
      $composableBuilder(column: $table.wellbeing, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyLogsTable,
          DailyLogRow,
          $$DailyLogsTableFilterComposer,
          $$DailyLogsTableOrderingComposer,
          $$DailyLogsTableAnnotationComposer,
          $$DailyLogsTableCreateCompanionBuilder,
          $$DailyLogsTableUpdateCompanionBuilder,
          (
            DailyLogRow,
            BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLogRow>,
          ),
          DailyLogRow,
          PrefetchHooks Function()
        > {
  $$DailyLogsTableTableManager(_$AppDatabase db, $DailyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> loggedOn = const Value.absent(),
                Value<String?> flowIntensity = const Value.absent(),
                Value<int?> crampIntensity = const Value.absent(),
                Value<String?> moods = const Value.absent(),
                Value<String?> energyLevel = const Value.absent(),
                Value<String?> sleepQuality = const Value.absent(),
                Value<int?> wellbeing = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyLogsCompanion(
                id: id,
                loggedOn: loggedOn,
                flowIntensity: flowIntensity,
                crampIntensity: crampIntensity,
                moods: moods,
                energyLevel: energyLevel,
                sleepQuality: sleepQuality,
                wellbeing: wellbeing,
                symptoms: symptoms,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime loggedOn,
                Value<String?> flowIntensity = const Value.absent(),
                Value<int?> crampIntensity = const Value.absent(),
                Value<String?> moods = const Value.absent(),
                Value<String?> energyLevel = const Value.absent(),
                Value<String?> sleepQuality = const Value.absent(),
                Value<int?> wellbeing = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DailyLogsCompanion.insert(
                id: id,
                loggedOn: loggedOn,
                flowIntensity: flowIntensity,
                crampIntensity: crampIntensity,
                moods: moods,
                energyLevel: energyLevel,
                sleepQuality: sleepQuality,
                wellbeing: wellbeing,
                symptoms: symptoms,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyLogsTable,
      DailyLogRow,
      $$DailyLogsTableFilterComposer,
      $$DailyLogsTableOrderingComposer,
      $$DailyLogsTableAnnotationComposer,
      $$DailyLogsTableCreateCompanionBuilder,
      $$DailyLogsTableUpdateCompanionBuilder,
      (
        DailyLogRow,
        BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLogRow>,
      ),
      DailyLogRow,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      required DateTime loggedOn,
      required String body,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> loggedOn,
      Value<String> body,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
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
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
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
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedOn =>
      $composableBuilder(column: $table.loggedOn, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntryRow,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntryRow,
            BaseReferences<
              _$AppDatabase,
              $JournalEntriesTable,
              JournalEntryRow
            >,
          ),
          JournalEntryRow,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> loggedOn = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                loggedOn: loggedOn,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime loggedOn,
                required String body,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => JournalEntriesCompanion.insert(
                id: id,
                loggedOn: loggedOn,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntryRow,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntryRow,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntryRow>,
      ),
      JournalEntryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$PeriodLogsTableTableManager get periodLogs =>
      $$PeriodLogsTableTableManager(_db, _db.periodLogs);
  $$PeriodEndPromptsTableTableManager get periodEndPrompts =>
      $$PeriodEndPromptsTableTableManager(_db, _db.periodEndPrompts);
  $$CustomSymptomsTableTableManager get customSymptoms =>
      $$CustomSymptomsTableTableManager(_db, _db.customSymptoms);
  $$DailyLogsTableTableManager get dailyLogs =>
      $$DailyLogsTableTableManager(_db, _db.dailyLogs);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
}

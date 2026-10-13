// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BossesTable extends Bosses with TableInfo<$BossesTable, Boss> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BossesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defeatMeaningMeta = const VerificationMeta(
    'defeatMeaning',
  );
  @override
  late final GeneratedColumn<String> defeatMeaning = GeneratedColumn<String>(
    'defeat_meaning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BossStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<BossStatus>($BossesTable.$converterstatus);
  static const VerificationMeta _attemptNumberMeta = const VerificationMeta(
    'attemptNumber',
  );
  @override
  late final GeneratedColumn<int> attemptNumber = GeneratedColumn<int>(
    'attempt_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ResetOnFail, int> resetOnFail =
      GeneratedColumn<int>(
        'reset_on_fail',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ResetOnFail>($BossesTable.$converterresetOnFail);
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFoughtAtMeta = const VerificationMeta(
    'lastFoughtAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFoughtAt = GeneratedColumn<DateTime>(
    'last_fought_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openFromAttemptMeta = const VerificationMeta(
    'openFromAttempt',
  );
  @override
  late final GeneratedColumn<int> openFromAttempt = GeneratedColumn<int>(
    'open_from_attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _defeatedAtMeta = const VerificationMeta(
    'defeatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> defeatedAt = GeneratedColumn<DateTime>(
    'defeated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    defeatMeaning,
    status,
    attemptNumber,
    resetOnFail,
    isPinned,
    targetDate,
    lastFoughtAt,
    openFromAttempt,
    createdAt,
    updatedAt,
    defeatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bosses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Boss> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('defeat_meaning')) {
      context.handle(
        _defeatMeaningMeta,
        defeatMeaning.isAcceptableOrUnknown(
          data['defeat_meaning']!,
          _defeatMeaningMeta,
        ),
      );
    }
    if (data.containsKey('attempt_number')) {
      context.handle(
        _attemptNumberMeta,
        attemptNumber.isAcceptableOrUnknown(
          data['attempt_number']!,
          _attemptNumberMeta,
        ),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('last_fought_at')) {
      context.handle(
        _lastFoughtAtMeta,
        lastFoughtAt.isAcceptableOrUnknown(
          data['last_fought_at']!,
          _lastFoughtAtMeta,
        ),
      );
    }
    if (data.containsKey('open_from_attempt')) {
      context.handle(
        _openFromAttemptMeta,
        openFromAttempt.isAcceptableOrUnknown(
          data['open_from_attempt']!,
          _openFromAttemptMeta,
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
    if (data.containsKey('defeated_at')) {
      context.handle(
        _defeatedAtMeta,
        defeatedAt.isAcceptableOrUnknown(data['defeated_at']!, _defeatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Boss map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Boss(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      defeatMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}defeat_meaning'],
      ),
      status: $BossesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      attemptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_number'],
      )!,
      resetOnFail: $BossesTable.$converterresetOnFail.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}reset_on_fail'],
        )!,
      ),
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      lastFoughtAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fought_at'],
      ),
      openFromAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}open_from_attempt'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      defeatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}defeated_at'],
      ),
    );
  }

  @override
  $BossesTable createAlias(String alias) {
    return $BossesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BossStatus, int, int> $converterstatus =
      const EnumIndexConverter<BossStatus>(BossStatus.values);
  static JsonTypeConverter2<ResetOnFail, int, int> $converterresetOnFail =
      const EnumIndexConverter<ResetOnFail>(ResetOnFail.values);
}

class Boss extends DataClass implements Insertable<Boss> {
  final String id;
  final String title;
  final String? defeatMeaning;
  final BossStatus status;
  final int attemptNumber;
  final ResetOnFail resetOnFail;
  final bool isPinned;
  final DateTime? targetDate;
  final DateTime? lastFoughtAt;

  /// Floor for standalone one-time tasks; raised by a whole-boss reset.
  final int openFromAttempt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? defeatedAt;
  const Boss({
    required this.id,
    required this.title,
    this.defeatMeaning,
    required this.status,
    required this.attemptNumber,
    required this.resetOnFail,
    required this.isPinned,
    this.targetDate,
    this.lastFoughtAt,
    required this.openFromAttempt,
    required this.createdAt,
    required this.updatedAt,
    this.defeatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || defeatMeaning != null) {
      map['defeat_meaning'] = Variable<String>(defeatMeaning);
    }
    {
      map['status'] = Variable<int>(
        $BossesTable.$converterstatus.toSql(status),
      );
    }
    map['attempt_number'] = Variable<int>(attemptNumber);
    {
      map['reset_on_fail'] = Variable<int>(
        $BossesTable.$converterresetOnFail.toSql(resetOnFail),
      );
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    if (!nullToAbsent || lastFoughtAt != null) {
      map['last_fought_at'] = Variable<DateTime>(lastFoughtAt);
    }
    map['open_from_attempt'] = Variable<int>(openFromAttempt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || defeatedAt != null) {
      map['defeated_at'] = Variable<DateTime>(defeatedAt);
    }
    return map;
  }

  BossesCompanion toCompanion(bool nullToAbsent) {
    return BossesCompanion(
      id: Value(id),
      title: Value(title),
      defeatMeaning: defeatMeaning == null && nullToAbsent
          ? const Value.absent()
          : Value(defeatMeaning),
      status: Value(status),
      attemptNumber: Value(attemptNumber),
      resetOnFail: Value(resetOnFail),
      isPinned: Value(isPinned),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      lastFoughtAt: lastFoughtAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFoughtAt),
      openFromAttempt: Value(openFromAttempt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      defeatedAt: defeatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(defeatedAt),
    );
  }

  factory Boss.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Boss(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      defeatMeaning: serializer.fromJson<String?>(json['defeatMeaning']),
      status: $BossesTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      attemptNumber: serializer.fromJson<int>(json['attemptNumber']),
      resetOnFail: $BossesTable.$converterresetOnFail.fromJson(
        serializer.fromJson<int>(json['resetOnFail']),
      ),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      lastFoughtAt: serializer.fromJson<DateTime?>(json['lastFoughtAt']),
      openFromAttempt: serializer.fromJson<int>(json['openFromAttempt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      defeatedAt: serializer.fromJson<DateTime?>(json['defeatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'defeatMeaning': serializer.toJson<String?>(defeatMeaning),
      'status': serializer.toJson<int>(
        $BossesTable.$converterstatus.toJson(status),
      ),
      'attemptNumber': serializer.toJson<int>(attemptNumber),
      'resetOnFail': serializer.toJson<int>(
        $BossesTable.$converterresetOnFail.toJson(resetOnFail),
      ),
      'isPinned': serializer.toJson<bool>(isPinned),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'lastFoughtAt': serializer.toJson<DateTime?>(lastFoughtAt),
      'openFromAttempt': serializer.toJson<int>(openFromAttempt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'defeatedAt': serializer.toJson<DateTime?>(defeatedAt),
    };
  }

  Boss copyWith({
    String? id,
    String? title,
    Value<String?> defeatMeaning = const Value.absent(),
    BossStatus? status,
    int? attemptNumber,
    ResetOnFail? resetOnFail,
    bool? isPinned,
    Value<DateTime?> targetDate = const Value.absent(),
    Value<DateTime?> lastFoughtAt = const Value.absent(),
    int? openFromAttempt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> defeatedAt = const Value.absent(),
  }) => Boss(
    id: id ?? this.id,
    title: title ?? this.title,
    defeatMeaning: defeatMeaning.present
        ? defeatMeaning.value
        : this.defeatMeaning,
    status: status ?? this.status,
    attemptNumber: attemptNumber ?? this.attemptNumber,
    resetOnFail: resetOnFail ?? this.resetOnFail,
    isPinned: isPinned ?? this.isPinned,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    lastFoughtAt: lastFoughtAt.present ? lastFoughtAt.value : this.lastFoughtAt,
    openFromAttempt: openFromAttempt ?? this.openFromAttempt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    defeatedAt: defeatedAt.present ? defeatedAt.value : this.defeatedAt,
  );
  Boss copyWithCompanion(BossesCompanion data) {
    return Boss(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      defeatMeaning: data.defeatMeaning.present
          ? data.defeatMeaning.value
          : this.defeatMeaning,
      status: data.status.present ? data.status.value : this.status,
      attemptNumber: data.attemptNumber.present
          ? data.attemptNumber.value
          : this.attemptNumber,
      resetOnFail: data.resetOnFail.present
          ? data.resetOnFail.value
          : this.resetOnFail,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      lastFoughtAt: data.lastFoughtAt.present
          ? data.lastFoughtAt.value
          : this.lastFoughtAt,
      openFromAttempt: data.openFromAttempt.present
          ? data.openFromAttempt.value
          : this.openFromAttempt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      defeatedAt: data.defeatedAt.present
          ? data.defeatedAt.value
          : this.defeatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Boss(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('defeatMeaning: $defeatMeaning, ')
          ..write('status: $status, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('resetOnFail: $resetOnFail, ')
          ..write('isPinned: $isPinned, ')
          ..write('targetDate: $targetDate, ')
          ..write('lastFoughtAt: $lastFoughtAt, ')
          ..write('openFromAttempt: $openFromAttempt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('defeatedAt: $defeatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    defeatMeaning,
    status,
    attemptNumber,
    resetOnFail,
    isPinned,
    targetDate,
    lastFoughtAt,
    openFromAttempt,
    createdAt,
    updatedAt,
    defeatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Boss &&
          other.id == this.id &&
          other.title == this.title &&
          other.defeatMeaning == this.defeatMeaning &&
          other.status == this.status &&
          other.attemptNumber == this.attemptNumber &&
          other.resetOnFail == this.resetOnFail &&
          other.isPinned == this.isPinned &&
          other.targetDate == this.targetDate &&
          other.lastFoughtAt == this.lastFoughtAt &&
          other.openFromAttempt == this.openFromAttempt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.defeatedAt == this.defeatedAt);
}

class BossesCompanion extends UpdateCompanion<Boss> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> defeatMeaning;
  final Value<BossStatus> status;
  final Value<int> attemptNumber;
  final Value<ResetOnFail> resetOnFail;
  final Value<bool> isPinned;
  final Value<DateTime?> targetDate;
  final Value<DateTime?> lastFoughtAt;
  final Value<int> openFromAttempt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> defeatedAt;
  final Value<int> rowid;
  const BossesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.defeatMeaning = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptNumber = const Value.absent(),
    this.resetOnFail = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.lastFoughtAt = const Value.absent(),
    this.openFromAttempt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.defeatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BossesCompanion.insert({
    required String id,
    required String title,
    this.defeatMeaning = const Value.absent(),
    required BossStatus status,
    this.attemptNumber = const Value.absent(),
    required ResetOnFail resetOnFail,
    this.isPinned = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.lastFoughtAt = const Value.absent(),
    this.openFromAttempt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.defeatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       status = Value(status),
       resetOnFail = Value(resetOnFail),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Boss> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? defeatMeaning,
    Expression<int>? status,
    Expression<int>? attemptNumber,
    Expression<int>? resetOnFail,
    Expression<bool>? isPinned,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? lastFoughtAt,
    Expression<int>? openFromAttempt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? defeatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (defeatMeaning != null) 'defeat_meaning': defeatMeaning,
      if (status != null) 'status': status,
      if (attemptNumber != null) 'attempt_number': attemptNumber,
      if (resetOnFail != null) 'reset_on_fail': resetOnFail,
      if (isPinned != null) 'is_pinned': isPinned,
      if (targetDate != null) 'target_date': targetDate,
      if (lastFoughtAt != null) 'last_fought_at': lastFoughtAt,
      if (openFromAttempt != null) 'open_from_attempt': openFromAttempt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (defeatedAt != null) 'defeated_at': defeatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BossesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? defeatMeaning,
    Value<BossStatus>? status,
    Value<int>? attemptNumber,
    Value<ResetOnFail>? resetOnFail,
    Value<bool>? isPinned,
    Value<DateTime?>? targetDate,
    Value<DateTime?>? lastFoughtAt,
    Value<int>? openFromAttempt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? defeatedAt,
    Value<int>? rowid,
  }) {
    return BossesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      defeatMeaning: defeatMeaning ?? this.defeatMeaning,
      status: status ?? this.status,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      resetOnFail: resetOnFail ?? this.resetOnFail,
      isPinned: isPinned ?? this.isPinned,
      targetDate: targetDate ?? this.targetDate,
      lastFoughtAt: lastFoughtAt ?? this.lastFoughtAt,
      openFromAttempt: openFromAttempt ?? this.openFromAttempt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      defeatedAt: defeatedAt ?? this.defeatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (defeatMeaning.present) {
      map['defeat_meaning'] = Variable<String>(defeatMeaning.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $BossesTable.$converterstatus.toSql(status.value),
      );
    }
    if (attemptNumber.present) {
      map['attempt_number'] = Variable<int>(attemptNumber.value);
    }
    if (resetOnFail.present) {
      map['reset_on_fail'] = Variable<int>(
        $BossesTable.$converterresetOnFail.toSql(resetOnFail.value),
      );
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (lastFoughtAt.present) {
      map['last_fought_at'] = Variable<DateTime>(lastFoughtAt.value);
    }
    if (openFromAttempt.present) {
      map['open_from_attempt'] = Variable<int>(openFromAttempt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (defeatedAt.present) {
      map['defeated_at'] = Variable<DateTime>(defeatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BossesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('defeatMeaning: $defeatMeaning, ')
          ..write('status: $status, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('resetOnFail: $resetOnFail, ')
          ..write('isPinned: $isPinned, ')
          ..write('targetDate: $targetDate, ')
          ..write('lastFoughtAt: $lastFoughtAt, ')
          ..write('openFromAttempt: $openFromAttempt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('defeatedAt: $defeatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhasesTable extends Phases with TableInfo<$PhasesTable, Phase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bossIdMeta = const VerificationMeta('bossId');
  @override
  late final GeneratedColumn<String> bossId = GeneratedColumn<String>(
    'boss_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bosses (id) ON DELETE CASCADE',
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
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openFromAttemptMeta = const VerificationMeta(
    'openFromAttempt',
  );
  @override
  late final GeneratedColumn<int> openFromAttempt = GeneratedColumn<int>(
    'open_from_attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
    bossId,
    name,
    position,
    openFromAttempt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Phase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boss_id')) {
      context.handle(
        _bossIdMeta,
        bossId.isAcceptableOrUnknown(data['boss_id']!, _bossIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bossIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('open_from_attempt')) {
      context.handle(
        _openFromAttemptMeta,
        openFromAttempt.isAcceptableOrUnknown(
          data['open_from_attempt']!,
          _openFromAttemptMeta,
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
  Phase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Phase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bossId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boss_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      openFromAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}open_from_attempt'],
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
  $PhasesTable createAlias(String alias) {
    return $PhasesTable(attachedDatabase, alias);
  }
}

class Phase extends DataClass implements Insertable<Phase> {
  final String id;
  final String bossId;
  final String name;
  final int position;

  /// A strike counts for this phase only from this attempt number on.
  final int openFromAttempt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Phase({
    required this.id,
    required this.bossId,
    required this.name,
    required this.position,
    required this.openFromAttempt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boss_id'] = Variable<String>(bossId);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    map['open_from_attempt'] = Variable<int>(openFromAttempt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PhasesCompanion toCompanion(bool nullToAbsent) {
    return PhasesCompanion(
      id: Value(id),
      bossId: Value(bossId),
      name: Value(name),
      position: Value(position),
      openFromAttempt: Value(openFromAttempt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Phase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Phase(
      id: serializer.fromJson<String>(json['id']),
      bossId: serializer.fromJson<String>(json['bossId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
      openFromAttempt: serializer.fromJson<int>(json['openFromAttempt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bossId': serializer.toJson<String>(bossId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
      'openFromAttempt': serializer.toJson<int>(openFromAttempt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Phase copyWith({
    String? id,
    String? bossId,
    String? name,
    int? position,
    int? openFromAttempt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Phase(
    id: id ?? this.id,
    bossId: bossId ?? this.bossId,
    name: name ?? this.name,
    position: position ?? this.position,
    openFromAttempt: openFromAttempt ?? this.openFromAttempt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Phase copyWithCompanion(PhasesCompanion data) {
    return Phase(
      id: data.id.present ? data.id.value : this.id,
      bossId: data.bossId.present ? data.bossId.value : this.bossId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      openFromAttempt: data.openFromAttempt.present
          ? data.openFromAttempt.value
          : this.openFromAttempt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Phase(')
          ..write('id: $id, ')
          ..write('bossId: $bossId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('openFromAttempt: $openFromAttempt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bossId,
    name,
    position,
    openFromAttempt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Phase &&
          other.id == this.id &&
          other.bossId == this.bossId &&
          other.name == this.name &&
          other.position == this.position &&
          other.openFromAttempt == this.openFromAttempt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PhasesCompanion extends UpdateCompanion<Phase> {
  final Value<String> id;
  final Value<String> bossId;
  final Value<String> name;
  final Value<int> position;
  final Value<int> openFromAttempt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PhasesCompanion({
    this.id = const Value.absent(),
    this.bossId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.openFromAttempt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhasesCompanion.insert({
    required String id,
    required String bossId,
    required String name,
    required int position,
    this.openFromAttempt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bossId = Value(bossId),
       name = Value(name),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Phase> custom({
    Expression<String>? id,
    Expression<String>? bossId,
    Expression<String>? name,
    Expression<int>? position,
    Expression<int>? openFromAttempt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bossId != null) 'boss_id': bossId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (openFromAttempt != null) 'open_from_attempt': openFromAttempt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhasesCompanion copyWith({
    Value<String>? id,
    Value<String>? bossId,
    Value<String>? name,
    Value<int>? position,
    Value<int>? openFromAttempt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PhasesCompanion(
      id: id ?? this.id,
      bossId: bossId ?? this.bossId,
      name: name ?? this.name,
      position: position ?? this.position,
      openFromAttempt: openFromAttempt ?? this.openFromAttempt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bossId.present) {
      map['boss_id'] = Variable<String>(bossId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (openFromAttempt.present) {
      map['open_from_attempt'] = Variable<int>(openFromAttempt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhasesCompanion(')
          ..write('id: $id, ')
          ..write('bossId: $bossId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('openFromAttempt: $openFromAttempt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bossIdMeta = const VerificationMeta('bossId');
  @override
  late final GeneratedColumn<String> bossId = GeneratedColumn<String>(
    'boss_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bosses (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _phaseIdMeta = const VerificationMeta(
    'phaseId',
  );
  @override
  late final GeneratedColumn<String> phaseId = GeneratedColumn<String>(
    'phase_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES phases (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Weight, int> weight =
      GeneratedColumn<int>(
        'weight',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Weight>($TasksTable.$converterweight);
  @override
  late final GeneratedColumnWithTypeConverter<Recurrence, int> recurrence =
      GeneratedColumn<int>(
        'recurrence',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Recurrence>($TasksTable.$converterrecurrence);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSplitMeta = const VerificationMeta(
    'isSplit',
  );
  @override
  late final GeneratedColumn<bool> isSplit = GeneratedColumn<bool>(
    'is_split',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_split" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    bossId,
    phaseId,
    title,
    weight,
    recurrence,
    position,
    isSplit,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boss_id')) {
      context.handle(
        _bossIdMeta,
        bossId.isAcceptableOrUnknown(data['boss_id']!, _bossIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bossIdMeta);
    }
    if (data.containsKey('phase_id')) {
      context.handle(
        _phaseIdMeta,
        phaseId.isAcceptableOrUnknown(data['phase_id']!, _phaseIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('is_split')) {
      context.handle(
        _isSplitMeta,
        isSplit.isAcceptableOrUnknown(data['is_split']!, _isSplitMeta),
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
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bossId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boss_id'],
      )!,
      phaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      weight: $TasksTable.$converterweight.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}weight'],
        )!,
      ),
      recurrence: $TasksTable.$converterrecurrence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}recurrence'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isSplit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_split'],
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
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Weight, int, int> $converterweight =
      const EnumIndexConverter<Weight>(Weight.values);
  static JsonTypeConverter2<Recurrence, int, int> $converterrecurrence =
      const EnumIndexConverter<Recurrence>(Recurrence.values);
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String bossId;

  /// Null for a standalone task ("Beyond the phases").
  final String? phaseId;
  final String title;
  final Weight weight;
  final Recurrence recurrence;
  final int position;
  final bool isSplit;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Task({
    required this.id,
    required this.bossId,
    this.phaseId,
    required this.title,
    required this.weight,
    required this.recurrence,
    required this.position,
    required this.isSplit,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boss_id'] = Variable<String>(bossId);
    if (!nullToAbsent || phaseId != null) {
      map['phase_id'] = Variable<String>(phaseId);
    }
    map['title'] = Variable<String>(title);
    {
      map['weight'] = Variable<int>($TasksTable.$converterweight.toSql(weight));
    }
    {
      map['recurrence'] = Variable<int>(
        $TasksTable.$converterrecurrence.toSql(recurrence),
      );
    }
    map['position'] = Variable<int>(position);
    map['is_split'] = Variable<bool>(isSplit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      bossId: Value(bossId),
      phaseId: phaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(phaseId),
      title: Value(title),
      weight: Value(weight),
      recurrence: Value(recurrence),
      position: Value(position),
      isSplit: Value(isSplit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      bossId: serializer.fromJson<String>(json['bossId']),
      phaseId: serializer.fromJson<String?>(json['phaseId']),
      title: serializer.fromJson<String>(json['title']),
      weight: $TasksTable.$converterweight.fromJson(
        serializer.fromJson<int>(json['weight']),
      ),
      recurrence: $TasksTable.$converterrecurrence.fromJson(
        serializer.fromJson<int>(json['recurrence']),
      ),
      position: serializer.fromJson<int>(json['position']),
      isSplit: serializer.fromJson<bool>(json['isSplit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bossId': serializer.toJson<String>(bossId),
      'phaseId': serializer.toJson<String?>(phaseId),
      'title': serializer.toJson<String>(title),
      'weight': serializer.toJson<int>(
        $TasksTable.$converterweight.toJson(weight),
      ),
      'recurrence': serializer.toJson<int>(
        $TasksTable.$converterrecurrence.toJson(recurrence),
      ),
      'position': serializer.toJson<int>(position),
      'isSplit': serializer.toJson<bool>(isSplit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Task copyWith({
    String? id,
    String? bossId,
    Value<String?> phaseId = const Value.absent(),
    String? title,
    Weight? weight,
    Recurrence? recurrence,
    int? position,
    bool? isSplit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Task(
    id: id ?? this.id,
    bossId: bossId ?? this.bossId,
    phaseId: phaseId.present ? phaseId.value : this.phaseId,
    title: title ?? this.title,
    weight: weight ?? this.weight,
    recurrence: recurrence ?? this.recurrence,
    position: position ?? this.position,
    isSplit: isSplit ?? this.isSplit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      bossId: data.bossId.present ? data.bossId.value : this.bossId,
      phaseId: data.phaseId.present ? data.phaseId.value : this.phaseId,
      title: data.title.present ? data.title.value : this.title,
      weight: data.weight.present ? data.weight.value : this.weight,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      position: data.position.present ? data.position.value : this.position,
      isSplit: data.isSplit.present ? data.isSplit.value : this.isSplit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('bossId: $bossId, ')
          ..write('phaseId: $phaseId, ')
          ..write('title: $title, ')
          ..write('weight: $weight, ')
          ..write('recurrence: $recurrence, ')
          ..write('position: $position, ')
          ..write('isSplit: $isSplit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bossId,
    phaseId,
    title,
    weight,
    recurrence,
    position,
    isSplit,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.bossId == this.bossId &&
          other.phaseId == this.phaseId &&
          other.title == this.title &&
          other.weight == this.weight &&
          other.recurrence == this.recurrence &&
          other.position == this.position &&
          other.isSplit == this.isSplit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> bossId;
  final Value<String?> phaseId;
  final Value<String> title;
  final Value<Weight> weight;
  final Value<Recurrence> recurrence;
  final Value<int> position;
  final Value<bool> isSplit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.bossId = const Value.absent(),
    this.phaseId = const Value.absent(),
    this.title = const Value.absent(),
    this.weight = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.position = const Value.absent(),
    this.isSplit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String bossId,
    this.phaseId = const Value.absent(),
    required String title,
    required Weight weight,
    required Recurrence recurrence,
    required int position,
    this.isSplit = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bossId = Value(bossId),
       title = Value(title),
       weight = Value(weight),
       recurrence = Value(recurrence),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? bossId,
    Expression<String>? phaseId,
    Expression<String>? title,
    Expression<int>? weight,
    Expression<int>? recurrence,
    Expression<int>? position,
    Expression<bool>? isSplit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bossId != null) 'boss_id': bossId,
      if (phaseId != null) 'phase_id': phaseId,
      if (title != null) 'title': title,
      if (weight != null) 'weight': weight,
      if (recurrence != null) 'recurrence': recurrence,
      if (position != null) 'position': position,
      if (isSplit != null) 'is_split': isSplit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? bossId,
    Value<String?>? phaseId,
    Value<String>? title,
    Value<Weight>? weight,
    Value<Recurrence>? recurrence,
    Value<int>? position,
    Value<bool>? isSplit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      bossId: bossId ?? this.bossId,
      phaseId: phaseId ?? this.phaseId,
      title: title ?? this.title,
      weight: weight ?? this.weight,
      recurrence: recurrence ?? this.recurrence,
      position: position ?? this.position,
      isSplit: isSplit ?? this.isSplit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bossId.present) {
      map['boss_id'] = Variable<String>(bossId.value);
    }
    if (phaseId.present) {
      map['phase_id'] = Variable<String>(phaseId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(
        $TasksTable.$converterweight.toSql(weight.value),
      );
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<int>(
        $TasksTable.$converterrecurrence.toSql(recurrence.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isSplit.present) {
      map['is_split'] = Variable<bool>(isSplit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('bossId: $bossId, ')
          ..write('phaseId: $phaseId, ')
          ..write('title: $title, ')
          ..write('weight: $weight, ')
          ..write('recurrence: $recurrence, ')
          ..write('position: $position, ')
          ..write('isSplit: $isSplit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bossIdMeta = const VerificationMeta('bossId');
  @override
  late final GeneratedColumn<String> bossId = GeneratedColumn<String>(
    'boss_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bosses (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _bossAttemptMeta = const VerificationMeta(
    'bossAttempt',
  );
  @override
  late final GeneratedColumn<int> bossAttempt = GeneratedColumn<int>(
    'boss_attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Outcome, int> outcome =
      GeneratedColumn<int>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Outcome>($AttemptsTable.$converteroutcome);
  @override
  late final GeneratedColumnWithTypeConverter<FallCause?, int> cause =
      GeneratedColumn<int>(
        'cause',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<FallCause?>($AttemptsTable.$convertercausen);
  static const VerificationMeta _phaseIdMeta = const VerificationMeta(
    'phaseId',
  );
  @override
  late final GeneratedColumn<String> phaseId = GeneratedColumn<String>(
    'phase_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES phases (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _lessonMeta = const VerificationMeta('lesson');
  @override
  late final GeneratedColumn<String> lesson = GeneratedColumn<String>(
    'lesson',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Weight?, int> weight =
      GeneratedColumn<int>(
        'weight',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Weight?>($AttemptsTable.$converterweightn);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bossId,
    taskId,
    bossAttempt,
    outcome,
    cause,
    phaseId,
    lesson,
    weight,
    day,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('boss_id')) {
      context.handle(
        _bossIdMeta,
        bossId.isAcceptableOrUnknown(data['boss_id']!, _bossIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bossIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('boss_attempt')) {
      context.handle(
        _bossAttemptMeta,
        bossAttempt.isAcceptableOrUnknown(
          data['boss_attempt']!,
          _bossAttemptMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bossAttemptMeta);
    }
    if (data.containsKey('phase_id')) {
      context.handle(
        _phaseIdMeta,
        phaseId.isAcceptableOrUnknown(data['phase_id']!, _phaseIdMeta),
      );
    }
    if (data.containsKey('lesson')) {
      context.handle(
        _lessonMeta,
        lesson.isAcceptableOrUnknown(data['lesson']!, _lessonMeta),
      );
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bossId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boss_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      bossAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boss_attempt'],
      )!,
      outcome: $AttemptsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      cause: $AttemptsTable.$convertercausen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cause'],
        ),
      ),
      phaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase_id'],
      ),
      lesson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson'],
      ),
      weight: $AttemptsTable.$converterweightn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}weight'],
        ),
      ),
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Outcome, int, int> $converteroutcome =
      const EnumIndexConverter<Outcome>(Outcome.values);
  static JsonTypeConverter2<FallCause, int, int> $convertercause =
      const EnumIndexConverter<FallCause>(FallCause.values);
  static JsonTypeConverter2<FallCause?, int?, int?> $convertercausen =
      JsonTypeConverter2.asNullable($convertercause);
  static JsonTypeConverter2<Weight, int, int> $converterweight =
      const EnumIndexConverter<Weight>(Weight.values);
  static JsonTypeConverter2<Weight?, int?, int?> $converterweightn =
      JsonTypeConverter2.asNullable($converterweight);
}

class Attempt extends DataClass implements Insertable<Attempt> {
  final String id;
  final String bossId;
  final String? taskId;
  final int bossAttempt;
  final Outcome outcome;
  final FallCause? cause;
  final String? phaseId;
  final String? lesson;

  /// The task's weight when the attempt was recorded (D12). Null for falls
  /// and for rows written before schema v2.
  final Weight? weight;
  final String day;
  final DateTime at;
  const Attempt({
    required this.id,
    required this.bossId,
    this.taskId,
    required this.bossAttempt,
    required this.outcome,
    this.cause,
    this.phaseId,
    this.lesson,
    this.weight,
    required this.day,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['boss_id'] = Variable<String>(bossId);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['boss_attempt'] = Variable<int>(bossAttempt);
    {
      map['outcome'] = Variable<int>(
        $AttemptsTable.$converteroutcome.toSql(outcome),
      );
    }
    if (!nullToAbsent || cause != null) {
      map['cause'] = Variable<int>(
        $AttemptsTable.$convertercausen.toSql(cause),
      );
    }
    if (!nullToAbsent || phaseId != null) {
      map['phase_id'] = Variable<String>(phaseId);
    }
    if (!nullToAbsent || lesson != null) {
      map['lesson'] = Variable<String>(lesson);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<int>(
        $AttemptsTable.$converterweightn.toSql(weight),
      );
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      bossId: Value(bossId),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      bossAttempt: Value(bossAttempt),
      outcome: Value(outcome),
      cause: cause == null && nullToAbsent
          ? const Value.absent()
          : Value(cause),
      phaseId: phaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(phaseId),
      lesson: lesson == null && nullToAbsent
          ? const Value.absent()
          : Value(lesson),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      day: Value(day),
      at: Value(at),
    );
  }

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<String>(json['id']),
      bossId: serializer.fromJson<String>(json['bossId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      bossAttempt: serializer.fromJson<int>(json['bossAttempt']),
      outcome: $AttemptsTable.$converteroutcome.fromJson(
        serializer.fromJson<int>(json['outcome']),
      ),
      cause: $AttemptsTable.$convertercausen.fromJson(
        serializer.fromJson<int?>(json['cause']),
      ),
      phaseId: serializer.fromJson<String?>(json['phaseId']),
      lesson: serializer.fromJson<String?>(json['lesson']),
      weight: $AttemptsTable.$converterweightn.fromJson(
        serializer.fromJson<int?>(json['weight']),
      ),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bossId': serializer.toJson<String>(bossId),
      'taskId': serializer.toJson<String?>(taskId),
      'bossAttempt': serializer.toJson<int>(bossAttempt),
      'outcome': serializer.toJson<int>(
        $AttemptsTable.$converteroutcome.toJson(outcome),
      ),
      'cause': serializer.toJson<int?>(
        $AttemptsTable.$convertercausen.toJson(cause),
      ),
      'phaseId': serializer.toJson<String?>(phaseId),
      'lesson': serializer.toJson<String?>(lesson),
      'weight': serializer.toJson<int?>(
        $AttemptsTable.$converterweightn.toJson(weight),
      ),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  Attempt copyWith({
    String? id,
    String? bossId,
    Value<String?> taskId = const Value.absent(),
    int? bossAttempt,
    Outcome? outcome,
    Value<FallCause?> cause = const Value.absent(),
    Value<String?> phaseId = const Value.absent(),
    Value<String?> lesson = const Value.absent(),
    Value<Weight?> weight = const Value.absent(),
    String? day,
    DateTime? at,
  }) => Attempt(
    id: id ?? this.id,
    bossId: bossId ?? this.bossId,
    taskId: taskId.present ? taskId.value : this.taskId,
    bossAttempt: bossAttempt ?? this.bossAttempt,
    outcome: outcome ?? this.outcome,
    cause: cause.present ? cause.value : this.cause,
    phaseId: phaseId.present ? phaseId.value : this.phaseId,
    lesson: lesson.present ? lesson.value : this.lesson,
    weight: weight.present ? weight.value : this.weight,
    day: day ?? this.day,
    at: at ?? this.at,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      bossId: data.bossId.present ? data.bossId.value : this.bossId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      bossAttempt: data.bossAttempt.present
          ? data.bossAttempt.value
          : this.bossAttempt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      cause: data.cause.present ? data.cause.value : this.cause,
      phaseId: data.phaseId.present ? data.phaseId.value : this.phaseId,
      lesson: data.lesson.present ? data.lesson.value : this.lesson,
      weight: data.weight.present ? data.weight.value : this.weight,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('bossId: $bossId, ')
          ..write('taskId: $taskId, ')
          ..write('bossAttempt: $bossAttempt, ')
          ..write('outcome: $outcome, ')
          ..write('cause: $cause, ')
          ..write('phaseId: $phaseId, ')
          ..write('lesson: $lesson, ')
          ..write('weight: $weight, ')
          ..write('day: $day, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bossId,
    taskId,
    bossAttempt,
    outcome,
    cause,
    phaseId,
    lesson,
    weight,
    day,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.bossId == this.bossId &&
          other.taskId == this.taskId &&
          other.bossAttempt == this.bossAttempt &&
          other.outcome == this.outcome &&
          other.cause == this.cause &&
          other.phaseId == this.phaseId &&
          other.lesson == this.lesson &&
          other.weight == this.weight &&
          other.day == this.day &&
          other.at == this.at);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<String> id;
  final Value<String> bossId;
  final Value<String?> taskId;
  final Value<int> bossAttempt;
  final Value<Outcome> outcome;
  final Value<FallCause?> cause;
  final Value<String?> phaseId;
  final Value<String?> lesson;
  final Value<Weight?> weight;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<int> rowid;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.bossId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.bossAttempt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.cause = const Value.absent(),
    this.phaseId = const Value.absent(),
    this.lesson = const Value.absent(),
    this.weight = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttemptsCompanion.insert({
    required String id,
    required String bossId,
    this.taskId = const Value.absent(),
    required int bossAttempt,
    required Outcome outcome,
    this.cause = const Value.absent(),
    this.phaseId = const Value.absent(),
    this.lesson = const Value.absent(),
    this.weight = const Value.absent(),
    required String day,
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bossId = Value(bossId),
       bossAttempt = Value(bossAttempt),
       outcome = Value(outcome),
       day = Value(day),
       at = Value(at);
  static Insertable<Attempt> custom({
    Expression<String>? id,
    Expression<String>? bossId,
    Expression<String>? taskId,
    Expression<int>? bossAttempt,
    Expression<int>? outcome,
    Expression<int>? cause,
    Expression<String>? phaseId,
    Expression<String>? lesson,
    Expression<int>? weight,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bossId != null) 'boss_id': bossId,
      if (taskId != null) 'task_id': taskId,
      if (bossAttempt != null) 'boss_attempt': bossAttempt,
      if (outcome != null) 'outcome': outcome,
      if (cause != null) 'cause': cause,
      if (phaseId != null) 'phase_id': phaseId,
      if (lesson != null) 'lesson': lesson,
      if (weight != null) 'weight': weight,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? bossId,
    Value<String?>? taskId,
    Value<int>? bossAttempt,
    Value<Outcome>? outcome,
    Value<FallCause?>? cause,
    Value<String?>? phaseId,
    Value<String?>? lesson,
    Value<Weight?>? weight,
    Value<String>? day,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      bossId: bossId ?? this.bossId,
      taskId: taskId ?? this.taskId,
      bossAttempt: bossAttempt ?? this.bossAttempt,
      outcome: outcome ?? this.outcome,
      cause: cause ?? this.cause,
      phaseId: phaseId ?? this.phaseId,
      lesson: lesson ?? this.lesson,
      weight: weight ?? this.weight,
      day: day ?? this.day,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bossId.present) {
      map['boss_id'] = Variable<String>(bossId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (bossAttempt.present) {
      map['boss_attempt'] = Variable<int>(bossAttempt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<int>(
        $AttemptsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (cause.present) {
      map['cause'] = Variable<int>(
        $AttemptsTable.$convertercausen.toSql(cause.value),
      );
    }
    if (phaseId.present) {
      map['phase_id'] = Variable<String>(phaseId.value);
    }
    if (lesson.present) {
      map['lesson'] = Variable<String>(lesson.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(
        $AttemptsTable.$converterweightn.toSql(weight.value),
      );
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('bossId: $bossId, ')
          ..write('taskId: $taskId, ')
          ..write('bossAttempt: $bossAttempt, ')
          ..write('outcome: $outcome, ')
          ..write('cause: $cause, ')
          ..write('phaseId: $phaseId, ')
          ..write('lesson: $lesson, ')
          ..write('weight: $weight, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, AppSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tapModeMeta = const VerificationMeta(
    'tapMode',
  );
  @override
  late final GeneratedColumn<bool> tapMode = GeneratedColumn<bool>(
    'tap_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tap_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ResetOnFail, int>
  defaultResetOnFail = GeneratedColumn<int>(
    'default_reset_on_fail',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<ResetOnFail>($SettingsTable.$converterdefaultResetOnFail);
  static const VerificationMeta _hapticsMeta = const VerificationMeta(
    'haptics',
  );
  @override
  late final GeneratedColumn<bool> haptics = GeneratedColumn<bool>(
    'haptics',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptics" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tapMode,
    defaultResetOnFail,
    haptics,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettings> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tap_mode')) {
      context.handle(
        _tapModeMeta,
        tapMode.isAcceptableOrUnknown(data['tap_mode']!, _tapModeMeta),
      );
    }
    if (data.containsKey('haptics')) {
      context.handle(
        _hapticsMeta,
        haptics.isAcceptableOrUnknown(data['haptics']!, _hapticsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettings(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tapMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tap_mode'],
      )!,
      defaultResetOnFail: $SettingsTable.$converterdefaultResetOnFail.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}default_reset_on_fail'],
        )!,
      ),
      haptics: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptics'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ResetOnFail, int, int>
  $converterdefaultResetOnFail = const EnumIndexConverter<ResetOnFail>(
    ResetOnFail.values,
  );
}

class AppSettings extends DataClass implements Insertable<AppSettings> {
  final int id;
  final bool tapMode;
  final ResetOnFail defaultResetOnFail;
  final bool haptics;
  const AppSettings({
    required this.id,
    required this.tapMode,
    required this.defaultResetOnFail,
    required this.haptics,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tap_mode'] = Variable<bool>(tapMode);
    {
      map['default_reset_on_fail'] = Variable<int>(
        $SettingsTable.$converterdefaultResetOnFail.toSql(defaultResetOnFail),
      );
    }
    map['haptics'] = Variable<bool>(haptics);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      tapMode: Value(tapMode),
      defaultResetOnFail: Value(defaultResetOnFail),
      haptics: Value(haptics),
    );
  }

  factory AppSettings.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettings(
      id: serializer.fromJson<int>(json['id']),
      tapMode: serializer.fromJson<bool>(json['tapMode']),
      defaultResetOnFail: $SettingsTable.$converterdefaultResetOnFail.fromJson(
        serializer.fromJson<int>(json['defaultResetOnFail']),
      ),
      haptics: serializer.fromJson<bool>(json['haptics']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tapMode': serializer.toJson<bool>(tapMode),
      'defaultResetOnFail': serializer.toJson<int>(
        $SettingsTable.$converterdefaultResetOnFail.toJson(defaultResetOnFail),
      ),
      'haptics': serializer.toJson<bool>(haptics),
    };
  }

  AppSettings copyWith({
    int? id,
    bool? tapMode,
    ResetOnFail? defaultResetOnFail,
    bool? haptics,
  }) => AppSettings(
    id: id ?? this.id,
    tapMode: tapMode ?? this.tapMode,
    defaultResetOnFail: defaultResetOnFail ?? this.defaultResetOnFail,
    haptics: haptics ?? this.haptics,
  );
  AppSettings copyWithCompanion(SettingsCompanion data) {
    return AppSettings(
      id: data.id.present ? data.id.value : this.id,
      tapMode: data.tapMode.present ? data.tapMode.value : this.tapMode,
      defaultResetOnFail: data.defaultResetOnFail.present
          ? data.defaultResetOnFail.value
          : this.defaultResetOnFail,
      haptics: data.haptics.present ? data.haptics.value : this.haptics,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettings(')
          ..write('id: $id, ')
          ..write('tapMode: $tapMode, ')
          ..write('defaultResetOnFail: $defaultResetOnFail, ')
          ..write('haptics: $haptics')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tapMode, defaultResetOnFail, haptics);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.id == this.id &&
          other.tapMode == this.tapMode &&
          other.defaultResetOnFail == this.defaultResetOnFail &&
          other.haptics == this.haptics);
}

class SettingsCompanion extends UpdateCompanion<AppSettings> {
  final Value<int> id;
  final Value<bool> tapMode;
  final Value<ResetOnFail> defaultResetOnFail;
  final Value<bool> haptics;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.tapMode = const Value.absent(),
    this.defaultResetOnFail = const Value.absent(),
    this.haptics = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.tapMode = const Value.absent(),
    this.defaultResetOnFail = const Value.absent(),
    this.haptics = const Value.absent(),
  });
  static Insertable<AppSettings> custom({
    Expression<int>? id,
    Expression<bool>? tapMode,
    Expression<int>? defaultResetOnFail,
    Expression<bool>? haptics,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tapMode != null) 'tap_mode': tapMode,
      if (defaultResetOnFail != null)
        'default_reset_on_fail': defaultResetOnFail,
      if (haptics != null) 'haptics': haptics,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? tapMode,
    Value<ResetOnFail>? defaultResetOnFail,
    Value<bool>? haptics,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      tapMode: tapMode ?? this.tapMode,
      defaultResetOnFail: defaultResetOnFail ?? this.defaultResetOnFail,
      haptics: haptics ?? this.haptics,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tapMode.present) {
      map['tap_mode'] = Variable<bool>(tapMode.value);
    }
    if (defaultResetOnFail.present) {
      map['default_reset_on_fail'] = Variable<int>(
        $SettingsTable.$converterdefaultResetOnFail.toSql(
          defaultResetOnFail.value,
        ),
      );
    }
    if (haptics.present) {
      map['haptics'] = Variable<bool>(haptics.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('tapMode: $tapMode, ')
          ..write('defaultResetOnFail: $defaultResetOnFail, ')
          ..write('haptics: $haptics')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BossesTable bosses = $BossesTable(this);
  late final $PhasesTable phases = $PhasesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bosses,
    phases,
    tasks,
    attempts,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bosses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('phases', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bosses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'phases',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bosses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attempts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'phases',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attempts', kind: UpdateKind.update)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$BossesTableCreateCompanionBuilder = BossesCompanion Function({
  required String id,
  required String title,
  Value<String?> defeatMeaning,
  required BossStatus status,
  Value<int> attemptNumber,
  required ResetOnFail resetOnFail,
  Value<bool> isPinned,
  Value<DateTime?> targetDate,
  Value<DateTime?> lastFoughtAt,
  Value<int> openFromAttempt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> defeatedAt,
  Value<int> rowid,
});
typedef $$BossesTableUpdateCompanionBuilder = BossesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> defeatMeaning,
  Value<BossStatus> status,
  Value<int> attemptNumber,
  Value<ResetOnFail> resetOnFail,
  Value<bool> isPinned,
  Value<DateTime?> targetDate,
  Value<DateTime?> lastFoughtAt,
  Value<int> openFromAttempt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> defeatedAt,
  Value<int> rowid,
});

final class $$BossesTableReferences
    extends BaseReferences<_$AppDatabase, $BossesTable, Boss> {
  $$BossesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PhasesTable, List<Phase>> _phasesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.phases,
    aliasName: 'bosses__id__phases__boss_id',
  );

  $$PhasesTableProcessedTableManager get phasesRefs {
    final manager = $$PhasesTableTableManager(
      $_db,
      $_db.phases,
    ).filter((f) => f.bossId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_phasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'bosses__id__tasks__boss_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.bossId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttemptsTable, List<Attempt>> _attemptsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.attempts,
    aliasName: 'bosses__id__attempts__boss_id',
  );

  $$AttemptsTableProcessedTableManager get attemptsRefs {
    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.bossId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BossesTableFilterComposer
    extends Composer<_$AppDatabase, $BossesTable> {
  $$BossesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defeatMeaning => $composableBuilder(
    column: $table.defeatMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BossStatus, BossStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ResetOnFail, ResetOnFail, int>
  get resetOnFail => $composableBuilder(
    column: $table.resetOnFail,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFoughtAt => $composableBuilder(
    column: $table.lastFoughtAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openFromAttempt => $composableBuilder(
    column: $table.openFromAttempt,
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

  ColumnFilters<DateTime> get defeatedAt => $composableBuilder(
    column: $table.defeatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> phasesRefs(
    Expression<bool> Function($$PhasesTableFilterComposer f) f,
  ) {
    final $$PhasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableFilterComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attemptsRefs(
    Expression<bool> Function($$AttemptsTableFilterComposer f) f,
  ) {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BossesTableOrderingComposer
    extends Composer<_$AppDatabase, $BossesTable> {
  $$BossesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defeatMeaning => $composableBuilder(
    column: $table.defeatMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resetOnFail => $composableBuilder(
    column: $table.resetOnFail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFoughtAt => $composableBuilder(
    column: $table.lastFoughtAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openFromAttempt => $composableBuilder(
    column: $table.openFromAttempt,
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

  ColumnOrderings<DateTime> get defeatedAt => $composableBuilder(
    column: $table.defeatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BossesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BossesTable> {
  $$BossesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get defeatMeaning => $composableBuilder(
    column: $table.defeatMeaning,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BossStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ResetOnFail, int> get resetOnFail =>
      $composableBuilder(
        column: $table.resetOnFail,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFoughtAt => $composableBuilder(
    column: $table.lastFoughtAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openFromAttempt => $composableBuilder(
    column: $table.openFromAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get defeatedAt => $composableBuilder(
    column: $table.defeatedAt,
    builder: (column) => column,
  );

  Expression<T> phasesRefs<T extends Object>(
    Expression<T> Function($$PhasesTableAnnotationComposer a) f,
  ) {
    final $$PhasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableAnnotationComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attemptsRefs<T extends Object>(
    Expression<T> Function($$AttemptsTableAnnotationComposer a) f,
  ) {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BossesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BossesTable,
          Boss,
          $$BossesTableFilterComposer,
          $$BossesTableOrderingComposer,
          $$BossesTableAnnotationComposer,
          $$BossesTableCreateCompanionBuilder,
          $$BossesTableUpdateCompanionBuilder,
          (Boss, $$BossesTableReferences),
          Boss,
          PrefetchHooks Function({
            bool phasesRefs,
            bool tasksRefs,
            bool attemptsRefs,
          })
        > {
  $$BossesTableTableManager(_$AppDatabase db, $BossesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BossesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BossesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BossesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> defeatMeaning = const Value.absent(),
                Value<BossStatus> status = const Value.absent(),
                Value<int> attemptNumber = const Value.absent(),
                Value<ResetOnFail> resetOnFail = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime?> lastFoughtAt = const Value.absent(),
                Value<int> openFromAttempt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> defeatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BossesCompanion(
                id: id,
                title: title,
                defeatMeaning: defeatMeaning,
                status: status,
                attemptNumber: attemptNumber,
                resetOnFail: resetOnFail,
                isPinned: isPinned,
                targetDate: targetDate,
                lastFoughtAt: lastFoughtAt,
                openFromAttempt: openFromAttempt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                defeatedAt: defeatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> defeatMeaning = const Value.absent(),
                required BossStatus status,
                Value<int> attemptNumber = const Value.absent(),
                required ResetOnFail resetOnFail,
                Value<bool> isPinned = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime?> lastFoughtAt = const Value.absent(),
                Value<int> openFromAttempt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> defeatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BossesCompanion.insert(
                id: id,
                title: title,
                defeatMeaning: defeatMeaning,
                status: status,
                attemptNumber: attemptNumber,
                resetOnFail: resetOnFail,
                isPinned: isPinned,
                targetDate: targetDate,
                lastFoughtAt: lastFoughtAt,
                openFromAttempt: openFromAttempt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                defeatedAt: defeatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BossesTable, Boss>(table),
                  $$BossesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({phasesRefs = false, tasksRefs = false, attemptsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (phasesRefs) db.phases,
                    if (tasksRefs) db.tasks,
                    if (attemptsRefs) db.attempts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (phasesRefs)
                        await $_getPrefetchedData<Boss, $BossesTable, Phase>(
                          currentTable: table,
                          referencedTable: $$BossesTableReferences
                              ._phasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BossesTableReferences(db, table, p0).phasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bossId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tasksRefs)
                        await $_getPrefetchedData<Boss, $BossesTable, Task>(
                          currentTable: table,
                          referencedTable: $$BossesTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BossesTableReferences(db, table, p0).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bossId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attemptsRefs)
                        await $_getPrefetchedData<Boss, $BossesTable, Attempt>(
                          currentTable: table,
                          referencedTable: $$BossesTableReferences
                              ._attemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BossesTableReferences(
                                db,
                                table,
                                p0,
                              ).attemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bossId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BossesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BossesTable,
      Boss,
      $$BossesTableFilterComposer,
      $$BossesTableOrderingComposer,
      $$BossesTableAnnotationComposer,
      $$BossesTableCreateCompanionBuilder,
      $$BossesTableUpdateCompanionBuilder,
      (Boss, $$BossesTableReferences),
      Boss,
      PrefetchHooks Function({
        bool phasesRefs,
        bool tasksRefs,
        bool attemptsRefs,
      })
    >;
typedef $$PhasesTableCreateCompanionBuilder = PhasesCompanion Function({
  required String id,
  required String bossId,
  required String name,
  required int position,
  Value<int> openFromAttempt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PhasesTableUpdateCompanionBuilder = PhasesCompanion Function({
  Value<String> id,
  Value<String> bossId,
  Value<String> name,
  Value<int> position,
  Value<int> openFromAttempt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PhasesTableReferences
    extends BaseReferences<_$AppDatabase, $PhasesTable, Phase> {
  $$PhasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BossesTable _bossIdTable(_$AppDatabase db) =>
      db.bosses.createAlias('phases__boss_id__bosses__id');

  $$BossesTableProcessedTableManager get bossId {
    final $_column = $_itemColumn<String>('boss_id')!;

    final manager = $$BossesTableTableManager(
      $_db,
      $_db.bosses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bossIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'phases__id__tasks__phase_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.phaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttemptsTable, List<Attempt>> _attemptsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.attempts,
    aliasName: 'phases__id__attempts__phase_id',
  );

  $$AttemptsTableProcessedTableManager get attemptsRefs {
    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.phaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PhasesTableFilterComposer
    extends Composer<_$AppDatabase, $PhasesTable> {
  $$PhasesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openFromAttempt => $composableBuilder(
    column: $table.openFromAttempt,
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

  $$BossesTableFilterComposer get bossId {
    final $$BossesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableFilterComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.phaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attemptsRefs(
    Expression<bool> Function($$AttemptsTableFilterComposer f) f,
  ) {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.phaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PhasesTable> {
  $$PhasesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openFromAttempt => $composableBuilder(
    column: $table.openFromAttempt,
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

  $$BossesTableOrderingComposer get bossId {
    final $$BossesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableOrderingComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhasesTable> {
  $$PhasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get openFromAttempt => $composableBuilder(
    column: $table.openFromAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BossesTableAnnotationComposer get bossId {
    final $$BossesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableAnnotationComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.phaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attemptsRefs<T extends Object>(
    Expression<T> Function($$AttemptsTableAnnotationComposer a) f,
  ) {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.phaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhasesTable,
          Phase,
          $$PhasesTableFilterComposer,
          $$PhasesTableOrderingComposer,
          $$PhasesTableAnnotationComposer,
          $$PhasesTableCreateCompanionBuilder,
          $$PhasesTableUpdateCompanionBuilder,
          (Phase, $$PhasesTableReferences),
          Phase,
          PrefetchHooks Function({
            bool bossId,
            bool tasksRefs,
            bool attemptsRefs,
          })
        > {
  $$PhasesTableTableManager(_$AppDatabase db, $PhasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bossId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> openFromAttempt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhasesCompanion(
                id: id,
                bossId: bossId,
                name: name,
                position: position,
                openFromAttempt: openFromAttempt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bossId,
                required String name,
                required int position,
                Value<int> openFromAttempt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PhasesCompanion.insert(
                id: id,
                bossId: bossId,
                name: name,
                position: position,
                openFromAttempt: openFromAttempt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhasesTable, Phase>(table),
                  $$PhasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bossId = false, tasksRefs = false, attemptsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tasksRefs) db.tasks,
                    if (attemptsRefs) db.attempts,
                  ],
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
                        if (bossId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bossId,
                            referencedTable: $$PhasesTableReferences
                                ._bossIdTable(db),
                            referencedColumn: $$PhasesTableReferences
                                ._bossIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tasksRefs)
                        await $_getPrefetchedData<Phase, $PhasesTable, Task>(
                          currentTable: table,
                          referencedTable: $$PhasesTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PhasesTableReferences(db, table, p0).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.phaseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attemptsRefs)
                        await $_getPrefetchedData<Phase, $PhasesTable, Attempt>(
                          currentTable: table,
                          referencedTable: $$PhasesTableReferences
                              ._attemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PhasesTableReferences(
                                db,
                                table,
                                p0,
                              ).attemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.phaseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PhasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhasesTable,
      Phase,
      $$PhasesTableFilterComposer,
      $$PhasesTableOrderingComposer,
      $$PhasesTableAnnotationComposer,
      $$PhasesTableCreateCompanionBuilder,
      $$PhasesTableUpdateCompanionBuilder,
      (Phase, $$PhasesTableReferences),
      Phase,
      PrefetchHooks Function({bool bossId, bool tasksRefs, bool attemptsRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String bossId,
  Value<String?> phaseId,
  required String title,
  required Weight weight,
  required Recurrence recurrence,
  required int position,
  Value<bool> isSplit,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> bossId,
  Value<String?> phaseId,
  Value<String> title,
  Value<Weight> weight,
  Value<Recurrence> recurrence,
  Value<int> position,
  Value<bool> isSplit,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BossesTable _bossIdTable(_$AppDatabase db) =>
      db.bosses.createAlias('tasks__boss_id__bosses__id');

  $$BossesTableProcessedTableManager get bossId {
    final $_column = $_itemColumn<String>('boss_id')!;

    final manager = $$BossesTableTableManager(
      $_db,
      $_db.bosses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bossIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PhasesTable _phaseIdTable(_$AppDatabase db) =>
      db.phases.createAlias('tasks__phase_id__phases__id');

  $$PhasesTableProcessedTableManager? get phaseId {
    final $_column = $_itemColumn<String>('phase_id');
    if ($_column == null) return null;
    final manager = $$PhasesTableTableManager(
      $_db,
      $_db.phases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_phaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttemptsTable, List<Attempt>> _attemptsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.attempts,
    aliasName: 'tasks__id__attempts__task_id',
  );

  $$AttemptsTableProcessedTableManager get attemptsRefs {
    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Weight, Weight, int> get weight =>
      $composableBuilder(
        column: $table.weight,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Recurrence, Recurrence, int> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSplit => $composableBuilder(
    column: $table.isSplit,
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

  $$BossesTableFilterComposer get bossId {
    final $$BossesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableFilterComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhasesTableFilterComposer get phaseId {
    final $$PhasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableFilterComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attemptsRefs(
    Expression<bool> Function($$AttemptsTableFilterComposer f) f,
  ) {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSplit => $composableBuilder(
    column: $table.isSplit,
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

  $$BossesTableOrderingComposer get bossId {
    final $$BossesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableOrderingComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhasesTableOrderingComposer get phaseId {
    final $$PhasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableOrderingComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Weight, int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Recurrence, int> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => column,
      );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isSplit =>
      $composableBuilder(column: $table.isSplit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BossesTableAnnotationComposer get bossId {
    final $$BossesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableAnnotationComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhasesTableAnnotationComposer get phaseId {
    final $$PhasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableAnnotationComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attemptsRefs<T extends Object>(
    Expression<T> Function($$AttemptsTableAnnotationComposer a) f,
  ) {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool bossId, bool phaseId, bool attemptsRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bossId = const Value.absent(),
                Value<String?> phaseId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<Weight> weight = const Value.absent(),
                Value<Recurrence> recurrence = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isSplit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                bossId: bossId,
                phaseId: phaseId,
                title: title,
                weight: weight,
                recurrence: recurrence,
                position: position,
                isSplit: isSplit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bossId,
                Value<String?> phaseId = const Value.absent(),
                required String title,
                required Weight weight,
                required Recurrence recurrence,
                required int position,
                Value<bool> isSplit = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                bossId: bossId,
                phaseId: phaseId,
                title: title,
                weight: weight,
                recurrence: recurrence,
                position: position,
                isSplit: isSplit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bossId = false, phaseId = false, attemptsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (attemptsRefs) db.attempts],
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
                        if (bossId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bossId,
                            referencedTable: $$TasksTableReferences
                                ._bossIdTable(db),
                            referencedColumn: $$TasksTableReferences
                                ._bossIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (phaseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.phaseId,
                            referencedTable: $$TasksTableReferences
                                ._phaseIdTable(db),
                            referencedColumn: $$TasksTableReferences
                                ._phaseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attemptsRefs)
                        await $_getPrefetchedData<Task, $TasksTable, Attempt>(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._attemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).attemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool bossId, bool phaseId, bool attemptsRefs})
    >;
typedef $$AttemptsTableCreateCompanionBuilder = AttemptsCompanion Function({
  required String id,
  required String bossId,
  Value<String?> taskId,
  required int bossAttempt,
  required Outcome outcome,
  Value<FallCause?> cause,
  Value<String?> phaseId,
  Value<String?> lesson,
  Value<Weight?> weight,
  required String day,
  required DateTime at,
  Value<int> rowid,
});
typedef $$AttemptsTableUpdateCompanionBuilder = AttemptsCompanion Function({
  Value<String> id,
  Value<String> bossId,
  Value<String?> taskId,
  Value<int> bossAttempt,
  Value<Outcome> outcome,
  Value<FallCause?> cause,
  Value<String?> phaseId,
  Value<String?> lesson,
  Value<Weight?> weight,
  Value<String> day,
  Value<DateTime> at,
  Value<int> rowid,
});

final class $$AttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $AttemptsTable, Attempt> {
  $$AttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BossesTable _bossIdTable(_$AppDatabase db) =>
      db.bosses.createAlias('attempts__boss_id__bosses__id');

  $$BossesTableProcessedTableManager get bossId {
    final $_column = $_itemColumn<String>('boss_id')!;

    final manager = $$BossesTableTableManager(
      $_db,
      $_db.bosses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bossIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('attempts__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PhasesTable _phaseIdTable(_$AppDatabase db) =>
      db.phases.createAlias('attempts__phase_id__phases__id');

  $$PhasesTableProcessedTableManager? get phaseId {
    final $_column = $_itemColumn<String>('phase_id');
    if ($_column == null) return null;
    final manager = $$PhasesTableTableManager(
      $_db,
      $_db.phases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_phaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
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

  ColumnFilters<int> get bossAttempt => $composableBuilder(
    column: $table.bossAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Outcome, Outcome, int> get outcome =>
      $composableBuilder(
        column: $table.outcome,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<FallCause?, FallCause, int> get cause =>
      $composableBuilder(
        column: $table.cause,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get lesson => $composableBuilder(
    column: $table.lesson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Weight?, Weight, int> get weight =>
      $composableBuilder(
        column: $table.weight,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  $$BossesTableFilterComposer get bossId {
    final $$BossesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableFilterComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhasesTableFilterComposer get phaseId {
    final $$PhasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableFilterComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
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

  ColumnOrderings<int> get bossAttempt => $composableBuilder(
    column: $table.bossAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cause => $composableBuilder(
    column: $table.cause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lesson => $composableBuilder(
    column: $table.lesson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  $$BossesTableOrderingComposer get bossId {
    final $$BossesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableOrderingComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhasesTableOrderingComposer get phaseId {
    final $$PhasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableOrderingComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bossAttempt => $composableBuilder(
    column: $table.bossAttempt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Outcome, int> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FallCause?, int> get cause =>
      $composableBuilder(column: $table.cause, builder: (column) => column);

  GeneratedColumn<String> get lesson =>
      $composableBuilder(column: $table.lesson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Weight?, int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  $$BossesTableAnnotationComposer get bossId {
    final $$BossesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bossId,
      referencedTable: $db.bosses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BossesTableAnnotationComposer(
            $db: $db,
            $table: $db.bosses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhasesTableAnnotationComposer get phaseId {
    final $$PhasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableAnnotationComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (Attempt, $$AttemptsTableReferences),
          Attempt,
          PrefetchHooks Function({bool bossId, bool taskId, bool phaseId})
        > {
  $$AttemptsTableTableManager(_$AppDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bossId = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int> bossAttempt = const Value.absent(),
                Value<Outcome> outcome = const Value.absent(),
                Value<FallCause?> cause = const Value.absent(),
                Value<String?> phaseId = const Value.absent(),
                Value<String?> lesson = const Value.absent(),
                Value<Weight?> weight = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                bossId: bossId,
                taskId: taskId,
                bossAttempt: bossAttempt,
                outcome: outcome,
                cause: cause,
                phaseId: phaseId,
                lesson: lesson,
                weight: weight,
                day: day,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bossId,
                Value<String?> taskId = const Value.absent(),
                required int bossAttempt,
                required Outcome outcome,
                Value<FallCause?> cause = const Value.absent(),
                Value<String?> phaseId = const Value.absent(),
                Value<String?> lesson = const Value.absent(),
                Value<Weight?> weight = const Value.absent(),
                required String day,
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => AttemptsCompanion.insert(
                id: id,
                bossId: bossId,
                taskId: taskId,
                bossAttempt: bossAttempt,
                outcome: outcome,
                cause: cause,
                phaseId: phaseId,
                lesson: lesson,
                weight: weight,
                day: day,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttemptsTable, Attempt>(table),
                  $$AttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bossId = false, taskId = false, phaseId = false}) {
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
                        if (bossId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bossId,
                            referencedTable: $$AttemptsTableReferences
                                ._bossIdTable(db),
                            referencedColumn: $$AttemptsTableReferences
                                ._bossIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (taskId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.taskId,
                            referencedTable: $$AttemptsTableReferences
                                ._taskIdTable(db),
                            referencedColumn: $$AttemptsTableReferences
                                ._taskIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (phaseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.phaseId,
                            referencedTable: $$AttemptsTableReferences
                                ._phaseIdTable(db),
                            referencedColumn: $$AttemptsTableReferences
                                ._phaseIdTable(db)
                                .id,
                          ) as T;
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

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, $$AttemptsTableReferences),
      Attempt,
      PrefetchHooks Function({bool bossId, bool taskId, bool phaseId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<bool> tapMode,
  Value<ResetOnFail> defaultResetOnFail,
  Value<bool> haptics,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<bool> tapMode,
  Value<ResetOnFail> defaultResetOnFail,
  Value<bool> haptics,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<bool> get tapMode => $composableBuilder(
    column: $table.tapMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ResetOnFail, ResetOnFail, int>
  get defaultResetOnFail => $composableBuilder(
    column: $table.defaultResetOnFail,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get haptics => $composableBuilder(
    column: $table.haptics,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get tapMode => $composableBuilder(
    column: $table.tapMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultResetOnFail => $composableBuilder(
    column: $table.defaultResetOnFail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get haptics => $composableBuilder(
    column: $table.haptics,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get tapMode =>
      $composableBuilder(column: $table.tapMode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ResetOnFail, int> get defaultResetOnFail =>
      $composableBuilder(
        column: $table.defaultResetOnFail,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get haptics =>
      $composableBuilder(column: $table.haptics, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          AppSettings,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            AppSettings,
            BaseReferences<_$AppDatabase, $SettingsTable, AppSettings>,
          ),
          AppSettings,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> tapMode = const Value.absent(),
                Value<ResetOnFail> defaultResetOnFail = const Value.absent(),
                Value<bool> haptics = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                tapMode: tapMode,
                defaultResetOnFail: defaultResetOnFail,
                haptics: haptics,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> tapMode = const Value.absent(),
                Value<ResetOnFail> defaultResetOnFail = const Value.absent(),
                Value<bool> haptics = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                tapMode: tapMode,
                defaultResetOnFail: defaultResetOnFail,
                haptics: haptics,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, AppSettings>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, AppSettings>(
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

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      AppSettings,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (AppSettings, BaseReferences<_$AppDatabase, $SettingsTable, AppSettings>),
      AppSettings,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BossesTableTableManager get bosses =>
      $$BossesTableTableManager(_db, _db.bosses);
  $$PhasesTableTableManager get phases =>
      $$PhasesTableTableManager(_db, _db.phases);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}

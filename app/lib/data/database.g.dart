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
  static const VerificationMeta _dailyDeadlineMinutesMeta =
      const VerificationMeta('dailyDeadlineMinutes');
  @override
  late final GeneratedColumn<int> dailyDeadlineMinutes = GeneratedColumn<int>(
    'daily_deadline_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    bossId,
    phaseId,
    title,
    weight,
    recurrence,
    position,
    isSplit,
    dailyDeadlineMinutes,
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
    if (data.containsKey('daily_deadline_minutes')) {
      context.handle(
        _dailyDeadlineMinutesMeta,
        dailyDeadlineMinutes.isAcceptableOrUnknown(
          data['daily_deadline_minutes']!,
          _dailyDeadlineMinutesMeta,
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
      dailyDeadlineMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_deadline_minutes'],
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

  /// A standing daily deadline, minutes from midnight; daily tasks only
  /// (Stage 4 plan D12).
  final int? dailyDeadlineMinutes;
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
    this.dailyDeadlineMinutes,
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
    if (!nullToAbsent || dailyDeadlineMinutes != null) {
      map['daily_deadline_minutes'] = Variable<int>(dailyDeadlineMinutes);
    }
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
      dailyDeadlineMinutes: dailyDeadlineMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyDeadlineMinutes),
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
      dailyDeadlineMinutes: serializer.fromJson<int?>(
        json['dailyDeadlineMinutes'],
      ),
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
      'dailyDeadlineMinutes': serializer.toJson<int?>(dailyDeadlineMinutes),
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
    Value<int?> dailyDeadlineMinutes = const Value.absent(),
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
    dailyDeadlineMinutes: dailyDeadlineMinutes.present
        ? dailyDeadlineMinutes.value
        : this.dailyDeadlineMinutes,
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
      dailyDeadlineMinutes: data.dailyDeadlineMinutes.present
          ? data.dailyDeadlineMinutes.value
          : this.dailyDeadlineMinutes,
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
          ..write('dailyDeadlineMinutes: $dailyDeadlineMinutes, ')
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
    dailyDeadlineMinutes,
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
          other.dailyDeadlineMinutes == this.dailyDeadlineMinutes &&
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
  final Value<int?> dailyDeadlineMinutes;
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
    this.dailyDeadlineMinutes = const Value.absent(),
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
    this.dailyDeadlineMinutes = const Value.absent(),
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
    Expression<int>? dailyDeadlineMinutes,
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
      if (dailyDeadlineMinutes != null)
        'daily_deadline_minutes': dailyDeadlineMinutes,
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
    Value<int?>? dailyDeadlineMinutes,
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
      dailyDeadlineMinutes: dailyDeadlineMinutes ?? this.dailyDeadlineMinutes,
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
    if (dailyDeadlineMinutes.present) {
      map['daily_deadline_minutes'] = Variable<int>(dailyDeadlineMinutes.value);
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
          ..write('dailyDeadlineMinutes: $dailyDeadlineMinutes, ')
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
  static const VerificationMeta _rolloverHourMeta = const VerificationMeta(
    'rolloverHour',
  );
  @override
  late final GeneratedColumn<int> rolloverHour = GeneratedColumn<int>(
    'rollover_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderMinutesMeta = const VerificationMeta(
    'reminderMinutes',
  );
  @override
  late final GeneratedColumn<int> reminderMinutes = GeneratedColumn<int>(
    'reminder_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1260),
  );
  static const VerificationMeta _flasksMeta = const VerificationMeta('flasks');
  @override
  late final GeneratedColumn<int> flasks = GeneratedColumn<int>(
    'flasks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _lastResolvedDayMeta = const VerificationMeta(
    'lastResolvedDay',
  );
  @override
  late final GeneratedColumn<String> lastResolvedDay = GeneratedColumn<String>(
    'last_resolved_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstDayMeta = const VerificationMeta(
    'firstDay',
  );
  @override
  late final GeneratedColumn<String> firstDay = GeneratedColumn<String>(
    'first_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<bool> sound = GeneratedColumn<bool>(
    'sound',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tapMode,
    defaultResetOnFail,
    haptics,
    rolloverHour,
    reminderEnabled,
    reminderMinutes,
    flasks,
    lastResolvedDay,
    firstDay,
    sound,
    onboarded,
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
    if (data.containsKey('rollover_hour')) {
      context.handle(
        _rolloverHourMeta,
        rolloverHour.isAcceptableOrUnknown(
          data['rollover_hour']!,
          _rolloverHourMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minutes')) {
      context.handle(
        _reminderMinutesMeta,
        reminderMinutes.isAcceptableOrUnknown(
          data['reminder_minutes']!,
          _reminderMinutesMeta,
        ),
      );
    }
    if (data.containsKey('flasks')) {
      context.handle(
        _flasksMeta,
        flasks.isAcceptableOrUnknown(data['flasks']!, _flasksMeta),
      );
    }
    if (data.containsKey('last_resolved_day')) {
      context.handle(
        _lastResolvedDayMeta,
        lastResolvedDay.isAcceptableOrUnknown(
          data['last_resolved_day']!,
          _lastResolvedDayMeta,
        ),
      );
    }
    if (data.containsKey('first_day')) {
      context.handle(
        _firstDayMeta,
        firstDay.isAcceptableOrUnknown(data['first_day']!, _firstDayMeta),
      );
    }
    if (data.containsKey('sound')) {
      context.handle(
        _soundMeta,
        sound.isAcceptableOrUnknown(data['sound']!, _soundMeta),
      );
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
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
      rolloverHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rollover_hour'],
      )!,
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes'],
      )!,
      flasks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flasks'],
      )!,
      lastResolvedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_resolved_day'],
      ),
      firstDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_day'],
      ),
      sound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound'],
      )!,
      onboarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarded'],
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

  /// A day ends at this local hour (0 to 6); see `dayOf`.
  final int rolloverHour;
  final bool reminderEnabled;

  /// Minutes from midnight; 1260 is 21:00.
  final int reminderMinutes;
  final int flasks;

  /// The last day already judged for a missed bonfire. Set to the install or
  /// upgrade day, so that day is never judged (plan D12).
  final String? lastResolvedDay;

  /// The install or v4 upgrade day; the newcomer grace week counts from here
  /// (Stage 4 plan D13).
  final String? firstDay;

  /// Sound cues are off until the user turns them on (Stage 5 plan D12).
  final bool sound;

  /// False until onboarding is finished or skipped. The v5 upgrade sets it
  /// true so existing installs never see it (Stage 5 plan D11).
  final bool onboarded;
  const AppSettings({
    required this.id,
    required this.tapMode,
    required this.defaultResetOnFail,
    required this.haptics,
    required this.rolloverHour,
    required this.reminderEnabled,
    required this.reminderMinutes,
    required this.flasks,
    this.lastResolvedDay,
    this.firstDay,
    required this.sound,
    required this.onboarded,
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
    map['rollover_hour'] = Variable<int>(rolloverHour);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_minutes'] = Variable<int>(reminderMinutes);
    map['flasks'] = Variable<int>(flasks);
    if (!nullToAbsent || lastResolvedDay != null) {
      map['last_resolved_day'] = Variable<String>(lastResolvedDay);
    }
    if (!nullToAbsent || firstDay != null) {
      map['first_day'] = Variable<String>(firstDay);
    }
    map['sound'] = Variable<bool>(sound);
    map['onboarded'] = Variable<bool>(onboarded);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      tapMode: Value(tapMode),
      defaultResetOnFail: Value(defaultResetOnFail),
      haptics: Value(haptics),
      rolloverHour: Value(rolloverHour),
      reminderEnabled: Value(reminderEnabled),
      reminderMinutes: Value(reminderMinutes),
      flasks: Value(flasks),
      lastResolvedDay: lastResolvedDay == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResolvedDay),
      firstDay: firstDay == null && nullToAbsent
          ? const Value.absent()
          : Value(firstDay),
      sound: Value(sound),
      onboarded: Value(onboarded),
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
      rolloverHour: serializer.fromJson<int>(json['rolloverHour']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderMinutes: serializer.fromJson<int>(json['reminderMinutes']),
      flasks: serializer.fromJson<int>(json['flasks']),
      lastResolvedDay: serializer.fromJson<String?>(json['lastResolvedDay']),
      firstDay: serializer.fromJson<String?>(json['firstDay']),
      sound: serializer.fromJson<bool>(json['sound']),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
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
      'rolloverHour': serializer.toJson<int>(rolloverHour),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderMinutes': serializer.toJson<int>(reminderMinutes),
      'flasks': serializer.toJson<int>(flasks),
      'lastResolvedDay': serializer.toJson<String?>(lastResolvedDay),
      'firstDay': serializer.toJson<String?>(firstDay),
      'sound': serializer.toJson<bool>(sound),
      'onboarded': serializer.toJson<bool>(onboarded),
    };
  }

  AppSettings copyWith({
    int? id,
    bool? tapMode,
    ResetOnFail? defaultResetOnFail,
    bool? haptics,
    int? rolloverHour,
    bool? reminderEnabled,
    int? reminderMinutes,
    int? flasks,
    Value<String?> lastResolvedDay = const Value.absent(),
    Value<String?> firstDay = const Value.absent(),
    bool? sound,
    bool? onboarded,
  }) => AppSettings(
    id: id ?? this.id,
    tapMode: tapMode ?? this.tapMode,
    defaultResetOnFail: defaultResetOnFail ?? this.defaultResetOnFail,
    haptics: haptics ?? this.haptics,
    rolloverHour: rolloverHour ?? this.rolloverHour,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    flasks: flasks ?? this.flasks,
    lastResolvedDay: lastResolvedDay.present
        ? lastResolvedDay.value
        : this.lastResolvedDay,
    firstDay: firstDay.present ? firstDay.value : this.firstDay,
    sound: sound ?? this.sound,
    onboarded: onboarded ?? this.onboarded,
  );
  AppSettings copyWithCompanion(SettingsCompanion data) {
    return AppSettings(
      id: data.id.present ? data.id.value : this.id,
      tapMode: data.tapMode.present ? data.tapMode.value : this.tapMode,
      defaultResetOnFail: data.defaultResetOnFail.present
          ? data.defaultResetOnFail.value
          : this.defaultResetOnFail,
      haptics: data.haptics.present ? data.haptics.value : this.haptics,
      rolloverHour: data.rolloverHour.present
          ? data.rolloverHour.value
          : this.rolloverHour,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderMinutes: data.reminderMinutes.present
          ? data.reminderMinutes.value
          : this.reminderMinutes,
      flasks: data.flasks.present ? data.flasks.value : this.flasks,
      lastResolvedDay: data.lastResolvedDay.present
          ? data.lastResolvedDay.value
          : this.lastResolvedDay,
      firstDay: data.firstDay.present ? data.firstDay.value : this.firstDay,
      sound: data.sound.present ? data.sound.value : this.sound,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettings(')
          ..write('id: $id, ')
          ..write('tapMode: $tapMode, ')
          ..write('defaultResetOnFail: $defaultResetOnFail, ')
          ..write('haptics: $haptics, ')
          ..write('rolloverHour: $rolloverHour, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('flasks: $flasks, ')
          ..write('lastResolvedDay: $lastResolvedDay, ')
          ..write('firstDay: $firstDay, ')
          ..write('sound: $sound, ')
          ..write('onboarded: $onboarded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tapMode,
    defaultResetOnFail,
    haptics,
    rolloverHour,
    reminderEnabled,
    reminderMinutes,
    flasks,
    lastResolvedDay,
    firstDay,
    sound,
    onboarded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.id == this.id &&
          other.tapMode == this.tapMode &&
          other.defaultResetOnFail == this.defaultResetOnFail &&
          other.haptics == this.haptics &&
          other.rolloverHour == this.rolloverHour &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderMinutes == this.reminderMinutes &&
          other.flasks == this.flasks &&
          other.lastResolvedDay == this.lastResolvedDay &&
          other.firstDay == this.firstDay &&
          other.sound == this.sound &&
          other.onboarded == this.onboarded);
}

class SettingsCompanion extends UpdateCompanion<AppSettings> {
  final Value<int> id;
  final Value<bool> tapMode;
  final Value<ResetOnFail> defaultResetOnFail;
  final Value<bool> haptics;
  final Value<int> rolloverHour;
  final Value<bool> reminderEnabled;
  final Value<int> reminderMinutes;
  final Value<int> flasks;
  final Value<String?> lastResolvedDay;
  final Value<String?> firstDay;
  final Value<bool> sound;
  final Value<bool> onboarded;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.tapMode = const Value.absent(),
    this.defaultResetOnFail = const Value.absent(),
    this.haptics = const Value.absent(),
    this.rolloverHour = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.flasks = const Value.absent(),
    this.lastResolvedDay = const Value.absent(),
    this.firstDay = const Value.absent(),
    this.sound = const Value.absent(),
    this.onboarded = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.tapMode = const Value.absent(),
    this.defaultResetOnFail = const Value.absent(),
    this.haptics = const Value.absent(),
    this.rolloverHour = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.flasks = const Value.absent(),
    this.lastResolvedDay = const Value.absent(),
    this.firstDay = const Value.absent(),
    this.sound = const Value.absent(),
    this.onboarded = const Value.absent(),
  });
  static Insertable<AppSettings> custom({
    Expression<int>? id,
    Expression<bool>? tapMode,
    Expression<int>? defaultResetOnFail,
    Expression<bool>? haptics,
    Expression<int>? rolloverHour,
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderMinutes,
    Expression<int>? flasks,
    Expression<String>? lastResolvedDay,
    Expression<String>? firstDay,
    Expression<bool>? sound,
    Expression<bool>? onboarded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tapMode != null) 'tap_mode': tapMode,
      if (defaultResetOnFail != null)
        'default_reset_on_fail': defaultResetOnFail,
      if (haptics != null) 'haptics': haptics,
      if (rolloverHour != null) 'rollover_hour': rolloverHour,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderMinutes != null) 'reminder_minutes': reminderMinutes,
      if (flasks != null) 'flasks': flasks,
      if (lastResolvedDay != null) 'last_resolved_day': lastResolvedDay,
      if (firstDay != null) 'first_day': firstDay,
      if (sound != null) 'sound': sound,
      if (onboarded != null) 'onboarded': onboarded,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? tapMode,
    Value<ResetOnFail>? defaultResetOnFail,
    Value<bool>? haptics,
    Value<int>? rolloverHour,
    Value<bool>? reminderEnabled,
    Value<int>? reminderMinutes,
    Value<int>? flasks,
    Value<String?>? lastResolvedDay,
    Value<String?>? firstDay,
    Value<bool>? sound,
    Value<bool>? onboarded,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      tapMode: tapMode ?? this.tapMode,
      defaultResetOnFail: defaultResetOnFail ?? this.defaultResetOnFail,
      haptics: haptics ?? this.haptics,
      rolloverHour: rolloverHour ?? this.rolloverHour,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      flasks: flasks ?? this.flasks,
      lastResolvedDay: lastResolvedDay ?? this.lastResolvedDay,
      firstDay: firstDay ?? this.firstDay,
      sound: sound ?? this.sound,
      onboarded: onboarded ?? this.onboarded,
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
    if (rolloverHour.present) {
      map['rollover_hour'] = Variable<int>(rolloverHour.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderMinutes.present) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes.value);
    }
    if (flasks.present) {
      map['flasks'] = Variable<int>(flasks.value);
    }
    if (lastResolvedDay.present) {
      map['last_resolved_day'] = Variable<String>(lastResolvedDay.value);
    }
    if (firstDay.present) {
      map['first_day'] = Variable<String>(firstDay.value);
    }
    if (sound.present) {
      map['sound'] = Variable<bool>(sound.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('tapMode: $tapMode, ')
          ..write('defaultResetOnFail: $defaultResetOnFail, ')
          ..write('haptics: $haptics, ')
          ..write('rolloverHour: $rolloverHour, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('flasks: $flasks, ')
          ..write('lastResolvedDay: $lastResolvedDay, ')
          ..write('firstDay: $firstDay, ')
          ..write('sound: $sound, ')
          ..write('onboarded: $onboarded')
          ..write(')'))
        .toString();
  }
}

class $DayLogsTable extends DayLogs with TableInfo<$DayLogsTable, DayLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DayKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DayKind>($DayLogsTable.$converterkind);
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
  List<GeneratedColumn> get $columns => [day, kind, lesson, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('lesson')) {
      context.handle(
        _lessonMeta,
        lesson.isAcceptableOrUnknown(data['lesson']!, _lessonMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, kind};
  @override
  DayLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayLog(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      kind: $DayLogsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      lesson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $DayLogsTable createAlias(String alias) {
    return $DayLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DayKind, int, int> $converterkind =
      const EnumIndexConverter<DayKind>(DayKind.values);
}

class DayLog extends DataClass implements Insertable<DayLog> {
  final String day;
  final DayKind kind;

  /// Only on a bonfire row.
  final String? lesson;
  final DateTime at;
  const DayLog({
    required this.day,
    required this.kind,
    this.lesson,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    {
      map['kind'] = Variable<int>($DayLogsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || lesson != null) {
      map['lesson'] = Variable<String>(lesson);
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  DayLogsCompanion toCompanion(bool nullToAbsent) {
    return DayLogsCompanion(
      day: Value(day),
      kind: Value(kind),
      lesson: lesson == null && nullToAbsent
          ? const Value.absent()
          : Value(lesson),
      at: Value(at),
    );
  }

  factory DayLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayLog(
      day: serializer.fromJson<String>(json['day']),
      kind: $DayLogsTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      lesson: serializer.fromJson<String?>(json['lesson']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'kind': serializer.toJson<int>($DayLogsTable.$converterkind.toJson(kind)),
      'lesson': serializer.toJson<String?>(lesson),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  DayLog copyWith({
    String? day,
    DayKind? kind,
    Value<String?> lesson = const Value.absent(),
    DateTime? at,
  }) => DayLog(
    day: day ?? this.day,
    kind: kind ?? this.kind,
    lesson: lesson.present ? lesson.value : this.lesson,
    at: at ?? this.at,
  );
  DayLog copyWithCompanion(DayLogsCompanion data) {
    return DayLog(
      day: data.day.present ? data.day.value : this.day,
      kind: data.kind.present ? data.kind.value : this.kind,
      lesson: data.lesson.present ? data.lesson.value : this.lesson,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayLog(')
          ..write('day: $day, ')
          ..write('kind: $kind, ')
          ..write('lesson: $lesson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, kind, lesson, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayLog &&
          other.day == this.day &&
          other.kind == this.kind &&
          other.lesson == this.lesson &&
          other.at == this.at);
}

class DayLogsCompanion extends UpdateCompanion<DayLog> {
  final Value<String> day;
  final Value<DayKind> kind;
  final Value<String?> lesson;
  final Value<DateTime> at;
  final Value<int> rowid;
  const DayLogsCompanion({
    this.day = const Value.absent(),
    this.kind = const Value.absent(),
    this.lesson = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayLogsCompanion.insert({
    required String day,
    required DayKind kind,
    this.lesson = const Value.absent(),
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       kind = Value(kind),
       at = Value(at);
  static Insertable<DayLog> custom({
    Expression<String>? day,
    Expression<int>? kind,
    Expression<String>? lesson,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (kind != null) 'kind': kind,
      if (lesson != null) 'lesson': lesson,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayLogsCompanion copyWith({
    Value<String>? day,
    Value<DayKind>? kind,
    Value<String?>? lesson,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return DayLogsCompanion(
      day: day ?? this.day,
      kind: kind ?? this.kind,
      lesson: lesson ?? this.lesson,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $DayLogsTable.$converterkind.toSql(kind.value),
      );
    }
    if (lesson.present) {
      map['lesson'] = Variable<String>(lesson.value);
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
    return (StringBuffer('DayLogsCompanion(')
          ..write('day: $day, ')
          ..write('kind: $kind, ')
          ..write('lesson: $lesson, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmberEventsTable extends EmberEvents
    with TableInfo<$EmberEventsTable, EmberEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmberEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EmberKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<EmberKind>($EmberEventsTable.$converterkind);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bossIdMeta = const VerificationMeta('bossId');
  @override
  late final GeneratedColumn<String> bossId = GeneratedColumn<String>(
    'boss_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bosses (id) ON DELETE SET NULL',
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
    kind,
    amount,
    bossId,
    taskId,
    day,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ember_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmberEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('boss_id')) {
      context.handle(
        _bossIdMeta,
        bossId.isAcceptableOrUnknown(data['boss_id']!, _bossIdMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
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
  EmberEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmberEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $EmberEventsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      bossId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boss_id'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
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
  $EmberEventsTable createAlias(String alias) {
    return $EmberEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EmberKind, int, int> $converterkind =
      const EnumIndexConverter<EmberKind>(EmberKind.values);
}

class EmberEvent extends DataClass implements Insertable<EmberEvent> {
  final String id;
  final EmberKind kind;
  final int amount;
  final String? bossId;
  final String? taskId;
  final String day;
  final DateTime at;
  const EmberEvent({
    required this.id,
    required this.kind,
    required this.amount,
    this.bossId,
    this.taskId,
    required this.day,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<int>($EmberEventsTable.$converterkind.toSql(kind));
    }
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || bossId != null) {
      map['boss_id'] = Variable<String>(bossId);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  EmberEventsCompanion toCompanion(bool nullToAbsent) {
    return EmberEventsCompanion(
      id: Value(id),
      kind: Value(kind),
      amount: Value(amount),
      bossId: bossId == null && nullToAbsent
          ? const Value.absent()
          : Value(bossId),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      day: Value(day),
      at: Value(at),
    );
  }

  factory EmberEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmberEvent(
      id: serializer.fromJson<String>(json['id']),
      kind: $EmberEventsTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      amount: serializer.fromJson<int>(json['amount']),
      bossId: serializer.fromJson<String?>(json['bossId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<int>(
        $EmberEventsTable.$converterkind.toJson(kind),
      ),
      'amount': serializer.toJson<int>(amount),
      'bossId': serializer.toJson<String?>(bossId),
      'taskId': serializer.toJson<String?>(taskId),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  EmberEvent copyWith({
    String? id,
    EmberKind? kind,
    int? amount,
    Value<String?> bossId = const Value.absent(),
    Value<String?> taskId = const Value.absent(),
    String? day,
    DateTime? at,
  }) => EmberEvent(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    amount: amount ?? this.amount,
    bossId: bossId.present ? bossId.value : this.bossId,
    taskId: taskId.present ? taskId.value : this.taskId,
    day: day ?? this.day,
    at: at ?? this.at,
  );
  EmberEvent copyWithCompanion(EmberEventsCompanion data) {
    return EmberEvent(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      amount: data.amount.present ? data.amount.value : this.amount,
      bossId: data.bossId.present ? data.bossId.value : this.bossId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmberEvent(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('bossId: $bossId, ')
          ..write('taskId: $taskId, ')
          ..write('day: $day, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, amount, bossId, taskId, day, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmberEvent &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.amount == this.amount &&
          other.bossId == this.bossId &&
          other.taskId == this.taskId &&
          other.day == this.day &&
          other.at == this.at);
}

class EmberEventsCompanion extends UpdateCompanion<EmberEvent> {
  final Value<String> id;
  final Value<EmberKind> kind;
  final Value<int> amount;
  final Value<String?> bossId;
  final Value<String?> taskId;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<int> rowid;
  const EmberEventsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.amount = const Value.absent(),
    this.bossId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmberEventsCompanion.insert({
    required String id,
    required EmberKind kind,
    required int amount,
    this.bossId = const Value.absent(),
    this.taskId = const Value.absent(),
    required String day,
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       amount = Value(amount),
       day = Value(day),
       at = Value(at);
  static Insertable<EmberEvent> custom({
    Expression<String>? id,
    Expression<int>? kind,
    Expression<int>? amount,
    Expression<String>? bossId,
    Expression<String>? taskId,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (amount != null) 'amount': amount,
      if (bossId != null) 'boss_id': bossId,
      if (taskId != null) 'task_id': taskId,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmberEventsCompanion copyWith({
    Value<String>? id,
    Value<EmberKind>? kind,
    Value<int>? amount,
    Value<String?>? bossId,
    Value<String?>? taskId,
    Value<String>? day,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return EmberEventsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      bossId: bossId ?? this.bossId,
      taskId: taskId ?? this.taskId,
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
    if (kind.present) {
      map['kind'] = Variable<int>(
        $EmberEventsTable.$converterkind.toSql(kind.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (bossId.present) {
      map['boss_id'] = Variable<String>(bossId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
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
    return (StringBuffer('EmberEventsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('bossId: $bossId, ')
          ..write('taskId: $taskId, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanPicksTable extends PlanPicks
    with TableInfo<$PlanPicksTable, PlanPick> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanPicksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
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
  @override
  List<GeneratedColumn> get $columns => [day, taskId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_picks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanPick> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, taskId};
  @override
  PlanPick map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanPick(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlanPicksTable createAlias(String alias) {
    return $PlanPicksTable(attachedDatabase, alias);
  }
}

class PlanPick extends DataClass implements Insertable<PlanPick> {
  final String day;
  final String taskId;
  final int position;
  const PlanPick({
    required this.day,
    required this.taskId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['task_id'] = Variable<String>(taskId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlanPicksCompanion toCompanion(bool nullToAbsent) {
    return PlanPicksCompanion(
      day: Value(day),
      taskId: Value(taskId),
      position: Value(position),
    );
  }

  factory PlanPick.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanPick(
      day: serializer.fromJson<String>(json['day']),
      taskId: serializer.fromJson<String>(json['taskId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'taskId': serializer.toJson<String>(taskId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlanPick copyWith({String? day, String? taskId, int? position}) => PlanPick(
    day: day ?? this.day,
    taskId: taskId ?? this.taskId,
    position: position ?? this.position,
  );
  PlanPick copyWithCompanion(PlanPicksCompanion data) {
    return PlanPick(
      day: data.day.present ? data.day.value : this.day,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanPick(')
          ..write('day: $day, ')
          ..write('taskId: $taskId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, taskId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanPick &&
          other.day == this.day &&
          other.taskId == this.taskId &&
          other.position == this.position);
}

class PlanPicksCompanion extends UpdateCompanion<PlanPick> {
  final Value<String> day;
  final Value<String> taskId;
  final Value<int> position;
  final Value<int> rowid;
  const PlanPicksCompanion({
    this.day = const Value.absent(),
    this.taskId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanPicksCompanion.insert({
    required String day,
    required String taskId,
    required int position,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       taskId = Value(taskId),
       position = Value(position);
  static Insertable<PlanPick> custom({
    Expression<String>? day,
    Expression<String>? taskId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (taskId != null) 'task_id': taskId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanPicksCompanion copyWith({
    Value<String>? day,
    Value<String>? taskId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return PlanPicksCompanion(
      day: day ?? this.day,
      taskId: taskId ?? this.taskId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanPicksCompanion(')
          ..write('day: $day, ')
          ..write('taskId: $taskId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommitmentsTable extends Commitments
    with TableInfo<$CommitmentsTable, Commitment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionsMeta = const VerificationMeta(
    'extensions',
  );
  @override
  late final GeneratedColumn<int> extensions = GeneratedColumn<int>(
    'extensions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remindMeta = const VerificationMeta('remind');
  @override
  late final GeneratedColumn<bool> remind = GeneratedColumn<bool>(
    'remind',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CommitmentOutcome?, int> outcome =
      GeneratedColumn<int>(
        'outcome',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<CommitmentOutcome?>($CommitmentsTable.$converteroutcomen);
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
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
    taskId,
    bossId,
    day,
    deadline,
    extensions,
    remind,
    outcome,
    resolvedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commitments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Commitment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('boss_id')) {
      context.handle(
        _bossIdMeta,
        bossId.isAcceptableOrUnknown(data['boss_id']!, _bossIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bossIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    } else if (isInserting) {
      context.missing(_deadlineMeta);
    }
    if (data.containsKey('extensions')) {
      context.handle(
        _extensionsMeta,
        extensions.isAcceptableOrUnknown(data['extensions']!, _extensionsMeta),
      );
    }
    if (data.containsKey('remind')) {
      context.handle(
        _remindMeta,
        remind.isAcceptableOrUnknown(data['remind']!, _remindMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
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
    {taskId, day},
  ];
  @override
  Commitment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Commitment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      bossId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boss_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      )!,
      extensions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extensions'],
      )!,
      remind: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind'],
      )!,
      outcome: $CommitmentsTable.$converteroutcomen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}outcome'],
        ),
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
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
  $CommitmentsTable createAlias(String alias) {
    return $CommitmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CommitmentOutcome, int, int> $converteroutcome =
      const EnumIndexConverter<CommitmentOutcome>(CommitmentOutcome.values);
  static JsonTypeConverter2<CommitmentOutcome?, int?, int?> $converteroutcomen =
      JsonTypeConverter2.asNullable($converteroutcome);
}

class Commitment extends DataClass implements Insertable<Commitment> {
  final String id;
  final String taskId;
  final String bossId;
  final String day;
  final DateTime deadline;
  final int extensions;
  final bool remind;
  final CommitmentOutcome? outcome;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Commitment({
    required this.id,
    required this.taskId,
    required this.bossId,
    required this.day,
    required this.deadline,
    required this.extensions,
    required this.remind,
    this.outcome,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['boss_id'] = Variable<String>(bossId);
    map['day'] = Variable<String>(day);
    map['deadline'] = Variable<DateTime>(deadline);
    map['extensions'] = Variable<int>(extensions);
    map['remind'] = Variable<bool>(remind);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<int>(
        $CommitmentsTable.$converteroutcomen.toSql(outcome),
      );
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CommitmentsCompanion toCompanion(bool nullToAbsent) {
    return CommitmentsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      bossId: Value(bossId),
      day: Value(day),
      deadline: Value(deadline),
      extensions: Value(extensions),
      remind: Value(remind),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Commitment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Commitment(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      bossId: serializer.fromJson<String>(json['bossId']),
      day: serializer.fromJson<String>(json['day']),
      deadline: serializer.fromJson<DateTime>(json['deadline']),
      extensions: serializer.fromJson<int>(json['extensions']),
      remind: serializer.fromJson<bool>(json['remind']),
      outcome: $CommitmentsTable.$converteroutcomen.fromJson(
        serializer.fromJson<int?>(json['outcome']),
      ),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'bossId': serializer.toJson<String>(bossId),
      'day': serializer.toJson<String>(day),
      'deadline': serializer.toJson<DateTime>(deadline),
      'extensions': serializer.toJson<int>(extensions),
      'remind': serializer.toJson<bool>(remind),
      'outcome': serializer.toJson<int?>(
        $CommitmentsTable.$converteroutcomen.toJson(outcome),
      ),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Commitment copyWith({
    String? id,
    String? taskId,
    String? bossId,
    String? day,
    DateTime? deadline,
    int? extensions,
    bool? remind,
    Value<CommitmentOutcome?> outcome = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Commitment(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    bossId: bossId ?? this.bossId,
    day: day ?? this.day,
    deadline: deadline ?? this.deadline,
    extensions: extensions ?? this.extensions,
    remind: remind ?? this.remind,
    outcome: outcome.present ? outcome.value : this.outcome,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Commitment copyWithCompanion(CommitmentsCompanion data) {
    return Commitment(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      bossId: data.bossId.present ? data.bossId.value : this.bossId,
      day: data.day.present ? data.day.value : this.day,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      extensions: data.extensions.present
          ? data.extensions.value
          : this.extensions,
      remind: data.remind.present ? data.remind.value : this.remind,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Commitment(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('bossId: $bossId, ')
          ..write('day: $day, ')
          ..write('deadline: $deadline, ')
          ..write('extensions: $extensions, ')
          ..write('remind: $remind, ')
          ..write('outcome: $outcome, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    bossId,
    day,
    deadline,
    extensions,
    remind,
    outcome,
    resolvedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Commitment &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.bossId == this.bossId &&
          other.day == this.day &&
          other.deadline == this.deadline &&
          other.extensions == this.extensions &&
          other.remind == this.remind &&
          other.outcome == this.outcome &&
          other.resolvedAt == this.resolvedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CommitmentsCompanion extends UpdateCompanion<Commitment> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> bossId;
  final Value<String> day;
  final Value<DateTime> deadline;
  final Value<int> extensions;
  final Value<bool> remind;
  final Value<CommitmentOutcome?> outcome;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CommitmentsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.bossId = const Value.absent(),
    this.day = const Value.absent(),
    this.deadline = const Value.absent(),
    this.extensions = const Value.absent(),
    this.remind = const Value.absent(),
    this.outcome = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommitmentsCompanion.insert({
    required String id,
    required String taskId,
    required String bossId,
    required String day,
    required DateTime deadline,
    this.extensions = const Value.absent(),
    this.remind = const Value.absent(),
    this.outcome = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       bossId = Value(bossId),
       day = Value(day),
       deadline = Value(deadline),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Commitment> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? bossId,
    Expression<String>? day,
    Expression<DateTime>? deadline,
    Expression<int>? extensions,
    Expression<bool>? remind,
    Expression<int>? outcome,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (bossId != null) 'boss_id': bossId,
      if (day != null) 'day': day,
      if (deadline != null) 'deadline': deadline,
      if (extensions != null) 'extensions': extensions,
      if (remind != null) 'remind': remind,
      if (outcome != null) 'outcome': outcome,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommitmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? bossId,
    Value<String>? day,
    Value<DateTime>? deadline,
    Value<int>? extensions,
    Value<bool>? remind,
    Value<CommitmentOutcome?>? outcome,
    Value<DateTime?>? resolvedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CommitmentsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      bossId: bossId ?? this.bossId,
      day: day ?? this.day,
      deadline: deadline ?? this.deadline,
      extensions: extensions ?? this.extensions,
      remind: remind ?? this.remind,
      outcome: outcome ?? this.outcome,
      resolvedAt: resolvedAt ?? this.resolvedAt,
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
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (bossId.present) {
      map['boss_id'] = Variable<String>(bossId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (extensions.present) {
      map['extensions'] = Variable<int>(extensions.value);
    }
    if (remind.present) {
      map['remind'] = Variable<bool>(remind.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<int>(
        $CommitmentsTable.$converteroutcomen.toSql(outcome.value),
      );
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
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
    return (StringBuffer('CommitmentsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('bossId: $bossId, ')
          ..write('day: $day, ')
          ..write('deadline: $deadline, ')
          ..write('extensions: $extensions, ')
          ..write('remind: $remind, ')
          ..write('outcome: $outcome, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthEventsTable extends HealthEvents
    with TableInfo<$HealthEventsTable, HealthEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HealthReason, int> reason =
      GeneratedColumn<int>(
        'reason',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<HealthReason>($HealthEventsTable.$converterreason);
  static const VerificationMeta _commitmentIdMeta = const VerificationMeta(
    'commitmentId',
  );
  @override
  late final GeneratedColumn<String> commitmentId = GeneratedColumn<String>(
    'commitment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES commitments (id) ON DELETE SET NULL',
    ),
  );
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
    amount,
    reason,
    commitmentId,
    day,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('commitment_id')) {
      context.handle(
        _commitmentIdMeta,
        commitmentId.isAcceptableOrUnknown(
          data['commitment_id']!,
          _commitmentIdMeta,
        ),
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
  HealthEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      reason: $HealthEventsTable.$converterreason.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}reason'],
        )!,
      ),
      commitmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commitment_id'],
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
  $HealthEventsTable createAlias(String alias) {
    return $HealthEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HealthReason, int, int> $converterreason =
      const EnumIndexConverter<HealthReason>(HealthReason.values);
}

class HealthEvent extends DataClass implements Insertable<HealthEvent> {
  final String id;
  final int amount;
  final HealthReason reason;
  final String? commitmentId;
  final String day;
  final DateTime at;
  const HealthEvent({
    required this.id,
    required this.amount,
    required this.reason,
    this.commitmentId,
    required this.day,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<int>(amount);
    {
      map['reason'] = Variable<int>(
        $HealthEventsTable.$converterreason.toSql(reason),
      );
    }
    if (!nullToAbsent || commitmentId != null) {
      map['commitment_id'] = Variable<String>(commitmentId);
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  HealthEventsCompanion toCompanion(bool nullToAbsent) {
    return HealthEventsCompanion(
      id: Value(id),
      amount: Value(amount),
      reason: Value(reason),
      commitmentId: commitmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(commitmentId),
      day: Value(day),
      at: Value(at),
    );
  }

  factory HealthEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthEvent(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: $HealthEventsTable.$converterreason.fromJson(
        serializer.fromJson<int>(json['reason']),
      ),
      commitmentId: serializer.fromJson<String?>(json['commitmentId']),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<int>(
        $HealthEventsTable.$converterreason.toJson(reason),
      ),
      'commitmentId': serializer.toJson<String?>(commitmentId),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  HealthEvent copyWith({
    String? id,
    int? amount,
    HealthReason? reason,
    Value<String?> commitmentId = const Value.absent(),
    String? day,
    DateTime? at,
  }) => HealthEvent(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
    commitmentId: commitmentId.present ? commitmentId.value : this.commitmentId,
    day: day ?? this.day,
    at: at ?? this.at,
  );
  HealthEvent copyWithCompanion(HealthEventsCompanion data) {
    return HealthEvent(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      commitmentId: data.commitmentId.present
          ? data.commitmentId.value
          : this.commitmentId,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthEvent(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('day: $day, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, reason, commitmentId, day, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthEvent &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.commitmentId == this.commitmentId &&
          other.day == this.day &&
          other.at == this.at);
}

class HealthEventsCompanion extends UpdateCompanion<HealthEvent> {
  final Value<String> id;
  final Value<int> amount;
  final Value<HealthReason> reason;
  final Value<String?> commitmentId;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<int> rowid;
  const HealthEventsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.commitmentId = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthEventsCompanion.insert({
    required String id,
    required int amount,
    required HealthReason reason,
    this.commitmentId = const Value.absent(),
    required String day,
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       reason = Value(reason),
       day = Value(day),
       at = Value(at);
  static Insertable<HealthEvent> custom({
    Expression<String>? id,
    Expression<int>? amount,
    Expression<int>? reason,
    Expression<String>? commitmentId,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (commitmentId != null) 'commitment_id': commitmentId,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthEventsCompanion copyWith({
    Value<String>? id,
    Value<int>? amount,
    Value<HealthReason>? reason,
    Value<String?>? commitmentId,
    Value<String>? day,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return HealthEventsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      commitmentId: commitmentId ?? this.commitmentId,
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
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<int>(
        $HealthEventsTable.$converterreason.toSql(reason.value),
      );
    }
    if (commitmentId.present) {
      map['commitment_id'] = Variable<String>(commitmentId.value);
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
    return (StringBuffer('HealthEventsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelicsTable extends Relics with TableInfo<$RelicsTable, Relic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelicsTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bosses (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Weathering, int> emblem =
      GeneratedColumn<int>(
        'emblem',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Weathering>($RelicsTable.$converteremblem);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effortMeta = const VerificationMeta('effort');
  @override
  late final GeneratedColumn<int> effort = GeneratedColumn<int>(
    'effort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storyMeta = const VerificationMeta('story');
  @override
  late final GeneratedColumn<String> story = GeneratedColumn<String>(
    'story',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inscriptionMeta = const VerificationMeta(
    'inscription',
  );
  @override
  late final GeneratedColumn<String> inscription = GeneratedColumn<String>(
    'inscription',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defeatedDayMeta = const VerificationMeta(
    'defeatedDay',
  );
  @override
  late final GeneratedColumn<String> defeatedDay = GeneratedColumn<String>(
    'defeated_day',
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
    bossId,
    name,
    emblem,
    attempts,
    days,
    effort,
    story,
    inscription,
    defeatedDay,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Relic> instance, {
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
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptsMeta);
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('effort')) {
      context.handle(
        _effortMeta,
        effort.isAcceptableOrUnknown(data['effort']!, _effortMeta),
      );
    } else if (isInserting) {
      context.missing(_effortMeta);
    }
    if (data.containsKey('story')) {
      context.handle(
        _storyMeta,
        story.isAcceptableOrUnknown(data['story']!, _storyMeta),
      );
    } else if (isInserting) {
      context.missing(_storyMeta);
    }
    if (data.containsKey('inscription')) {
      context.handle(
        _inscriptionMeta,
        inscription.isAcceptableOrUnknown(
          data['inscription']!,
          _inscriptionMeta,
        ),
      );
    }
    if (data.containsKey('defeated_day')) {
      context.handle(
        _defeatedDayMeta,
        defeatedDay.isAcceptableOrUnknown(
          data['defeated_day']!,
          _defeatedDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defeatedDayMeta);
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
    {bossId},
  ];
  @override
  Relic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Relic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bossId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boss_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emblem: $RelicsTable.$converteremblem.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}emblem'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
      effort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effort'],
      )!,
      story: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story'],
      )!,
      inscription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inscription'],
      ),
      defeatedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}defeated_day'],
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
  $RelicsTable createAlias(String alias) {
    return $RelicsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Weathering, int, int> $converteremblem =
      const EnumIndexConverter<Weathering>(Weathering.values);
}

class Relic extends DataClass implements Insertable<Relic> {
  final String id;

  /// Cleared when the boss is deleted; the relic stays.
  final String? bossId;
  final String name;
  final Weathering emblem;
  final int attempts;
  final int days;
  final int effort;

  /// JSON of a `RelicStory`.
  final String story;
  final String? inscription;
  final String defeatedDay;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Relic({
    required this.id,
    this.bossId,
    required this.name,
    required this.emblem,
    required this.attempts,
    required this.days,
    required this.effort,
    required this.story,
    this.inscription,
    required this.defeatedDay,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || bossId != null) {
      map['boss_id'] = Variable<String>(bossId);
    }
    map['name'] = Variable<String>(name);
    {
      map['emblem'] = Variable<int>(
        $RelicsTable.$converteremblem.toSql(emblem),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    map['days'] = Variable<int>(days);
    map['effort'] = Variable<int>(effort);
    map['story'] = Variable<String>(story);
    if (!nullToAbsent || inscription != null) {
      map['inscription'] = Variable<String>(inscription);
    }
    map['defeated_day'] = Variable<String>(defeatedDay);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RelicsCompanion toCompanion(bool nullToAbsent) {
    return RelicsCompanion(
      id: Value(id),
      bossId: bossId == null && nullToAbsent
          ? const Value.absent()
          : Value(bossId),
      name: Value(name),
      emblem: Value(emblem),
      attempts: Value(attempts),
      days: Value(days),
      effort: Value(effort),
      story: Value(story),
      inscription: inscription == null && nullToAbsent
          ? const Value.absent()
          : Value(inscription),
      defeatedDay: Value(defeatedDay),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Relic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Relic(
      id: serializer.fromJson<String>(json['id']),
      bossId: serializer.fromJson<String?>(json['bossId']),
      name: serializer.fromJson<String>(json['name']),
      emblem: $RelicsTable.$converteremblem.fromJson(
        serializer.fromJson<int>(json['emblem']),
      ),
      attempts: serializer.fromJson<int>(json['attempts']),
      days: serializer.fromJson<int>(json['days']),
      effort: serializer.fromJson<int>(json['effort']),
      story: serializer.fromJson<String>(json['story']),
      inscription: serializer.fromJson<String?>(json['inscription']),
      defeatedDay: serializer.fromJson<String>(json['defeatedDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bossId': serializer.toJson<String?>(bossId),
      'name': serializer.toJson<String>(name),
      'emblem': serializer.toJson<int>(
        $RelicsTable.$converteremblem.toJson(emblem),
      ),
      'attempts': serializer.toJson<int>(attempts),
      'days': serializer.toJson<int>(days),
      'effort': serializer.toJson<int>(effort),
      'story': serializer.toJson<String>(story),
      'inscription': serializer.toJson<String?>(inscription),
      'defeatedDay': serializer.toJson<String>(defeatedDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Relic copyWith({
    String? id,
    Value<String?> bossId = const Value.absent(),
    String? name,
    Weathering? emblem,
    int? attempts,
    int? days,
    int? effort,
    String? story,
    Value<String?> inscription = const Value.absent(),
    String? defeatedDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Relic(
    id: id ?? this.id,
    bossId: bossId.present ? bossId.value : this.bossId,
    name: name ?? this.name,
    emblem: emblem ?? this.emblem,
    attempts: attempts ?? this.attempts,
    days: days ?? this.days,
    effort: effort ?? this.effort,
    story: story ?? this.story,
    inscription: inscription.present ? inscription.value : this.inscription,
    defeatedDay: defeatedDay ?? this.defeatedDay,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Relic copyWithCompanion(RelicsCompanion data) {
    return Relic(
      id: data.id.present ? data.id.value : this.id,
      bossId: data.bossId.present ? data.bossId.value : this.bossId,
      name: data.name.present ? data.name.value : this.name,
      emblem: data.emblem.present ? data.emblem.value : this.emblem,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      days: data.days.present ? data.days.value : this.days,
      effort: data.effort.present ? data.effort.value : this.effort,
      story: data.story.present ? data.story.value : this.story,
      inscription: data.inscription.present
          ? data.inscription.value
          : this.inscription,
      defeatedDay: data.defeatedDay.present
          ? data.defeatedDay.value
          : this.defeatedDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Relic(')
          ..write('id: $id, ')
          ..write('bossId: $bossId, ')
          ..write('name: $name, ')
          ..write('emblem: $emblem, ')
          ..write('attempts: $attempts, ')
          ..write('days: $days, ')
          ..write('effort: $effort, ')
          ..write('story: $story, ')
          ..write('inscription: $inscription, ')
          ..write('defeatedDay: $defeatedDay, ')
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
    emblem,
    attempts,
    days,
    effort,
    story,
    inscription,
    defeatedDay,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Relic &&
          other.id == this.id &&
          other.bossId == this.bossId &&
          other.name == this.name &&
          other.emblem == this.emblem &&
          other.attempts == this.attempts &&
          other.days == this.days &&
          other.effort == this.effort &&
          other.story == this.story &&
          other.inscription == this.inscription &&
          other.defeatedDay == this.defeatedDay &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RelicsCompanion extends UpdateCompanion<Relic> {
  final Value<String> id;
  final Value<String?> bossId;
  final Value<String> name;
  final Value<Weathering> emblem;
  final Value<int> attempts;
  final Value<int> days;
  final Value<int> effort;
  final Value<String> story;
  final Value<String?> inscription;
  final Value<String> defeatedDay;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RelicsCompanion({
    this.id = const Value.absent(),
    this.bossId = const Value.absent(),
    this.name = const Value.absent(),
    this.emblem = const Value.absent(),
    this.attempts = const Value.absent(),
    this.days = const Value.absent(),
    this.effort = const Value.absent(),
    this.story = const Value.absent(),
    this.inscription = const Value.absent(),
    this.defeatedDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelicsCompanion.insert({
    required String id,
    this.bossId = const Value.absent(),
    required String name,
    required Weathering emblem,
    required int attempts,
    required int days,
    required int effort,
    required String story,
    this.inscription = const Value.absent(),
    required String defeatedDay,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       emblem = Value(emblem),
       attempts = Value(attempts),
       days = Value(days),
       effort = Value(effort),
       story = Value(story),
       defeatedDay = Value(defeatedDay),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Relic> custom({
    Expression<String>? id,
    Expression<String>? bossId,
    Expression<String>? name,
    Expression<int>? emblem,
    Expression<int>? attempts,
    Expression<int>? days,
    Expression<int>? effort,
    Expression<String>? story,
    Expression<String>? inscription,
    Expression<String>? defeatedDay,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bossId != null) 'boss_id': bossId,
      if (name != null) 'name': name,
      if (emblem != null) 'emblem': emblem,
      if (attempts != null) 'attempts': attempts,
      if (days != null) 'days': days,
      if (effort != null) 'effort': effort,
      if (story != null) 'story': story,
      if (inscription != null) 'inscription': inscription,
      if (defeatedDay != null) 'defeated_day': defeatedDay,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelicsCompanion copyWith({
    Value<String>? id,
    Value<String?>? bossId,
    Value<String>? name,
    Value<Weathering>? emblem,
    Value<int>? attempts,
    Value<int>? days,
    Value<int>? effort,
    Value<String>? story,
    Value<String?>? inscription,
    Value<String>? defeatedDay,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RelicsCompanion(
      id: id ?? this.id,
      bossId: bossId ?? this.bossId,
      name: name ?? this.name,
      emblem: emblem ?? this.emblem,
      attempts: attempts ?? this.attempts,
      days: days ?? this.days,
      effort: effort ?? this.effort,
      story: story ?? this.story,
      inscription: inscription ?? this.inscription,
      defeatedDay: defeatedDay ?? this.defeatedDay,
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
    if (emblem.present) {
      map['emblem'] = Variable<int>(
        $RelicsTable.$converteremblem.toSql(emblem.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    if (effort.present) {
      map['effort'] = Variable<int>(effort.value);
    }
    if (story.present) {
      map['story'] = Variable<String>(story.value);
    }
    if (inscription.present) {
      map['inscription'] = Variable<String>(inscription.value);
    }
    if (defeatedDay.present) {
      map['defeated_day'] = Variable<String>(defeatedDay.value);
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
    return (StringBuffer('RelicsCompanion(')
          ..write('id: $id, ')
          ..write('bossId: $bossId, ')
          ..write('name: $name, ')
          ..write('emblem: $emblem, ')
          ..write('attempts: $attempts, ')
          ..write('days: $days, ')
          ..write('effort: $effort, ')
          ..write('story: $story, ')
          ..write('inscription: $inscription, ')
          ..write('defeatedDay: $defeatedDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstAtMeta = const VerificationMeta(
    'firstAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstAt = GeneratedColumn<DateTime>(
    'first_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, firstAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Visit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('first_at')) {
      context.handle(
        _firstAtMeta,
        firstAt.isAcceptableOrUnknown(data['first_at']!, _firstAtMeta),
      );
    } else if (isInserting) {
      context.missing(_firstAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      firstAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_at'],
      )!,
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class Visit extends DataClass implements Insertable<Visit> {
  final String day;
  final DateTime firstAt;
  const Visit({required this.day, required this.firstAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['first_at'] = Variable<DateTime>(firstAt);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(day: Value(day), firstAt: Value(firstAt));
  }

  factory Visit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Visit(
      day: serializer.fromJson<String>(json['day']),
      firstAt: serializer.fromJson<DateTime>(json['firstAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'firstAt': serializer.toJson<DateTime>(firstAt),
    };
  }

  Visit copyWith({String? day, DateTime? firstAt}) =>
      Visit(day: day ?? this.day, firstAt: firstAt ?? this.firstAt);
  Visit copyWithCompanion(VisitsCompanion data) {
    return Visit(
      day: data.day.present ? data.day.value : this.day,
      firstAt: data.firstAt.present ? data.firstAt.value : this.firstAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Visit(')
          ..write('day: $day, ')
          ..write('firstAt: $firstAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, firstAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Visit &&
          other.day == this.day &&
          other.firstAt == this.firstAt);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<String> day;
  final Value<DateTime> firstAt;
  final Value<int> rowid;
  const VisitsCompanion({
    this.day = const Value.absent(),
    this.firstAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String day,
    required DateTime firstAt,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       firstAt = Value(firstAt);
  static Insertable<Visit> custom({
    Expression<String>? day,
    Expression<DateTime>? firstAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (firstAt != null) 'first_at': firstAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith({
    Value<String>? day,
    Value<DateTime>? firstAt,
    Value<int>? rowid,
  }) {
    return VisitsCompanion(
      day: day ?? this.day,
      firstAt: firstAt ?? this.firstAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (firstAt.present) {
      map['first_at'] = Variable<DateTime>(firstAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('day: $day, ')
          ..write('firstAt: $firstAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SignalEventsTable extends SignalEvents
    with TableInfo<$SignalEventsTable, SignalEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SignalKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SignalKind>($SignalEventsTable.$converterkind);
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
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, day, at, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signal_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SignalEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignalEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignalEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $SignalEventsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SignalEventsTable createAlias(String alias) {
    return $SignalEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SignalKind, int, int> $converterkind =
      const EnumIndexConverter<SignalKind>(SignalKind.values);
}

class SignalEvent extends DataClass implements Insertable<SignalEvent> {
  final String id;
  final SignalKind kind;
  final String day;
  final DateTime at;

  /// Tap mode on (1) or off (0), or a `CheckInAnswer` index.
  final int? value;
  const SignalEvent({
    required this.id,
    required this.kind,
    required this.day,
    required this.at,
    this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<int>(
        $SignalEventsTable.$converterkind.toSql(kind),
      );
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<int>(value);
    }
    return map;
  }

  SignalEventsCompanion toCompanion(bool nullToAbsent) {
    return SignalEventsCompanion(
      id: Value(id),
      kind: Value(kind),
      day: Value(day),
      at: Value(at),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SignalEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignalEvent(
      id: serializer.fromJson<String>(json['id']),
      kind: $SignalEventsTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
      value: serializer.fromJson<int?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<int>(
        $SignalEventsTable.$converterkind.toJson(kind),
      ),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
      'value': serializer.toJson<int?>(value),
    };
  }

  SignalEvent copyWith({
    String? id,
    SignalKind? kind,
    String? day,
    DateTime? at,
    Value<int?> value = const Value.absent(),
  }) => SignalEvent(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    day: day ?? this.day,
    at: at ?? this.at,
    value: value.present ? value.value : this.value,
  );
  SignalEvent copyWithCompanion(SignalEventsCompanion data) {
    return SignalEvent(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignalEvent(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, day, at, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignalEvent &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.day == this.day &&
          other.at == this.at &&
          other.value == this.value);
}

class SignalEventsCompanion extends UpdateCompanion<SignalEvent> {
  final Value<String> id;
  final Value<SignalKind> kind;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<int?> value;
  final Value<int> rowid;
  const SignalEventsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SignalEventsCompanion.insert({
    required String id,
    required SignalKind kind,
    required String day,
    required DateTime at,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       day = Value(day),
       at = Value(at);
  static Insertable<SignalEvent> custom({
    Expression<String>? id,
    Expression<int>? kind,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SignalEventsCompanion copyWith({
    Value<String>? id,
    Value<SignalKind>? kind,
    Value<String>? day,
    Value<DateTime>? at,
    Value<int?>? value,
    Value<int>? rowid,
  }) {
    return SignalEventsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      day: day ?? this.day,
      at: at ?? this.at,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $SignalEventsTable.$converterkind.toSql(kind.value),
      );
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalEventsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
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
  late final $DayLogsTable dayLogs = $DayLogsTable(this);
  late final $EmberEventsTable emberEvents = $EmberEventsTable(this);
  late final $PlanPicksTable planPicks = $PlanPicksTable(this);
  late final $CommitmentsTable commitments = $CommitmentsTable(this);
  late final $HealthEventsTable healthEvents = $HealthEventsTable(this);
  late final $RelicsTable relics = $RelicsTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $SignalEventsTable signalEvents = $SignalEventsTable(this);
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
    dayLogs,
    emberEvents,
    planPicks,
    commitments,
    healthEvents,
    relics,
    visits,
    signalEvents,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bosses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ember_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ember_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_picks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('commitments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bosses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('commitments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'commitments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('health_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bosses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('relics', kind: UpdateKind.update)],
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

  static MultiTypedResultKey<$EmberEventsTable, List<EmberEvent>>
  _emberEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.emberEvents,
    aliasName: 'bosses__id__ember_events__boss_id',
  );

  $$EmberEventsTableProcessedTableManager get emberEventsRefs {
    final manager = $$EmberEventsTableTableManager(
      $_db,
      $_db.emberEvents,
    ).filter((f) => f.bossId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_emberEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CommitmentsTable, List<Commitment>>
  _commitmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.commitments,
    aliasName: 'bosses__id__commitments__boss_id',
  );

  $$CommitmentsTableProcessedTableManager get commitmentsRefs {
    final manager = $$CommitmentsTableTableManager(
      $_db,
      $_db.commitments,
    ).filter((f) => f.bossId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commitmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RelicsTable, List<Relic>> _relicsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.relics,
    aliasName: 'bosses__id__relics__boss_id',
  );

  $$RelicsTableProcessedTableManager get relicsRefs {
    final manager = $$RelicsTableTableManager(
      $_db,
      $_db.relics,
    ).filter((f) => f.bossId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_relicsRefsTable($_db));
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

  Expression<bool> emberEventsRefs(
    Expression<bool> Function($$EmberEventsTableFilterComposer f) f,
  ) {
    final $$EmberEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emberEvents,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmberEventsTableFilterComposer(
            $db: $db,
            $table: $db.emberEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commitmentsRefs(
    Expression<bool> Function($$CommitmentsTableFilterComposer f) f,
  ) {
    final $$CommitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableFilterComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> relicsRefs(
    Expression<bool> Function($$RelicsTableFilterComposer f) f,
  ) {
    final $$RelicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relics,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelicsTableFilterComposer(
            $db: $db,
            $table: $db.relics,
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

  Expression<T> emberEventsRefs<T extends Object>(
    Expression<T> Function($$EmberEventsTableAnnotationComposer a) f,
  ) {
    final $$EmberEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emberEvents,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmberEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.emberEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commitmentsRefs<T extends Object>(
    Expression<T> Function($$CommitmentsTableAnnotationComposer a) f,
  ) {
    final $$CommitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> relicsRefs<T extends Object>(
    Expression<T> Function($$RelicsTableAnnotationComposer a) f,
  ) {
    final $$RelicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relics,
      getReferencedColumn: (t) => t.bossId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelicsTableAnnotationComposer(
            $db: $db,
            $table: $db.relics,
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
            bool emberEventsRefs,
            bool commitmentsRefs,
            bool relicsRefs,
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
              ({
                phasesRefs = false,
                tasksRefs = false,
                attemptsRefs = false,
                emberEventsRefs = false,
                commitmentsRefs = false,
                relicsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (phasesRefs) db.phases,
                    if (tasksRefs) db.tasks,
                    if (attemptsRefs) db.attempts,
                    if (emberEventsRefs) db.emberEvents,
                    if (commitmentsRefs) db.commitments,
                    if (relicsRefs) db.relics,
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
                      if (emberEventsRefs)
                        await $_getPrefetchedData<
                          Boss,
                          $BossesTable,
                          EmberEvent
                        >(
                          currentTable: table,
                          referencedTable: $$BossesTableReferences
                              ._emberEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BossesTableReferences(
                                db,
                                table,
                                p0,
                              ).emberEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bossId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commitmentsRefs)
                        await $_getPrefetchedData<
                          Boss,
                          $BossesTable,
                          Commitment
                        >(
                          currentTable: table,
                          referencedTable: $$BossesTableReferences
                              ._commitmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BossesTableReferences(
                                db,
                                table,
                                p0,
                              ).commitmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bossId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (relicsRefs)
                        await $_getPrefetchedData<Boss, $BossesTable, Relic>(
                          currentTable: table,
                          referencedTable: $$BossesTableReferences
                              ._relicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BossesTableReferences(db, table, p0).relicsRefs,
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
        bool emberEventsRefs,
        bool commitmentsRefs,
        bool relicsRefs,
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
  Value<int?> dailyDeadlineMinutes,
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
  Value<int?> dailyDeadlineMinutes,
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

  static MultiTypedResultKey<$EmberEventsTable, List<EmberEvent>>
  _emberEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.emberEvents,
    aliasName: 'tasks__id__ember_events__task_id',
  );

  $$EmberEventsTableProcessedTableManager get emberEventsRefs {
    final manager = $$EmberEventsTableTableManager(
      $_db,
      $_db.emberEvents,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_emberEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlanPicksTable, List<PlanPick>>
  _planPicksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planPicks,
    aliasName: 'tasks__id__plan_picks__task_id',
  );

  $$PlanPicksTableProcessedTableManager get planPicksRefs {
    final manager = $$PlanPicksTableTableManager(
      $_db,
      $_db.planPicks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_planPicksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CommitmentsTable, List<Commitment>>
  _commitmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.commitments,
    aliasName: 'tasks__id__commitments__task_id',
  );

  $$CommitmentsTableProcessedTableManager get commitmentsRefs {
    final manager = $$CommitmentsTableTableManager(
      $_db,
      $_db.commitments,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commitmentsRefsTable($_db));
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

  ColumnFilters<int> get dailyDeadlineMinutes => $composableBuilder(
    column: $table.dailyDeadlineMinutes,
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

  Expression<bool> emberEventsRefs(
    Expression<bool> Function($$EmberEventsTableFilterComposer f) f,
  ) {
    final $$EmberEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emberEvents,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmberEventsTableFilterComposer(
            $db: $db,
            $table: $db.emberEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planPicksRefs(
    Expression<bool> Function($$PlanPicksTableFilterComposer f) f,
  ) {
    final $$PlanPicksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planPicks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanPicksTableFilterComposer(
            $db: $db,
            $table: $db.planPicks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commitmentsRefs(
    Expression<bool> Function($$CommitmentsTableFilterComposer f) f,
  ) {
    final $$CommitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableFilterComposer(
            $db: $db,
            $table: $db.commitments,
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

  ColumnOrderings<int> get dailyDeadlineMinutes => $composableBuilder(
    column: $table.dailyDeadlineMinutes,
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

  GeneratedColumn<int> get dailyDeadlineMinutes => $composableBuilder(
    column: $table.dailyDeadlineMinutes,
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

  Expression<T> emberEventsRefs<T extends Object>(
    Expression<T> Function($$EmberEventsTableAnnotationComposer a) f,
  ) {
    final $$EmberEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emberEvents,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmberEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.emberEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planPicksRefs<T extends Object>(
    Expression<T> Function($$PlanPicksTableAnnotationComposer a) f,
  ) {
    final $$PlanPicksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planPicks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanPicksTableAnnotationComposer(
            $db: $db,
            $table: $db.planPicks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commitmentsRefs<T extends Object>(
    Expression<T> Function($$CommitmentsTableAnnotationComposer a) f,
  ) {
    final $$CommitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.commitments,
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
          PrefetchHooks Function({
            bool bossId,
            bool phaseId,
            bool attemptsRefs,
            bool emberEventsRefs,
            bool planPicksRefs,
            bool commitmentsRefs,
          })
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
                Value<int?> dailyDeadlineMinutes = const Value.absent(),
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
                dailyDeadlineMinutes: dailyDeadlineMinutes,
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
                Value<int?> dailyDeadlineMinutes = const Value.absent(),
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
                dailyDeadlineMinutes: dailyDeadlineMinutes,
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
              ({
                bossId = false,
                phaseId = false,
                attemptsRefs = false,
                emberEventsRefs = false,
                planPicksRefs = false,
                commitmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attemptsRefs) db.attempts,
                    if (emberEventsRefs) db.emberEvents,
                    if (planPicksRefs) db.planPicks,
                    if (commitmentsRefs) db.commitments,
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
                      if (emberEventsRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          EmberEvent
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._emberEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).emberEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (planPicksRefs)
                        await $_getPrefetchedData<Task, $TasksTable, PlanPick>(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._planPicksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).planPicksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commitmentsRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          Commitment
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._commitmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).commitmentsRefs,
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
      PrefetchHooks Function({
        bool bossId,
        bool phaseId,
        bool attemptsRefs,
        bool emberEventsRefs,
        bool planPicksRefs,
        bool commitmentsRefs,
      })
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
  Value<int> rolloverHour,
  Value<bool> reminderEnabled,
  Value<int> reminderMinutes,
  Value<int> flasks,
  Value<String?> lastResolvedDay,
  Value<String?> firstDay,
  Value<bool> sound,
  Value<bool> onboarded,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<bool> tapMode,
  Value<ResetOnFail> defaultResetOnFail,
  Value<bool> haptics,
  Value<int> rolloverHour,
  Value<bool> reminderEnabled,
  Value<int> reminderMinutes,
  Value<int> flasks,
  Value<String?> lastResolvedDay,
  Value<String?> firstDay,
  Value<bool> sound,
  Value<bool> onboarded,
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

  ColumnFilters<int> get rolloverHour => $composableBuilder(
    column: $table.rolloverHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flasks => $composableBuilder(
    column: $table.flasks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastResolvedDay => $composableBuilder(
    column: $table.lastResolvedDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstDay => $composableBuilder(
    column: $table.firstDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
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

  ColumnOrderings<int> get rolloverHour => $composableBuilder(
    column: $table.rolloverHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flasks => $composableBuilder(
    column: $table.flasks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastResolvedDay => $composableBuilder(
    column: $table.lastResolvedDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstDay => $composableBuilder(
    column: $table.firstDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
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

  GeneratedColumn<int> get rolloverHour => $composableBuilder(
    column: $table.rolloverHour,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flasks =>
      $composableBuilder(column: $table.flasks, builder: (column) => column);

  GeneratedColumn<String> get lastResolvedDay => $composableBuilder(
    column: $table.lastResolvedDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstDay =>
      $composableBuilder(column: $table.firstDay, builder: (column) => column);

  GeneratedColumn<bool> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);
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
                Value<int> rolloverHour = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderMinutes = const Value.absent(),
                Value<int> flasks = const Value.absent(),
                Value<String?> lastResolvedDay = const Value.absent(),
                Value<String?> firstDay = const Value.absent(),
                Value<bool> sound = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                tapMode: tapMode,
                defaultResetOnFail: defaultResetOnFail,
                haptics: haptics,
                rolloverHour: rolloverHour,
                reminderEnabled: reminderEnabled,
                reminderMinutes: reminderMinutes,
                flasks: flasks,
                lastResolvedDay: lastResolvedDay,
                firstDay: firstDay,
                sound: sound,
                onboarded: onboarded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> tapMode = const Value.absent(),
                Value<ResetOnFail> defaultResetOnFail = const Value.absent(),
                Value<bool> haptics = const Value.absent(),
                Value<int> rolloverHour = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderMinutes = const Value.absent(),
                Value<int> flasks = const Value.absent(),
                Value<String?> lastResolvedDay = const Value.absent(),
                Value<String?> firstDay = const Value.absent(),
                Value<bool> sound = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                tapMode: tapMode,
                defaultResetOnFail: defaultResetOnFail,
                haptics: haptics,
                rolloverHour: rolloverHour,
                reminderEnabled: reminderEnabled,
                reminderMinutes: reminderMinutes,
                flasks: flasks,
                lastResolvedDay: lastResolvedDay,
                firstDay: firstDay,
                sound: sound,
                onboarded: onboarded,
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
typedef $$DayLogsTableCreateCompanionBuilder = DayLogsCompanion Function({
  required String day,
  required DayKind kind,
  Value<String?> lesson,
  required DateTime at,
  Value<int> rowid,
});
typedef $$DayLogsTableUpdateCompanionBuilder = DayLogsCompanion Function({
  Value<String> day,
  Value<DayKind> kind,
  Value<String?> lesson,
  Value<DateTime> at,
  Value<int> rowid,
});

class $$DayLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DayLogsTable> {
  $$DayLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DayKind, DayKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get lesson => $composableBuilder(
    column: $table.lesson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DayLogsTable> {
  $$DayLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lesson => $composableBuilder(
    column: $table.lesson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayLogsTable> {
  $$DayLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DayKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get lesson =>
      $composableBuilder(column: $table.lesson, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$DayLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayLogsTable,
          DayLog,
          $$DayLogsTableFilterComposer,
          $$DayLogsTableOrderingComposer,
          $$DayLogsTableAnnotationComposer,
          $$DayLogsTableCreateCompanionBuilder,
          $$DayLogsTableUpdateCompanionBuilder,
          (DayLog, BaseReferences<_$AppDatabase, $DayLogsTable, DayLog>),
          DayLog,
          PrefetchHooks Function()
        > {
  $$DayLogsTableTableManager(_$AppDatabase db, $DayLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<DayKind> kind = const Value.absent(),
                Value<String?> lesson = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogsCompanion(
                day: day,
                kind: kind,
                lesson: lesson,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required DayKind kind,
                Value<String?> lesson = const Value.absent(),
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => DayLogsCompanion.insert(
                day: day,
                kind: kind,
                lesson: lesson,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayLogsTable, DayLog>(table),
                  BaseReferences<_$AppDatabase, $DayLogsTable, DayLog>(
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

typedef $$DayLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayLogsTable,
      DayLog,
      $$DayLogsTableFilterComposer,
      $$DayLogsTableOrderingComposer,
      $$DayLogsTableAnnotationComposer,
      $$DayLogsTableCreateCompanionBuilder,
      $$DayLogsTableUpdateCompanionBuilder,
      (DayLog, BaseReferences<_$AppDatabase, $DayLogsTable, DayLog>),
      DayLog,
      PrefetchHooks Function()
    >;
typedef $$EmberEventsTableCreateCompanionBuilder =
    EmberEventsCompanion Function({
      required String id,
      required EmberKind kind,
      required int amount,
      Value<String?> bossId,
      Value<String?> taskId,
      required String day,
      required DateTime at,
      Value<int> rowid,
    });
typedef $$EmberEventsTableUpdateCompanionBuilder =
    EmberEventsCompanion Function({
      Value<String> id,
      Value<EmberKind> kind,
      Value<int> amount,
      Value<String?> bossId,
      Value<String?> taskId,
      Value<String> day,
      Value<DateTime> at,
      Value<int> rowid,
    });

final class $$EmberEventsTableReferences
    extends BaseReferences<_$AppDatabase, $EmberEventsTable, EmberEvent> {
  $$EmberEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BossesTable _bossIdTable(_$AppDatabase db) =>
      db.bosses.createAlias('ember_events__boss_id__bosses__id');

  $$BossesTableProcessedTableManager? get bossId {
    final $_column = $_itemColumn<String>('boss_id');
    if ($_column == null) return null;
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
      db.tasks.createAlias('ember_events__task_id__tasks__id');

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
}

class $$EmberEventsTableFilterComposer
    extends Composer<_$AppDatabase, $EmberEventsTable> {
  $$EmberEventsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<EmberKind, EmberKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
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
}

class $$EmberEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmberEventsTable> {
  $$EmberEventsTableOrderingComposer({
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

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
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
}

class $$EmberEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmberEventsTable> {
  $$EmberEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EmberKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

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
}

class $$EmberEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmberEventsTable,
          EmberEvent,
          $$EmberEventsTableFilterComposer,
          $$EmberEventsTableOrderingComposer,
          $$EmberEventsTableAnnotationComposer,
          $$EmberEventsTableCreateCompanionBuilder,
          $$EmberEventsTableUpdateCompanionBuilder,
          (EmberEvent, $$EmberEventsTableReferences),
          EmberEvent,
          PrefetchHooks Function({bool bossId, bool taskId})
        > {
  $$EmberEventsTableTableManager(_$AppDatabase db, $EmberEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmberEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmberEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmberEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<EmberKind> kind = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> bossId = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmberEventsCompanion(
                id: id,
                kind: kind,
                amount: amount,
                bossId: bossId,
                taskId: taskId,
                day: day,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required EmberKind kind,
                required int amount,
                Value<String?> bossId = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                required String day,
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => EmberEventsCompanion.insert(
                id: id,
                kind: kind,
                amount: amount,
                bossId: bossId,
                taskId: taskId,
                day: day,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmberEventsTable, EmberEvent>(table),
                  $$EmberEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bossId = false, taskId = false}) {
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
                        referencedTable: $$EmberEventsTableReferences
                            ._bossIdTable(db),
                        referencedColumn: $$EmberEventsTableReferences
                            ._bossIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$EmberEventsTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$EmberEventsTableReferences
                            ._taskIdTable(db)
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

typedef $$EmberEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmberEventsTable,
      EmberEvent,
      $$EmberEventsTableFilterComposer,
      $$EmberEventsTableOrderingComposer,
      $$EmberEventsTableAnnotationComposer,
      $$EmberEventsTableCreateCompanionBuilder,
      $$EmberEventsTableUpdateCompanionBuilder,
      (EmberEvent, $$EmberEventsTableReferences),
      EmberEvent,
      PrefetchHooks Function({bool bossId, bool taskId})
    >;
typedef $$PlanPicksTableCreateCompanionBuilder = PlanPicksCompanion Function({
  required String day,
  required String taskId,
  required int position,
  Value<int> rowid,
});
typedef $$PlanPicksTableUpdateCompanionBuilder = PlanPicksCompanion Function({
  Value<String> day,
  Value<String> taskId,
  Value<int> position,
  Value<int> rowid,
});

final class $$PlanPicksTableReferences
    extends BaseReferences<_$AppDatabase, $PlanPicksTable, PlanPick> {
  $$PlanPicksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('plan_picks__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

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
}

class $$PlanPicksTableFilterComposer
    extends Composer<_$AppDatabase, $PlanPicksTable> {
  $$PlanPicksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

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
}

class $$PlanPicksTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanPicksTable> {
  $$PlanPicksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

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
}

class $$PlanPicksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanPicksTable> {
  $$PlanPicksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

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
}

class $$PlanPicksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanPicksTable,
          PlanPick,
          $$PlanPicksTableFilterComposer,
          $$PlanPicksTableOrderingComposer,
          $$PlanPicksTableAnnotationComposer,
          $$PlanPicksTableCreateCompanionBuilder,
          $$PlanPicksTableUpdateCompanionBuilder,
          (PlanPick, $$PlanPicksTableReferences),
          PlanPick,
          PrefetchHooks Function({bool taskId})
        > {
  $$PlanPicksTableTableManager(_$AppDatabase db, $PlanPicksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanPicksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanPicksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanPicksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanPicksCompanion(
                day: day,
                taskId: taskId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required String taskId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => PlanPicksCompanion.insert(
                day: day,
                taskId: taskId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanPicksTable, PlanPick>(table),
                  $$PlanPicksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
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
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$PlanPicksTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$PlanPicksTableReferences
                            ._taskIdTable(db)
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

typedef $$PlanPicksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanPicksTable,
      PlanPick,
      $$PlanPicksTableFilterComposer,
      $$PlanPicksTableOrderingComposer,
      $$PlanPicksTableAnnotationComposer,
      $$PlanPicksTableCreateCompanionBuilder,
      $$PlanPicksTableUpdateCompanionBuilder,
      (PlanPick, $$PlanPicksTableReferences),
      PlanPick,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$CommitmentsTableCreateCompanionBuilder =
    CommitmentsCompanion Function({
      required String id,
      required String taskId,
      required String bossId,
      required String day,
      required DateTime deadline,
      Value<int> extensions,
      Value<bool> remind,
      Value<CommitmentOutcome?> outcome,
      Value<DateTime?> resolvedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CommitmentsTableUpdateCompanionBuilder =
    CommitmentsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> bossId,
      Value<String> day,
      Value<DateTime> deadline,
      Value<int> extensions,
      Value<bool> remind,
      Value<CommitmentOutcome?> outcome,
      Value<DateTime?> resolvedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CommitmentsTableReferences
    extends BaseReferences<_$AppDatabase, $CommitmentsTable, Commitment> {
  $$CommitmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('commitments__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

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

  static $BossesTable _bossIdTable(_$AppDatabase db) =>
      db.bosses.createAlias('commitments__boss_id__bosses__id');

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

  static MultiTypedResultKey<$HealthEventsTable, List<HealthEvent>>
  _healthEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.healthEvents,
    aliasName: 'commitments__id__health_events__commitment_id',
  );

  $$HealthEventsTableProcessedTableManager get healthEventsRefs {
    final manager = $$HealthEventsTableTableManager(
      $_db,
      $_db.healthEvents,
    ).filter((f) => f.commitmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_healthEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CommitmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CommitmentsTable> {
  $$CommitmentsTableFilterComposer({
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

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get extensions => $composableBuilder(
    column: $table.extensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remind => $composableBuilder(
    column: $table.remind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CommitmentOutcome?, CommitmentOutcome, int>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
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

  Expression<bool> healthEventsRefs(
    Expression<bool> Function($$HealthEventsTableFilterComposer f) f,
  ) {
    final $$HealthEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.healthEvents,
      getReferencedColumn: (t) => t.commitmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HealthEventsTableFilterComposer(
            $db: $db,
            $table: $db.healthEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommitmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommitmentsTable> {
  $$CommitmentsTableOrderingComposer({
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

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extensions => $composableBuilder(
    column: $table.extensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remind => $composableBuilder(
    column: $table.remind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
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

class $$CommitmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommitmentsTable> {
  $$CommitmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get extensions => $composableBuilder(
    column: $table.extensions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CommitmentOutcome?, int> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

  Expression<T> healthEventsRefs<T extends Object>(
    Expression<T> Function($$HealthEventsTableAnnotationComposer a) f,
  ) {
    final $$HealthEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.healthEvents,
      getReferencedColumn: (t) => t.commitmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HealthEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.healthEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommitmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommitmentsTable,
          Commitment,
          $$CommitmentsTableFilterComposer,
          $$CommitmentsTableOrderingComposer,
          $$CommitmentsTableAnnotationComposer,
          $$CommitmentsTableCreateCompanionBuilder,
          $$CommitmentsTableUpdateCompanionBuilder,
          (Commitment, $$CommitmentsTableReferences),
          Commitment,
          PrefetchHooks Function({
            bool taskId,
            bool bossId,
            bool healthEventsRefs,
          })
        > {
  $$CommitmentsTableTableManager(_$AppDatabase db, $CommitmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommitmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommitmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommitmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> bossId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> deadline = const Value.absent(),
                Value<int> extensions = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<CommitmentOutcome?> outcome = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommitmentsCompanion(
                id: id,
                taskId: taskId,
                bossId: bossId,
                day: day,
                deadline: deadline,
                extensions: extensions,
                remind: remind,
                outcome: outcome,
                resolvedAt: resolvedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String bossId,
                required String day,
                required DateTime deadline,
                Value<int> extensions = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<CommitmentOutcome?> outcome = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CommitmentsCompanion.insert(
                id: id,
                taskId: taskId,
                bossId: bossId,
                day: day,
                deadline: deadline,
                extensions: extensions,
                remind: remind,
                outcome: outcome,
                resolvedAt: resolvedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CommitmentsTable, Commitment>(table),
                  $$CommitmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({taskId = false, bossId = false, healthEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (healthEventsRefs) db.healthEvents,
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
                        if (taskId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.taskId,
                            referencedTable: $$CommitmentsTableReferences
                                ._taskIdTable(db),
                            referencedColumn: $$CommitmentsTableReferences
                                ._taskIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (bossId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bossId,
                            referencedTable: $$CommitmentsTableReferences
                                ._bossIdTable(db),
                            referencedColumn: $$CommitmentsTableReferences
                                ._bossIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (healthEventsRefs)
                        await $_getPrefetchedData<
                          Commitment,
                          $CommitmentsTable,
                          HealthEvent
                        >(
                          currentTable: table,
                          referencedTable: $$CommitmentsTableReferences
                              ._healthEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CommitmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).healthEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.commitmentId == item.id,
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

typedef $$CommitmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommitmentsTable,
      Commitment,
      $$CommitmentsTableFilterComposer,
      $$CommitmentsTableOrderingComposer,
      $$CommitmentsTableAnnotationComposer,
      $$CommitmentsTableCreateCompanionBuilder,
      $$CommitmentsTableUpdateCompanionBuilder,
      (Commitment, $$CommitmentsTableReferences),
      Commitment,
      PrefetchHooks Function({bool taskId, bool bossId, bool healthEventsRefs})
    >;
typedef $$HealthEventsTableCreateCompanionBuilder =
    HealthEventsCompanion Function({
      required String id,
      required int amount,
      required HealthReason reason,
      Value<String?> commitmentId,
      required String day,
      required DateTime at,
      Value<int> rowid,
    });
typedef $$HealthEventsTableUpdateCompanionBuilder =
    HealthEventsCompanion Function({
      Value<String> id,
      Value<int> amount,
      Value<HealthReason> reason,
      Value<String?> commitmentId,
      Value<String> day,
      Value<DateTime> at,
      Value<int> rowid,
    });

final class $$HealthEventsTableReferences
    extends BaseReferences<_$AppDatabase, $HealthEventsTable, HealthEvent> {
  $$HealthEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CommitmentsTable _commitmentIdTable(_$AppDatabase db) => db
      .commitments
      .createAlias('health_events__commitment_id__commitments__id');

  $$CommitmentsTableProcessedTableManager? get commitmentId {
    final $_column = $_itemColumn<String>('commitment_id');
    if ($_column == null) return null;
    final manager = $$CommitmentsTableTableManager(
      $_db,
      $_db.commitments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_commitmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HealthEventsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableFilterComposer({
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

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HealthReason, HealthReason, int> get reason =>
      $composableBuilder(
        column: $table.reason,
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

  $$CommitmentsTableFilterComposer get commitmentId {
    final $$CommitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableFilterComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reason => $composableBuilder(
    column: $table.reason,
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

  $$CommitmentsTableOrderingComposer get commitmentId {
    final $$CommitmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableOrderingComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HealthReason, int> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  $$CommitmentsTableAnnotationComposer get commitmentId {
    final $$CommitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthEventsTable,
          HealthEvent,
          $$HealthEventsTableFilterComposer,
          $$HealthEventsTableOrderingComposer,
          $$HealthEventsTableAnnotationComposer,
          $$HealthEventsTableCreateCompanionBuilder,
          $$HealthEventsTableUpdateCompanionBuilder,
          (HealthEvent, $$HealthEventsTableReferences),
          HealthEvent,
          PrefetchHooks Function({bool commitmentId})
        > {
  $$HealthEventsTableTableManager(_$AppDatabase db, $HealthEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<HealthReason> reason = const Value.absent(),
                Value<String?> commitmentId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthEventsCompanion(
                id: id,
                amount: amount,
                reason: reason,
                commitmentId: commitmentId,
                day: day,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amount,
                required HealthReason reason,
                Value<String?> commitmentId = const Value.absent(),
                required String day,
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => HealthEventsCompanion.insert(
                id: id,
                amount: amount,
                reason: reason,
                commitmentId: commitmentId,
                day: day,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HealthEventsTable, HealthEvent>(table),
                  $$HealthEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({commitmentId = false}) {
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
                    if (commitmentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.commitmentId,
                        referencedTable: $$HealthEventsTableReferences
                            ._commitmentIdTable(db),
                        referencedColumn: $$HealthEventsTableReferences
                            ._commitmentIdTable(db)
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

typedef $$HealthEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthEventsTable,
      HealthEvent,
      $$HealthEventsTableFilterComposer,
      $$HealthEventsTableOrderingComposer,
      $$HealthEventsTableAnnotationComposer,
      $$HealthEventsTableCreateCompanionBuilder,
      $$HealthEventsTableUpdateCompanionBuilder,
      (HealthEvent, $$HealthEventsTableReferences),
      HealthEvent,
      PrefetchHooks Function({bool commitmentId})
    >;
typedef $$RelicsTableCreateCompanionBuilder = RelicsCompanion Function({
  required String id,
  Value<String?> bossId,
  required String name,
  required Weathering emblem,
  required int attempts,
  required int days,
  required int effort,
  required String story,
  Value<String?> inscription,
  required String defeatedDay,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RelicsTableUpdateCompanionBuilder = RelicsCompanion Function({
  Value<String> id,
  Value<String?> bossId,
  Value<String> name,
  Value<Weathering> emblem,
  Value<int> attempts,
  Value<int> days,
  Value<int> effort,
  Value<String> story,
  Value<String?> inscription,
  Value<String> defeatedDay,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$RelicsTableReferences
    extends BaseReferences<_$AppDatabase, $RelicsTable, Relic> {
  $$RelicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BossesTable _bossIdTable(_$AppDatabase db) =>
      db.bosses.createAlias('relics__boss_id__bosses__id');

  $$BossesTableProcessedTableManager? get bossId {
    final $_column = $_itemColumn<String>('boss_id');
    if ($_column == null) return null;
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
}

class $$RelicsTableFilterComposer
    extends Composer<_$AppDatabase, $RelicsTable> {
  $$RelicsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Weathering, Weathering, int> get emblem =>
      $composableBuilder(
        column: $table.emblem,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effort => $composableBuilder(
    column: $table.effort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get story => $composableBuilder(
    column: $table.story,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inscription => $composableBuilder(
    column: $table.inscription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defeatedDay => $composableBuilder(
    column: $table.defeatedDay,
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
}

class $$RelicsTableOrderingComposer
    extends Composer<_$AppDatabase, $RelicsTable> {
  $$RelicsTableOrderingComposer({
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

  ColumnOrderings<int> get emblem => $composableBuilder(
    column: $table.emblem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effort => $composableBuilder(
    column: $table.effort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get story => $composableBuilder(
    column: $table.story,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inscription => $composableBuilder(
    column: $table.inscription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defeatedDay => $composableBuilder(
    column: $table.defeatedDay,
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

class $$RelicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelicsTable> {
  $$RelicsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<Weathering, int> get emblem =>
      $composableBuilder(column: $table.emblem, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<int> get effort =>
      $composableBuilder(column: $table.effort, builder: (column) => column);

  GeneratedColumn<String> get story =>
      $composableBuilder(column: $table.story, builder: (column) => column);

  GeneratedColumn<String> get inscription => $composableBuilder(
    column: $table.inscription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defeatedDay => $composableBuilder(
    column: $table.defeatedDay,
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
}

class $$RelicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelicsTable,
          Relic,
          $$RelicsTableFilterComposer,
          $$RelicsTableOrderingComposer,
          $$RelicsTableAnnotationComposer,
          $$RelicsTableCreateCompanionBuilder,
          $$RelicsTableUpdateCompanionBuilder,
          (Relic, $$RelicsTableReferences),
          Relic,
          PrefetchHooks Function({bool bossId})
        > {
  $$RelicsTableTableManager(_$AppDatabase db, $RelicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> bossId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Weathering> emblem = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> days = const Value.absent(),
                Value<int> effort = const Value.absent(),
                Value<String> story = const Value.absent(),
                Value<String?> inscription = const Value.absent(),
                Value<String> defeatedDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelicsCompanion(
                id: id,
                bossId: bossId,
                name: name,
                emblem: emblem,
                attempts: attempts,
                days: days,
                effort: effort,
                story: story,
                inscription: inscription,
                defeatedDay: defeatedDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> bossId = const Value.absent(),
                required String name,
                required Weathering emblem,
                required int attempts,
                required int days,
                required int effort,
                required String story,
                Value<String?> inscription = const Value.absent(),
                required String defeatedDay,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RelicsCompanion.insert(
                id: id,
                bossId: bossId,
                name: name,
                emblem: emblem,
                attempts: attempts,
                days: days,
                effort: effort,
                story: story,
                inscription: inscription,
                defeatedDay: defeatedDay,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RelicsTable, Relic>(table),
                  $$RelicsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bossId = false}) {
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
                        referencedTable: $$RelicsTableReferences._bossIdTable(
                          db,
                        ),
                        referencedColumn: $$RelicsTableReferences
                            ._bossIdTable(db)
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

typedef $$RelicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelicsTable,
      Relic,
      $$RelicsTableFilterComposer,
      $$RelicsTableOrderingComposer,
      $$RelicsTableAnnotationComposer,
      $$RelicsTableCreateCompanionBuilder,
      $$RelicsTableUpdateCompanionBuilder,
      (Relic, $$RelicsTableReferences),
      Relic,
      PrefetchHooks Function({bool bossId})
    >;
typedef $$VisitsTableCreateCompanionBuilder = VisitsCompanion Function({
  required String day,
  required DateTime firstAt,
  Value<int> rowid,
});
typedef $$VisitsTableUpdateCompanionBuilder = VisitsCompanion Function({
  Value<String> day,
  Value<DateTime> firstAt,
  Value<int> rowid,
});

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstAt => $composableBuilder(
    column: $table.firstAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstAt => $composableBuilder(
    column: $table.firstAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get firstAt =>
      $composableBuilder(column: $table.firstAt, builder: (column) => column);
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          Visit,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (Visit, BaseReferences<_$AppDatabase, $VisitsTable, Visit>),
          Visit,
          PrefetchHooks Function()
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<DateTime> firstAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => VisitsCompanion(day: day, firstAt: firstAt, rowid: rowid),
          createCompanionCallback:
              ({
                required String day,
                required DateTime firstAt,
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion.insert(
                day: day,
                firstAt: firstAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitsTable, Visit>(table),
                  BaseReferences<_$AppDatabase, $VisitsTable, Visit>(
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

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      Visit,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (Visit, BaseReferences<_$AppDatabase, $VisitsTable, Visit>),
      Visit,
      PrefetchHooks Function()
    >;
typedef $$SignalEventsTableCreateCompanionBuilder =
    SignalEventsCompanion Function({
      required String id,
      required SignalKind kind,
      required String day,
      required DateTime at,
      Value<int?> value,
      Value<int> rowid,
    });
typedef $$SignalEventsTableUpdateCompanionBuilder =
    SignalEventsCompanion Function({
      Value<String> id,
      Value<SignalKind> kind,
      Value<String> day,
      Value<DateTime> at,
      Value<int?> value,
      Value<int> rowid,
    });

class $$SignalEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SignalEventsTable> {
  $$SignalEventsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<SignalKind, SignalKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
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

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SignalEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SignalEventsTable> {
  $$SignalEventsTableOrderingComposer({
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

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
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

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SignalEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignalEventsTable> {
  $$SignalEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SignalEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SignalEventsTable,
          SignalEvent,
          $$SignalEventsTableFilterComposer,
          $$SignalEventsTableOrderingComposer,
          $$SignalEventsTableAnnotationComposer,
          $$SignalEventsTableCreateCompanionBuilder,
          $$SignalEventsTableUpdateCompanionBuilder,
          (
            SignalEvent,
            BaseReferences<_$AppDatabase, $SignalEventsTable, SignalEvent>,
          ),
          SignalEvent,
          PrefetchHooks Function()
        > {
  $$SignalEventsTableTableManager(_$AppDatabase db, $SignalEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<SignalKind> kind = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SignalEventsCompanion(
                id: id,
                kind: kind,
                day: day,
                at: at,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required SignalKind kind,
                required String day,
                required DateTime at,
                Value<int?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SignalEventsCompanion.insert(
                id: id,
                kind: kind,
                day: day,
                at: at,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SignalEventsTable, SignalEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SignalEventsTable,
                    SignalEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SignalEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SignalEventsTable,
      SignalEvent,
      $$SignalEventsTableFilterComposer,
      $$SignalEventsTableOrderingComposer,
      $$SignalEventsTableAnnotationComposer,
      $$SignalEventsTableCreateCompanionBuilder,
      $$SignalEventsTableUpdateCompanionBuilder,
      (
        SignalEvent,
        BaseReferences<_$AppDatabase, $SignalEventsTable, SignalEvent>,
      ),
      SignalEvent,
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
  $$DayLogsTableTableManager get dayLogs =>
      $$DayLogsTableTableManager(_db, _db.dayLogs);
  $$EmberEventsTableTableManager get emberEvents =>
      $$EmberEventsTableTableManager(_db, _db.emberEvents);
  $$PlanPicksTableTableManager get planPicks =>
      $$PlanPicksTableTableManager(_db, _db.planPicks);
  $$CommitmentsTableTableManager get commitments =>
      $$CommitmentsTableTableManager(_db, _db.commitments);
  $$HealthEventsTableTableManager get healthEvents =>
      $$HealthEventsTableTableManager(_db, _db.healthEvents);
  $$RelicsTableTableManager get relics =>
      $$RelicsTableTableManager(_db, _db.relics);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$SignalEventsTableTableManager get signalEvents =>
      $$SignalEventsTableTableManager(_db, _db.signalEvents);
}

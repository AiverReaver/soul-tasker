import 'package:drift/drift.dart';

import 'enums.dart';

// Schema for STAGE1_PLAN.md §6. Editable records carry updatedAt for
// Stage 7 sync; attempts are append-only and use `at`.

@DataClassName('Boss')
class Bosses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 80)();
  TextColumn get defeatMeaning => text().nullable()();
  IntColumn get status => intEnum<BossStatus>()();
  IntColumn get attemptNumber => integer().withDefault(const Constant(1))();
  IntColumn get resetOnFail => intEnum<ResetOnFail>()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get lastFoughtAt => dateTime().nullable()();

  /// Floor for standalone one-time tasks; raised by a whole-boss reset.
  IntColumn get openFromAttempt => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get defeatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Phases extends Table {
  TextColumn get id => text()();
  TextColumn get bossId =>
      text().references(Bosses, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get position => integer()();

  /// A strike counts for this phase only from this attempt number on.
  IntColumn get openFromAttempt => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get bossId =>
      text().references(Bosses, #id, onDelete: KeyAction.cascade)();

  /// Null for a standalone task ("Beyond the phases").
  TextColumn get phaseId =>
      text().nullable().references(Phases, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 80)();
  IntColumn get weight => intEnum<Weight>()();
  IntColumn get recurrence => intEnum<Recurrence>()();
  IntColumn get position => integer()();
  BoolColumn get isSplit => boolean().withDefault(const Constant(false))();

  /// A standing daily deadline, minutes from midnight; daily tasks only
  /// (Stage 4 plan D12).
  IntColumn get dailyDeadlineMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Attempts extends Table {
  TextColumn get id => text()();
  TextColumn get bossId =>
      text().references(Bosses, #id, onDelete: KeyAction.cascade)();
  TextColumn get taskId =>
      text().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  IntColumn get bossAttempt => integer()();
  IntColumn get outcome => intEnum<Outcome>()();
  IntColumn get cause => intEnum<FallCause>().nullable()();
  TextColumn get phaseId =>
      text().nullable().references(Phases, #id, onDelete: KeyAction.setNull)();
  TextColumn get lesson => text().nullable().withLength(max: 120)();

  /// The task's weight when the attempt was recorded (D12). Null for falls
  /// and for rows written before schema v2.
  IntColumn get weight => intEnum<Weight>().nullable()();
  TextColumn get day => text()();
  DateTimeColumn get at => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSettings')
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get tapMode => boolean().withDefault(const Constant(false))();
  IntColumn get defaultResetOnFail =>
      intEnum<ResetOnFail>().withDefault(const Constant(0))();
  BoolColumn get haptics => boolean().withDefault(const Constant(true))();

  /// A day ends at this local hour (0 to 6); see `dayOf`.
  IntColumn get rolloverHour => integer().withDefault(const Constant(4))();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Minutes from midnight; 1260 is 21:00.
  IntColumn get reminderMinutes =>
      integer().withDefault(const Constant(1260))();
  IntColumn get flasks => integer().withDefault(const Constant(3))();

  /// The last day already judged for a missed bonfire. Set to the install or
  /// upgrade day, so that day is never judged (plan D12).
  TextColumn get lastResolvedDay => text().nullable()();

  /// The install or v4 upgrade day; the newcomer grace week counts from here
  /// (Stage 4 plan D13).
  TextColumn get firstDay => text().nullable()();

  /// Sound cues are off until the user turns them on (Stage 5 plan D12).
  BoolColumn get sound => boolean().withDefault(const Constant(false))();

  /// False until onboarding is finished or skipped. The v5 upgrade sets it
  /// true so existing installs never see it (Stage 5 plan D11).
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per day kept: a bonfire rest, a flask, or a light day (plan D3).
class DayLogs extends Table {
  TextColumn get day => text()();
  IntColumn get kind => intEnum<DayKind>()();

  /// Only on a bonfire row.
  TextColumn get lesson => text().nullable().withLength(max: 120)();
  DateTimeColumn get at => dateTime()();

  @override
  Set<Column> get primaryKey => {day, kind};
}

/// Append-only embers ledger. Carried = earns since the last bank.
class EmberEvents extends Table {
  TextColumn get id => text()();
  IntColumn get kind => intEnum<EmberKind>()();
  IntColumn get amount => integer()();
  TextColumn get bossId =>
      text().nullable().references(Bosses, #id, onDelete: KeyAction.setNull)();
  TextColumn get taskId =>
      text().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  TextColumn get day => text()();
  DateTimeColumn get at => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tomorrow's top three (plan D11). At most 3 per day, enforced in the DAO.
class PlanPicks extends Table {
  TextColumn get day => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {day, taskId};
}

/// A promise to finish a task by a deadline, one per task per day
/// (Stage 4 plan D1). [outcome] null means still open.
class Commitments extends Table {
  TextColumn get id => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get bossId =>
      text().references(Bosses, #id, onDelete: KeyAction.cascade)();
  TextColumn get day => text()();
  DateTimeColumn get deadline => dateTime()();
  IntColumn get extensions => integer().withDefault(const Constant(0))();
  BoolColumn get remind => boolean().withDefault(const Constant(false))();
  IntColumn get outcome => intEnum<CommitmentOutcome>().nullable()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {taskId, day},
  ];
}

/// Append-only health ledger in half points (Stage 4 plan D4).
class HealthEvents extends Table {
  TextColumn get id => text()();
  IntColumn get amount => integer()();
  IntColumn get reason => intEnum<HealthReason>()();
  TextColumn get commitmentId => text().nullable().references(
    Commitments,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get day => text()();
  DateTimeColumn get at => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A permanent record of a defeated boss (Stage 5 plan D1). Written once at
/// defeat with its own copy of the story; only [inscription] changes after.
class Relics extends Table {
  TextColumn get id => text()();

  /// Cleared when the boss is deleted; the relic stays.
  TextColumn get bossId =>
      text().nullable().references(Bosses, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  IntColumn get emblem => intEnum<Weathering>()();
  IntColumn get attempts => integer()();
  IntColumn get days => integer()();
  IntColumn get effort => integer()();

  /// JSON of a `RelicStory`.
  TextColumn get story => text()();
  TextColumn get inscription => text().nullable().withLength(max: 120)();
  TextColumn get defeatedDay => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {bossId},
  ];
}

import 'package:drift/drift.dart';

import '../core/palette.dart';
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

  /// Sync's last-write-wins key: a lesson can be added to a fall after it
  /// is written (Stage 7). Starts equal to [at].
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// What only this phone keeps (Stage 7 plan D9); never synced.
@DataClassName('DeviceSettings')
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// The last day already judged for a missed bonfire. Set to the install or
  /// upgrade day, so that day is never judged (plan D12).
  TextColumn get lastResolvedDay => text().nullable()();

  /// False until onboarding is finished or skipped. The v5 upgrade sets it
  /// true so existing installs never see it (Stage 5 plan D11).
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))();

  /// The colour theme. Stored as the [Biome] index; never synced (THEME_PLAN
  /// D3). Add new biomes only at the end.
  IntColumn get biome => intEnum<Biome>().withDefault(const Constant(0))();

  /// The glass light follows the phone's motion, and drifts on its own.
  /// Device-only; off stills the light (V41_PLAN.md D3b).
  BoolColumn get motionEffects => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The fixed id of the one [UserSettings] row; the column default repeats it.
const kUserSettingsId = 'user';

/// The synced settings, one row (Stage 7 plan D9), last write wins.
@DataClassName('AppSettings')
class UserSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('user'))();
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

  /// The install or v4 upgrade day; the newcomer grace week counts from here
  /// (Stage 4 plan D13). Syncs as the earliest value seen (Stage 7 D9).
  TextColumn get firstDay => text().nullable()();

  /// Sound cues are off until the user turns them on (Stage 5 plan D12).
  BoolColumn get sound => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per day kept: a bonfire rest, a flask, or a light day (plan D3).
/// Never deleted, only upserted (Stage 7 plan D5); synced as "$day:$kind".
class DayLogs extends Table {
  TextColumn get day => text()();
  IntColumn get kind => intEnum<DayKind>()();

  /// Only on a bonfire row.
  TextColumn get lesson => text().nullable().withLength(max: 120)();
  DateTimeColumn get at => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {day, kind};
}

/// Append-only flask ledger (Stage 7 plan D8); see `foldFlasks`.
class FlaskEvents extends Table {
  TextColumn get id => text()();
  IntColumn get kind => intEnum<FlaskKind>()();
  IntColumn get amount => integer()();
  IntColumn get reason => intEnum<FlaskReason>()();
  TextColumn get day => text()();
  DateTimeColumn get at => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Embers left where a boss was fallen (§5.8). Active while neither
/// recovered nor lost; at most one active per boss (Stage 7 plan D11).
class Bloodstains extends Table {
  TextColumn get id => text()();
  TextColumn get bossId =>
      text().references(Bosses, #id, onDelete: KeyAction.cascade)();
  TextColumn get taskId =>
      text().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  TextColumn get attemptId => text().nullable().references(
    Attempts,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get recoveredAt => dateTime().nullable()();
  DateTimeColumn get lostAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local writes waiting to be pushed (Stage 7 plan D14).
@DataClassName('OutboxEntry')
class SyncOutbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get tbl => text()();
  TextColumn get rowId => text()();
  IntColumn get op => intEnum<SyncOp>()();
  DateTimeColumn get at => dateTime()();

  /// Set when the server refused the row as malformed; the sender skips it.
  TextColumn get rejectedReason => text().nullable()();
}

/// A day's plan, saved whole (Stage 7 plan D20). [taskIds] is a JSON list
/// in order; ids of deleted tasks are skipped by readers.
class DayPlans extends Table {
  TextColumn get day => text()();
  TextColumn get taskIds => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {day};
}

/// This installation's sync bookkeeping, one row (Stage 7 plan D13, D18).
/// The session token lives in secure storage, not here.
@DataClassName('SyncStateRow')
class SyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text()();
  IntColumn get cursor => integer().withDefault(const Constant(0))();

  /// 1 while pulled rows are applied, so triggers queue nothing.
  BoolColumn get applying => boolean().withDefault(const Constant(false))();
  TextColumn get accountEmail => text().nullable()();
  TextColumn get lastAccountId => text().nullable()();
  BoolColumn get sessionEnded => boolean().withDefault(const Constant(false))();
  BoolColumn get mergeNoticeShown =>
      boolean().withDefault(const Constant(false))();
  TextColumn get lastAppVersion => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
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

/// One row per ritual day the app was opened (Stage 6 plan D2).
class Visits extends Table {
  TextColumn get day => text()();
  DateTimeColumn get firstAt => dateTime()();

  @override
  Set<Column> get primaryKey => {day};
}

/// Append-only tester signals (Stage 6 plan D3). No foreign keys, so a
/// deleted boss keeps its falls; no text, so nothing personal is held.
class SignalEvents extends Table {
  TextColumn get id => text()();
  IntColumn get kind => intEnum<SignalKind>()();
  TextColumn get day => text()();
  DateTimeColumn get at => dateTime()();

  /// Tap mode on (1) or off (0), or a `CheckInAnswer` index.
  IntColumn get value => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

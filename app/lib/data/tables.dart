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

  @override
  Set<Column> get primaryKey => {id};
}

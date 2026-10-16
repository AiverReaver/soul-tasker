import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import '../core/missed_days.dart';
import 'attempt_dao.dart';
import 'database.dart';
import 'ember_dao.dart';
import 'flask_dao.dart';
import 'health_dao.dart';
import 'enums.dart';
import 'plan_pick_dao.dart';

/// Flask charges never exceed this (Stage 3 plan D5).
const kFlaskCap = 3;

/// What covers today, and the flasks left.
@immutable
class DayStatus {
  const DayStatus({required this.kinds, required this.flasks});

  final Set<DayKind> kinds;
  final int flasks;

  /// Today's bonfire rest has happened (D9).
  bool get isRested => kinds.contains(DayKind.bonfire);

  /// A flask or a rest already covers today.
  bool get isCovered => isRested || kinds.contains(DayKind.flask);
}

/// What the day held, for the bonfire.
@immutable
class DaySummaryData {
  const DaySummaryData({
    required this.strikes,
    required this.tried,
    required this.falls,
    required this.lessons,
    required this.embers,
  });

  final int strikes;
  final int tried;
  final int falls;
  final List<String> lessons;
  final EmberTally embers;
}

/// Days that ended with no cover, and who falls for them.
@immutable
class PendingDays {
  const PendingDays({
    required this.days,
    required this.bosses,
    required this.flasks,
  });

  /// Missed days, oldest first.
  final List<String> days;

  /// Active bosses created before the latest missed day: they fall unless
  /// flasks cover every day (plan D4).
  final List<Boss> bosses;
  final int flasks;

  bool get isEmpty => days.isEmpty;
}

/// The day's ritual state: bonfire rests, flasks and light days. Rows are only
/// ever inserted; flasks are counted from their own ledger (Stage 7 D8).
class DayDao {
  DayDao(this._db, this._clock, this._attempts)
    : _embers = EmberDao(_db, _clock),
      _flaskLedger = FlaskDao(_db, _clock);

  final AppDatabase _db;
  final Clock _clock;
  final AttemptDao _attempts;
  final EmberDao _embers;
  final FlaskDao _flaskLedger;
  late final _health = HealthDao(_db, _clock, _attempts);

  Future<String> _today() async =>
      dayOf(_clock(), rolloverHour: await _db.rolloverHour());

  Future<Set<DayKind>> _kindsOn(String day) async => {
    for (final l in await (_db.select(
      _db.dayLogs,
    )..where((l) => l.day.equals(day))).get())
      l.kind,
  };

  Future<int> _flasks() => _flaskLedger.count();

  Future<void> _log(String day, DayKind kind, DateTime at, [String? lesson]) =>
      _db
          .into(_db.dayLogs)
          .insert(
            DayLogsCompanion.insert(
              day: day,
              kind: kind,
              lesson: Value(lesson),
              at: at,
              updatedAt: at,
            ),
          );

  /// How many bonfire rests there have been, ever.
  Future<int> restCount() async => (await (_db.select(
    _db.dayLogs,
  )..where((l) => l.kind.equalsValue(DayKind.bonfire))).get()).length;

  Future<DayStatus> today() async =>
      DayStatus(kinds: await _kindsOn(await _today()), flasks: await _flasks());

  Stream<DayStatus> watchToday() async* {
    yield await today();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.dayLogs,
            _db.flaskEvents,
            _db.userSettings,
          ]),
        )
        .asyncMap((_) => today());
  }

  /// Rests at the bonfire: banks the carried embers, restores one flask and
  /// full health, keeps the lesson, and saves [pickTaskIds] as tomorrow's
  /// three. Returns false, changing nothing, if today was already rested or
  /// the player is fallen (rise first, Stage 4 plan D15). Throws, changing
  /// nothing, for more than three picks.
  Future<bool> rest({String? lesson, List<String> pickTaskIds = const []}) =>
      _db.transaction(() async {
        // Settle passed deadlines first, so the restore comes after them.
        await _health.resolveDue();
        final day = await _today();
        if ((await _kindsOn(day)).contains(DayKind.bonfire)) return false;
        if (await _health.isDead(day)) return false;
        final now = _clock();
        await _log(day, DayKind.bonfire, now, cleanLesson(lesson));
        await _health.restore(HealthReason.bonfireRestore, day, now);
        await _embers.bank();
        await _flaskLedger.restore(FlaskReason.bonfire, day, at: now);
        if (pickTaskIds.isNotEmpty) {
          await writePicks(_db, shiftDay(day, 1), pickTaskIds, now);
        }
        return true;
      });

  /// Rises after a fall (§5.6): full health and banked embers, but no flask,
  /// no lesson or picks, and the day is not covered. False when not fallen.
  Future<bool> rise() => _db.transaction(() async {
    await _health.resolveDue();
    final day = await _today();
    if (!await _health.isDead(day)) return false;
    await _health.restore(HealthReason.rise, day, _clock());
    await _embers.bank();
    return true;
  });

  Future<DaySummaryData> summary() async {
    final day = await _today();
    final rows = await (_db.select(
      _db.attempts,
    )..where((a) => a.day.equals(day))).get();
    int count(Outcome o) => rows.where((a) => a.outcome == o).length;
    return DaySummaryData(
      strikes: count(Outcome.strike),
      tried: count(Outcome.tried),
      falls: count(Outcome.fallen),
      lessons: [
        for (final a in rows)
          if (a.outcome == Outcome.fallen && a.lesson != null) a.lesson!,
      ],
      embers: await _embers.tally(),
    );
  }

  Stream<DaySummaryData> watchSummary() async* {
    yield await summary();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.attempts,
            _db.emberEvents,
            _db.userSettings,
          ]),
        )
        .asyncMap((_) => summary());
  }

  /// Spends a flask to cover today. False if none is left or today is
  /// already covered.
  Future<bool> skipToday() => _db.transaction(() async {
    final day = await _today();
    final flasks = await _flasks();
    if (flasks == 0 || (await _kindsOn(day)).any(_isCover)) return false;
    final now = _clock();
    await _log(day, DayKind.flask, now);
    await _flaskLedger.spend(1, FlaskReason.skipDay, day, at: now);
    return true;
  });

  /// Marks today a light day. It counts only if a task is struck (D8).
  Future<bool> markLight() => _db.transaction(() async {
    final day = await _today();
    if ((await _kindsOn(day)).contains(DayKind.light)) return false;
    await _log(day, DayKind.light, _clock());
    return true;
  });

  Future<List<String>> _missed(DeviceSettings s, String today) async {
    final last = s.lastResolvedDay ?? today;
    final logs = await (_db.select(
      _db.dayLogs,
    )..where((l) => l.day.isBiggerThanValue(last))).get();
    final strikes =
        await (_db.select(_db.attempts)..where(
              (a) =>
                  a.day.isBiggerThanValue(last) &
                  a.outcome.equalsValue(Outcome.strike),
            ))
            .get();
    Set<String> daysOf(bool Function(DayKind) keep) => {
      for (final l in logs)
        if (keep(l.kind)) l.day,
    };
    return missedDays(
      lastResolved: last,
      today: today,
      restedDays: daysOf(_isCover),
      lightDays: daysOf((k) => k == DayKind.light),
      strikeDays: {for (final a in strikes) a.day},
    );
  }

  /// Active bosses that were created before the last of [days] (plan D4),
  /// except those that already fell by health on one of them (Stage 4 D14).
  Future<List<Boss>> _affected(List<String> days, int hour) async {
    final active = await (_db.select(
      _db.bosses,
    )..where((b) => b.status.equalsValue(BossStatus.active))).get();
    final died = {
      for (final a
          in await (_db.select(_db.attempts)..where(
                (a) =>
                    a.cause.equalsValue(FallCause.healthDeath) &
                    a.day.isIn(days),
              ))
              .get())
        a.bossId,
    };
    return [
      for (final b in active)
        if (dayOf(b.createdAt, rolloverHour: hour).compareTo(days.last) < 0 &&
            !died.contains(b.id))
          b,
    ];
  }

  /// The days that ended with no rest, flask or valid light day, and the
  /// bosses that would fall for them. Reads only.
  Future<PendingDays> pending() async {
    final s = await _db.select(_db.settings).getSingle();
    final hour = await _db.rolloverHour();
    final today = dayOf(_clock(), rolloverHour: hour);
    final missed = await _missed(s, today);
    return PendingDays(
      days: missed,
      bosses: missed.isEmpty ? const [] : await _affected(missed, hour),
      flasks: await _flasks(),
    );
  }

  /// Judges every ended day (plan D1). Spends up to [flasksToSpend] flasks on
  /// the oldest missed days; if any day is left, each affected boss fails
  /// once, whatever the count (D2), with the shared [lesson]. Always moves
  /// `lastResolvedDay` to yesterday. All or nothing. Returns how many bosses
  /// fell.
  Future<int> resolve({String? lesson, int flasksToSpend = 0}) {
    return _db.transaction(() async {
      final s = await _db.select(_db.settings).getSingle();
      final hour = await _db.rolloverHour();
      final now = _clock();
      final today = dayOf(now, rolloverHour: hour);
      final missed = await _missed(s, today);

      final spend = flasksToSpend.clamp(0, await _flasks());
      final covered = missed.take(spend).toList();
      for (final day in covered) {
        await _log(day, DayKind.flask, now);
      }
      if (covered.isNotEmpty) {
        await _flaskLedger.spend(
          covered.length,
          FlaskReason.skipDay,
          today,
          at: now,
        );
      }
      final left = missed.skip(spend).toList();
      var fallen = 0;
      if (left.isNotEmpty) {
        for (final boss in await _affected(left, hour)) {
          await _attempts.failBoss(
            boss.id,
            FallCause.missedDay,
            cleanLesson(lesson),
            onDay: left.last,
          );
          fallen++;
        }
      }
      final yesterday = shiftDay(today, -1);
      await _db
          .update(_db.settings)
          .write(
            SettingsCompanion(
              lastResolvedDay: Value(
                (s.lastResolvedDay ?? '').compareTo(yesterday) > 0
                    ? s.lastResolvedDay
                    : yesterday,
              ),
            ),
          );
      return fallen;
    });
  }

  static bool _isCover(DayKind kind) =>
      kind == DayKind.bonfire || kind == DayKind.flask;
}

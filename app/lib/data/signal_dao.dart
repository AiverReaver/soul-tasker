import 'package:drift/drift.dart';

import '../core/check_in.dart';
import '../core/clock.dart';
import '../core/ids.dart';
import '../core/signals.dart';
import 'database.dart';
import 'enums.dart';

/// The append-only tester signal log (Stage 6 plan D3). Counts and times
/// only: never a title or a lesson.
class SignalDao {
  SignalDao(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Writes one event. [day] and [at] default to the current ritual day
  /// and now; a fall passes its own.
  Future<void> add(
    SignalKind kind, {
    String? day,
    DateTime? at,
    int? value,
  }) async {
    final when = at ?? _clock();
    await _db
        .into(_db.signalEvents)
        .insert(
          SignalEventsCompanion.insert(
            id: newId(),
            kind: kind,
            day: day ?? dayOf(when, rolloverHour: await _db.rolloverHour()),
            at: when,
            value: Value(value),
          ),
        );
  }

  /// Every event, oldest first.
  Future<List<SignalEvent>> events() =>
      (_db.select(_db.signalEvents)..orderBy([
            (e) => OrderingTerm(expression: e.at),
            (e) => OrderingTerm(expression: e.id),
          ]))
          .get();

  /// What the tester report counts. Reads outcomes, weights and whether a
  /// lesson exists, never the lesson or any title.
  Future<SignalInput> input() async {
    final settings = await _db.select(_db.userSettings).getSingle();
    final visits = await (_db.select(
      _db.visits,
    )..orderBy([(v) => OrderingTerm(expression: v.day)])).get();
    final attempts = await (_db.select(
      _db.attempts,
    )..orderBy([(a) => OrderingTerm(expression: a.at)])).get();
    final bonfireLessons =
        await (_db.select(_db.dayLogs)..where(
              (d) => d.kind.equalsValue(DayKind.bonfire) & d.lesson.isNotNull(),
            ))
            .get();
    final firstDay =
        settings.firstDay ??
        (visits.isEmpty
            ? dayOf(_clock(), rolloverHour: settings.rolloverHour)
            : visits.first.day);
    return SignalInput(
      firstDay: firstDay,
      rolloverHour: settings.rolloverHour,
      visitDays: [for (final v in visits) v.day],
      marks: [
        for (final e in await events())
          SignalMark(kind: e.kind, day: e.day, at: e.at, value: e.value),
      ],
      attempts: [
        for (final a in attempts)
          AttemptMark(
            outcome: a.outcome,
            weight: a.weight,
            hasLesson: a.lesson != null,
          ),
      ],
      bonfireLessons: bonfireLessons.length,
      tapMode: settings.tapMode,
      haptics: settings.haptics,
      commits: [
        for (final c in await _db.select(_db.commitments).get())
          CommitMark(day: c.day, extensions: c.extensions, outcome: c.outcome),
      ],
    );
  }

  /// The check-in window due at today's bonfire, or null.
  Future<int?> checkInDue() async {
    final input = await this.input();
    final today = dayOf(_clock(), rolloverHour: input.rolloverHour);
    return dueCheckIn(input.firstDay, today, input.marks);
  }
}

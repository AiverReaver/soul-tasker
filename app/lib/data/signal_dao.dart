import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/ids.dart';
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
}

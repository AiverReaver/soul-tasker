import 'package:drift/drift.dart';

import '../core/clock.dart';
import 'database.dart';

/// Ritual days the app was opened (Stage 6 plan D2).
class VisitDao {
  VisitDao(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Notes today as visited; the first open of the day keeps its time.
  Future<void> record() async {
    final now = _clock();
    final day = dayOf(now, rolloverHour: await _db.rolloverHour());
    await _db
        .into(_db.visits)
        .insert(
          VisitsCompanion.insert(day: day, firstAt: now),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Every visited day, oldest first.
  Future<List<String>> days() async {
    final rows = await (_db.select(
      _db.visits,
    )..orderBy([(v) => OrderingTerm(expression: v.day)])).get();
    return [for (final v in rows) v.day];
  }
}

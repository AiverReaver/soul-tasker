import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/ids.dart';
import 'database.dart';
import 'day_dao.dart' show kFlaskCap;
import 'enums.dart';

typedef FlaskStep = ({FlaskKind kind, int amount});

/// Flasks left: [kFlaskCap] plus restores minus spends, clamped to 0 and
/// the cap at each step, so [steps] must be in time order (Stage 7 plan D8).
int foldFlasks(Iterable<FlaskStep> steps) {
  var left = kFlaskCap;
  for (final s in steps) {
    final delta = s.kind == FlaskKind.spend ? -s.amount : s.amount;
    left = (left + delta).clamp(0, kFlaskCap);
  }
  return left;
}

/// The flask ledger. Only ever inserts, so two phones' events merge by
/// adding rows (D8).
class FlaskDao {
  FlaskDao(this._db, [this._clock = DateTime.now]);

  final AppDatabase _db;
  final Clock _clock;

  Future<int> count() async {
    final rows =
        await (_db.select(_db.flaskEvents)..orderBy([
              (e) => OrderingTerm(expression: e.at),
              (e) => OrderingTerm(expression: e.id),
            ]))
            .get();
    return foldFlasks([for (final e in rows) (kind: e.kind, amount: e.amount)]);
  }

  Future<void> spend(
    int amount,
    FlaskReason reason,
    String day, {
    DateTime? at,
  }) => _add(FlaskKind.spend, amount, reason, day, at);

  Future<void> restore(FlaskReason reason, String day, {DateTime? at}) =>
      _add(FlaskKind.restore, 1, reason, day, at);

  /// Writes one event that brings the count to [target], or none if it is
  /// there already.
  Future<void> adjustTo(int target, String day) async {
    final diff =
        RangeError.checkValueInInterval(target, 0, kFlaskCap) - await count();
    if (diff == 0) return;
    await _add(
      diff < 0 ? FlaskKind.spend : FlaskKind.restore,
      diff.abs(),
      FlaskReason.backfill,
      day,
      null,
    );
  }

  Future<void> _add(
    FlaskKind kind,
    int amount,
    FlaskReason reason,
    String day,
    DateTime? at,
  ) => _db
      .into(_db.flaskEvents)
      .insert(
        FlaskEventsCompanion.insert(
          id: newId(),
          kind: kind,
          amount: amount,
          reason: reason,
          day: day,
          at: at ?? _clock(),
        ),
      );
}

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../core/clock.dart';
import '../core/ids.dart';
import 'database.dart';
import 'enums.dart';

/// Embers the player holds: carried since the last bank, and banked for good.
@immutable
class EmberTally {
  const EmberTally({required this.carried, required this.banked});

  final int carried;
  final int banked;

  @override
  bool operator ==(Object other) =>
      other is EmberTally && other.carried == carried && other.banked == banked;

  @override
  int get hashCode => Object.hash(carried, banked);

  @override
  String toString() => 'EmberTally(carried: $carried, banked: $banked)';
}

/// The embers ledger (Stage 3 plan D7). Events are only ever inserted, and in
/// gentle mode nothing is subtracted: carried = earned - banked.
class EmberDao {
  EmberDao(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// What an outcome earns: a strike the weight's embers, a try half of that
  /// rounded up, a fall nothing.
  static int amountFor(Outcome outcome, Weight? weight) {
    final full = weight?.embers ?? 0;
    return switch (outcome) {
      Outcome.strike => full,
      Outcome.tried => (full + 1) ~/ 2,
      Outcome.fallen => 0,
    };
  }

  /// Writes the earn event for an attempt. Call inside the attempt's
  /// transaction. Nothing is written for a zero amount.
  Future<void> earn({
    required Outcome outcome,
    required Weight? weight,
    required String bossId,
    required String? taskId,
    required String day,
    required DateTime at,
  }) async {
    final amount = amountFor(outcome, weight);
    if (amount == 0) return;
    await _insert(EmberKind.earn, amount, bossId, taskId, day, at);
  }

  /// Makes the carried embers permanent. Returns the amount banked; with
  /// nothing carried it writes nothing and returns 0.
  Future<int> bank() => _db.transaction(() async {
    final carried = (await tally()).carried;
    if (carried == 0) return 0;
    final now = _clock();
    final day = dayOf(now, rolloverHour: await _db.rolloverHour());
    await _insert(EmberKind.bank, carried, null, null, day, now);
    return carried;
  });

  Future<EmberTally> tally() async =>
      _sum(await _db.select(_db.emberEvents).get());

  Stream<EmberTally> watchTally() =>
      _db.select(_db.emberEvents).watch().map(_sum);

  EmberTally _sum(List<EmberEvent> events) {
    int total(EmberKind kind) =>
        events.where((e) => e.kind == kind).fold(0, (sum, e) => sum + e.amount);
    final banked = total(EmberKind.bank);
    return EmberTally(carried: total(EmberKind.earn) - banked, banked: banked);
  }

  Future<void> _insert(
    EmberKind kind,
    int amount,
    String? bossId,
    String? taskId,
    String day,
    DateTime at,
  ) => _db
      .into(_db.emberEvents)
      .insert(
        EmberEventsCompanion.insert(
          id: newId(),
          kind: kind,
          amount: amount,
          bossId: Value(bossId),
          taskId: Value(taskId),
          day: day,
          at: at,
        ),
      );
}

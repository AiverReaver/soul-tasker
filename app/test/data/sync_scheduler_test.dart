import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/sync_service.dart';

/// Timers on a clock the test moves.
class FakeTimers {
  final _timers = <_FakeTimer>[];
  Duration now = Duration.zero;

  Timer create(Duration after, void Function() fire) {
    final t = _FakeTimer(now + after, fire);
    _timers.add(t);
    return t;
  }

  List<Duration> get pendingIn => [
    for (final t in _timers)
      if (t.isActive) t.due - now,
  ];

  Future<void> elapse(Duration d) async {
    final end = now + d;
    while (true) {
      final due = _timers.where((t) => t.isActive && t.due <= end).toList()
        ..sort((a, b) => a.due.compareTo(b.due));
      if (due.isEmpty) break;
      now = due.first.due;
      due.first.fire();
      await pumpEventQueue();
    }
    now = end;
  }
}

class _FakeTimer implements Timer {
  _FakeTimer(this.due, this._fire);

  final Duration due;
  final void Function() _fire;
  bool _active = true;

  void fire() {
    _active = false;
    _fire();
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}

void main() {
  late FakeTimers timers;
  late List<SyncOutcome> outcomes;
  late int runs;
  late SyncScheduler scheduler;

  setUp(() {
    timers = FakeTimers();
    outcomes = [];
    runs = 0;
    scheduler = SyncScheduler(
      run: () async {
        runs++;
        return outcomes.isEmpty ? SyncOutcome.synced : outcomes.removeAt(0);
      },
      timer: timers.create,
    );
  });

  test('start and resume sync at once', () async {
    scheduler.start();
    await pumpEventQueue();
    expect(runs, 1);
    scheduler.resumed();
    await pumpEventQueue();
    expect(runs, 2);
  });

  test('a write syncs 5 s after the last one (debounce)', () async {
    scheduler.localWrite();
    await timers.elapse(const Duration(seconds: 3));
    scheduler.localWrite();
    await timers.elapse(const Duration(seconds: 3));
    expect(runs, 0, reason: '6 s in, but only 3 s since the last write');
    await timers.elapse(const Duration(seconds: 2));
    expect(runs, 1);
    await timers.elapse(const Duration(minutes: 1));
    expect(runs, 1);
  });

  test('failures back off 30 s, 2 min, 10 min, then wait for start', () async {
    outcomes = List.filled(10, SyncOutcome.failed, growable: true);
    scheduler.start();
    await pumpEventQueue();
    expect(runs, 1);
    expect(timers.pendingIn, [const Duration(seconds: 30)]);

    await timers.elapse(const Duration(seconds: 29));
    expect(runs, 1);
    await timers.elapse(const Duration(seconds: 1));
    expect(runs, 2);
    expect(timers.pendingIn, [const Duration(minutes: 2)]);

    await timers.elapse(const Duration(minutes: 2));
    expect(runs, 3);
    expect(timers.pendingIn, [const Duration(minutes: 10)]);

    await timers.elapse(const Duration(minutes: 10));
    expect(runs, 4);
    expect(timers.pendingIn, isEmpty, reason: 'no fifth attempt on its own');
    await timers.elapse(const Duration(hours: 5));
    expect(runs, 4);

    scheduler.resumed();
    await pumpEventQueue();
    expect(runs, 5, reason: 'the next resume tries again');
  });

  test('a write during back-off does not skip the wait', () async {
    outcomes = [SyncOutcome.failed];
    scheduler.start();
    await pumpEventQueue();
    scheduler.localWrite();
    await timers.elapse(const Duration(seconds: 6));
    expect(runs, 1);
    await timers.elapse(const Duration(seconds: 24));
    expect(runs, 2);
  });

  test('a success resets the back-off', () async {
    outcomes = [SyncOutcome.failed, SyncOutcome.synced, SyncOutcome.failed];
    scheduler.start();
    await pumpEventQueue();
    await timers.elapse(const Duration(seconds: 30));
    expect(runs, 2);
    scheduler.resumed();
    await pumpEventQueue();
    expect(timers.pendingIn, [const Duration(seconds: 30)]);
  });

  test('being signed out stops the retries', () async {
    outcomes = [SyncOutcome.signedOut];
    scheduler.start();
    await pumpEventQueue();
    expect(timers.pendingIn, isEmpty);
  });

  test('dispose cancels what is waiting', () async {
    scheduler.localWrite();
    scheduler.dispose();
    await timers.elapse(const Duration(minutes: 1));
    expect(runs, 0);
  });
}

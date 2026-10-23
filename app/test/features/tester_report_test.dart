import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/clock.dart';
import 'package:hearthrise/core/signals.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/signal_dao.dart';
import 'package:hearthrise/data/visit_dao.dart';
import 'package:hearthrise/features/tester_report/tester_report.dart';

import '../data/harness.dart';
import 'pump.dart';

String _d(int day) => '2026-10-${day.toString().padLeft(2, '0')}';
DateTime _on(int day, [int hour = 21]) => DateTime(2026, 10, day, hour);

SignalInput _input({
  List<String> visits = const [],
  List<SignalMark> marks = const [],
  List<AttemptMark> attempts = const [],
  int bonfireLessons = 0,
  bool tapMode = false,
  bool haptics = true,
  List<CommitMark> commits = const [],
}) => SignalInput(
  firstDay: _d(1),
  rolloverHour: 4,
  visitDays: visits,
  marks: marks,
  attempts: attempts,
  bonfireLessons: bonfireLessons,
  tapMode: tapMode,
  haptics: haptics,
  commits: commits,
);

SignalMark _m(SignalKind kind, int day, [int? value]) =>
    SignalMark(kind: kind, day: _d(day), at: _on(day), value: value);

void main() {
  test('a full report, every line', () {
    final s = computeSignals(
      _input(
        visits: [_d(1), _d(2), _d(4), _d(9), _d(10)],
        marks: [
          _m(SignalKind.fell, 1),
          _m(SignalKind.fell, 2),
          _m(SignalKind.fell, 9),
          _m(SignalKind.tapModeChanged, 5, 1),
          _m(SignalKind.checkInDismissed, 7),
          _m(SignalKind.checkIn, 8, CheckInAnswer.never.index),
        ],
        attempts: const [
          AttemptMark(outcome: Outcome.strike, weight: Weight.light),
          AttemptMark(outcome: Outcome.strike, weight: Weight.light),
          AttemptMark(outcome: Outcome.strike, weight: Weight.heavy),
          AttemptMark(outcome: Outcome.strike, weight: Weight.bossTier),
          AttemptMark(outcome: Outcome.strike),
          AttemptMark(outcome: Outcome.tried, weight: Weight.heavy),
          AttemptMark(outcome: Outcome.tried),
          AttemptMark(outcome: Outcome.fallen, hasLesson: true),
          AttemptMark(outcome: Outcome.fallen),
          AttemptMark(outcome: Outcome.fallen),
        ],
        bonfireLessons: 4,
        tapMode: true,
        haptics: false,
        commits: [
          for (final (day, ext, outcome) in [
            (1, 1, CommitmentOutcome.kept),
            (2, 2, CommitmentOutcome.lateStrike),
            (3, 0, CommitmentOutcome.missed),
            (4, 0, CommitmentOutcome.kept),
          ])
            CommitMark(day: _d(day), extensions: ext, outcome: outcome),
        ],
      ),
      _d(10),
    );

    expect(
      buildTesterReport(s, '0.6.0+1'),
      'Hearthrise tester report\n'
      'Version: 0.6.0+1\n'
      'Period: 2026-10-01 to 2026-10-10 (day 10)\n'
      'Visits recorded since: 2026-10-01\n'
      'Fallen days: 3\n'
      'Returned the next day after a fall: 1 of 2 (1 pending)\n'
      'First-week fallen days: 2 (returned the next day 1 of 2)\n'
      'Strikes: 5 (Light 2, Heavy 1, Boss-tier 1, weight unknown 1)\n'
      'Tried: 2\n'
      'Tried per Strike: 0.40\n'
      'Lessons on falls: written 1, skipped 2\n'
      'Bonfire lessons: 4\n'
      'Tap mode: on (changed 1 time, first on day 5)\n'
      'Haptics: off\n'
      'Check-in from day 7: Never (dismissed 1)\n'
      'Check-in from day 14: not asked yet\n'
      'Extensions: free 2, with a flask 1\n'
      'Late strikes: 1\n'
      'Promises week 1: 4 made, 2 kept over 7 days (0.6 a day)\n'
      'Promises week 4: not yet\n',
    );
  });

  test('an empty install: zeros, n/a, nothing pending', () {
    final report = buildTesterReport(computeSignals(_input(), _d(1)), 'v');

    expect(report, contains('Period: 2026-10-01 to 2026-10-01 (day 1)\n'));
    expect(report, contains('Visits recorded since: none yet\n'));
    expect(report, contains('Fallen days: 0\n'));
    expect(
      report,
      contains('Returned the next day after a fall: 0 of 0 (0 pending)\n'),
    );
    expect(report, contains('Tried per Strike: n/a\n'));
    expect(report, contains('Tap mode: off (never changed)\n'));
    expect(report, contains('Check-in from day 7: not asked yet\n'));
    expect(report, contains('Extensions: free 0, with a flask 0\n'));
    expect(report, contains('Late strikes: 0\n'));
    expect(
      report,
      contains('Promises week 1: 0 made, 0 kept over 1 day (0.0 a day)\n'),
    );
  });

  test('a window passed with no answer says so', () {
    final report = buildTesterReport(
      computeSignals(
        _input(
          marks: [
            _m(SignalKind.checkInDismissed, 14),
            _m(SignalKind.checkInDismissed, 15),
          ],
        ),
        _d(20),
      ),
      'v',
    );
    expect(report, contains('Check-in from day 7: no answer\n'));
    expect(report, contains('Check-in from day 14: no answer (dismissed 2)\n'));
  });

  test('changed twice reads in the plural', () {
    final report = buildTesterReport(
      computeSignals(
        _input(
          marks: [
            _m(SignalKind.tapModeChanged, 2, 1),
            _m(SignalKind.tapModeChanged, 3, 0),
          ],
        ),
        _d(5),
      ),
      'v',
    );
    expect(report, contains('Tap mode: off (changed 2 times, first on day 2)'));
  });

  test('carries no boss, chapter, task, lesson or inscription text', () async {
    final h = Harness();
    final id = await h.bosses.saveBoss(
      const BossDraft(
        title: 'Zorblax the Unnamed',
        resetOnFail: ResetOnFail.nothing,
        phases: [
          PhaseDraft(
            name: 'Quuxchapter',
            tasks: [TaskDraft(title: 'Frobnicate widgets')],
          ),
        ],
      ),
    );
    await VisitDao(h.db, h.clock.call).record();
    final view = await h.reload(id);
    await h.attempts.strike(view.segments.single.task.id);
    await h.attempts.fall(id, 'Grumblesnort lesson');
    await DayDao(h.db, h.clock.call, h.attempts).rest(lesson: 'Plinkwhistle');
    await h.bosses.setStatus(id, BossStatus.defeated);
    final relic = (await h.db.select(h.db.relics).get()).single;
    await h.relics.setInscription(relic.id, 'Snorkelvane');

    final input = await SignalDao(h.db, h.clock.call).input();
    final report = buildTesterReport(
      computeSignals(input, dayOf(h.clock.now)),
      'v',
    );

    for (final secret in [
      'Zorblax',
      'Quuxchapter',
      'Frobnicate',
      'Grumblesnort',
      'Plinkwhistle',
      'Snorkelvane',
    ]) {
      expect(report, isNot(contains(secret)));
    }
    await h.db.close();
  });

  test('kAppVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);

    expect(kAppVersion, version);
  });

  testWidgets('the settings row copies the report and says so quietly', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await pumpApp(tester, h);

    await tester.tap(find.bySemanticsLabel('Settings'));
    await settle(tester);
    expect(find.text('Copied.'), findsNothing);
    await tester.tap(find.text('Copy tester report'));
    await settle(tester);

    expect(copied, startsWith('Hearthrise tester report\n'));
    expect(copied, contains('Version: $kAppVersion'));
    expect(copied, contains('Visits recorded since: 2026-10-13'));
    expect(
      copied,
      contains('Strikes: 1 (Light 1, Heavy 0, Boss-tier 0, weight unknown 0)'),
    );
    expect(find.text('Copied.'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}

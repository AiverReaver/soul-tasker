import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/feel_report_data.dart';
import 'package:hearthrise/features/feel_report/feel_report.dart';

import '../data/harness.dart';
import 'pump.dart';

final _now = DateTime(2026, 10, 13, 12);

AppSettings _settings({
  bool tapMode = false,
  bool haptics = true,
  int rolloverHour = 4,
}) => AppSettings(
  id: 1,
  tapMode: tapMode,
  defaultResetOnFail: ResetOnFail.nothing,
  haptics: haptics,
  rolloverHour: rolloverHour,
  reminderEnabled: false,
  reminderMinutes: 21 * 60,
  flasks: 3,
  sound: false,
  onboarded: true,
);

FeelAttempt _a(Outcome outcome, {Weight? weight, bool hasLesson = false}) =>
    FeelAttempt(outcome: outcome, weight: weight, hasLesson: hasLesson);

void main() {
  group('buildFeelReport', () {
    test('counts strikes by weight, tried, falls and lessons', () {
      final report = buildFeelReport(
        FeelReportData(
          attempts: [
            _a(Outcome.strike, weight: Weight.light),
            _a(Outcome.strike, weight: Weight.light),
            _a(Outcome.strike, weight: Weight.heavy),
            _a(Outcome.strike, weight: Weight.bossTier),
            _a(Outcome.strike), // a v1 row: weight unknown
            _a(Outcome.tried, weight: Weight.heavy),
            _a(Outcome.tried),
            _a(Outcome.fallen, hasLesson: true),
            _a(Outcome.fallen),
          ],
          since: DateTime(2026, 10, 10, 9),
          settings: _settings(tapMode: true, haptics: false),
        ),
        _now,
        '1.0.0+1',
      );

      expect(
        report,
        'Hearthrise feel report\n'
        'Version: 1.0.0+1\n'
        'Period: 2026-10-10 to 2026-10-13 '
        '(since the earliest surviving boss)\n'
        'Strikes: 5 (Light 2, Heavy 1, Boss-tier 1, weight unknown 1)\n'
        'Tried: 2\n'
        'Falls: 2 (lessons written 1, skipped 1)\n'
        'Tap mode: on\n'
        'Haptics: off\n',
      );
    });

    test('an empty database gives zeros and no period start', () {
      final report = buildFeelReport(
        FeelReportData(attempts: const [], since: null, settings: _settings()),
        _now,
        '1.0.0+1',
      );

      expect(report, contains('Period: no bosses yet (to 2026-10-13)'));
      expect(
        report,
        contains(
          'Strikes: 0 (Light 0, Heavy 0, Boss-tier 0, weight unknown 0)',
        ),
      );
      expect(report, contains('Tried: 0'));
      expect(report, contains('Falls: 0 (lessons written 0, skipped 0)'));
      expect(report, contains('Tap mode: off'));
      expect(report, contains('Haptics: on'));
    });
  });

  test('the period end uses the stored rollover hour', () {
    final threeAm = DateTime(2026, 10, 14, 3);
    String periodAt(int hour) => buildFeelReport(
      FeelReportData(
        attempts: const [],
        since: null,
        settings: _settings(rolloverHour: hour),
      ),
      threeAm,
      '1.0.0+1',
    );

    expect(periodAt(4), contains('(to 2026-10-13)'));
    expect(periodAt(2), contains('(to 2026-10-14)'));
  });

  test('deleting the earliest boss moves the period start (D9)', () async {
    final h = Harness();
    final first = await h.seed();
    h.clock.now = h.clock.now.add(const Duration(days: 3));
    await h.seed();

    var report = buildFeelReport(
      await h.attempts.feelReportData(),
      h.clock.now,
      '1.0.0+1',
    );
    expect(report, contains('Period: 2026-10-13 to 2026-10-16'));

    await h.bosses.deleteBoss(first.boss.id);
    report = buildFeelReport(
      await h.attempts.feelReportData(),
      h.clock.now,
      '1.0.0+1',
    );
    expect(report, contains('Period: 2026-10-16 to 2026-10-16'));
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

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    expect(find.text('Copied.'), findsNothing);
    await tester.tap(find.text('Copy feel report'));
    await settle(tester);

    expect(copied, startsWith('Hearthrise feel report\n'));
    expect(copied, contains('Version: $kAppVersion'));
    expect(
      copied,
      contains('Strikes: 1 (Light 1, Heavy 0, Boss-tier 0, weight unknown 0)'),
    );
    expect(find.text('Copied.'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}

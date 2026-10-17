import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/fake_reminders.dart';
import 'pump.dart';

void main() {
  late Harness h;
  late FakeReminders reminders;
  setUp(() {
    h = Harness();
    reminders = FakeReminders();
  });

  Future<AppSettings> settings() => h.db.select(h.db.userSettings).getSingle();
  Future<void> open(WidgetTester tester) async {
    await pumpApp(tester, h, reminders: reminders);
    reminders.calls.clear(); // the start-up rearm is not under test here
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
  }

  testWidgets('the home button opens a screen, not a sheet', (tester) async {
    await open(tester);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('lists every Stage 3 setting', (tester) async {
    await open(tester);
    for (final label in [
      'Tap instead of hold',
      'Haptics',
      'Evening reminder',
      'Reminder time',
      'Day starts at',
      'On a failed attempt, reset (new bosses)',
      'Copy tester report',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('9:00 PM'), findsOneWidget);
    expect(find.text('4:00 AM'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the switches and the reset choice write through', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Tap instead of hold'));
    await tester.tap(find.text('Haptics'));
    await tester.tap(find.text('Whole boss'));
    await settle(tester);

    final s = await settings();
    expect(s.tapMode, isTrue);
    expect(s.haptics, isFalse);
    expect(s.defaultResetOnFail, ResetOnFail.wholeBoss);
    await tearDownApp(tester, h);
  });

  testWidgets('the reminder switch asks, schedules, and cancels', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Evening reminder'));
    await settle(tester);
    expect(reminders.calls, ['permission', 'schedule:1260']);
    expect((await settings()).reminderEnabled, isTrue);

    reminders.calls.clear();
    await tester.tap(find.text('Evening reminder'));
    await settle(tester);
    expect(reminders.calls, ['cancel']);
    expect((await settings()).reminderEnabled, isFalse);
    await tearDownApp(tester, h);
  });

  testWidgets('a refused permission leaves the switch off with a quiet line', (
    tester,
  ) async {
    reminders.grants = false;
    await open(tester);
    await tester.tap(find.text('Evening reminder'));
    await settle(tester);

    expect((await settings()).reminderEnabled, isFalse);
    expect(find.text('No reminder without permission.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the time picker stores minutes from midnight', (tester) async {
    await open(tester);
    await tester.tap(find.text('Reminder time'));
    await settle(tester);

    // Keyboard entry: 7:30, the period stays PM from the initial 9:00 PM.
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '7');
    await tester.enterText(fields.at(1), '30');
    await tester.tap(find.text('OK'));
    await settle(tester);

    expect((await settings()).reminderMinutes, 19 * 60 + 30);
    expect(find.text('7:30 PM'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the rollover control offers 0 to 6 and stores the pick', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Day starts at'));
    await settle(tester);

    expect(find.byType(SimpleDialogOption), findsNWidgets(7));
    expect(find.text('12:00 AM'), findsOneWidget);
    expect(find.text('6:00 AM'), findsOneWidget);
    expect(find.text('7:00 AM'), findsNothing);

    await tester.tap(find.text('2:00 AM'));
    await settle(tester);
    expect((await settings()).rolloverHour, 2);
    await tearDownApp(tester, h);
  });
}

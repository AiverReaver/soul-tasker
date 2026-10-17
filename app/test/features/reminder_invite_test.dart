import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/ui/ember_button.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/fake_reminders.dart';
import 'pump.dart';

// The one-time invitation after the first rest (Stage 3 plan D6).
void main() {
  late Harness h;
  late FakeReminders reminders;
  setUp(() async {
    h = Harness();
    reminders = FakeReminders();
    await h.seed();
  });

  Future<AppSettings> settings() => h.db.select(h.db.userSettings).getSingle();
  Future<void> rest(WidgetTester tester) async {
    final button = find.widgetWithText(EmberButton, 'Rest at the hearth');
    await tester.scrollUntilVisible(
      button,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(button);
    await settle(tester);
  }

  testWidgets('the first rest invites, and accepting asks then schedules', (
    tester,
  ) async {
    await pumpApp(tester, h, location: '/bonfire', reminders: reminders);
    await rest(tester);

    expect(find.text('A quiet nudge each evening?'), findsOneWidget);
    await tester.tap(find.text('Yes, remind me'));
    await settle(tester);

    expect(reminders.calls, ['permission', 'schedule:1260']);
    expect((await settings()).reminderEnabled, isTrue);
    await tearDownApp(tester, h);
  });

  testWidgets('declining leaves the reminder off', (tester) async {
    await pumpApp(tester, h, location: '/bonfire', reminders: reminders);
    await rest(tester);
    await tester.tap(find.text('Not now'));
    await settle(tester);

    expect(reminders.calls, isEmpty);
    expect((await settings()).reminderEnabled, isFalse);
    await tearDownApp(tester, h);
  });

  testWidgets('the second rest does not invite again', (tester) async {
    await DayDao(h.db, h.clock.call, h.attempts).rest();
    h.clock.now = DateTime(2026, 10, 14, 12);
    await pumpApp(tester, h, location: '/bonfire', reminders: reminders);
    await rest(tester);

    expect(find.text('A quiet nudge each evening?'), findsNothing);
    expect(find.text('You have rested.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('no invitation when the reminder is already on', (tester) async {
    await h.settings.setReminder(enabled: true, minutes: 1260);
    await pumpApp(tester, h, location: '/bonfire', reminders: reminders);
    await rest(tester);

    expect(find.text('A quiet nudge each evening?'), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('a denied permission says so quietly and stays off', (
    tester,
  ) async {
    reminders.grants = false;
    await pumpApp(tester, h, location: '/bonfire', reminders: reminders);
    await rest(tester);
    await tester.tap(find.text('Yes, remind me'));
    await settle(tester);

    expect((await settings()).reminderEnabled, isFalse);
    expect(find.text('No reminder without permission.'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}

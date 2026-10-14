import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/ui/ember_button.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../support/recording_haptics.dart';
import 'pump.dart';

void main() {
  testWidgets('shows the summary, the lesson field and the open tasks', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await pumpApp(tester, h, location: '/bonfire');

    expect(find.text('BONFIRE'), findsOneWidget);
    expect(find.text('Struck 1'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text("TOMORROW'S THREE"), findsOneWidget);
    expect(find.text('Read chapter 4'), findsOneWidget);
    expect(find.text('Flashcards'), findsNothing); // struck, so not offered
    await tearDownApp(tester, h);
  });

  testWidgets('a fourth pick is blocked with a quiet line', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, location: '/bonfire');

    for (final title in [
      'Read chapter 4',
      'Walk',
      'Sit the exam',
      'Book the room',
    ]) {
      await tester.ensureVisible(find.text(title));
      await tester.tap(find.text(title));
      await settle(tester);
    }

    expect(find.text('Three is enough for one day.'), findsOneWidget);
    final picked = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .where((c) => c.value == true);
    expect(picked, hasLength(3));
    await tearDownApp(tester, h);
  });

  testWidgets('Rest banks, keeps the lesson, saves the picks and turns '
      'read-only', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    final haptics = RecordingHaptics();
    await pumpApp(
      tester,
      h,
      location: '/bonfire',
      overrides: [haptics.asOverride],
    );

    await tester.enterText(find.byType(TextField), 'Plan earlier.');
    await tester.ensureVisible(find.text('Walk'));
    await tester.tap(find.text('Walk'));
    await settle(tester);
    await tester.ensureVisible(find.widgetWithText(EmberButton, 'Rest'));
    await tester.tap(find.widgetWithText(EmberButton, 'Rest'));
    await settle(tester);

    final log = (await h.db.select(h.db.dayLogs).get()).single;
    expect(log.kind, DayKind.bonfire);
    expect(log.lesson, 'Plan earlier.');
    final picks = await h.db.select(h.db.planPicks).get();
    expect(picks.single.day, '2026-10-14');
    final embers = await h.db.select(h.db.emberEvents).get();
    expect(embers.where((e) => e.kind == EmberKind.bank).single.amount, 1);
    expect(haptics.events, contains('medium'));

    expect(find.text('You have rested.'), findsOneWidget);
    expect(find.widgetWithText(EmberButton, 'Rest'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('reopening after a rest is read-only (D9)', (tester) async {
    final h = Harness();
    await h.seed();
    await DayDao(h.db, h.clock.call, h.attempts).rest();
    await pumpApp(tester, h, location: '/bonfire');

    expect(find.text('You have rested.'), findsOneWidget);
    expect(find.widgetWithText(EmberButton, 'Rest'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('the home card opens the bonfire', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h);

    await tester.tap(find.text('Rest at the bonfire'));
    await settle(tester);
    expect(find.text('BONFIRE'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('ritual text is at least 15 px', (tester) async {
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await pumpApp(tester, h, location: '/bonfire');

    for (final label in ['Struck 1', 'Read chapter 4']) {
      final style = tester.widget<Text>(find.text(label)).style;
      final size =
          style?.fontSize ??
          Theme.of(tester.element(find.text(label)))
              .textTheme
              .bodyMedium!
              .fontSize!;
      expect(size, greaterThanOrEqualTo(15), reason: label);
    }
    await tearDownApp(tester, h);
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/signal_dao.dart';
import 'package:hearthrise/ui/check_in_card.dart';
import 'package:material_ui/material_ui.dart';

import 'data/harness.dart';
import 'features/pump.dart';

// The Stage 6 gate, scripted (STAGE6_PLAN.md step 9): a fresh install
// falls on day 1 and comes back on day 2, falls on day 3 and stays away on
// day 4, turns the hold into a tap on day 5, answers the day-7 check-in,
// and the copied tester report says so with no personal text.
void main() {
  testWidgets('falls, returns, check-in, and an honest tester report', (
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

    // The database is created on 2026-10-13: day 1.
    final h = Harness();
    final days = DayDao(h.db, h.clock.call, h.attempts);
    void at(int day, [int hour = 9]) =>
        h.clock.now = DateTime(2026, 10, 12 + day, hour);
    Future<void> open({String location = '/', bool? onboarded}) =>
        pumpApp(tester, h, location: location, onboarded: onboarded);
    Future<void> close() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    }

    // Day 1: onboarding to a boss, then a declared fall and a rest.
    at(1);
    await open(onboarded: false);
    await tester.tap(find.text('Next'));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('boss-title')),
      'Zorblax the Unnamed',
    );
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await settle(tester);
    }
    await tester.tap(find.text('Begin'));
    await settle(tester);
    expect(find.text('All bosses · 1 active'), findsOneWidget);
    await close();
    final bossId = (await h.bosses.loadAll()).single.boss.id;
    at(1, 20);
    await h.attempts.fall(bossId, 'Grumblesnort lesson');
    at(1, 21);
    expect(await days.rest(), isTrue);

    // Day 2: back the next day.
    at(2);
    await open();
    await close();
    at(2, 21);
    expect(await days.rest(), isTrue);

    // Day 3: falls again and rests.
    at(3);
    await open();
    await close();
    at(3, 20);
    await h.attempts.fall(bossId, null);
    at(3, 21);
    expect(await days.rest(), isTrue);

    // Day 4: away. Day 5: a flask covers the 4th; hold becomes a tap.
    at(5);
    await open();
    await tester.tap(find.text('Use a flask'));
    await settle(tester);
    await close();
    await h.settings.setTapMode(true);
    at(5, 21);
    expect(await days.rest(), isTrue);

    // Day 6: a quiet day with a rest.
    at(6);
    await open();
    await close();
    at(6, 21);
    expect(await days.rest(), isTrue);

    // Day 7: the bonfire asks once; "Never".
    at(7, 20);
    await open(location: '/bonfire');
    expect(find.byType(CheckInCard), findsOneWidget);
    await tester.tap(find.text('Never'));
    await settle(tester);
    expect(find.byType(CheckInCard), findsNothing);
    await close();

    // The tester report, copied from Settings.
    Future<String> copyReport() async {
      await open();
      await tester.tap(find.bySemanticsLabel('Settings'));
      await settle(tester);
      await tester.tap(find.text('Copy tester report'));
      await settle(tester);
      await close();
      return copied!;
    }

    final report = await copyReport();
    expect(report, contains('Period: 2026-10-13 to 2026-10-19 (day 7)\n'));
    expect(report, contains('Fallen days: 2\n'));
    expect(
      report,
      contains('Returned the next day after a fall: 1 of 2 (0 pending)\n'),
    );
    expect(
      report,
      contains('First-week fallen days: 2 (returned the next day 1 of 2)\n'),
    );
    expect(report, contains('Tap mode: on (changed 1 time, first on day 5)\n'));
    expect(report, contains('Lessons on falls: written 1, skipped 1\n'));
    expect(report, contains('Check-in from day 7: Never\n'));
    expect(report, isNot(contains('Zorblax')));
    expect(report, isNot(contains('Grumblesnort')));

    // Deleting the boss does not change what the falls tell us.
    await h.bosses.deleteBoss(bossId);
    final after = await copyReport();
    expect(after, contains('Fallen days: 2\n'));
    expect(
      after,
      contains('Returned the next day after a fall: 1 of 2 (0 pending)\n'),
    );
    expect(after, contains('First-week fallen days: 2'));
    expect(
      (await SignalDao(
        h.db,
        h.clock.call,
      ).events()).where((e) => e.kind == SignalKind.fell),
      hasLength(2),
    );
    await h.db.close();
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/signal_dao.dart';
import 'package:hearthrise/ui/check_in_card.dart';

import '../data/harness.dart';
import 'pump.dart';

// The harness installs on 2026-10-13 (day 1); day 7 is the 19th.
void main() {
  late Harness h;
  setUp(() async {
    h = Harness();
    await h.seed();
  });

  Future<List<SignalKind>> kinds() async => [
    for (final e in await SignalDao(h.db, h.clock.call).events()) e.kind,
  ];

  testWidgets('no card on day 6', (tester) async {
    h.clock.now = DateTime(2026, 10, 18, 20);
    await h.db.customStatement(
      "UPDATE settings SET last_resolved_day = "
      "'2026-10-17'",
    );
    await pumpApp(tester, h, location: '/bonfire');
    expect(find.byType(CheckInCard), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('on day 7 the card shows; an answer is saved and it goes', (
    tester,
  ) async {
    h.clock.now = DateTime(2026, 10, 19, 20);
    await h.db.customStatement(
      "UPDATE settings SET last_resolved_day = "
      "'2026-10-18'",
    );
    await pumpApp(tester, h, location: '/bonfire');
    expect(find.byType(CheckInCard), findsOneWidget);

    await tester.tap(find.text('Never'));
    await settle(tester);

    expect(find.byType(CheckInCard), findsNothing);
    expect(find.text('Thank you.'), findsOneWidget);
    expect(await kinds(), [SignalKind.checkIn]);
    await tearDownApp(tester, h);
  });

  testWidgets('"Not now" hides it and is counted', (tester) async {
    h.clock.now = DateTime(2026, 10, 19, 20);
    await h.db.customStatement(
      "UPDATE settings SET last_resolved_day = "
      "'2026-10-18'",
    );
    await pumpApp(tester, h, location: '/bonfire');

    await tester.tap(find.text('Not now'));
    await settle(tester);

    expect(find.byType(CheckInCard), findsNothing);
    expect(await kinds(), [SignalKind.checkInDismissed]);
    await tearDownApp(tester, h);
  });
}

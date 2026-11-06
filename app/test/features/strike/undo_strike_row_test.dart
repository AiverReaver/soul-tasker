import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/ui/flash_line.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/harness.dart';
import '../../support/hold_finders.dart';
import '../pump.dart';

void main() {
  testWidgets('a strike offers Undo, and Undo reopens the task', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, tall: true);

    await tester.tap(holdButton('Read chapter 4'));
    await settle(tester);
    expect(find.text('It is done.'), findsOneWidget);
    expect(
      taskNamed(await h.reload(view.boss.id), 'Read chapter 4').isStruck,
      isTrue,
    );

    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(
      taskNamed(await h.reload(view.boss.id), 'Read chapter 4').isStruck,
      isFalse,
    );
    expect(await h.db.select(h.db.attempts).get(), isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('a strike asks nothing; "Only partly" turns it into a try', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, tall: true);

    await tester.tap(holdButton('Read chapter 4'));
    await settle(tester);
    expect(find.text('HOW DID THE STRIKE LAND?'), findsNothing);
    // Two choices need longer than the default 4 s to read.
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).duration,
      const Duration(seconds: 6),
    );
    expect(
      taskNamed(await h.reload(view.boss.id), 'Read chapter 4').isStruck,
      isTrue,
    );

    await tester.tap(find.text('Only partly'));
    await settle(tester);
    final attempts = await h.db.select(h.db.attempts).get();
    expect(attempts.single.outcome, Outcome.tried);
    expect(
      taskNamed(await h.reload(view.boss.id), 'Read chapter 4').isStruck,
      isFalse,
    );
    expect(find.text('You tried. That counts.'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('a short tap on the needle says to hold it', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);

    await tester.tap(holdButton('Read chapter 4'));
    await settle(tester);
    expect(
      find.descendant(
        of: find.byType(FlashLine),
        matching: find.text('Press and hold to strike.'),
      ),
      findsOneWidget,
    );
    expect(await h.db.select(h.db.attempts).get(), isEmpty);
    await tearDownApp(tester, h);
  });

  testWidgets('a strike clears the hold hint', (tester) async {
    final h = Harness();
    await h.seed();
    await h.settings.setTapMode(true);
    await pumpApp(tester, h, tall: true);
    await h.settings.setTapMode(false);
    await settle(tester);
    await tester.tap(holdButton('Read chapter 4'));
    await settle(tester);
    expect(find.text('Press and hold to strike.'), findsOneWidget);

    await h.settings.setTapMode(true);
    await settle(tester);
    await tester.tap(holdButton('Read chapter 4'));
    await settle(tester);
    expect(find.text('Press and hold to strike.'), findsNothing);
    await tearDownApp(tester, h);
  });
}

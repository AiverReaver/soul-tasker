import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/health_dao.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  late Harness h;
  late HealthDao health;
  setUp(() {
    h = Harness();
    health = HealthDao(h.db, h.clock.call, h.attempts);
  });

  testWidgets('while fallen the bonfire offers only Rise; then Rest', (
    tester,
  ) async {
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Flashcards').task.id);
    await health.record(-20, HealthReason.miss, '2026-10-13', h.clock());
    await pumpApp(tester, h, location: '/bonfire');

    expect(find.text('You have fallen.'), findsOneWidget);
    expect(find.text('Rise'), findsOneWidget);
    expect(find.text('Rest'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text("TOMORROW'S THREE"), findsNothing);
    expect(find.bySemanticsLabel('Fallen. Health 0 of 10'), findsOneWidget);

    await tester.tap(find.text('Rise'));
    await settle(tester);

    expect(find.bySemanticsLabel('Health 10 of 10'), findsOneWidget);
    expect(
      await EmberDao(h.db, h.clock.call).tally(),
      const EmberTally(carried: 0, banked: 1),
    );
    expect(find.byType(TextField), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Rest'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Rest'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  testWidgets('the bonfire shows today\'s and the week\'s accuracy', (
    tester,
  ) async {
    final view = await h.seed();
    final commits = CommitmentDao(h.db, h.clock.call);
    final read = taskNamed(view, 'Read chapter 4').task.id;
    await commits.commit(read, DeadlinePreset.tonight);
    await commits.commit(
      taskNamed(view, 'Flashcards').task.id,
      DeadlinePreset.tonight,
    );
    await h.attempts.strike(read);
    await pumpApp(tester, h, location: '/bonfire');

    expect(find.text('Today: 1 of 2 kept. This week: 1 of 2.'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}

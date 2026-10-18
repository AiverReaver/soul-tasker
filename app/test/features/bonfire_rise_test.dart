import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('Rest at the hearth'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Tomorrow’s foes'), findsNothing);
    expect(find.text('How did today go?'), findsNothing);

    await tester.tap(find.text('Rise'));
    await settle(tester);

    expect(
      await EmberDao(h.db, h.clock.call).tally(),
      const EmberTally(carried: 0, banked: 1),
    );
    expect(find.byType(TextField), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Rest at the hearth'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Rest at the hearth'), findsOneWidget);
    await tearDownApp(tester, h);
  });
}

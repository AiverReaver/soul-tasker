import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_view.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  testWidgets('the Today tab shows carried embers and they rise after a '
      'strike', (tester) async {
    final h = Harness();
    final BossView view = await h.seed();
    await pumpApp(tester, h);

    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.text('Carried 0'), findsOneWidget);

    await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
    await settle(tester);
    expect(find.text('Carried 3'), findsOneWidget);

    await tearDownApp(tester, h);
  });
}

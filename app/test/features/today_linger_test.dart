import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  testWidgets('a struck task stays on Home for its animation, then goes', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(find.text('Read chapter 4'), findsOneWidget);
    await h.attempts.strike(taskNamed(view, 'Read chapter 4').task.id);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Read chapter 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('row-check')), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(find.text('Read chapter 4'), findsNothing);
    await tearDownApp(tester, h);
  });
}

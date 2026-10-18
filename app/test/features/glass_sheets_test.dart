import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/features/boss/rule_of_three_sheet.dart';
import 'package:hearthrise/ui/glass_sheet.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  testWidgets('the task sheet is a glass sheet with needle segments', (
    tester,
  ) async {
    final h = Harness();
    final view = await h.seed();
    await pumpApp(
      tester,
      h,
      location: '/boss/${view.boss.id}/edit',
      tall: true,
    );
    await tester.tap(find.text('Read chapter 4'));
    await settle(tester);

    expect(find.byType(GlassSheet), findsOneWidget);
    expect(find.text('Edit foe'), findsOneWidget);
    expect(find.byType(SegmentedButton<dynamic>), findsNothing);
    expect(find.byType(Switch), findsNothing);
    await tearDownApp(tester, h);
  });

  testWidgets('the rule of three sheet is a glass sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildTheme(),
          home: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () =>
                  showRuleOfThree(context, ref, bossId: 'x', onMessage: (_) {}),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(GlassSheet), findsOneWidget);
    expect(
      find.text('Same path, same result. What will you change?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Keep going'));
    await tester.pumpAndSettle();
    expect(find.byType(GlassSheet), findsNothing);
  });
}

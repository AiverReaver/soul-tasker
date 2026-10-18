import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/plan_banner.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('PlanBanner', () {
    testWidgets('lists the planned tasks and marks the struck ones', (
      tester,
    ) async {
      await _pump(
        tester,
        const PlanBanner(
          items: [
            PlanItem(title: 'Read chapter 4', bossTitle: 'Cert', isDone: true),
            PlanItem(title: 'Walk', bossTitle: 'Run', isDone: false),
          ],
        ),
      );
      expect(find.text("TODAY'S THREE"), findsOneWidget);
      expect(find.text('Read chapter 4'), findsOneWidget);
      expect(find.text('Walk'), findsOneWidget);
      expect(find.byKey(const ValueKey('plan-done')), findsOneWidget);
      expect(find.text('The three are done.'), findsNothing);
    });

    testWidgets('says so quietly when all are done', (tester) async {
      await _pump(
        tester,
        const PlanBanner(
          items: [PlanItem(title: 'Walk', bossTitle: 'Run', isDone: true)],
        ),
      );
      expect(find.text('The three are done.'), findsOneWidget);
    });
  });
}

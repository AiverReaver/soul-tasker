import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/bonfire_card.dart';
import 'package:hearthrise/ui/day_summary.dart';
import 'package:hearthrise/ui/ember_button.dart';
import 'package:hearthrise/ui/plan_banner.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DaySummary', () {
    testWidgets('renders the counts and the lessons from its values', (
      tester,
    ) async {
      await _pump(
        tester,
        const DaySummary(
          strikes: 3,
          tried: 1,
          falls: 2,
          lessons: ['Start earlier.'],
        ),
      );
      expect(find.text('Struck 3'), findsOneWidget);
      expect(find.text('Tried 1'), findsOneWidget);
      expect(find.text('Fallen 2'), findsOneWidget);
      expect(find.text('Start earlier.'), findsOneWidget);
    });

    testWidgets('shows the day lesson, even on an otherwise quiet day', (
      tester,
    ) async {
      await _pump(
        tester,
        const DaySummary(
          strikes: 0,
          tried: 0,
          falls: 0,
          lessons: [],
          dayLesson: 'Plan earlier.',
        ),
      );
      expect(find.text('Plan earlier.'), findsOneWidget);
    });

    testWidgets('a day with nothing says so quietly', (tester) async {
      await _pump(
        tester,
        const DaySummary(strikes: 0, tried: 0, falls: 0, lessons: []),
      );
      expect(find.text('A quiet day so far.'), findsOneWidget);
      expect(find.text('Struck 0'), findsNothing);
    });
  });

  group('BonfireCard', () {
    testWidgets('invites a rest before one, and fires onTap', (tester) async {
      var taps = 0;
      await _pump(tester, BonfireCard(isRested: false, onTap: () => taps++));
      expect(find.text('Rest at the bonfire'), findsOneWidget);
      await tester.tap(find.text('Rest at the bonfire'));
      expect(taps, 1);
    });

    testWidgets('is quiet after the rest', (tester) async {
      await _pump(tester, BonfireCard(isRested: true, onTap: () {}));
      expect(find.text('Rested'), findsOneWidget);
      expect(find.text('Rest at the bonfire'), findsNothing);
    });
  });

  testWidgets('EmberButton shows its label and fires onPressed', (
    tester,
  ) async {
    var pressed = 0;
    await _pump(tester, EmberButton(label: 'Rest', onPressed: () => pressed++));
    await tester.tap(find.text('Rest'));
    expect(pressed, 1);
    // Solid silk with onSilk text, at least 52 px tall (THEME_PLAN step 7).
    final p = Biome.pharloom.palette;
    expect(tester.widget<Text>(find.text('Rest')).style?.color, p.onSilk);
    expect(
      tester.getSize(find.byType(EmberButton)).height,
      greaterThanOrEqualTo(52),
    );
    final fill = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(EmberButton),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(fill.color, p.silk);
  });

  testWidgets('PlanBanner can carry another title', (tester) async {
    await _pump(
      tester,
      const PlanBanner(
        title: "TOMORROW'S THREE",
        items: [PlanItem(title: 'Walk', bossTitle: 'Run', isDone: false)],
      ),
    );
    expect(find.text("TOMORROW'S THREE"), findsOneWidget);
    expect(find.text("TODAY'S THREE"), findsNothing);
  });
}

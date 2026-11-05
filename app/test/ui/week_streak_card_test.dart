import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/core/week_streak.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:hearthrise/ui/week_streak_card.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, WeekStreak streak) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: WeekStreakCard(streak: streak)),
  ),
);

void main() {
  // Thursday, with Monday to Wednesday kept and today still open.
  final streak = weekStreakOn(
    today: '2026-11-05',
    kept: {'2026-11-02', '2026-11-03', '2026-11-04'},
  );

  testWidgets('a card with the count, seven days and their marks', (
    tester,
  ) async {
    await _pump(tester, streak);
    expect(find.byType(NeedleFrame), findsOneWidget);
    expect(find.text('STREAK'), findsOneWidget);
    expect(find.text('3 days unbroken'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('S'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('day-kept')), findsNWidgets(3));
    expect(find.byKey(const ValueKey('day-open')), findsNWidgets(4));
    expect(find.byKey(const ValueKey('day-today-ring')), findsOneWidget);
  });

  testWidgets('one day is singular; none reads as a beginning', (tester) async {
    await _pump(
      tester,
      weekStreakOn(today: '2026-11-05', kept: {'2026-11-05'}),
    );
    expect(find.text('1 day unbroken'), findsOneWidget);
    await _pump(tester, weekStreakOn(today: '2026-11-05', kept: const {}));
    expect(find.text('Begins today'), findsOneWidget);
  });

  testWidgets('it speaks as one line', (tester) async {
    await _pump(tester, streak);
    expect(
      find.bySemanticsLabel(
        'Streak: 3 days unbroken. 3 of 7 days kept this week',
      ),
      findsOneWidget,
    );
  });
}

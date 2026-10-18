import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/accuracy_line.dart';
import 'package:hearthrise/ui/away_summary.dart';
import 'package:hearthrise/ui/commit_sheet.dart';
import 'package:hearthrise/ui/deadline_chip.dart';
import 'package:hearthrise/ui/extend_sheet.dart';
import 'package:hearthrise/ui/player_health_bar.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('PlayerHealthBar', () {
    testWidgets('full health fills every pip', (tester) async {
      await _pump(tester, const PlayerHealthBar(health: 20, max: 20));
      expect(find.byKey(const ValueKey('health-full')), findsNWidgets(10));
      expect(find.bySemanticsLabel('Health 10 of 10'), findsOneWidget);
    });

    testWidgets('a half point draws a half pip', (tester) async {
      await _pump(tester, const PlayerHealthBar(health: 7, max: 20));
      expect(find.byKey(const ValueKey('health-full')), findsNWidgets(3));
      expect(find.byKey(const ValueKey('health-half')), findsOneWidget);
      expect(find.byKey(const ValueKey('health-empty')), findsNWidgets(6));
      expect(find.bySemanticsLabel('Health 3.5 of 10'), findsOneWidget);
    });

    testWidgets('at zero it reads as fallen', (tester) async {
      await _pump(tester, const PlayerHealthBar(health: 0, max: 20));
      expect(find.byKey(const ValueKey('health-empty')), findsNWidgets(10));
      expect(find.bySemanticsLabel('Fallen. Health 0 of 10'), findsOneWidget);
    });
  });

  group('DeadlineChip', () {
    testWidgets('shows the label; soon is ember, otherwise muted, never red', (
      tester,
    ) async {
      await _pump(
        tester,
        const Column(
          children: [
            DeadlineChip(label: 'in 40 min', isSoon: true),
            DeadlineChip(label: 'missed', isSoon: false),
          ],
        ),
      );
      Color colorOf(String s) =>
          tester.widget<Text>(find.text(s)).style!.color!;
      expect(colorOf('in 40 min'), Biome.pharloom.palette.silk);
      expect(colorOf('missed'), Biome.pharloom.palette.ash);
    });

    testWidgets('sits in a needle frame, edged silk only when soon', (
      tester,
    ) async {
      await _pump(
        tester,
        const Column(
          children: [
            DeadlineChip(label: 'in 40 min', isSoon: true),
            DeadlineChip(label: 'missed', isSoon: false),
          ],
        ),
      );
      final frames = tester.widgetList<NeedleFrame>(find.byType(NeedleFrame));
      expect(frames.map((f) => f.edge), [Biome.pharloom.palette.silk, null]);
    });
  });

  group('CommitSheet', () {
    testWidgets('fires onCommit with the preset and shows the note', (
      tester,
    ) async {
      DeadlinePreset? picked;
      await _pump(
        tester,
        CommitSheet(
          title: 'Read chapter 4',
          isDaily: false,
          remind: false,
          everyDay: false,
          note: 'That is six promises, four of them heavy.',
          onRemindChanged: (_) {},
          onEveryDayChanged: (_) {},
          onCommit: (p) => picked = p,
        ),
      );
      expect(find.text('Every day'), findsNothing);
      expect(
        find.text('That is six promises, four of them heavy.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Tonight'));
      expect(picked, DeadlinePreset.tonight);
    });

    testWidgets('a daily task offers every day; switches report', (
      tester,
    ) async {
      bool? remind;
      bool? everyDay;
      await _pump(
        tester,
        CommitSheet(
          title: 'Walk',
          isDaily: true,
          remind: false,
          everyDay: false,
          onRemindChanged: (v) => remind = v,
          onEveryDayChanged: (v) => everyDay = v,
          onCommit: (_) {},
        ),
      );
      await tester.tap(find.text('Remind me 10 minutes before'));
      await tester.tap(find.text('Every day'));
      expect(remind, isTrue);
      expect(everyDay, isTrue);
    });
  });

  group('ExtendSheet', () {
    testWidgets('first move is free and fires onExtend', (tester) async {
      DeadlinePreset? picked;
      await _pump(
        tester,
        ExtendSheet(
          options: const [DeadlinePreset.threeHours, DeadlinePreset.tonight],
          costsFlask: false,
          flasks: 0,
          onExtend: (p) => picked = p,
        ),
      );
      expect(find.text('Free, once.'), findsOneWidget);
      await tester.tap(find.text('In 3 hours'));
      expect(picked, DeadlinePreset.threeHours);
    });

    testWidgets('with no flask left the choices are disabled', (tester) async {
      DeadlinePreset? picked;
      await _pump(
        tester,
        ExtendSheet(
          options: const [DeadlinePreset.tonight],
          costsFlask: true,
          flasks: 0,
          onExtend: (p) => picked = p,
        ),
      );
      expect(find.text('No flask left to move it again.'), findsOneWidget);
      await tester.tap(find.text('Tonight'));
      expect(picked, isNull);
    });

    testWidgets('a paid move says so', (tester) async {
      await _pump(
        tester,
        ExtendSheet(
          options: const [DeadlinePreset.tonight],
          costsFlask: true,
          flasks: 2,
          onExtend: (_) {},
        ),
      );
      expect(find.text('Costs a flask. You hold 2.'), findsOneWidget);
    });
  });

  group('AwaySummary', () {
    testWidgets('plural copy, rows with cost, done late fires', (tester) async {
      String? late;
      await _pump(
        tester,
        AwaySummary(
          rows: const [
            AwayRow(id: 'c1', title: 'Read chapter 4', cost: '−2 health'),
            AwayRow(id: 'c2', title: 'Walk', cost: 'frozen'),
          ],
          onDoneLate: (id) => late = id,
          onClose: () {},
        ),
      );
      expect(
        find.text('While you were away, two deadlines passed.'),
        findsOneWidget,
      );
      expect(find.text('−2 health'), findsOneWidget);
      await tester.tap(find.text('Done late').first);
      expect(late, 'c1');
    });

    testWidgets('singular copy; a done row has no action', (tester) async {
      await _pump(
        tester,
        AwaySummary(
          rows: const [
            AwayRow(id: 'c1', title: 'Walk', cost: '−1 health', isDone: true),
          ],
          onDoneLate: (_) {},
          onClose: () {},
        ),
      );
      expect(
        find.text('While you were away, a deadline passed.'),
        findsOneWidget,
      );
      expect(find.text('Done late'), findsNothing);
    });
  });

  group('AccuracyLine', () {
    testWidgets('shows today and the week', (tester) async {
      await _pump(
        tester,
        const AccuracyLine(
          todayKept: 3,
          todayMade: 9,
          weekKept: 12,
          weekMade: 20,
        ),
      );
      expect(
        find.text('Today: 3 of 9 kept. This week: 12 of 20.'),
        findsOneWidget,
      );
    });

    testWidgets('no number for a day with no promises', (tester) async {
      await _pump(
        tester,
        const AccuracyLine(
          todayKept: 0,
          todayMade: 0,
          weekKept: 4,
          weekMade: 5,
        ),
      );
      expect(find.text('This week: 4 of 5.'), findsOneWidget);
    });

    testWidgets('nothing at all with no promises this week', (tester) async {
      await _pump(
        tester,
        const AccuracyLine(
          todayKept: 0,
          todayMade: 0,
          weekKept: 0,
          weekMade: 0,
        ),
      );
      expect(find.byType(Text), findsNothing);
    });
  });

  testWidgets('AwaySummary scrolls when many deadlines passed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: AwaySummary(
            rows: [
              for (var i = 0; i < 30; i++)
                AwayRow(id: 'c$i', title: 'Task $i', cost: '−1 health'),
            ],
            onDoneLate: (_) {},
            onClose: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

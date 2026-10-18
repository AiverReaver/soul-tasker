import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/ui/hall_of_relics.dart';
import 'package:hearthrise/ui/inscription_field.dart';
import 'package:hearthrise/ui/lesson_timeline.dart';
import 'package:hearthrise/ui/level_line.dart';
import 'package:hearthrise/ui/onboarding_page.dart';
import 'package:hearthrise/ui/relic_emblem.dart';
import 'package:hearthrise/ui/relic_tile.dart';
import 'package:hearthrise/ui/victory_numbers.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('RelicEmblem', () {
    testWidgets('each level paints and has its label', (tester) async {
      for (final w in Weathering.values) {
        await _pump(tester, RelicEmblem(weathering: w));
        expect(find.byKey(ValueKey('emblem-${w.name}')), findsOneWidget);
        expect(find.bySemanticsLabel(RelicEmblem.labelFor(w)), findsOneWidget);
      }
      expect(RelicEmblem.labelFor(Weathering.worn), 'A worn emblem');
    });

    test('more attempts, more marks; no rank word or red in the labels', () {
      final marks = [
        for (final w in Weathering.values)
          EmblemPainter(w, Biome.pharloom.palette).markCount,
      ];
      expect(marks, [...marks]..sort());
      expect(marks.toSet(), hasLength(4));
      for (final w in Weathering.values) {
        expect(
          RelicEmblem.labelFor(w).toLowerCase(),
          isNot(anyOf(contains('best'), contains('perfect'), contains('lvl'))),
        );
      }
      expect(Biome.pharloom.palette.shard, isNot(Biome.pharloom.palette.silk));
    });
  });

  group('VictoryNumbers', () {
    testWidgets('plural copy', (tester) async {
      await _pump(
        tester,
        const VictoryNumbers(attempts: 3, days: 12, effort: 48),
      );
      expect(find.text('3'), findsOneWidget); // the 88 px numeral
      expect(tester.widget<Text>(find.text('3')).style?.fontSize, 88);
      expect(find.text('attempts'), findsOneWidget);
      expect(find.text('12 days'), findsOneWidget);
      expect(find.text('48 embers of effort'), findsOneWidget);
    });

    testWidgets('singular copy, never "first try"', (tester) async {
      await _pump(
        tester,
        const VictoryNumbers(attempts: 1, days: 1, effort: 1),
      );
      expect(find.text('attempt'), findsOneWidget);
      expect(find.text('1 day'), findsOneWidget);
      expect(find.text('1 ember of effort'), findsOneWidget);
      expect(find.textContaining('first try'), findsNothing);
    });
  });

  group('LessonTimeline', () {
    testWidgets('rows in order with a quiet missed-day marker', (tester) async {
      await _pump(
        tester,
        const LessonTimeline(
          lessons: [
            LessonRow(attempt: 1, text: 'Started too late.'),
            LessonRow(attempt: 2, text: 'Rushed it.', isMissedDay: true),
          ],
        ),
      );
      expect(
        find.textContaining('Attempt 1. Started too late.'),
        findsOneWidget,
      );
      expect(find.textContaining('Attempt 2. Rushed it.'), findsOneWidget);
      expect(find.textContaining('a missed day'), findsOneWidget);
    });

    testWidgets('empty shows nothing', (tester) async {
      await _pump(tester, const LessonTimeline(lessons: []));
      expect(find.byType(Text), findsNothing);
    });
  });

  group('InscriptionField', () {
    testWidgets('fires onSaved with the text; counter shows the limit', (
      tester,
    ) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      String? saved;
      await _pump(
        tester,
        InscriptionField(controller: c, onSaved: (t) => saved = t),
      );
      expect(find.text('What did this fight make of you?'), findsOneWidget);
      expect(find.text('0 / $kInscriptionMax'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Patience.');
      await tester.tap(find.text('Save'));
      expect(saved, 'Patience.');
    });

    testWidgets('has no Save action without a callback', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await _pump(tester, InscriptionField(controller: c));
      expect(find.text('Save'), findsNothing);
    });
  });

  testWidgets('RelicTile shows name and date and fires onTap', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      RelicTile(
        name: 'Relic of The Certification',
        weathering: Weathering.worn,
        dateLabel: '5 Oct 2026',
        onTap: () => taps++,
      ),
    );
    expect(find.text('Relic of The Certification'), findsOneWidget);
    expect(find.text('5 Oct 2026'), findsOneWidget);
    await tester.tap(find.byType(RelicTile));
    expect(taps, 1);
  });

  group('HallOfRelics', () {
    testWidgets('empty state', (tester) async {
      await _pump(tester, HallOfRelics(entries: const [], onOpen: (_) {}));
      expect(
        find.text('No foes vanquished yet. The first relic awaits.'),
        findsOneWidget,
      );
    });

    testWidgets('filled, in the given order, opens by id', (tester) async {
      String? opened;
      await _pump(
        tester,
        HallOfRelics(
          entries: const [
            HallEntry(
              id: 'r2',
              name: 'Relic of B',
              weathering: Weathering.unmarked,
              dateLabel: 'today',
            ),
            HallEntry(
              id: 'r1',
              name: 'Relic of A',
              weathering: Weathering.scarred,
              dateLabel: 'earlier',
            ),
          ],
          onOpen: (id) => opened = id,
        ),
      );
      expect(
        tester.getTopLeft(find.text('Relic of B')).dy,
        lessThan(tester.getTopLeft(find.text('Relic of A')).dy),
      );
      await tester.tap(find.text('Relic of A'));
      expect(opened, 'r1');
    });
  });

  testWidgets('LevelLine shows level and distance', (tester) async {
    await _pump(tester, const LevelLine(level: 4, toNext: 12));
    expect(find.text('Level 4'), findsOneWidget);
    expect(find.text('12 embers to the next'), findsOneWidget);
    await _pump(tester, const LevelLine(level: 2, toNext: 1));
    expect(find.text('1 ember to the next'), findsOneWidget);
  });

  group('OnboardingPage', () {
    testWidgets('fires Next and Skip', (tester) async {
      var next = 0, skip = 0;
      await _pump(
        tester,
        OnboardingPage(
          line: 'Failing is fine.',
          body: const Text('body'),
          onNext: () => next++,
          onSkip: () => skip++,
        ),
      );
      expect(find.text('Failing is fine.'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.tap(find.text('Skip'));
      expect((next, skip), (1, 1));
    });

    testWidgets('last page says Begin, disabled when told', (tester) async {
      var next = 0;
      await _pump(
        tester,
        OnboardingPage(
          line: 'x',
          body: const SizedBox(),
          isLast: true,
          canAdvance: false,
          onNext: () => next++,
          onSkip: () {},
        ),
      );
      await tester.tap(find.text('Begin'), warnIfMissed: false);
      expect(next, 0);
      await _pump(
        tester,
        OnboardingPage(
          line: 'x',
          body: const SizedBox(),
          isLast: true,
          onNext: () => next++,
          onSkip: () {},
        ),
      );
      await tester.tap(find.text('Begin'));
      expect(next, 1);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/ui/diamond_pip.dart';
import 'package:hearthrise/ui/action_row.dart';
import 'package:hearthrise/ui/mood_choice.dart';
import 'package:hearthrise/ui/pick_toggle_row.dart';
import 'package:hearthrise/ui/tomorrow_pick_sheet.dart';
import 'package:hearthrise/ui/tomorrow_row.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  group('MoodChoice', () {
    Future<void> pump(
      WidgetTester tester, {
      int? selected,
      String? note,
      ValueChanged<int>? onChanged,
    }) => tester.pumpWidget(
      glassHost(
        MoodChoice(
          labels: const ['Fought well', 'Held on', 'I fell'],
          selected: selected,
          note: note,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );

    testWidgets('shows the labels and no note until one is picked', (
      tester,
    ) async {
      await pump(tester);
      for (final l in ['Fought well', 'Held on', 'I fell']) {
        expect(find.text(l), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('mood-note')), findsNothing);
    });

    testWidgets('the note shows, the pick is marked, taps report the index', (
      tester,
    ) async {
      int? tapped;
      await pump(
        tester,
        selected: 1,
        note: 'Holding on is a kind of winning.',
        onChanged: (i) => tapped = i,
      );
      expect(find.text('Holding on is a kind of winning.'), findsOneWidget);
      final held = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Held on',
        ),
      );
      expect(held.properties.selected, isTrue);
      await tester.tap(find.text('I fell'));
      expect(tapped, 2);
    });
  });

  group('TomorrowRow', () {
    Future<void> pump(
      WidgetTester tester,
      List<String> titles,
      VoidCallback on,
    ) => tester.pumpWidget(glassHost(TomorrowRow(titles: titles, onTap: on)));

    testWidgets('none chosen', (tester) async {
      await pump(tester, const [], () {});
      expect(find.text('Tomorrow’s tasks'), findsOneWidget);
      expect(find.text('0 of 3 chosen'), findsOneWidget);
    });

    testWidgets('lists the first titles and opens on tap', (tester) async {
      var taps = 0;
      await pump(tester, const ['Walk', 'Sit', 'Call'], () => taps++);
      expect(find.text('3 of 3 chosen · Walk, Sit'), findsOneWidget);
      await tester.tap(find.text('Tomorrow’s tasks'));
      expect(taps, 1);
    });
  });

  group('PickToggleRow', () {
    testWidgets('shows pips, title and subtitle; tap reports', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        glassHost(
          PickToggleRow(
            title: 'Walk',
            subtitle: 'Run · Heavy',
            pips: 2,
            isSelected: false,
            onTap: () => taps++,
          ),
        ),
      );
      expect(find.text('Walk'), findsOneWidget);
      expect(find.text('Run · Heavy'), findsOneWidget);
      expect(find.byType(DiamondPip), findsNWidgets(3)); // 2 weight + checkbox
      await tester.tap(find.text('Walk'));
      expect(taps, 1);
    });

    testWidgets('is marked selected for screen readers', (tester) async {
      await tester.pumpWidget(
        glassHost(
          PickToggleRow(
            title: 'Walk',
            subtitle: 'Run · Light',
            pips: 1,
            isSelected: true,
            onTap: () {},
          ),
        ),
      );
      final s = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Walk, Run · Light',
        ),
      );
      expect(s.properties.selected, isTrue);
    });
  });

  group('TomorrowPickSheet', () {
    const options = [
      PickOption(id: 'a', title: 'Walk', subtitle: 'Run · Light', pips: 1),
      PickOption(id: 'b', title: 'Sit', subtitle: 'Exam · Boss-tier', pips: 3),
    ];

    Future<void> pump(
      WidgetTester tester, {
      Set<String> picked = const {},
      String? flash,
      ValueChanged<String>? onToggle,
      VoidCallback? onSet,
    }) => tester.pumpWidget(
      glassHost(
        TomorrowPickSheet(
          options: options,
          picked: picked,
          flash: flash,
          onToggle: onToggle ?? (_) {},
          onSet: onSet ?? () {},
        ),
      ),
    );

    testWidgets('header, count, rows, flash and the set button', (
      tester,
    ) async {
      await pump(tester, picked: {'a'}, flash: 'Three is enough for one day.');
      expect(find.text('Tomorrow’s three'), findsOneWidget);
      expect(
        find.text(
          'Choose up to three tasks to face tomorrow. Keeping them is what counts.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tasks waiting'), findsOneWidget);
      expect(find.text('1 of 3 chosen'), findsOneWidget);
      expect(find.text('Walk'), findsOneWidget);
      expect(find.text('Three is enough for one day.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Set tomorrow'), findsOneWidget);
    });

    testWidgets('taps report the id and Set tomorrow fires', (tester) async {
      String? toggled;
      var set = 0;
      await pump(tester, onToggle: (id) => toggled = id, onSet: () => set++);
      // Called directly: the test font wraps the sheet taller than the screen.
      tester.widget<PickToggleRow>(find.byType(PickToggleRow).last).onTap();
      expect(toggled, 'b');
      tester.widget<ActionRow>(find.byType(ActionRow)).onTap();
      expect(set, 1);
    });
  });
}

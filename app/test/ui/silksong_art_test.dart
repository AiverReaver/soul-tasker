import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/bonfire_card.dart';
import 'package:hearthrise/ui/boss_art.dart';
import 'package:hearthrise/ui/boss_card_tile.dart';
import 'package:hearthrise/ui/carved_frame.dart';
import 'package:hearthrise/ui/silk_page_transition.dart';
import 'package:hearthrise/ui/ink_path.dart';
import 'package:hearthrise/ui/pharloom_backdrop.dart';
import 'package:hearthrise/ui/strike_sweep_view.dart';
import 'package:hearthrise/ui/task_row_tile.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('inkPath', () {
    test('reads absolute and relative lines and closes', () {
      expect(
        inkPath('M0 0L10 0L10 10z').getBounds(),
        const Rect.fromLTRB(0, 0, 10, 10),
      );
      expect(
        inkPath('M10 10h5v5H10z').getBounds(),
        const Rect.fromLTRB(10, 10, 15, 15),
      );
    });

    test('reads packed numbers and implicit repeats', () {
      // "l5-5 5 5": two relative lines after one command letter.
      expect(
        inkPath('M0 0l5-5 5 5').getBounds(),
        const Rect.fromLTRB(0, -5, 10, 0),
      );
      // A second cubic reuses "c"; the curve ends back at the start.
      final b = inkPath('M0 0c0-10 10-10 10 0 0 10-10 10-10 0z').getBounds();
      expect(b.left, closeTo(0, 0.01));
      expect(b.right, closeTo(10, 0.01));
    });

    test('jitter boils the line: seeds differ, the shape stays close', () {
      const d = 'M0 0L100 0L100 100L0 100z';
      final a = inkPath(d, jitter: 2, seed: 1).getBounds();
      final b = inkPath(d, jitter: 2, seed: 2).getBounds();
      expect(a, isNot(b));
      for (final r in [a, b]) {
        expect(r.left, closeTo(0, 2));
        expect(r.bottom, closeTo(100, 2));
      }
    });

    test('rejects text that is not a path', () {
      expect(() => inkPath('Z 4 4'), throwsFormatException);
    });
  });

  group('BossArt', () {
    testWidgets('draws, hidden from screen readers', (tester) async {
      await _pump(tester, const BossArt(boilFrame: 0));
      expect(find.byType(CustomPaint), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(BossArt),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    test('repaints when the line boils or a hit lands, not otherwise', () {
      const a = BossArtPainter(boilFrame: 0, hit: 0);
      expect(
        a.shouldRepaint(const BossArtPainter(boilFrame: 0, hit: 0)),
        false,
      );
      expect(a.shouldRepaint(const BossArtPainter(boilFrame: 1, hit: 0)), true);
      expect(a.shouldRepaint(const BossArtPainter(boilFrame: 0, hit: 1)), true);
    });
  });

  group('silk slash', () {
    test('beats run arc, full arc, hit-stop, shatter', () {
      expect(slashBeat(0.05), SlashBeat.arcRising);
      expect(slashBeat(0.2), SlashBeat.arcFull);
      expect(slashBeat(0.3), SlashBeat.hitStop);
      expect(slashBeat(0.6), SlashBeat.shatter);
      expect(slashBeat(1), SlashBeat.shatter);
    });

    test('the shake lives only early in the shatter and ends still', () {
      expect(strikeShake(0.2), Offset.zero);
      expect(strikeShake(0.3), Offset.zero); // hit-stop holds still
      expect(strikeShake(0.4), isNot(Offset.zero));
      expect(strikeShake(1), Offset.zero);
    });

    test('a boss-tier strike throws more flecks', () {
      expect(slashFlecks(true), greaterThan(slashFlecks(false)));
    });

    testWidgets('paints every beat without error', (tester) async {
      for (final t in [0.05, 0.2, 0.3, 0.5, 0.9]) {
        await _pump(
          tester,
          SizedBox(
            width: 300,
            height: 60,
            child: StrikeSweepView(progress: t, isBossTier: true),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  testWidgets('CarvedFrame wraps its child; a lit frame glows', (tester) async {
    BoxDecoration deco() =>
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(CarvedFrame),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;

    await _pump(tester, const CarvedFrame(child: Text('Inside')));
    expect(find.text('Inside'), findsOneWidget);
    expect(deco().boxShadow, isNull);

    await _pump(tester, const CarvedFrame(isLit: true, child: Text('Inside')));
    expect(deco().boxShadow, isNotEmpty);
  });

  group('carved cards', () {
    bool lit(WidgetTester tester) =>
        tester.widget<CarvedFrame>(find.byType(CarvedFrame)).isLit;

    testWidgets('a pinned boss card is lit and shows the boss portrait', (
      tester,
    ) async {
      Future<void> pump(bool pinned) => _pump(
        tester,
        BossCardTile(
          title: 'Gwyn',
          attemptNumber: 1,
          progressLabel: 'Phase 1 of 2',
          health: 1,
          isPinned: pinned,
          onTap: () {},
          onLongPress: () {},
        ),
      );
      await pump(true);
      expect(lit(tester), isTrue);
      expect(find.byType(BossArt), findsOneWidget);
      await pump(false);
      expect(lit(tester), isFalse);
    });

    testWidgets('the bonfire card is lit until you have rested', (
      tester,
    ) async {
      await _pump(tester, BonfireCard(isRested: false, onTap: () {}));
      expect(lit(tester), isTrue);
      await _pump(tester, BonfireCard(isRested: true, onTap: () {}));
      expect(lit(tester), isFalse);
    });
  });

  test('pages cross-fade on every platform, over the backdrop', () {
    final builders = buildTheme().pageTransitionsTheme.builders;
    expect(builders[TargetPlatform.android], isA<SilkPageTransitions>());
    expect(builders[TargetPlatform.iOS], isA<SilkPageTransitions>());
  });

  testWidgets('PharloomBackdrop paints behind its child', (tester) async {
    await _pump(
      tester,
      const SizedBox(
        width: 200,
        height: 400,
        child: PharloomBackdrop(drift: 0.3, child: Text('Above')),
      ),
    );
    expect(find.text('Above'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the slash is drawn at full strength over a struck row', (
    tester,
  ) async {
    const slash = Key('slash');
    await _pump(
      tester,
      const TaskRowTile(
        title: 'Draft',
        weightLabel: 'Heavy',
        isDone: true,
        progress: 1,
        sweep: SizedBox(key: slash),
      ),
    );
    expect(
      find.ancestor(
        of: find.byKey(slash),
        matching: find.byType(AnimatedOpacity),
      ),
      findsNothing,
    );
  });

  testWidgets('a task row glows porcelain once the charge is ready', (
    tester,
  ) async {
    Color edge(double progress) {
      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(TaskRowTile),
              matching: find.byType(Container),
            )
            .first,
      );
      return ((box.decoration! as BoxDecoration).border! as Border).top.color;
    }

    await _pump(
      tester,
      const TaskRowTile(
        title: 'Draft',
        weightLabel: 'Heavy',
        isDone: false,
        progress: 0.5,
      ),
    );
    expect(edge(0.5), isNot(kDust));

    await _pump(
      tester,
      const TaskRowTile(
        title: 'Draft',
        weightLabel: 'Heavy',
        isDone: false,
        progress: 0.9,
      ),
    );
    expect(edge(0.9), kDust);
  });
}

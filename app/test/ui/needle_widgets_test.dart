import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/diamond_pip.dart';
import 'package:hearthrise/ui/needle_frame.dart';
import 'package:hearthrise/ui/shard_meter.dart';
import 'package:hearthrise/ui/thread_divider.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    home: Scaffold(body: Center(child: child)),
  ),
);

final _p = Biome.pharloom.palette;

void main() {
  group('NeedleFrame', () {
    for (final (tier, radius) in [
      (Cut.lg, 8.0),
      (Cut.md, 6.0),
      (Cut.sm, 4.0),
    ]) {
      testWidgets('tier $radius clips to a $radius px radius', (tester) async {
        await _pump(tester, NeedleFrame(tier: tier, child: const Text('x')));
        final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
        expect(clip.borderRadius, BorderRadius.circular(radius - 1));
      });
    }

    testWidgets('edge is seam at rest and takes the state colour', (
      tester,
    ) async {
      Color edge() =>
          (tester
                      .widget<DecoratedBox>(
                        find.byKey(const ValueKey('needle-edge')),
                      )
                      .decoration
                  as BoxDecoration)
              .color!;
      await _pump(tester, const NeedleFrame(child: Text('x')));
      expect(edge(), _p.seam);
      await _pump(tester, NeedleFrame(edge: _p.silk, child: const Text('x')));
      expect(edge(), _p.silk);
    });

    testWidgets('focus is a 2 px bone ring outside the clip', (tester) async {
      await _pump(tester, const NeedleFrame(child: Text('x')));
      expect(find.byKey(const ValueKey('needle-focus')), findsNothing);
      await _pump(tester, const NeedleFrame(isFocused: true, child: Text('x')));
      final ring = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('needle-focus')),
      );
      final border = (ring.decoration as BoxDecoration).border! as Border;
      expect(border.top.width, 2);
      expect(border.top.color, _p.bone);
    });
  });

  group('ShardMeter', () {
    testWidgets('12 shards, `filled` of them lit, spoken label', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(width: 300, child: ShardMeter(filled: 7)),
      );
      expect(find.byKey(const ValueKey('shard-on')), findsNWidgets(7));
      expect(find.byKey(const ValueKey('shard-off')), findsNWidgets(5));
      expect(find.bySemanticsLabel('Boss health 7 of 12'), findsOneWidget);
    });
  });

  testWidgets('DiamondPip is a rotated square in the given colour', (
    tester,
  ) async {
    await _pump(tester, DiamondPip(color: _p.silk));
    final t = tester.widget<Transform>(
      find.descendant(
        of: find.byType(DiamondPip),
        matching: find.byType(Transform),
      ),
    );
    expect(t.transform.getRotation().entry(0, 1).abs(), greaterThan(0.5));
    expect(find.byType(ColoredBox), findsWidgets);
  });

  testWidgets('ThreadDivider has a centre diamond', (tester) async {
    await _pump(tester, const SizedBox(width: 200, child: ThreadDivider()));
    expect(find.byType(DiamondPip), findsOneWidget);
  });

  test('type: Hanken body, label 12 / +1.6', () {
    final t = buildTheme().textTheme;
    expect(t.bodyMedium?.fontFamily, 'HankenGrotesk');
    expect(t.labelSmall?.fontSize, 12);
    expect(t.labelSmall?.letterSpacing, 1.6);
  });
}

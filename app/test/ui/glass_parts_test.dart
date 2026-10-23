import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/glass_circle_button.dart';
import 'package:hearthrise/ui/glass_pill_button.dart';
import 'package:hearthrise/ui/glass_surface.dart';
import 'package:hearthrise/ui/glass_tap_target.dart';
import 'package:hearthrise/ui/stroke_icon.dart';
import 'package:material_ui/material_ui.dart';

import 'glass_host.dart';

void main() {
  group('StrokeIcon', () {
    testWidgets('draws at its size and lays out without a child', (
      tester,
    ) async {
      await tester.pumpWidget(
        glassHost(
          const StrokeIcon(path: StrokeIcons.back, color: Colors.white),
        ),
      );
      expect(tester.getSize(find.byType(StrokeIcon)), const Size.square(22));
    });
  });

  group('GlassTapTarget', () {
    testWidgets('has a 48 px hit area round a smaller child and taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        glassHost(
          GlassTapTarget(
            semanticLabel: 'Back',
            onTap: () => taps++,
            child: const SizedBox.square(dimension: 44),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(GlassTapTarget)),
        const Size.square(48),
      );
      await tester.tapAt(
        tester.getTopLeft(find.byType(GlassTapTarget)) + const Offset(1, 1),
      );
      expect(taps, 1);
    });

    testWidgets('is a labelled semantics button', (tester) async {
      await tester.pumpWidget(
        glassHost(
          GlassTapTarget(
            semanticLabel: 'Back',
            onTap: () {},
            child: const SizedBox.square(dimension: 44),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Back')),
        matchesSemantics(label: 'Back', isButton: true, hasTapAction: true),
      );
    });

    testWidgets('reports press and release', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        glassHost(
          GlassTapTarget(
            semanticLabel: 'Back',
            onTap: () {},
            onPressChanged: log.add,
            child: const SizedBox.square(dimension: 44),
          ),
        ),
      );
      final g = await tester.startGesture(
        tester.getCenter(find.byType(GlassTapTarget)),
      );
      await tester.pump();
      await g.up();
      await tester.pump();
      expect(log, [true, false]);
    });
  });

  group('GlassCircleButton', () {
    testWidgets('is a 44 px glass circle in a 48 px target that taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        glassHost(
          GlassCircleButton(
            icon: StrokeIcons.back,
            semanticLabel: 'Back',
            onTap: () => taps++,
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(GlassTapTarget)),
        const Size.square(48),
      );
      expect(tester.getSize(find.byType(GlassSurface)), const Size.square(44));
      await tester.tap(find.byType(GlassCircleButton));
      expect(taps, 1);
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
    });

    testWidgets('tint and press pass through to the glass', (tester) async {
      await tester.pumpWidget(
        glassHost(
          GlassCircleButton(
            icon: StrokeIcons.more,
            semanticLabel: 'Boss actions',
            onTap: () {},
            isPressed: true,
            isTinted: true,
          ),
        ),
      );
      final s = tester.widget<GlassSurface>(find.byType(GlassSurface));
      expect(s.isPressed, isTrue);
      expect(s.isTinted, isTrue);
    });
  });

  group('GlassPillButton', () {
    testWidgets('is a 44 px stadium with its label, and taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        glassHost(GlassPillButton(label: 'Cancel', onTap: () => taps++)),
      );
      expect(tester.getSize(find.byType(GlassSurface)).height, 44);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Cancel')),
        matchesSemantics(label: 'Cancel', isButton: true, hasTapAction: true),
      );
    });
  });

  test(
    'palette is reachable',
    () => expect(Biome.pharloom.palette.glassKey, isNotNull),
  );
}

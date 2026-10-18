import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/glass_surface.dart';
import 'package:material_ui/material_ui.dart';

const _box = SizedBox(width: 100, height: 100);

Widget _host(Widget child, {bool highContrast = false}) => MaterialApp(
  theme: buildTheme(),
  home: MediaQuery(
    data: MediaQueryData(highContrast: highContrast),
    child: Scaffold(body: Center(child: child)),
  ),
);

Finder get _fill => find.byKey(const ValueKey('glass-fill'));
Color _fillColor(WidgetTester t) => t.widget<ColoredBox>(_fill).color;

void main() {
  final p = Biome.pharloom.palette;

  group('shapes clip their child and their hits', () {
    for (final (name, shape) in [
      ('circle', const GlassShape.circle()),
      ('stadium', const GlassShape.stadium()),
      ('rounded 8', GlassShape.rounded(8)),
    ]) {
      testWidgets(name, (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          _host(
            GestureDetector(
              onTap: () => taps++,
              child: GlassSurface(
                shape: shape,
                child: const ColoredBox(color: Colors.red, child: _box),
              ),
            ),
          ),
        );
        expect(find.byType(ClipPath), findsOneWidget);
        final box = find.byType(GlassSurface);
        await tester.tapAt(tester.getCenter(box));
        expect(taps, 1);
        if (name != 'rounded 8') {
          // The corner of the bounding box lies outside a circle or stadium.
          await tester.tapAt(tester.getTopLeft(box) + const Offset(2, 2));
          expect(taps, 1);
        }
      });
    }
  });

  group('backdrop', () {
    testWidgets('one BackdropFilter by default', (tester) async {
      await tester.pumpWidget(
        _host(const GlassSurface(shape: GlassShape.circle(), child: _box)),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('none with blur 0', (tester) async {
      await tester.pumpWidget(
        _host(
          const GlassSurface(shape: GlassShape.circle(), blur: 0, child: _box),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('high contrast: no filter, a flat shell fill', (tester) async {
      await tester.pumpWidget(
        _host(
          const GlassSurface(shape: GlassShape.circle(), child: _box),
          highContrast: true,
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      expect(_fillColor(tester), p.shell);
    });
  });

  group('fill and press', () {
    testWidgets('rests on glassFill', (tester) async {
      await tester.pumpWidget(
        _host(const GlassSurface(shape: GlassShape.circle(), child: _box)),
      );
      expect(_fillColor(tester), p.glassFill);
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    });

    testWidgets('pressed scales to 1.04 over 350 ms and brightens', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const GlassSurface(
            shape: GlassShape.circle(),
            isPressed: true,
            child: _box,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, 1.04);
      expect(scale.duration, const Duration(milliseconds: 350));
      expect(scale.curve, Curves.easeOutBack);
      expect(_fillColor(tester), p.glassFillHi);
    });

    testWidgets('tinted fills with silk at 55%', (tester) async {
      await tester.pumpWidget(
        _host(
          const GlassSurface(
            shape: GlassShape.circle(),
            isTinted: true,
            child: _box,
          ),
        ),
      );
      expect(_fillColor(tester), p.silk.withValues(alpha: .55));
    });

    testWidgets('reduced motion removes the press animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: GlassSurface(
              shape: GlassShape.circle(),
              isPressed: true,
              child: _box,
            ),
          ),
        ),
      );
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
        Duration.zero,
      );
    });
  });

  group('GlassPainter', () {
    final tilt = ValueNotifier(Offset.zero);
    GlassPainter painter({Color? key, ValueListenable<Offset>? t}) =>
        GlassPainter(
          border: const CircleBorder(),
          keyColor: key ?? p.glassKey,
          lightColor: p.glassLight,
          tilt: t ?? tilt,
        );

    test('repaints when a colour changes, not for the same values', () {
      expect(painter().shouldRepaint(painter()), isFalse);
      expect(
        painter(key: const Color(0xFF123456)).shouldRepaint(painter()),
        isTrue,
      );
    });

    testWidgets('a tilt change repaints the painter, not the builders', (
      tester,
    ) async {
      var builds = 0;
      final moving = ValueNotifier(Offset.zero);
      await tester.pumpWidget(
        _host(
          GlassSurface(
            shape: const GlassShape.circle(),
            tilt: moving,
            child: Builder(
              builder: (_) {
                builds++;
                return _box;
              },
            ),
          ),
        ),
      );
      moving.value = const Offset(.5, -.5);
      await tester.pump();
      moving.value = const Offset(-.5, .5);
      await tester.pump();
      expect(builds, 1);
    });
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/glass_tilt.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('idleTilt', () {
    test('starts at (0, 0.5) and follows sin and cos', () {
      expect(idleTilt(Duration.zero), const Offset(0, 0.5));
      final t = idleTilt(const Duration(seconds: 3));
      expect(t.dx, closeTo(0.8 * 0.8632, 1e-3)); // 0.8 * sin(2.1)
      expect(t.dy, closeTo(0.5 * 0.0707, 1e-3)); // 0.5 * cos(1.5)
    });

    test('never leaves -1 to 1 on either axis', () {
      for (var ms = 0; ms < 120000; ms += 250) {
        final t = idleTilt(Duration(milliseconds: ms));
        expect(t.dx.abs(), lessThanOrEqualTo(1));
        expect(t.dy.abs(), lessThanOrEqualTo(1));
      }
    });
  });

  group('easeTilt', () {
    test('closes 12% of the gap in one 60 Hz frame', () {
      final next = easeTilt(
        Offset.zero,
        const Offset(1, -1),
        const Duration(microseconds: 16667),
      );
      expect(next.dx, closeTo(0.12, 1e-3));
      expect(next.dy, closeTo(-0.12, 1e-3));
    });

    test('takes the same path at 30 Hz as two 60 Hz frames', () {
      const target = Offset(0.6, 0.2);
      const frame = Duration(microseconds: 16667);
      final two = easeTilt(easeTilt(Offset.zero, target, frame), target, frame);
      final one = easeTilt(Offset.zero, target, frame * 2);
      expect(one.dx, closeTo(two.dx, 1e-3));
    });

    test('a zero step stays put', () {
      expect(
        easeTilt(const Offset(.3, .3), Offset.zero, Duration.zero),
        const Offset(.3, .3),
      );
    });
  });

  group('GlassTilt.of', () {
    testWidgets('is a still zero with no GlassTilt above', (tester) async {
      late ValueListenable<Offset> tilt;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            tilt = GlassTilt.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(tilt.value, Offset.zero);
    });

    testWidgets('reads the notifier above and rebuilds nothing by itself', (
      tester,
    ) async {
      final source = ValueNotifier(const Offset(.5, -.5));
      late ValueListenable<Offset> tilt;
      var builds = 0;
      await tester.pumpWidget(
        GlassTilt(
          notifier: source,
          child: Builder(
            builder: (context) {
              builds++;
              tilt = GlassTilt.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tilt.value, const Offset(.5, -.5));
      source.value = const Offset(.1, .1);
      await tester.pump();
      expect(tilt.value, const Offset(.1, .1));
      expect(builds, 1);
    });
  });
}

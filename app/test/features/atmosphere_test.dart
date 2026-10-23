import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/glass_tilt.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/features/boss/boss_stage.dart';
import 'package:hearthrise/features/shell/atmosphere.dart';
import 'package:hearthrise/features/shell/tilt_controller.dart';
import 'package:hearthrise/ui/boss_art.dart';
import 'package:hearthrise/ui/pharloom_backdrop.dart';
import 'package:material_ui/material_ui.dart';

import 'shell/tilt_controller_test.dart' show FakeTiltSource;

void main() {
  int? frame;
  Widget probe() => Builder(
    builder: (context) {
      frame = Atmosphere.boilFrameOf(context);
      return const SizedBox();
    },
  );

  testWidgets('a still atmosphere holds the boil on one frame and settles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Atmosphere(isStill: true, child: probe())),
    );
    await tester.pumpAndSettle();
    expect(frame, 0);
  });

  testWidgets('a live atmosphere boils the ink through its frames', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Atmosphere(child: probe())));
    final first = frame;
    await tester.pump(const Duration(milliseconds: 150));
    expect(frame, isNot(first));
    await tester.pumpWidget(const SizedBox()); // stop the ticker
  });

  testWidgets('the ambient clock changes at most 30 times a second', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Atmosphere(child: probe())));
    final seen = <double>{};
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      seen.add(
        tester.widget<PharloomBackdrop>(find.byType(PharloomBackdrop)).drift,
      );
    }
    expect(seen.length, lessThanOrEqualTo(32));
    await tester.pumpWidget(const SizedBox()); // stop the ticker
  });

  testWidgets('reduced motion stills the atmosphere', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Atmosphere(child: probe()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(frame, 0);
  });

  group('glass tilt', () {
    Offset? tilt;
    Widget tiltProbe() => Builder(
      builder: (context) {
        final source = GlassTilt.of(context);
        return ValueListenableBuilder<Offset>(
          valueListenable: source,
          builder: (_, value, _) {
            tilt = value;
            return const SizedBox();
          },
        );
      },
    );

    testWidgets('a still atmosphere keeps the tilt at zero for 10 s', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Atmosphere(isStill: true, child: tiltProbe())),
      );
      await tester.pump(const Duration(seconds: 10));
      expect(tilt, Offset.zero);
    });

    testWidgets('reduced motion keeps the tilt at zero', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Atmosphere(child: tiltProbe()),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 10));
      expect(tilt, Offset.zero);
    });

    testWidgets(
      'a live atmosphere with no phone motion keeps the light still',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Atmosphere(child: tiltProbe())),
        );
        for (var i = 0; i < 180; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(tilt, Offset.zero);
        }
        await tester.pumpWidget(const SizedBox()); // stop the tickers
      },
    );
  });

  group('motion tilt', () {
    Offset? tilt;
    late FakeTiltSource source;
    setUp(() => source = FakeTiltSource());

    Widget host({bool disableAnimations = false, bool motionEffects = true}) =>
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: Atmosphere(
              tiltSource: source,
              motionEffects: motionEffects,
              child: Builder(
                builder: (context) => ValueListenableBuilder<Offset>(
                  valueListenable: GlassTilt.of(context),
                  builder: (_, v, _) {
                    tilt = v;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );

    Future<void> feed(WidgetTester tester, Gravity g, int frames) async {
      for (var i = 0; i < frames; i++) {
        if (i % 4 == 0) source.controller.add(g);
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    testWidgets('phone motion steers the shared tilt', (tester) async {
      await tester.pumpWidget(host());
      await feed(tester, (0.0, 6.3, 7.5), 90);
      await feed(tester, (3.7, 6.3, 7.5), 150);
      expect(tilt!.dx, greaterThan(0.6));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a listening phone held still leaves the light at rest', (
      tester,
    ) async {
      await tester.pumpWidget(host());
      await feed(tester, (0.0, 6.3, 7.5), 300);
      expect(tilt, Offset.zero);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('reduced motion never listens, and the tilt stays zero', (
      tester,
    ) async {
      await tester.pumpWidget(host(disableAnimations: true));
      expect(source.isListening, isFalse);
      await tester.pump(const Duration(seconds: 3));
      expect(tilt, Offset.zero);
    });

    testWidgets('the Motion effects setting off: no listener, no drift', (
      tester,
    ) async {
      await tester.pumpWidget(host(motionEffects: false));
      expect(source.isListening, isFalse);
      await tester.pump(const Duration(seconds: 3));
      expect(tilt, Offset.zero);
    });

    testWidgets('pausing the app cancels the sensor; resuming listens', (
      tester,
    ) async {
      await tester.pumpWidget(host());
      expect(source.isListening, isTrue);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(source.isListening, isFalse);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(source.isListening, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  });

  testWidgets('a struck boss flashes white, then recovers', (tester) async {
    Future<void> stage(double health) => tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(body: BossStage(health: health)),
      ),
    );
    double hit() => tester.widget<BossArt>(find.byType(BossArt)).hit;

    await stage(1);
    expect(hit(), 0);

    // The flash waits for the row's slash to reach its hit-stop.
    await stage(0.5);
    await tester.pump(const Duration(milliseconds: 30));
    expect(hit(), 0);
    await tester.pump(const Duration(milliseconds: 170));
    expect(hit(), 1);

    await tester.pumpAndSettle();
    expect(hit(), 0);
  });
}

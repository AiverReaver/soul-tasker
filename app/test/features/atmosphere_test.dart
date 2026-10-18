import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/glass_tilt.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/features/boss/boss_stage.dart';
import 'package:hearthrise/features/shell/atmosphere.dart';
import 'package:hearthrise/ui/boss_art.dart';
import 'package:material_ui/material_ui.dart';

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

    testWidgets('a live atmosphere drifts the tilt within -1 to 1', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Atmosphere(child: tiltProbe())),
      );
      for (var i = 0; i < 180; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tilt!.dx.abs(), lessThanOrEqualTo(1));
        expect(tilt!.dy.abs(), lessThanOrEqualTo(1));
      }
      expect(tilt, isNot(Offset.zero));
      await tester.pumpWidget(const SizedBox()); // stop the tickers
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

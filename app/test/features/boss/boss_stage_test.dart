import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/features/boss/boss_stage.dart';
import 'package:hearthrise/ui/boss_art.dart';
import 'package:material_ui/material_ui.dart';

Widget _stage({
  bool stamp = false,
  bool felled = false,
  bool reduceMotion = false,
  Biome biome = Biome.pharloom,
}) => MaterialApp(
  theme: buildTheme(biome),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(
      body: BossStage(health: 1, stamp: stamp, felled: felled),
    ),
  ),
);

double _angle(WidgetTester t, Key key) {
  final m = t.widget<Transform>(find.byKey(key)).transform.storage;
  return math.atan2(m[1], m[0]);
}

const _stampRotate = ValueKey('boss-stamp-rotate');
const _stampScale = ValueKey('boss-stamp-scale');
const _felled = ValueKey('boss-felled');

void main() {
  group('Struck stamp', () {
    testWidgets('is absent until asked for', (tester) async {
      await tester.pumpWidget(_stage());
      expect(find.text('Struck'), findsNothing);
    });

    testWidgets('lands from 1.6 at -8 degrees to rest at -5 degrees', (
      tester,
    ) async {
      await tester.pumpWidget(_stage());
      await tester.pumpWidget(_stage(stamp: true));
      expect(find.text('Struck'), findsNWidgets(2)); // outline and fill
      expect(_angle(tester, _stampRotate), closeTo(-8 * math.pi / 180, 1e-3));
      expect(
        tester.widget<Transform>(find.byKey(_stampScale)).transform.storage[0],
        closeTo(1.6, 1e-3),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 1));
      expect(_angle(tester, _stampRotate), closeTo(-5 * math.pi / 180, 1e-3));
      expect(
        tester.widget<Transform>(find.byKey(_stampScale)).transform.storage[0],
        closeTo(1, 1e-3),
      );
    });

    testWidgets('moves in held steps, not a glide', (tester) async {
      await tester.pumpWidget(_stage());
      await tester.pumpWidget(_stage(stamp: true));
      double scale() => tester
          .widget<Transform>(find.byKey(_stampScale))
          .transform
          .storage[0];
      await tester.pump(const Duration(milliseconds: 20));
      final first = scale();
      await tester.pump(const Duration(milliseconds: 100)); // still step 1
      expect(scale(), first);
      await tester.pump(const Duration(milliseconds: 100)); // step 2
      expect(scale(), isNot(first));
    });

    testWidgets('reduced motion shows it at rest at once', (tester) async {
      await tester.pumpWidget(_stage(reduceMotion: true));
      await tester.pumpWidget(_stage(stamp: true, reduceMotion: true));
      expect(_angle(tester, _stampRotate), closeTo(-5 * math.pi / 180, 1e-3));
    });
  });

  group('kneel', () {
    double opacity(WidgetTester t) =>
        t.widget<Opacity>(find.byKey(_felled)).opacity;

    testWidgets('a standing boss is fully opaque', (tester) async {
      await tester.pumpWidget(_stage());
      expect(opacity(tester), 1);
    });

    testWidgets('felled ends at 50% opacity after 1.4 s in 7 steps', (
      tester,
    ) async {
      await tester.pumpWidget(_stage());
      await tester.pumpWidget(_stage(felled: true));
      final seen = <double>{};
      for (var i = 0; i < 90; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        seen.add(opacity(tester));
      }
      expect(opacity(tester), 0.5);
      expect(seen.length, lessThanOrEqualTo(8)); // 7 held steps plus the start
    });

    testWidgets('reduced motion kneels at once', (tester) async {
      await tester.pumpWidget(_stage(reduceMotion: true));
      await tester.pumpWidget(_stage(felled: true, reduceMotion: true));
      expect(opacity(tester), 0.5);
    });
  });

  group('hit flash', () {
    for (final biome in [Biome.pharloom, Biome.choral]) {
      testWidgets('${biome.label}: paints the whole figure in mask', (
        tester,
      ) async {
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildTheme(biome),
            home: RepaintBoundary(
              key: key,
              child: const ColoredBox(
                color: Colors.transparent,
                child: BossArt(boilFrame: 0, hit: 1, width: 200),
              ),
            ),
          ),
        );
        late ByteData bytes;
        await tester.runAsync(() async {
          final r =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final img = await r.toImage();
          bytes = (await img.toByteData())!;
        });
        final mask = biome.palette.mask;
        var solid = 0;
        for (var i = 0; i < bytes.lengthInBytes; i += 4) {
          if (bytes.getUint8(i + 3) != 255) continue;
          solid++;
          expect(bytes.getUint8(i), (mask.r * 255).round(), reason: 'red');
          expect(
            bytes.getUint8(i + 1),
            (mask.g * 255).round(),
            reason: 'green',
          );
          expect(bytes.getUint8(i + 2), (mask.b * 255).round(), reason: 'blue');
        }
        expect(solid, greaterThan(500));
      });
    }
  });
}

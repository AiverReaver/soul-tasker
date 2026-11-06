import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/boss_art.dart';
import 'package:material_ui/material_ui.dart';

final _p = Biome.pharloom.palette;

/// The painter's pixels, so two drawings can be told apart.
Future<Uint8List> _pixels(BossArtPainter painter) async {
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), const Size(200, 180));
  final image = await recorder.endRecording().toImage(200, 180);
  final bytes = await image.toByteData();
  return bytes!.buffer.asUint8List();
}

BossArtPainter _painter(BossDesign d, {double seconds = 0, double hit = 0}) =>
    BossArtPainter(
      design: d,
      boilFrame: 0,
      seconds: seconds,
      hit: hit,
      palette: _p,
    );

void main() {
  test('the cast is the eight approved bosses', () {
    expect(BossDesign.values.map((d) => d.name), [
      'porcelain',
      'grafted',
      'rotBloom',
      'matron',
      'host',
      'wyrm',
      'lightless',
      'blister',
    ]);
  });

  group('bossDesignFor', () {
    test('the same boss always wears the same design', () {
      expect(bossDesignFor('b-42'), bossDesignFor('b-42'));
    });

    test('a roster of bosses wears every design', () {
      final worn = {for (var i = 0; i < 200; i++) bossDesignFor('boss-$i')};
      expect(worn, BossDesign.values.toSet());
    });
  });

  group('designs', () {
    testWidgets('no two designs draw the same figure', (tester) async {
      await tester.runAsync(() async {
        final seen = <String>{};
        for (final d in BossDesign.values) {
          final px = await _pixels(_painter(d));
          expect(seen.add(String.fromCharCodes(px)), true, reason: d.name);
        }
      });
    });

    testWidgets('every design moves while idle', (tester) async {
      await tester.runAsync(() async {
        for (final d in BossDesign.values) {
          final a = await _pixels(_painter(d));
          final b = await _pixels(_painter(d, seconds: 1.3));
          expect(a, isNot(b), reason: d.name);
        }
      });
    });

    testWidgets('a landed hit burns every design to the mask colour', (
      tester,
    ) async {
      await tester.runAsync(() async {
        for (final d in BossDesign.values) {
          final a = await _pixels(_painter(d));
          final b = await _pixels(_painter(d, hit: 1));
          expect(a, isNot(b), reason: d.name);
        }
      });
    });

    test('repaints when the design or the idle clock changes', () {
      final a = _painter(BossDesign.porcelain);
      expect(a.shouldRepaint(_painter(BossDesign.porcelain)), false);
      expect(a.shouldRepaint(_painter(BossDesign.grafted)), true);
      expect(a.shouldRepaint(_painter(BossDesign.porcelain, seconds: 1)), true);
    });

    testWidgets('BossArt hands its design and clock to the painter', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: const Center(
            child: BossArt(boilFrame: 0, design: BossDesign.wyrm, seconds: 2),
          ),
        ),
      );
      final painter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((c) => c.painter)
          .whereType<BossArtPainter>()
          .single;
      expect(painter.design, BossDesign.wyrm);
      expect(painter.seconds, 2);
    });
  });
}

// Screen goldens: each main screen in each biome at 393 x 852 pt (1 px = 1 pt,
// the same size as docs/ui-tour/shots), so a design board can sit beside it.
// Update after an approved visual change:
//   flutter test --tags golden --update-goldens
@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/palette.dart';
import 'package:material_ui/material_ui.dart';

import '../data/harness.dart';
import '../features/pump.dart';

void main() {
  for (final biome in Biome.values) {
    group(biome.name, () {
      for (final (name, location) in const [
        ('home', '/'),
        ('today', '/today'),
        ('bonfire', '/bonfire'),
        ('profile', '/profile'),
        ('bosses', '/bosses'),
        ('settings', '/settings'),
        ('boss', null), // the seeded boss
      ]) {
        testWidgets(name, (tester) async {
          tester.view
            ..physicalSize = const Size(393, 852)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final h = Harness();
          final view = await h.seed();
          await h.settings.setBiome(biome);
          await pumpApp(
            tester,
            h,
            location: location ?? '/boss/${view.boss.id}',
          );
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/${biome.name}/$name.png'),
          );
          await tearDownApp(tester, h);
        });
      }
    });
  }
}

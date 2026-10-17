import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:material_ui/material_ui.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('the palette is Pharloom night: violet-black ground, silk crimson', () {
    expect(kBackground, const Color(0xFF09060C));
    expect(kEmber, const Color(0xFFE8566D));
    expect(kBossHealth, const Color(0xFFE9DFCB)); // mask ivory shards
  });

  test('every text token keeps 4.5:1 on the ground and on surfaces', () {
    for (final ink in [kAsh, kTextMuted, kEmber, kDust]) {
      for (final ground in [kBackground, kSurface, kSelected]) {
        expect(_contrast(ink, ground), greaterThanOrEqualTo(4.5));
      }
    }
  });

  test('boss health shards keep 3:1 as a UI component', () {
    expect(_contrast(kBossHealth, kBackground), greaterThanOrEqualTo(3));
  });

  test('display styles are porcelain; body stays bone', () {
    final text = buildTheme().textTheme;
    expect(text.displaySmall?.color, kDust);
    expect(text.titleMedium?.color, kDust);
    expect(text.bodyMedium?.color, kAsh);
  });
}

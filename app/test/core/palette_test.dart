import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:material_ui/material_ui.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('pharloom keeps the shipped values', () {
    final p = Biome.pharloom.palette;
    expect(p.void_, const Color(0xFF09060C));
    expect(p.silk, const Color(0xFFE8566D));
    expect(p.shard, const Color(0xFFE9DFCB));
    expect(p.shell, const Color(0xFF130E17));
    expect(p.bone, const Color(0xFFF4EBDD));
    expect(p.text, const Color(0xFFE6DDCB));
    expect(p.ash, const Color(0xFFA79BA6));
  });

  test('lerp hits both ends; copyWith replaces only what is passed', () {
    final a = Biome.pharloom.palette, b = Biome.moss.palette;
    expect(a.lerp(b, 0).silk, a.silk);
    expect(a.lerp(b, 1).silk, b.silk);
    expect(a.lerp(b, 1).void_, b.void_);
    final c = a.copyWith(silk: const Color(0xFF123456));
    expect(c.silk, const Color(0xFF123456));
    expect(c.shell, a.shell);
  });

  test('buildTheme carries the palette and bone/text colors', () {
    final theme = buildTheme(Biome.pharloom);
    expect(theme.extension<HearthPalette>(), isNotNull);
    expect(theme.textTheme.displaySmall?.color, Biome.pharloom.palette.bone);
    expect(theme.textTheme.titleMedium?.color, Biome.pharloom.palette.bone);
    expect(theme.textTheme.bodyMedium?.color, Biome.pharloom.palette.text);
  });

  test('light biomes are Choral and Moss; the rest are dark', () {
    for (final b in Biome.values) {
      final light = b == Biome.choral || b == Biome.moss;
      expect(b.brightness, light ? Brightness.light : Brightness.dark);
      expect(buildTheme(b).brightness, b.brightness);
    }
  });

  test('silk hex per biome is pinned', () {
    expect(Biome.docks.palette.silk, const Color(0xFFFF7A2E));
    expect(Biome.choral.palette.silk, const Color(0xFF94640F));
    expect(Biome.moss.palette.silk, const Color(0xFF3D6B2C));
    expect(Biome.greymoor.palette.silk, const Color(0xFF7FB2D9));
  });

  group('contrast', () {
    for (final b in Biome.values) {
      final p = b.palette;
      test('${b.label}: text and ash 4.5:1 on shell, raised, void', () {
        for (final ink in [p.text, p.ash]) {
          for (final ground in [p.shell, p.raised, p.void_]) {
            expect(_contrast(ink, ground), greaterThanOrEqualTo(4.5));
          }
        }
      });
      test('${b.label}: shard 3:1 on shell, onSilk 4.5:1 on silk', () {
        expect(_contrast(p.shard, p.shell), greaterThanOrEqualTo(3));
        expect(_contrast(p.onSilk, p.silk), greaterThanOrEqualTo(4.5));
      });
    }
  });
}

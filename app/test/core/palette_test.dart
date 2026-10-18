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

  group('glass tokens', () {
    Color white(double a) => Color.fromARGB((a * 255).round(), 255, 255, 255);
    Color c(int rgb, double a) => Color((((a * 255).round()) << 24) | rgb);
    final dark = [Biome.pharloom, Biome.docks, Biome.greymoor];
    const keys = {
      Biome.pharloom: Color(0xFF050307),
      Biome.docks: Color(0xFF050302),
      Biome.choral: Color(0xFF2A1E0F),
      Biome.moss: Color(0xFF1C2A1A),
      Biome.greymoor: Color(0xFF04070A),
    };

    test('each biome pins its four glass values', () {
      for (final b in Biome.values) {
        final p = b.palette;
        expect(p.glassKey, keys[b], reason: b.label);
        if (dark.contains(b)) {
          expect(p.glassFill, white(0.08), reason: b.label);
          expect(p.glassFillHi, white(0.16), reason: b.label);
          expect(p.glassLight, c(0xFFF8EC, 0.85), reason: b.label);
        }
      }
      expect(Biome.choral.palette.glassFill, c(0xFFFAF0, 0.6));
      expect(Biome.choral.palette.glassFillHi, c(0xFFFAF0, 0.9));
      expect(Biome.choral.palette.glassLight, white(0.95));
      expect(Biome.moss.palette.glassFill, c(0xFBFDF5, 0.6));
      expect(Biome.moss.palette.glassFillHi, c(0xFBFDF5, 0.9));
      expect(Biome.moss.palette.glassLight, white(0.95));
    });

    test('lerp blends the glass fields; copyWith replaces them', () {
      final a = Biome.pharloom.palette, b = Biome.moss.palette;
      final m = a.lerp(b, 0.5);
      expect(m.glassFill, Color.lerp(a.glassFill, b.glassFill, 0.5));
      expect(m.glassFillHi, Color.lerp(a.glassFillHi, b.glassFillHi, 0.5));
      expect(m.glassLight, Color.lerp(a.glassLight, b.glassLight, 0.5));
      expect(m.glassKey, Color.lerp(a.glassKey, b.glassKey, 0.5));
      const x = Color(0xFF123456);
      final k = a.copyWith(glassKey: x);
      expect(k.glassKey, x);
      expect(k.glassFill, a.glassFill);
    });

    test('equality covers the glass fields', () {
      final a = Biome.pharloom.palette;
      expect(a.copyWith(glassFill: const Color(0x11FFFFFF)), isNot(a));
    });

    test('the fixed whites are 14%, 16% and 22%', () {
      expect(glassSheen, white(0.14));
      expect(glassRing, white(0.16));
      expect(glassRim, white(0.22));
    });

    for (final b in Biome.values) {
      test('${b.label}: ash and bone keep 4.5:1 over glassFill on void', () {
        final p = b.palette;
        final bg = Color.alphaBlend(p.glassFill, p.void_);
        expect(_contrast(p.ash, bg), greaterThanOrEqualTo(4.5));
        expect(_contrast(p.bone, bg), greaterThanOrEqualTo(4.5));
      });
    }
  });
}

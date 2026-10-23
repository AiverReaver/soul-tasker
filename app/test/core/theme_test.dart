import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/theme.dart';
import 'package:hearthrise/ui/onboarding_fields.dart';

void main() {
  for (final b in Biome.values) {
    test('${b.label}: dialogs use the shell surface', () {
      final t = buildTheme(b);
      expect(t.dialogTheme.backgroundColor, b.palette.shell);
    });

    test('${b.label}: boss title style sits in the TextTheme at 28', () {
      expect(buildTheme(b).textTheme.headlineMedium?.fontSize, 28);
    });
  }

  test('inscriptionDecoration uses palette hint, dim and silk edges', () {
    final p = Biome.moss.palette;
    final d = inscriptionDecoration(p, 'hint');
    expect(d.hintText, 'hint');
    expect(d.hintStyle?.color, p.ash);
    expect(d.enabledBorder?.borderSide.color, p.dim);
    expect(d.focusedBorder?.borderSide.color, p.silk);
  });
}

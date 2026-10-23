import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'lib/ has no raw colour literals or k-colour tokens outside palette',
    () {
      final literal = RegExp(r'Color\(0x[0-9A-Fa-f]+\)');
      final token = RegExp(
        r'\bk(Background|Surface|Selected|Ash|TextMuted|'
        r'AshDim|Ember|BossHealth|Wine|Pharloom|Mote|Ink|Dust)\b',
      );
      final hits = <String>[];
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        if (f.path.endsWith('lib/core/palette.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (literal.hasMatch(lines[i]) || token.hasMatch(lines[i])) {
            hits.add('${f.path}:${i + 1}');
          }
        }
      }
      expect(hits, isEmpty);
    },
  );
}

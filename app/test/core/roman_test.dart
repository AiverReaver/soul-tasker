import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/roman.dart';

void main() {
  test('romanNumeral covers the small numbers screens use', () {
    expect(
      [for (var i = 1; i <= 12; i++) romanNumeral(i)],
      [
        'I',
        'II',
        'III',
        'IV',
        'V',
        'VI',
        'VII',
        'VIII',
        'IX',
        'X',
        'XI',
        'XII', //
      ],
    );
    expect(romanNumeral(49), 'XLIX');
  });
}

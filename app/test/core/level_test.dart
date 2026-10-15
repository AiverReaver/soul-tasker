import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/level.dart';

void main() {
  test('level 1 at zero, 10 embers to the next', () {
    final l = levelFor(0);
    expect(l.level, 1);
    expect(l.toNext, 10);
  });

  test('10 is level 2; 29 is level 2 with 1 to go; 30 is level 3', () {
    expect(levelFor(9).level, 1);
    expect(levelFor(10).level, 2);
    expect(levelFor(10).toNext, 20);
    expect(levelFor(29).level, 2);
    expect(levelFor(29).toNext, 1);
    expect(levelFor(30).level, 3);
    expect(levelFor(60).level, 4);
  });

  test('100 is level 5', () {
    expect(levelFor(100).level, 5);
    expect(levelFor(100).toNext, 50);
  });

  test('never below 1, even for a negative input', () {
    expect(levelFor(-5).level, 1);
  });
}

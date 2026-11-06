import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/features/home/home_screen.dart';

void main() {
  group('showsBonfireCard: evening, everything struck, or rested', () {
    bool at(int hour, {bool rested = false, int total = 3, int struck = 0}) =>
        showsBonfireCard(
          hour: hour,
          isRested: rested,
          total: total,
          struck: struck,
        );

    test('hidden by day while tasks are open', () {
      expect(at(9), isFalse);
      expect(at(16), isFalse);
    });

    test('shown from 17:00 until 05:00', () {
      expect(at(17), isTrue);
      expect(at(23), isTrue);
      expect(at(4), isTrue);
      expect(at(5), isFalse);
    });

    test('shown by day once every task is struck', () {
      expect(at(10, struck: 3), isTrue);
    });

    test('an empty day is not "all struck"', () {
      expect(at(10, total: 0), isFalse);
    });

    test('after a rest it stays, as Rested', () {
      expect(at(10, rested: true), isTrue);
    });
  });
}

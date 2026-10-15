import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/enums.dart';

void main() {
  final now = DateTime(2026, 10, 13, 20);

  test('an open deadline within the hour counts minutes and is soon', () {
    final l = deadlineLabel(null, DateTime(2026, 10, 13, 20, 40), now);
    expect(l.text, 'in 40 min');
    expect(l.isSoon, isTrue);
  });

  test('a later open deadline shows its time', () {
    final l = deadlineLabel(null, DateTime(2026, 10, 13, 23), now);
    expect(l.text, 'by 11:00 PM');
    expect(l.isSoon, isFalse);
  });

  test('closed commitments show their outcome', () {
    final at = DateTime(2026, 10, 13, 9);
    expect(deadlineLabel(CommitmentOutcome.kept, at, now).text, 'kept');
    expect(deadlineLabel(CommitmentOutcome.tried, at, now).text, 'tried');
    expect(deadlineLabel(CommitmentOutcome.missed, at, now).text, 'missed');
    expect(deadlineLabel(CommitmentOutcome.frozen, at, now).text, 'frozen');
    expect(
      deadlineLabel(CommitmentOutcome.lateStrike, at, now).text,
      'done late',
    );
    expect(
      deadlineLabel(CommitmentOutcome.cancelled, at, now).text,
      'set aside',
    );
  });

  test('health in half points reads as points', () {
    expect(formatHealth(20), '10');
    expect(formatHealth(7), '3.5');
  });

  test('counts up to twenty read as words, then digits', () {
    expect(countWord(9), 'nine');
    expect(countWord(0), 'none');
    expect(countWord(21), '21');
  });
}

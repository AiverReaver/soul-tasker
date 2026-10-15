import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/missed_days.dart';

List<String> _missed({
  String lastResolved = '2026-10-10',
  String today = '2026-10-14',
  Set<String> rested = const {},
  Set<String> light = const {},
  Set<String> struck = const {},
}) => missedDays(
  lastResolved: lastResolved,
  today: today,
  restedDays: rested,
  lightDays: light,
  strikeDays: struck,
);

void main() {
  test('nothing has ended yet: no days', () {
    expect(_missed(lastResolved: '2026-10-13', today: '2026-10-14'), isEmpty);
    expect(_missed(lastResolved: '2026-10-14', today: '2026-10-14'), isEmpty);
  });

  test('one day ended with no cover is missed', () {
    expect(_missed(lastResolved: '2026-10-12', today: '2026-10-14'), [
      '2026-10-13',
    ]);
  });

  test('a bonfire or flask row covers a day', () {
    expect(
      _missed(lastResolved: '2026-10-12', rested: {'2026-10-13'}),
      isEmpty,
    );
  });

  test('a light day covers only with a strike that day', () {
    const day = '2026-10-13';
    expect(
      _missed(lastResolved: '2026-10-12', light: {day}, struck: {day}),
      isEmpty,
    );
    expect(_missed(lastResolved: '2026-10-12', light: {day}), [day]);
  });

  test('striking without a rest does not cover a day (D3)', () {
    expect(_missed(lastResolved: '2026-10-12', struck: {'2026-10-13'}), [
      '2026-10-13',
    ]);
  });

  test('today is never judged', () {
    expect(
      _missed(lastResolved: '2026-10-12', today: '2026-10-14'),
      isNot(contains('2026-10-14')),
    );
  });

  test('a three-day gap returns three days, oldest first', () {
    expect(_missed(lastResolved: '2026-10-10', today: '2026-10-14'), [
      '2026-10-11',
      '2026-10-12',
      '2026-10-13',
    ]);
  });

  test('covered days inside a gap are skipped', () {
    expect(_missed(rested: {'2026-10-12'}), ['2026-10-11', '2026-10-13']);
  });

  test('month and year boundaries and a daylight-saving day count once', () {
    List<String> between(String last, String today) =>
        _missed(lastResolved: last, today: today);
    expect(between('2026-12-30', '2027-01-02'), ['2026-12-31', '2027-01-01']);
    expect(between('2026-03-07', '2026-03-10'), ['2026-03-08', '2026-03-09']);
  });

  test('shiftDay moves by calendar days', () {
    expect(shiftDay('2026-10-14', -1), '2026-10-13');
    expect(shiftDay('2026-03-01', -1), '2026-02-28');
    expect(shiftDay('2026-12-31', 1), '2027-01-01');
  });
}

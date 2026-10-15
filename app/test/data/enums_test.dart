import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/enums.dart';

void main() {
  test('a miss costs 1, 2, 3 health, stored as half points', () {
    expect(Weight.light.healthLoss, 2);
    expect(Weight.heavy.healthLoss, 4);
    expect(Weight.bossTier.healthLoss, 6);
  });

  test('stored enum indexes never move', () {
    expect(FallCause.healthDeath.index, 1);
    expect(DayKind.light.index, 2);
    expect(EmberKind.bank.index, 1);
    expect(CommitmentOutcome.values.map((o) => o.name), [
      'kept',
      'tried',
      'missed',
      'frozen',
      'lateStrike',
      'cancelled',
    ]);
    expect(HealthReason.values.map((r) => r.name), [
      'miss',
      'tried',
      'bonfireRestore',
      'rise',
    ]);
  });
}

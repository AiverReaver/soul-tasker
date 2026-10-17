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

  test('weathering follows attempts: 1, 2-3, 4-8, 9+', () {
    expect(Weathering.forAttempts(1), Weathering.unmarked);
    expect(Weathering.forAttempts(2), Weathering.worn);
    expect(Weathering.forAttempts(3), Weathering.worn);
    expect(Weathering.forAttempts(4), Weathering.scarred);
    expect(Weathering.forAttempts(8), Weathering.scarred);
    expect(Weathering.forAttempts(9), Weathering.weathered);
    expect(Weathering.forAttempts(40), Weathering.weathered);
    expect(Weathering.values.map((w) => w.name), [
      'unmarked',
      'worn',
      'scarred',
      'weathered',
    ]);
  });

  test('signal kinds and check-in answers keep their order', () {
    expect(SignalKind.values.map((k) => k.name), [
      'fell',
      'tapModeChanged',
      'checkIn',
      'checkInDismissed',
    ]);
    expect(CheckInAnswer.values.map((a) => a.name), [
      'never',
      'sometimes',
      'often',
    ]);
  });

  test('flask and sync enums keep their order (Stage 7)', () {
    expect(FlaskKind.values.map((k) => k.name), ['spend', 'restore']);
    expect(FlaskReason.values.map((r) => r.name), [
      'skipDay',
      'lightDay',
      'extension',
      'bonfire',
      'backfill',
    ]);
    expect(SyncOp.values.map((o) => o.name), ['upsert', 'delete']);
  });
}

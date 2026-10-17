import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.db.close());

  test('Stage 3 settings start at their defaults', () async {
    final s = await h.settings.watch().first;
    expect(s.rolloverHour, 4);
    expect(s.reminderEnabled, isFalse);
    expect(s.reminderMinutes, 21 * 60);
    expect(await h.flasks(), 3);
    // The harness clock starts on 2026-10-13; the install day is never judged.
    expect((await h.settings.device()).lastResolvedDay, '2026-10-13');
  });

  group('setRolloverHour', () {
    test('stores 0 to 6', () async {
      for (final hour in [0, 2, 6]) {
        await h.settings.setRolloverHour(hour);
        expect((await h.settings.watch().first).rolloverHour, hour);
      }
    });

    test('rejects hours outside 0 to 6', () async {
      expect(() => h.settings.setRolloverHour(7), throwsArgumentError);
      expect(() => h.settings.setRolloverHour(-1), throwsArgumentError);
      expect((await h.settings.watch().first).rolloverHour, 4);
    });
  });

  group('setReminder', () {
    test('round-trips the switch and the time', () async {
      await h.settings.setReminder(enabled: true, minutes: 18 * 60 + 30);
      final s = await h.settings.watch().first;
      expect(s.reminderEnabled, isTrue);
      expect(s.reminderMinutes, 18 * 60 + 30);
    });

    test('rejects minutes outside 0 to 1439', () async {
      expect(
        () => h.settings.setReminder(enabled: true, minutes: -1),
        throwsArgumentError,
      );
      expect(
        () => h.settings.setReminder(enabled: true, minutes: 1440),
        throwsArgumentError,
      );
      expect((await h.settings.watch().first).reminderMinutes, 21 * 60);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/features/ritual/reminder_coordinator.dart';

import '../data/harness.dart';
import '../support/fake_reminders.dart';

void main() {
  late Harness h;
  late FakeReminders reminders;
  late ReminderCoordinator coordinator;
  setUp(() {
    h = Harness();
    reminders = FakeReminders();
    coordinator = ReminderCoordinator(h.settings, reminders);
  });
  tearDown(() => h.db.close());

  Future<AppSettings> settings() => h.db.select(h.db.userSettings).getSingle();

  group('enable', () {
    test('asks for permission, then schedules at the stored time', () async {
      expect(await coordinator.enable(), isTrue);
      expect(reminders.calls, ['permission', 'schedule:1260']);
      final s = await settings();
      expect(s.reminderEnabled, isTrue);
      expect(s.reminderMinutes, 1260);
    });

    test('a chosen time is stored and scheduled', () async {
      await coordinator.enable(minutes: 18 * 60);
      expect(reminders.calls, ['permission', 'schedule:1080']);
      expect((await settings()).reminderMinutes, 1080);
    });

    test('a denied permission leaves it off and schedules nothing', () async {
      reminders.grants = false;
      expect(await coordinator.enable(), isFalse);
      expect(reminders.calls, ['permission']);
      expect((await settings()).reminderEnabled, isFalse);
    });
  });

  group('setTime', () {
    test('when on, cancels and reschedules once', () async {
      await coordinator.enable();
      reminders.calls.clear();
      await coordinator.setTime(19 * 60);
      expect(reminders.calls, ['cancel', 'schedule:1140']);
      expect((await settings()).reminderMinutes, 1140);
    });

    test('when off, only stores the time', () async {
      await coordinator.setTime(19 * 60);
      expect(reminders.calls, isEmpty);
      expect((await settings()).reminderMinutes, 1140);
    });
  });

  test('disable cancels and turns it off', () async {
    await coordinator.enable();
    reminders.calls.clear();
    await coordinator.disable();
    expect(reminders.calls, ['cancel']);
    expect((await settings()).reminderEnabled, isFalse);
  });

  group('rearm at app start', () {
    test('schedules again when it is on', () async {
      await coordinator.enable(minutes: 20 * 60);
      reminders.calls.clear();
      await coordinator.rearm();
      expect(reminders.calls, ['schedule:1200']);
    });

    test('cancels when it is off', () async {
      await coordinator.rearm();
      expect(reminders.calls, ['cancel']);
    });
  });
}

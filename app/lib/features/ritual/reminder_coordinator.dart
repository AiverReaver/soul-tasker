import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/reminders.dart';
import '../../data/providers.dart';
import '../../data/settings_dao.dart';

/// The reminder rules (Stage 3 plan D6): the stored setting and the system
/// schedule are changed together, so they cannot drift apart.
class ReminderCoordinator {
  ReminderCoordinator(this._settings, this._reminders);

  final SettingsDao _settings;
  final Reminders _reminders;

  Future<({bool isEnabled, int minutes})> _stored() async {
    final s = await _settings.read();
    return (isEnabled: s.reminderEnabled, minutes: s.reminderMinutes);
  }

  /// Turns the reminder on, at [minutes] if given. Returns false, leaving it
  /// off, when the system permission is refused.
  Future<bool> enable({int? minutes}) async {
    if (!await _reminders.requestPermission()) {
      await _settings.setReminder(
        enabled: false,
        minutes: minutes ?? (await _stored()).minutes,
      );
      return false;
    }
    final at = minutes ?? (await _stored()).minutes;
    await _settings.setReminder(enabled: true, minutes: at);
    await _reminders.schedule(minutes: at);
    return true;
  }

  /// Changes the time; reschedules only if the reminder is on.
  Future<void> setTime(int minutes) async {
    final stored = await _stored();
    await _settings.setReminder(enabled: stored.isEnabled, minutes: minutes);
    if (!stored.isEnabled) return;
    await _reminders.cancel();
    await _reminders.schedule(minutes: minutes);
  }

  Future<void> disable() async {
    await _settings.setReminder(
      enabled: false,
      minutes: (await _stored()).minutes,
    );
    await _reminders.cancel();
  }

  /// At app start: make the system schedule match the setting.
  Future<void> rearm() async {
    final stored = await _stored();
    if (stored.isEnabled) {
      await _reminders.schedule(minutes: stored.minutes);
    } else {
      await _reminders.cancel();
    }
  }
}

final reminderCoordinatorProvider = Provider(
  (ref) => ReminderCoordinator(
    ref.watch(settingsDaoProvider),
    ref.watch(remindersProvider),
  ),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_reminders.dart';

/// The daily bonfire reminder, behind an interface so the rules around it are
/// tested without a device (Stage 3 plan D6).
abstract interface class Reminders {
  /// Asks the system for permission to notify. True when granted.
  Future<bool> requestPermission();

  /// Schedules the one daily reminder, replacing any earlier one.
  /// [minutes] is the local time, from midnight.
  Future<void> schedule({required int minutes});

  Future<void> cancel();
}

/// Overridden in tests with a fake.
final remindersProvider = Provider<Reminders>((ref) => LocalReminders());

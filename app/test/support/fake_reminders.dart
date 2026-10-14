import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hearthrise/core/reminders.dart';

/// Records what the app asks of the notification system, so the reminder
/// rules can be tested without a device.
class FakeReminders implements Reminders {
  FakeReminders({this.grants = true});

  /// What the permission prompt answers.
  bool grants;
  final calls = <String>[];

  @override
  Future<bool> requestPermission() async {
    calls.add('permission');
    return grants;
  }

  @override
  Future<void> schedule({required int minutes}) async =>
      calls.add('schedule:$minutes');

  @override
  Future<void> cancel() async => calls.add('cancel');

  Override get asOverride => remindersProvider.overrideWithValue(this);
}

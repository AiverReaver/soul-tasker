import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/reminders.dart';
import '../../data/commitment_dao.dart';

/// How long before a deadline its reminder fires (plan D20).
const kReminderLead = Duration(minutes: 10);

/// Keeps the system's one-shot reminders in step with today's promises:
/// one for each open promise that asked, ten minutes before, while that time
/// is still ahead; none for anything else (Stage 4 plan D20).
class DeadlineReminders {
  DeadlineReminders(this._reminders, this._clock);

  final Reminders _reminders;
  final Clock _clock;

  /// What this run of the app has scheduled, so unchanged ones are skipped.
  final _scheduled = <String, ({DateTime at, String body})>{};

  Future<void> sync(Map<String, CommitmentView> today) async {
    final now = _clock();
    final wanted = <String, ({DateTime at, String body})>{
      for (final v in today.values)
        if (v.commitment.remind && v.commitment.outcome == null)
          if (v.commitment.deadline.subtract(kReminderLead) case final at
              when at.isAfter(now))
            v.commitment.id: (at: at, body: v.taskTitle),
    };
    for (final v in today.values) {
      final id = v.commitment.id;
      final want = wanted[id];
      if (want == null) {
        if (_scheduled.remove(id) != null || v.commitment.remind) {
          await _reminders.cancelOnce(id);
        }
      } else if (_scheduled[id] != want) {
        _scheduled[id] = want;
        await _reminders.scheduleOnce(id, want.at, want.body);
      }
    }
  }
}

final deadlineRemindersProvider = Provider(
  (ref) =>
      DeadlineReminders(ref.watch(remindersProvider), ref.watch(clockProvider)),
);

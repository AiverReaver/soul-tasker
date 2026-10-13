import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hearthrise/data/attempt_dao.dart';
import 'package:hearthrise/data/boss_dao.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/settings_dao.dart';

/// A clock that moves one second per read, so event order is exact.
class StepClock {
  StepClock([DateTime? start]) : now = start ?? DateTime(2026, 10, 13, 12);

  DateTime now;

  DateTime call() {
    now = now.add(const Duration(seconds: 1));
    return now;
  }
}

class Harness {
  Harness._(this.db, this.clock)
    : bosses = BossDao(db, clock.call),
      settings = SettingsDao(db) {
    attempts = AttemptDao(db, bosses, clock.call);
  }

  factory Harness([QueryExecutor? executor, StepClock? clock]) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    return Harness._(
      AppDatabase(executor ?? NativeDatabase.memory()),
      clock ?? StepClock(),
    );
  }

  final AppDatabase db;
  final StepClock clock;
  final BossDao bosses;
  final SettingsDao settings;
  late final AttemptDao attempts;

  /// Two phases (2 + 1 one-time tasks), one daily task in phase 1,
  /// one standalone one-time task.
  Future<BossView> seed({ResetOnFail reset = ResetOnFail.nothing}) async {
    final id = await bosses.saveBoss(
      BossDraft(
        title: 'The Certification',
        resetOnFail: reset,
        phases: const [
          PhaseDraft(
            name: 'Learn',
            tasks: [
              TaskDraft(title: 'Read chapter 4'),
              TaskDraft(title: 'Flashcards', weight: Weight.light),
              TaskDraft(title: 'Walk', recurrence: Recurrence.daily),
            ],
          ),
          PhaseDraft(
            name: 'Fight',
            tasks: [TaskDraft(title: 'Sit the exam', weight: Weight.bossTier)],
          ),
        ],
        standalone: const [TaskDraft(title: 'Book the room')],
      ),
    );
    return (await bosses.loadBoss(id))!;
  }

  Future<BossView> reload(String id) async => (await bosses.loadBoss(id))!;
}

TaskView taskNamed(BossView view, String title) =>
    view.allTasks.firstWhere((t) => t.task.title == title);

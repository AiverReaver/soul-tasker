// Dev only: `flutter run -t lib/main_demo.dart`. Fills an empty database
// with a few bosses, strikes, a fall and a relic, then starts the app.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/attempt_dao.dart';
import 'data/boss_dao.dart';
import 'data/boss_draft.dart';
import 'data/database.dart';
import 'data/enums.dart';
import 'data/providers.dart';
import 'data/settings_dao.dart';

Future<void> _seed(AppDatabase db) async {
  if ((await db.select(db.bosses).get()).isNotEmpty) return;
  final bosses = BossDao(db, DateTime.now);
  final attempts = AttemptDao(db, bosses, DateTime.now);
  await SettingsDao(db, DateTime.now).setOnboarded(true);

  Future<String> save(BossDraft d) => bosses.saveBoss(d);
  Future<String> taskId(String boss, String title) async {
    final view = (await bosses.loadBoss(boss))!;
    return view.allTasks.firstWhere((t) => t.task.title == title).task.id;
  }

  final cert = await save(
    const BossDraft(
      title: 'The Certification',
      defeatMeaning: 'Pass the exam and breathe out.',
      resetOnFail: ResetOnFail.currentPhase,
      phases: [
        PhaseDraft(
          name: 'Learn',
          tasks: [
            TaskDraft(title: 'Read chapter 4'),
            TaskDraft(title: 'Flashcards', weight: Weight.light),
            TaskDraft(title: 'Practice paper', weight: Weight.heavy),
            TaskDraft(title: 'Walk', recurrence: Recurrence.daily),
          ],
        ),
        PhaseDraft(
          name: 'Revise',
          tasks: [TaskDraft(title: 'Mock exam', weight: Weight.heavy)],
        ),
        PhaseDraft(
          name: 'Fight',
          tasks: [TaskDraft(title: 'Sit the exam', weight: Weight.bossTier)],
        ),
      ],
      standalone: [TaskDraft(title: 'Book the room')],
    ),
  );
  await bosses.setPinned(cert, isPinned: true);
  await attempts.fall(cert, 'Started too late.');
  await attempts.strike(await taskId(cert, 'Read chapter 4'));

  final run = await save(
    const BossDraft(
      title: 'Marathon Sentinel',
      resetOnFail: ResetOnFail.nothing,
      phases: [],
      standalone: [
        TaskDraft(title: 'Run 3 km', recurrence: Recurrence.daily),
        TaskDraft(title: 'Stretch', recurrence: Recurrence.daily),
      ],
    ),
  );
  await attempts.strike(await taskId(run, 'Stretch'));

  final novel = await save(
    const BossDraft(
      title: 'The Novel',
      resetOnFail: ResetOnFail.nothing,
      phases: [
        PhaseDraft(
          name: 'Draft',
          tasks: [TaskDraft(title: 'Outline')],
        ),
      ],
    ),
  );
  await bosses.setStatus(novel, BossStatus.waiting);

  final garage = await save(
    const BossDraft(
      title: 'The Garage',
      resetOnFail: ResetOnFail.nothing,
      phases: [
        PhaseDraft(
          name: 'Clear',
          tasks: [TaskDraft(title: 'Sweep')],
        ),
      ],
    ),
  );
  await attempts.fall(garage, 'Tried to do it all in one day.');
  await attempts.strike(await taskId(garage, 'Sweep'));
  await bosses.setStatus(garage, BossStatus.defeated);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.open();
  await _seed(db);
  await BossDao(db, DateTime.now).ensureDayBoss();
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const HearthriseApp(),
    ),
  );
}

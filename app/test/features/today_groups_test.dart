import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/day_boss.dart';
import 'package:hearthrise/features/today/today_view.dart';
import 'package:hearthrise/ui/task_group_header.dart';

import '../data/harness.dart';
import 'pump.dart';

void main() {
  test('groups: daily, then the current chapter, then the rest', () async {
    final h = Harness();
    final view = await h.seed();
    final groups = todayGroups(view);
    expect(
      [for (final g in groups) g.label],
      [
        'The Certification · daily',
        'The Certification · Chapter I · Learn',
        'The Certification',
      ],
    );
    expect(
      [
        for (final g in groups) [for (final t in g.tasks) t.task.title],
      ],
      [
        ['Walk'],
        ['Read chapter 4', 'Flashcards'],
        ['Book the room'],
      ],
    );
    expect([for (final g in groups) g.count], ['0 of 1', '0 of 2', '0 of 1']);
    await h.db.close();
  });

  test('a struck task counts, leaves its group once it has lingered', () async {
    final h = Harness();
    final view = await h.seed();
    final read = taskNamed(view, 'Read chapter 4').task.id;
    final walk = taskNamed(view, 'Walk').task.id;
    await h.attempts.strike(read);
    await h.attempts.strike(walk);
    final after = await h.reload(view.boss.id);
    List<String> titles(Set<String> linger, int group) => [
      for (final t in todayGroups(after, lingering: linger)[group].tasks)
        t.task.title,
    ];
    final settled = todayGroups(after);
    expect(settled[0].count, '1 of 1');
    expect(settled[1].count, '1 of 2');
    // Struck dailies sink to the bottom of their group but stay on show.
    expect(titles({}, 0), ['Walk']);
    expect(titles({}, 1), ['Flashcards']);
    // While lingering the one-time task keeps its slot.
    expect(titles({read}, 1), ['Read chapter 4', 'Flashcards']);
    await h.db.close();
  });

  test('a group with nothing to show is left out', () async {
    final h = Harness();
    final view = await h.seed();
    await h.attempts.strike(taskNamed(view, 'Book the room').task.id);
    final after = await h.reload(view.boss.id);
    expect(
      [for (final g in todayGroups(after)) g.label],
      ['The Certification · daily', 'The Certification · Chapter I · Learn'],
    );
    await h.db.close();
  });

  testWidgets('Home groups rows under labels and drops the boss name', (
    tester,
  ) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h, tall: true);
    expect(find.byType(TaskGroupHeader), findsNWidgets(3));
    expect(find.text('THE CERTIFICATION · CHAPTER I · LEARN'), findsOneWidget);
    expect(find.text('0 of 2'), findsOneWidget);
    // The row says only what it earns; boss and chapter live in the label.
    expect(find.textContaining('The Certification ·'), findsNothing);
    expect(find.text('Walk · daily'), findsNothing);
    expect(find.text('Walk'), findsOneWidget);
    await tearDownApp(tester, h);
  });

  test('an empty Day still has its group, so Home can open it', () async {
    final h = Harness();
    await h.bosses.ensureDayBoss();
    final groups = todayGroups(await h.reload(dayBossId));
    expect(
      [for (final g in groups) (g.label, g.tasks.length, g.count)],
      [('The Day', 0, 'No tasks yet')],
    );
    await h.db.close();
  });
}

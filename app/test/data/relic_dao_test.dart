import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.db.close());

  Future<String> bossWith(List<TaskDraft> tasks) => h.bosses.saveBoss(
    BossDraft(
      title: 'The Certification',
      defeatMeaning: 'I am certified',
      resetOnFail: ResetOnFail.nothing,
      phases: [
        PhaseDraft(name: 'Learn', tasks: tasks),
        const PhaseDraft(name: 'Fight'),
      ],
    ),
  );

  Future<void> strikeAll(String id) async {
    for (final t in (await h.reload(id)).allTasks) {
      await h.attempts.strike(t.task.id);
    }
  }

  Future<Relic> defeat(String id) async {
    await h.bosses.setStatus(id, BossStatus.defeated);
    return (await h.relics.watchAll().first).firstWhere((r) => r.bossId == id);
  }

  test('defeat writes one relic in the same transaction', () async {
    final id = await bossWith([const TaskDraft(title: 'Read')]);
    await h.attempts.fall(id, 'Started too late.');
    await h.attempts.fall(id, null);
    await h.attempts.fall(id, 'Skipped the warm-up.');
    await strikeAll(id);
    final relic = await defeat(id);

    expect(relic.name, 'Relic of The Certification');
    expect(relic.attempts, 4);
    expect(relic.emblem, Weathering.scarred);
    expect(relic.defeatedDay, '2026-10-13');
    expect(relic.inscription, isNull);
    final full = (await h.relics.load(relic.id))!;
    expect(full.story.phases, ['Learn', 'Fight']);
    expect(full.story.defeatMeaning, 'I am certified');
    expect(full.story.lessons.map((l) => (l.attempt, l.text)), [
      (1, 'Started too late.'),
      (3, 'Skipped the warm-up.'),
    ]);
    expect(full.story.lessons.first.cause, FallCause.declared);
  });

  test('a first-try win is unmarked with one attempt', () async {
    final id = await bossWith([const TaskDraft(title: 'Read')]);
    await strikeAll(id);
    final relic = await defeat(id);
    expect(relic.attempts, 1);
    expect(relic.emblem, Weathering.unmarked);
  });

  test('days count ritual days from creation to defeat, inclusive', () async {
    h.clock.now = DateTime(2026, 10, 13, 23);
    final id = await bossWith([const TaskDraft(title: 'Read')]);
    // 01:00 on the 14th still belongs to the 13th (rollover at 04:00).
    h.clock.now = DateTime(2026, 10, 14, 1);
    expect((await defeat(id)).days, 1);
    h.clock.now = DateTime(2026, 10, 14, 9);
    final later = await bossWith([const TaskDraft(title: 'Read')]);
    h.clock.now = DateTime(2026, 10, 17, 9);
    final relic = await defeat(later);
    expect(relic.days, 4); // 14th to 17th
  });

  test('effort counts only earn events on this boss', () async {
    final id = await bossWith([
      const TaskDraft(title: 'Read'), // heavy: 3
      const TaskDraft(title: 'Cards', weight: Weight.light), // 1
    ]);
    final other = await bossWith([const TaskDraft(title: 'Else')]);
    await h.attempts.strike((await h.reload(other)).allTasks.first.task.id);
    await strikeAll(id);
    await h.db.customStatement(
      "INSERT INTO ember_events (id, kind, amount, day, at) "
      "VALUES ('bank', 1, 4, '2026-10-13', '2026-10-13T12:30:00.000')",
    );
    expect((await defeat(id)).effort, 4);
  });

  test('empty and null lessons are left out', () async {
    final id = await bossWith([const TaskDraft(title: 'Read')]);
    await h.attempts.fall(id, '   ');
    await h.attempts.fall(id, null);
    await h.attempts.fall(id, 'Real one.');
    await strikeAll(id);
    final full = (await h.relics.load((await defeat(id)).id))!;
    expect(full.story.lessons.map((l) => l.text), ['Real one.']);
  });

  test('a missed-day lesson appears on each boss it was written for', () async {
    final a = await bossWith([const TaskDraft(title: 'Read')]);
    final b = await bossWith([const TaskDraft(title: 'Else')]);
    for (final id in [a, b]) {
      await h.attempts.failBoss(id, FallCause.missedDay, 'Shared lesson.');
      await strikeAll(id);
    }
    for (final id in [a, b]) {
      final full = (await h.relics.load((await defeat(id)).id))!;
      expect(full.story.lessons.single.text, 'Shared lesson.');
      expect(full.story.lessons.single.cause, FallCause.missedDay);
    }
  });

  test('defeating twice writes one relic; defeat is final', () async {
    final id = await bossWith([const TaskDraft(title: 'Read')]);
    await strikeAll(id);
    await h.bosses.setStatus(id, BossStatus.defeated);
    await h.bosses.setStatus(id, BossStatus.defeated);
    expect(await h.relics.watchAll().first, hasLength(1));
    expect(() => h.bosses.setStatus(id, BossStatus.active), throwsStateError);
    expect(() => h.bosses.setStatus(id, BossStatus.waiting), throwsStateError);
    expect((await h.reload(id)).boss.status, BossStatus.defeated);
  });

  test('editing then deleting the boss leaves the relic unchanged', () async {
    final id = await bossWith([const TaskDraft(title: 'Read')]);
    await h.attempts.fall(id, 'A lesson.');
    await strikeAll(id);
    final relic = await defeat(id);
    final before = (await h.relics.load(relic.id))!;

    final draft = BossDraft.fromView(await h.reload(id));
    await h.bosses.saveBoss(
      draft.copyWith(
        title: 'Renamed',
        phases: [draft.phases.first.copyWith(name: 'Edited')],
      ),
    );
    await h.bosses.deleteBoss(id);

    final after = (await h.relics.load(relic.id))!;
    expect(after.relic.bossId, isNull);
    expect(after.relic.name, 'Relic of The Certification');
    expect(after.relic.attempts, before.relic.attempts);
    expect(after.relic.effort, before.relic.effort);
    expect(after.story.title, 'The Certification');
    expect(after.story.phases, ['Learn', 'Fight']);
    expect(after.story.lessons.single.text, 'A lesson.');
  });

  group('inscription', () {
    late String relicId;
    setUp(() async {
      final id = await bossWith([const TaskDraft(title: 'Read')]);
      await strikeAll(id);
      relicId = (await defeat(id)).id;
    });

    test('saves trimmed and stamps updatedAt, changing nothing else', () async {
      final before = (await h.relics.load(relicId))!.relic;
      await h.relics.setInscription(relicId, '  Patience.  ');
      final after = (await h.relics.load(relicId))!.relic;
      expect(after.inscription, 'Patience.');
      expect(after.updatedAt.isAfter(before.updatedAt), isTrue);
      expect(
        after.copyWith(
          inscription: const Value(null),
          updatedAt: before.updatedAt,
        ),
        before,
      );
    });

    test('empty saves as null', () async {
      await h.relics.setInscription(relicId, 'Something');
      await h.relics.setInscription(relicId, '   ');
      expect((await h.relics.load(relicId))!.relic.inscription, isNull);
    });

    test('refuses over 120 characters', () async {
      expect(
        () => h.relics.setInscription(relicId, 'x' * 121),
        throwsArgumentError,
      );
      await h.relics.setInscription(relicId, 'x' * 120);
    });
  });

  test('watchAll lists the most recent first', () async {
    final a = await bossWith([const TaskDraft(title: 'Read')]);
    final b = await bossWith([const TaskDraft(title: 'Else')]);
    await strikeAll(a);
    await strikeAll(b);
    await h.bosses.setStatus(b, BossStatus.defeated);
    await h.bosses.setStatus(a, BossStatus.defeated);
    final all = await h.relics.watchAll().first;
    expect(all.map((r) => r.bossId), [a, b]);
  });

  test('load returns null for an unknown id', () async {
    expect(await h.relics.load('nope'), isNull);
  });
}

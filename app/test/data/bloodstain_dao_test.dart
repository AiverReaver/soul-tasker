import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/bloodstain_merge.dart';
import 'package:hearthrise/data/bloodstain_dao.dart';
import 'package:hearthrise/data/database.dart';
import 'package:hearthrise/data/enums.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late BloodstainDao stains;
  late String bossA;
  late String bossB;
  setUp(() async {
    h = Harness();
    stains = BloodstainDao(h.db, h.clock.call);
    bossA = (await h.seed()).boss.id;
    bossB = (await h.seed()).boss.id;
  });
  tearDown(() => h.db.close());

  Future<Bloodstain> row(String id) => (h.db.select(
    h.db.bloodstains,
  )..where((b) => b.id.equals(id))).getSingle();

  group('drop', () {
    test('creates an active bloodstain', () async {
      final id = await stains.drop(bossId: bossA, amount: 5);
      final s = await row(id);
      expect(s.amount, 5);
      expect(s.recoveredAt, isNull);
      expect(s.lostAt, isNull);
      expect((await stains.active(bossA))?.id, id);
    });

    test('a second drop marks the first lost at its time (§9.2)', () async {
      final first = await stains.drop(bossId: bossA, amount: 5);
      final second = await stains.drop(bossId: bossA, amount: 2);
      expect((await row(first)).lostAt, (await row(second)).createdAt);
      expect((await stains.active(bossA))?.id, second);
    });

    test('a drop on another boss leaves the first active', () async {
      final first = await stains.drop(bossId: bossA, amount: 5);
      await stains.drop(bossId: bossB, amount: 2);
      expect((await stains.active(bossA))?.id, first);
    });
  });

  group('recover', () {
    test('sets recoveredAt; a later drop never marks it lost', () async {
      final first = await stains.drop(bossId: bossA, amount: 5);
      expect(await stains.recover(first), isTrue);
      expect((await row(first)).recoveredAt, isNotNull);
      expect(await stains.active(bossA), isNull);
      await stains.drop(bossId: bossA, amount: 2);
      expect((await row(first)).lostAt, isNull);
    });

    test('a lost one cannot be recovered', () async {
      final first = await stains.drop(bossId: bossA, amount: 5);
      await stains.drop(bossId: bossA, amount: 2);
      expect(await stains.recover(first), isFalse);
      expect((await row(first)).recoveredAt, isNull);
    });
  });

  group('references', () {
    test('deleting the boss deletes its bloodstains', () async {
      await stains.drop(bossId: bossA, amount: 5);
      await h.bosses.deleteBoss(bossA);
      expect(await h.db.select(h.db.bloodstains).get(), isEmpty);
    });

    test('deleting the task or attempt clears the reference', () async {
      final view = await h.reload(bossA);
      final task = view.allTasks.first.task.id;
      final fall = await h.attempts.failBoss(bossA, FallCause.declared, null);
      final id = await stains.drop(
        bossId: bossA,
        taskId: task,
        attemptId: fall,
        amount: 5,
      );
      await h.bosses.deleteTask(task);
      await h.db.customStatement('DELETE FROM attempts WHERE id = ?', [fall]);
      final s = await row(id);
      expect(s.taskId, isNull);
      expect(s.attemptId, isNull);
      expect(s.bossId, bossA);
    });
  });

  group('mergeStainTimes (D19)', () {
    final t1 = DateTime(2026, 10, 13, 9);
    final t2 = DateTime(2026, 10, 13, 10);
    final values = <StainTimes>[
      (recoveredAt: null, lostAt: null),
      (recoveredAt: t1, lostAt: null),
      (recoveredAt: t2, lostAt: null),
      (recoveredAt: null, lostAt: t1),
      (recoveredAt: null, lostAt: t2),
      (recoveredAt: t1, lostAt: t2),
    ];

    test('every pair gives the same answer in both orders', () {
      for (final a in values) {
        for (final b in values) {
          expect(mergeStainTimes(a, b), mergeStainTimes(b, a), reason: '$a $b');
        }
      }
    });

    test('earliest recovery wins and clears lostAt', () {
      expect(
        mergeStainTimes(
          (recoveredAt: t2, lostAt: null),
          (recoveredAt: null, lostAt: t1),
        ),
        (recoveredAt: t2, lostAt: null),
      );
      expect(
        mergeStainTimes(
          (recoveredAt: t2, lostAt: null),
          (recoveredAt: t1, lostAt: null),
        ),
        (recoveredAt: t1, lostAt: null),
      );
    });

    test('earliest loss wins when neither side recovered', () {
      expect(
        mergeStainTimes(
          (recoveredAt: null, lostAt: t2),
          (recoveredAt: null, lostAt: t1),
        ),
        (recoveredAt: null, lostAt: t1),
      );
    });
  });

  test('mergeBloodstain keeps the local immutable fields', () async {
    final id = await stains.drop(bossId: bossA, amount: 5);
    final local = await row(id);
    final remote = local.copyWith(
      amount: 99,
      recoveredAt: Value(DateTime(2026, 10, 14)),
      updatedAt: DateTime(2026, 10, 14),
    );
    final merged = mergeBloodstain(local, remote);
    expect(merged.amount, 5);
    expect(merged.recoveredAt, DateTime(2026, 10, 14));
    expect(merged.lostAt, isNull);
    expect(merged.updatedAt, DateTime(2026, 10, 14));
    expect(mergeBloodstain(remote, local).recoveredAt, merged.recoveredAt);
  });

  group('settleBloodstains (D11)', () {
    Future<void> insertActive(String id, DateTime createdAt) => h.db
        .into(h.db.bloodstains)
        .insert(
          BloodstainsCompanion.insert(
            id: id,
            bossId: bossA,
            amount: 3,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
    Future<void> applying(Future<void> Function() run) async {
      await h.db.customStatement('UPDATE sync_state SET applying = 1');
      await run();
      await h.db.customStatement('UPDATE sync_state SET applying = 0');
    }

    test('keeps the newer active and marks the older lost', () async {
      final older = DateTime(2026, 10, 13, 9);
      final newer = DateTime(2026, 10, 13, 10);
      await applying(() async {
        await insertActive('s-old', older);
        await insertActive('s-new', newer);
      });
      await stains.settleBloodstains(bossA);
      expect((await stains.active(bossA))?.id, 's-new');
      expect((await row('s-old')).lostAt, newer);
    });

    test(
      'equal times: the larger id wins; a second run changes nothing',
      () async {
        final at = DateTime(2026, 10, 13, 9);
        await applying(() async {
          await insertActive('s-a', at);
          await insertActive('s-b', at);
        });
        await stains.settleBloodstains(bossA);
        expect((await stains.active(bossA))?.id, 's-b');
        final once = await h.db.select(h.db.bloodstains).get();
        await stains.settleBloodstains(bossA);
        expect(await h.db.select(h.db.bloodstains).get(), once);
      },
    );
  });
}

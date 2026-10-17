import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/bloodstain_dao.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/sync_dao.dart';
import 'package:hearthrise/data/sync_schema.dart';
import 'package:hearthrise/data/sync_service.dart';
import 'package:hearthrise_api/hearthrise_api.dart' hide SyncApi;

import 'fake_sync_api.dart';
import 'harness.dart';

const _serverNow = '2026-10-16T00:00:00.000Z';

/// Inside the 24 h the server accepts, and later than any local write.
const _newer = '2026-10-16T12:00:00.000Z';
const _older = '2026-10-01T00:00:00.000Z';

void main() {
  late Harness h;
  late FakeSyncApi fake;
  late SyncDao outbox;
  late SyncService service;

  setUp(() {
    h = Harness();
    fake = FakeSyncApi(now: () => DateTime.parse(_serverNow));
    outbox = SyncDao(h.db);
    service = SyncService(
      db: h.db,
      api: fake,
      clock: h.clock.call,
      appVersion: '0.7.0',
    );
  });
  tearDown(() => h.db.close());

  Future<String> deviceId() async =>
      (await h.db.select(h.db.syncState).getSingle()).deviceId;

  Future<String> saveBoss([String title = 'The Garage']) => h.bosses.saveBoss(
    BossDraft(
      title: title,
      resetOnFail: ResetOnFail.nothing,
      phases: const [
        PhaseDraft(
          name: 'Clear',
          tasks: [
            TaskDraft(title: 'Sweep'),
            TaskDraft(title: 'Bins'),
          ],
        ),
      ],
    ),
  );

  Future<List<Map<String, Object?>>> rows(
    String sql, [
    List<Object?> v = const [],
  ]) async => [
    for (final r
        in await h.db
            .customSelect(sql, variables: [for (final x in v) Variable(x)])
            .get())
      r.data,
  ];

  Future<Object?> cell(String sql, [List<Object?> v = const []]) async =>
      (await rows(sql, v)).single.values.single;

  Future<int> count(String table) async =>
      (await cell('SELECT COUNT(*) FROM $table'))! as int;

  /// A row as another phone would push it; [over] replaces defaults.
  ChangeDto remote(
    String table,
    String id,
    Map<String, Object?> over, {
    String? updatedAt,
  }) {
    const defaults = <String, Map<String, Object?>>{
      'bosses': {
        'title': 'Remote boss',
        'defeat_meaning': null,
        'status': 0,
        'attempt_number': 1,
        'reset_on_fail': 0,
        'is_pinned': false,
        'target_date': null,
        'last_fought_at': null,
        'open_from_attempt': 1,
        'created_at': '2026-10-01T00:00:00.000Z',
        'defeated_at': null,
      },
      'phases': {
        'name': 'Remote phase',
        'position': 0,
        'open_from_attempt': 1,
        'created_at': '2026-10-01T00:00:00.000Z',
      },
      'tasks': {
        'phase_id': null,
        'title': 'Remote task',
        'weight': 0,
        'recurrence': 0,
        'position': 0,
        'is_split': false,
        'daily_deadline_minutes': null,
        'created_at': '2026-10-01T00:00:00.000Z',
      },
      'attempts': {
        'task_id': null,
        'boss_attempt': 1,
        'outcome': 0,
        'cause': null,
        'phase_id': null,
        'lesson': null,
        'weight': null,
        'day': '2026-10-01',
        'at': '2026-10-01T00:00:00.000Z',
      },
      'health_events': {
        'amount': -2,
        'reason': 0,
        'commitment_id': null,
        'day': '2026-10-01',
        'at': '2026-10-01T00:00:00.000Z',
      },
      'bloodstains': {
        'task_id': null,
        'attempt_id': null,
        'amount': 4,
        'created_at': '2026-10-01T00:00:00.000Z',
        'recovered_at': null,
        'lost_at': null,
      },
      'user_settings': {
        'tap_mode': true,
        'default_reset_on_fail': 0,
        'haptics': true,
        'rollover_hour': 4,
        'reminder_enabled': false,
        'reminder_minutes': 1260,
        'first_day': '2026-10-13',
        'sound': false,
      },
    };
    return ChangeDto(
      table: table,
      id: id,
      op: ChangeDtoOpEnum.upsert,
      updatedAt: kEventTables.contains(table) ? null : (updatedAt ?? _older),
      row: {...defaults[table]!, ...over},
    );
  }

  ChangeDto gone(String table, String id) => ChangeDto(
    table: table,
    id: id,
    op: ChangeDtoOpEnum.delete,
    deletedAt: _newer,
  );

  Future<void> asRemote(List<ChangeDto> changes, [String device = 'other']) =>
      fake.push(device, changes);

  group('push', () {
    test('sends current rows with the device id, then acks them', () async {
      final bossId = await saveBoss();
      expect(await service.sync(), SyncOutcome.synced);

      expect(await outbox.pending(), isEmpty);
      final (sentBy, changes) = fake.pushes.single;
      expect(sentBy, await deviceId());
      expect(changes.map((c) => c.table).toSet(), {
        'bosses',
        'phases',
        'tasks',
      });
      final boss = changes.firstWhere((c) => c.table == 'bosses');
      expect(boss.id, bossId);
      expect(boss.op, ChangeDtoOpEnum.upsert);
      expect(boss.updatedAt, matches(RegExp(r'^\d{4}-.*Z$')));
      expect(boss.row!.keys, kSyncColumns['bosses']!.keys);
      expect(boss.row!['title'], 'The Garage');
      expect(boss.row!['is_pinned'], false);
      expect(fake.rowOf('bosses', bossId)!['title'], 'The Garage');
      expect(fake.liveIds('tasks'), hasLength(2));
    });

    test('sends parents before children', () async {
      await saveBoss();
      await service.sync();
      const order = ['bosses', 'phases', 'tasks'];
      final sent = [
        for (final c in fake.pushes.single.$2) order.indexOf(c.table),
      ];
      expect(sent, [...sent]..sort());
    });

    test('a delete goes as a tombstone with its own time', () async {
      final bossId = await saveBoss();
      await service.sync();
      await h.bosses.deleteBoss(bossId);
      final deletedAt = h.clock.now;
      await service.sync();

      expect(fake.isDeleted('bosses', bossId), isTrue);
      final sent = fake.pushes.last.$2.firstWhere((c) => c.table == 'bosses');
      expect(sent.op, ChangeDtoOpEnum.delete);
      expect(sent.row, isNull);
      expect(DateTime.parse(sent.deletedAt!).toUtc(), deletedAt.toUtc());
      expect(await outbox.pending(), isEmpty);
    });

    test(
      'a row created and deleted before any push sends one tombstone',
      () async {
        final bossId = await saveBoss();
        await h.bosses.deleteBoss(bossId);
        await service.sync();
        expect(fake.isDeleted('bosses', bossId), isTrue);
        expect(await outbox.pending(), isEmpty);
      },
    );

    test('an edit made while the push is in flight is sent next run', () async {
      final bossId = await saveBoss();
      fake.duringPush = () => h.db.customStatement(
        "UPDATE bosses SET title = 'Edited', updated_at = ? WHERE id = ?",
        [h.clock().toIso8601String(), bossId],
      );
      await service.sync();

      final left = await outbox.pending();
      expect(left.map((e) => (e.tbl, e.rowId)), [('bosses', bossId)]);
      expect(fake.rowOf('bosses', bossId)!['title'], 'The Garage');

      await service.sync();
      expect(await outbox.pending(), isEmpty);
      expect(fake.rowOf('bosses', bossId)!['title'], 'Edited');
    });

    test('with nothing queued it makes no push', () async {
      await service.sync();
      expect(fake.pushes, isEmpty);
    });

    test('a push over the server batch size is split', () async {
      await saveBoss();
      final big = SyncService(
        db: h.db,
        api: fake,
        clock: h.clock.call,
        appVersion: '0.7.0',
        batchSize: 2,
      );
      await big.sync();
      expect(fake.pushes.map((p) => p.$2.length), [2, 2]);
      expect(await outbox.pending(), isEmpty);
    });
  });

  group('rejections', () {
    test('a clock 422 sets updatedAt to now and requeues it once', () async {
      final bossId = await saveBoss();
      await h.db.customStatement(
        "UPDATE bosses SET updated_at = '2026-11-30T00:00:00.000Z' WHERE id = ?",
        [bossId],
      );
      await service.sync();

      expect(fake.rowOf('bosses', bossId), isNull);
      final pending = await outbox.pending();
      expect(pending.map((e) => e.rowId), [bossId]);
      final updated = DateTime.parse(
        (await cell('SELECT updated_at FROM bosses WHERE id = ?', [bossId]))!
            as String,
      );
      expect(updated.isBefore(DateTime.utc(2026, 10, 16)), isTrue);

      await service.sync();
      expect(fake.rowOf('bosses', bossId)!['title'], 'The Garage');
      expect(await outbox.pending(), isEmpty);
    });

    test('a clock 422 that repeats is quarantined, not looped', () async {
      final bossId = await saveBoss();
      fake.reject['bosses/$bossId'] = PushResultReasonEnum.clock;
      await service.sync();
      await service.sync();
      expect((await outbox.pending()).where((e) => e.rowId == bossId), isEmpty);
      expect((await outbox.quarantined()).map((e) => e.rowId), [bossId]);
    });

    test(
      'a malformed 422 quarantines only that entry; the rest lands',
      () async {
        final bossId = await saveBoss();
        final taskId =
            (await cell("SELECT id FROM tasks WHERE title = 'Bins'"))!
                as String;
        fake.reject['tasks/$taskId'] = PushResultReasonEnum.malformed;
        await service.sync();

        expect(fake.rowOf('bosses', bossId), isNotNull);
        expect(fake.rowOf('tasks', taskId), isNull);
        expect(fake.liveIds('tasks'), hasLength(1));
        final q = await outbox.quarantined();
        expect(q.map((e) => e.rowId), [taskId]);
        expect(q.single.rejectedReason, contains('forced'));
        expect(await outbox.pending(), isEmpty);
      },
    );

    test('quarantine survives a rebuilt service and is skipped', () async {
      await saveBoss();
      final taskId =
          (await cell("SELECT id FROM tasks WHERE title = 'Bins'"))! as String;
      fake.reject['tasks/$taskId'] = PushResultReasonEnum.malformed;
      await service.sync();
      fake.pushes.clear();

      final rebuilt = SyncService(
        db: h.db,
        api: fake,
        clock: h.clock.call,
        appVersion: '0.7.0',
      );
      await rebuilt.sync();
      expect(fake.pushes, isEmpty);
      expect(await outbox.quarantined(), hasLength(1));
    });

    test('editing the row sends it again and drops the old entry', () async {
      await saveBoss();
      final taskId =
          (await cell("SELECT id FROM tasks WHERE title = 'Bins'"))! as String;
      fake.rejectOnce['tasks/$taskId'] = PushResultReasonEnum.malformed;
      await service.sync();
      expect(await outbox.quarantined(), hasLength(1));

      await h.db.customStatement(
        "UPDATE tasks SET title = 'Bins out', updated_at = ? WHERE id = ?",
        [h.clock().toIso8601String(), taskId],
      );
      await service.sync();
      expect(fake.rowOf('tasks', taskId)!['title'], 'Bins out');
      expect(await outbox.quarantined(), isEmpty);
      expect(await outbox.pending(), isEmpty);
    });

    test('a new app version retries quarantined entries once', () async {
      await saveBoss();
      final taskId =
          (await cell("SELECT id FROM tasks WHERE title = 'Bins'"))! as String;
      fake.rejectOnce['tasks/$taskId'] = PushResultReasonEnum.malformed;
      await service.sync();
      expect(await outbox.quarantined(), hasLength(1));

      final upgraded = SyncService(
        db: h.db,
        api: fake,
        clock: h.clock.call,
        appVersion: '0.7.1',
      );
      await upgraded.sync();
      expect(fake.rowOf('tasks', taskId), isNotNull);
      expect(await outbox.quarantined(), isEmpty);
    });
  });

  group('pull', () {
    test(
      'applies remote rows without queueing them, and moves the cursor',
      () async {
        await asRemote([
          remote('bosses', 'rb', {}),
          remote('tasks', 'rt', {'boss_id': 'rb'}),
        ]);
        await service.sync();

        expect(
          await cell("SELECT title FROM bosses WHERE id = 'rb'"),
          'Remote boss',
        );
        expect(await cell("SELECT boss_id FROM tasks WHERE id = 'rt'"), 'rb');
        expect(await outbox.pending(), isEmpty);
        final state = await h.db.select(h.db.syncState).getSingle();
        expect(state.cursor, 2);
        expect(state.applying, isFalse);
        expect(state.lastError, isNull);
        expect(state.lastSyncAt, isNotNull);
      },
    );

    test('follows hasMore across pages', () async {
      final paged = FakeSyncApi(
        pageSize: 2,
        now: () => DateTime.parse(_serverNow),
      );
      await paged.push('other', [
        remote('bosses', 'rb', {}),
        for (var i = 0; i < 4; i++) remote('tasks', 't$i', {'boss_id': 'rb'}),
      ]);
      await SyncService(
        db: h.db,
        api: paged,
        clock: h.clock.call,
        appVersion: '0.7.0',
      ).sync();
      expect(paged.pullCalls, 3);
      expect(await count('tasks'), 4);
      expect((await h.db.select(h.db.syncState).getSingle()).cursor, 5);
    });

    test('recomputes the attempt number from the falls (D7)', () async {
      await asRemote([
        remote('bosses', 'rb', {'attempt_number': 1}),
        remote('attempts', 'a1', {
          'boss_id': 'rb',
          'outcome': Outcome.fallen.index,
        }),
        remote('attempts', 'a2', {
          'boss_id': 'rb',
          'outcome': Outcome.fallen.index,
        }),
        remote('attempts', 'a3', {
          'boss_id': 'rb',
          'outcome': Outcome.strike.index,
        }),
      ]);
      await service.sync();
      expect(
        await cell("SELECT attempt_number FROM bosses WHERE id = 'rb'"),
        3,
      );
      expect(await outbox.pending(), isEmpty);
    });

    test('last write wins: older loses, newer wins', () async {
      final bossId = await saveBoss();
      await service.sync();
      await asRemote([
        remote('bosses', bossId, {'title': 'Old news'}),
      ]);
      await service.sync();
      expect(
        await cell('SELECT title FROM bosses WHERE id = ?', [bossId]),
        'The Garage',
      );

      await asRemote([
        remote('bosses', bossId, {'title': 'New news'}, updatedAt: _newer),
      ]);
      await service.sync();
      expect(
        await cell('SELECT title FROM bosses WHERE id = ?', [bossId]),
        'New news',
      );
      expect(await outbox.pending(), isEmpty);
    });

    test('equal times break on the device id, as on the server', () async {
      final bossId = await saveBoss();
      final at =
          (await cell('SELECT updated_at FROM bosses WHERE id = ?', [bossId]))!
              as String;
      final iso = DateTime.parse(at).toUtc().toIso8601String();
      await service.sync();

      // The server keeps the first copy; a pull of equal time from a device
      // that sorts lower changes nothing here either.
      final low = FakeSyncApi(now: () => DateTime.parse(_serverNow));
      await low.push('0', [
        remote('bosses', bossId, {'title': 'Low'}, updatedAt: iso),
      ]);
      await SyncService(
        db: h.db,
        api: low,
        clock: h.clock.call,
        appVersion: '0.7.0',
      ).sync();
      expect(
        await cell('SELECT title FROM bosses WHERE id = ?', [bossId]),
        'The Garage',
      );

      await h.db.customStatement('UPDATE sync_state SET cursor = 0');
      final high = FakeSyncApi(now: () => DateTime.parse(_serverNow));
      await high.push('zzzz', [
        remote('bosses', bossId, {'title': 'High'}, updatedAt: iso),
      ]);
      await SyncService(
        db: h.db,
        api: high,
        clock: h.clock.call,
        appVersion: '0.7.0',
      ).sync();
      expect(
        await cell('SELECT title FROM bosses WHERE id = ?', [bossId]),
        'High',
      );
    });

    test('an event that exists locally is not changed', () async {
      await asRemote([
        remote('bosses', 'rb', {}),
        remote('health_events', 'h1', {'amount': -2}),
      ]);
      await service.sync();
      await h.db.customStatement(
        "UPDATE health_events SET amount = -9 WHERE id = 'h1'",
      );
      await outbox.ack([for (final e in await outbox.pending()) e.seq]);

      await h.db.customStatement('UPDATE sync_state SET cursor = 0');
      final again = FakeSyncApi(now: () => DateTime.parse(_serverNow));
      await again.push('other', [
        remote('health_events', 'h1', {'amount': -2}),
      ]);
      await SyncService(
        db: h.db,
        api: again,
        clock: h.clock.call,
        appVersion: '0.7.0',
      ).sync();
      expect(
        await cell("SELECT amount FROM health_events WHERE id = 'h1'"),
        -9,
      );
    });

    test(
      'a child of a parent that is gone is dropped; a link is cleared',
      () async {
        await asRemote([
          remote('bosses', 'rb', {}),
          remote('tasks', 'rt', {'boss_id': 'rb'}),
          remote('attempts', 'ra', {'boss_id': 'rb', 'task_id': 'rt'}),
        ]);
        await service.sync();
        // The task is deleted here; a stale copy of the attempt still names it.
        await h.db.customStatement("DELETE FROM tasks WHERE id = 'rt'");
        await outbox.ack([for (final e in await outbox.pending()) e.seq]);

        await h.db.customStatement('UPDATE sync_state SET cursor = 0');
        final stale = FakeSyncApi(now: () => DateTime.parse(_serverNow));
        await stale.push('other', [
          remote('attempts', 'ra', {
            'boss_id': 'rb',
            'task_id': 'rt',
            'lesson': 'Hi',
          }, updatedAt: _newer),
          remote('tasks', 'orphan', {'boss_id': 'missing'}),
        ]);
        await SyncService(
          db: h.db,
          api: stale,
          clock: h.clock.call,
          appVersion: '0.7.0',
        ).sync();
        expect(await cell("SELECT lesson FROM attempts WHERE id = 'ra'"), 'Hi');
        expect(
          await cell("SELECT task_id FROM attempts WHERE id = 'ra'"),
          isNull,
        );
        expect(await count('tasks'), 0);
      },
    );
  });

  group('tombstones', () {
    test('a pulled tombstone deletes the row and its outbox entries', () async {
      final bossId = await saveBoss();
      await service.sync();
      await asRemote([gone('bosses', bossId)]);
      await h.db.customStatement(
        "UPDATE bosses SET title = 'Late', updated_at = ? WHERE id = ?",
        [h.clock().toIso8601String(), bossId],
      );
      expect(await outbox.pending(), isNotEmpty);

      await service.sync();
      // The stale edit was pushed first and acknowledged as a no-op.
      expect(fake.pushes.last.$2.single.table, 'bosses');
      expect(await count('bosses'), 0);
      expect(await outbox.pending(), isEmpty);
      expect(fake.isDeleted('bosses', bossId), isTrue);
    });

    test(
      'a pulled boss tombstone removes its children, queueing nothing',
      () async {
        final bossId = await saveBoss();
        await service.sync();
        expect(await count('tasks'), 2);

        await asRemote([gone('bosses', bossId)]);
        await service.sync();
        expect(await count('bosses'), 0);
        expect(await count('phases'), 0);
        expect(await count('tasks'), 0);
        expect(await outbox.pending(), isEmpty);
      },
    );

    test('tombstones that never existed here are harmless', () async {
      await asRemote([gone('bosses', 'never-seen')]);
      expect(await service.sync(), SyncOutcome.synced);
      expect(await count('bosses'), 0);
    });
  });

  group('failures', () {
    test(
      'a network error keeps the outbox and cursor, and sets lastError',
      () async {
        await saveBoss();
        final before = (await outbox.pending()).length;
        fake.failCalls = 1;
        expect(await service.sync(), SyncOutcome.failed);

        expect((await outbox.pending()).length, before);
        final state = await h.db.select(h.db.syncState).getSingle();
        expect(state.cursor, 0);
        expect(state.lastError, isNotNull);

        expect(await service.sync(), SyncOutcome.synced);
        expect(await outbox.pending(), isEmpty);
        expect(
          (await h.db.select(h.db.syncState).getSingle()).lastError,
          isNull,
        );
      },
    );

    test(
      'a failed pull after a good push still keeps what was acked',
      () async {
        await saveBoss();
        // Push call succeeds, pull call throws.
        fake.duringPush = () async => fake.failCalls = 1;
        expect(await service.sync(), SyncOutcome.failed);
        expect(await outbox.pending(), isEmpty);
        expect((await h.db.select(h.db.syncState).getSingle()).cursor, 0);
      },
    );

    test('a 401 sets sessionEnded and stops without an error line', () async {
      await saveBoss();
      fake.unauthorized = true;
      expect(await service.sync(), SyncOutcome.signedOut);
      final state = await h.db.select(h.db.syncState).getSingle();
      expect(state.sessionEnded, isTrue);
      expect(state.lastError, isNull);
      expect(await outbox.pending(), isNotEmpty);
    });

    test('runs do not overlap', () async {
      await saveBoss();
      final a = service.sync();
      final b = service.sync();
      expect(await a, SyncOutcome.synced);
      expect(await b, SyncOutcome.synced);
      expect(fake.pushes, hasLength(1));
    });
  });

  group('settings and bloodstains', () {
    test('firstDay becomes the earliest of local and remote (D9)', () async {
      // Local first_day is 2026-10-13 (the harness install day).
      await asRemote([
        remote('user_settings', 'user', {
          'first_day': '2026-10-01',
          'tap_mode': true,
        }, updatedAt: _newer),
      ]);
      await service.sync();
      expect(await cell('SELECT first_day FROM user_settings'), '2026-10-01');
      expect(await cell('SELECT tap_mode FROM user_settings'), 1);
      expect(await outbox.pending(), isEmpty);
    });

    test(
      'a later remote firstDay never wins; the merged row is pushed',
      () async {
        await asRemote([
          remote('user_settings', 'user', {
            'first_day': '2026-10-20',
            'tap_mode': true,
          }, updatedAt: _newer),
        ]);
        await service.sync();
        expect(await cell('SELECT first_day FROM user_settings'), '2026-10-13');
        expect(await cell('SELECT tap_mode FROM user_settings'), 1);

        // The fix is queued, so the account converges on the earliest day.
        expect((await outbox.pending()).map((e) => e.tbl), ['user_settings']);
        await service.sync();
        expect(fake.rowOf('user_settings', 'user')!['first_day'], '2026-10-13');
        expect(await outbox.pending(), isEmpty);
      },
    );

    test(
      'a pulled bloodstain settles the boss, and the fix is queued',
      () async {
        final bossId = await saveBoss();
        final stains = BloodstainDao(h.db, h.clock.call);
        final s1 = await stains.drop(bossId: bossId, amount: 3);
        await service.sync();
        final created = DateTime.parse(
          (await cell('SELECT created_at FROM bloodstains WHERE id = ?', [s1]))!
              as String,
        );
        final later = created
            .add(const Duration(hours: 1))
            .toUtc()
            .toIso8601String();
        // Another phone dropped s2 without ever seeing s1.
        final other = FakeSyncApi(now: () => DateTime.parse(_serverNow));
        await other.push('other', [
          remote('bosses', bossId, {}, updatedAt: _older),
          remote('bloodstains', 's2', {
            'boss_id': bossId,
            'created_at': later,
          }, updatedAt: later),
        ]);
        await h.db.customStatement('UPDATE sync_state SET cursor = 0');
        final svc = SyncService(
          db: h.db,
          api: other,
          clock: h.clock.call,
          appVersion: '0.7.0',
        );
        await svc.sync();

        // s2 is newer and stays active; s1 is lost at s2's time. The fix ran
        // after `applying` ended, so it is queued; s2 itself is not.
        expect(
          await cell("SELECT lost_at FROM bloodstains WHERE id = 's2'"),
          isNull,
        );
        expect(
          await cell(
            'SELECT lost_at IS NOT NULL FROM bloodstains WHERE id = ?',
            [s1],
          ),
          1,
        );
        expect((await outbox.pending()).map((e) => (e.tbl, e.rowId)), [
          ('bloodstains', s1),
        ]);

        await svc.sync();
        expect(await outbox.pending(), isEmpty);
        expect(other.rowOf('bloodstains', s1)!['lost_at'], isNotNull);
        expect(other.rowOf('bloodstains', 's2')!['lost_at'], isNull);
      },
    );

    test('a remote recovery stands against a local loss', () async {
      final bossId = await saveBoss();
      final stains = BloodstainDao(h.db, h.clock.call);
      final s1 = await stains.drop(bossId: bossId, amount: 3);
      await stains.drop(bossId: bossId, amount: 3); // s1 is now lost
      await service.sync();
      await asRemote([
        remote('bloodstains', s1, {
          'boss_id': bossId,
          'created_at': '2026-10-13T12:00:00.000Z',
          'recovered_at': '2026-10-13T12:30:00.000Z',
        }, updatedAt: _newer),
      ]);
      await service.sync();
      expect(
        await cell('SELECT lost_at FROM bloodstains WHERE id = ?', [s1]),
        isNull,
      );
      expect(
        await cell(
          'SELECT recovered_at IS NOT NULL FROM bloodstains WHERE id = ?',
          [s1],
        ),
        1,
      );
    });
  });

  group('a defeat is final across phones', () {
    const defeatedIndex = 2; // BossStatus.defeated

    test('a newer edit from another phone and our defeat both stand', () async {
      final bossId = await saveBoss();
      await h.bosses.setStatus(bossId, BossStatus.defeated);
      final defeatedAt = await cell(
        'SELECT defeated_at FROM bosses WHERE id = ?',
        [bossId],
      );
      await asRemote([
        remote('bosses', bossId, {'title': 'Edited by B'}, updatedAt: _newer),
      ]);
      await service.sync();

      expect(
        await cell('SELECT title FROM bosses WHERE id = ?', [bossId]),
        'Edited by B',
      );
      expect(
        await cell('SELECT status FROM bosses WHERE id = ?', [bossId]),
        defeatedIndex,
      );
      expect(
        await cell('SELECT defeated_at FROM bosses WHERE id = ?', [bossId]),
        defeatedAt,
      );
      // The push came first, so the server merged them the same way.
      expect(fake.rowOf('bosses', bossId)!['status'], defeatedIndex);
      expect(fake.rowOf('bosses', bossId)!['title'], 'Edited by B');
      expect(await outbox.pending(), isEmpty);
    });

    test(
      'a defeat made while the push is in flight is kept and re-sent',
      () async {
        final bossId = await saveBoss();
        await service.sync();
        await asRemote([
          remote('bosses', bossId, {'title': 'Edited by B'}, updatedAt: _newer),
        ]);
        await h.bosses.setPinned(bossId, isPinned: true);
        // The defeat lands after the push was built, before the pull.
        fake.duringPush = () => h.bosses.setStatus(bossId, BossStatus.defeated);
        await service.sync();

        expect(
          await cell('SELECT title FROM bosses WHERE id = ?', [bossId]),
          'Edited by B',
        );
        expect(
          await cell('SELECT status FROM bosses WHERE id = ?', [bossId]),
          defeatedIndex,
        );
        // The merged row is newer than the remote edit, so it wins there.
        final updated = DateTime.parse(
          (await cell('SELECT updated_at FROM bosses WHERE id = ?', [bossId]))!
              as String,
        );
        expect(updated.isAfter(DateTime.parse(_newer)), isTrue);
        expect(
          (await outbox.pending())
              .where((e) => e.tbl == 'bosses')
              .map((e) => e.rowId),
          [bossId],
        );

        await service.sync();
        expect(fake.rowOf('bosses', bossId)!['status'], defeatedIndex);
        expect(fake.rowOf('bosses', bossId)!['title'], 'Edited by B');
        expect(await outbox.pending(), isEmpty);
      },
    );

    test(
      'an older defeat from another phone is taken over our newer edit',
      () async {
        final bossId = await saveBoss();
        await service.sync();
        await h.bosses.saveBoss(
          BossDraft(
            id: bossId,
            title: 'Edited here',
            resetOnFail: ResetOnFail.nothing,
            standalone: const [],
            phases: const [],
          ),
          allowEmpty: true,
        );
        // Another phone, older than our edit, defeated it.
        final other = FakeSyncApi(now: () => DateTime.parse(_serverNow));
        await other.push('other', [
          remote('bosses', bossId, {
            'status': defeatedIndex,
            'defeated_at': '2026-10-02T00:00:00.000Z',
          }, updatedAt: _older),
        ]);
        await h.db.customStatement('UPDATE sync_state SET cursor = 0');
        await SyncService(
          db: h.db,
          api: other,
          clock: h.clock.call,
          appVersion: '0.7.0',
        ).sync();

        expect(
          await cell('SELECT status FROM bosses WHERE id = ?', [bossId]),
          defeatedIndex,
        );
        expect(
          DateTime.parse(
            (await cell('SELECT defeated_at FROM bosses WHERE id = ?', [
                  bossId,
                ]))!
                as String,
          ).toUtc(),
          DateTime.utc(2026, 10, 2),
        );
        expect(
          await cell('SELECT title FROM bosses WHERE id = ?', [bossId]),
          'Edited here',
        );
      },
    );

    test('two defeats keep the earliest time', () async {
      final bossId = await saveBoss();
      await h.bosses.setStatus(bossId, BossStatus.defeated); // 2026-10-13
      await asRemote([
        remote('bosses', bossId, {
          'status': defeatedIndex,
          'defeated_at': '2026-10-12T08:00:00.000Z',
        }, updatedAt: _newer),
      ]);
      await service.sync();
      expect(
        DateTime.parse(
          (await cell('SELECT defeated_at FROM bosses WHERE id = ?', [bossId]))!
              as String,
        ).toUtc(),
        DateTime.utc(2026, 10, 12, 8),
      );
    });

    test('a boss that is not defeated follows last write wins', () async {
      final bossId = await saveBoss();
      await service.sync();
      await asRemote([
        remote('bosses', bossId, {
          'title': 'B',
          'status': 1,
        }, updatedAt: _newer),
      ]);
      await service.sync();
      expect(await cell('SELECT status FROM bosses WHERE id = ?', [bossId]), 1);
      expect(await outbox.pending(), isEmpty);
    });
  });

  group('the shared bloodstain cases', () {
    final fixture = jsonDecode(
      File('../server/test/fixtures/bloodstains.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    ChangeDto stain(Map<String, dynamic> r) =>
        remote('bloodstains', r['id'] as String, {
          'boss_id': 'b1',
          for (final e in r.entries)
            if (e.key != 'id' && e.key != 'updated_at') e.key: e.value,
        }, updatedAt: (r['updated_at'] ?? r['created_at']) as String);

    String? iso(Object? v) => v == null
        ? null
        : DateTime.parse(v as String).toUtc().toIso8601String();

    for (final c in fixture['cases'] as List) {
      final batches = [
        for (final b in c['batches'] as List)
          [for (final r in b as List) stain(r as Map<String, dynamic>)],
      ];
      for (final (label, order) in [
        ('in order', batches),
        ('reversed', batches.reversed.toList()),
      ]) {
        test('${c['name']} ($label): the fake server', () async {
          final server = FakeSyncApi(now: () => DateTime.parse(_serverNow));
          await server.push('seed', [remote('bosses', 'b1', {})]);
          for (final (i, b) in order.indexed) {
            await server.push('dev-$i', b);
          }
          expect(
            [
              for (final id in server.liveIds('bloodstains')..sort())
                (
                  id,
                  iso(server.rowOf('bloodstains', id)!['recovered_at']),
                  iso(server.rowOf('bloodstains', id)!['lost_at']),
                ),
            ],
            [
              for (final e in c['expect'] as List)
                (e['id'], iso(e['recovered_at']), iso(e['lost_at'])),
            ],
          );
        });

        test('${c['name']} ($label): applied by pull', () async {
          await h.db.customStatement(
            "INSERT INTO bosses (id, title, status, reset_on_fail, created_at, updated_at) "
            "VALUES ('b1', 'B', 0, 0, '2026-10-01T00:00:00.000Z', '2026-10-01T00:00:00.000Z')",
          );
          for (final (i, b) in order.indexed) {
            // Each batch arrives as its own pull, as from another phone.
            final server = FakeSyncApi(now: () => DateTime.parse(_serverNow));
            await server.push('dev-$i', b);
            await SyncService(
              db: h.db,
              api: server,
              clock: h.clock.call,
              appVersion: '0.7.0',
            ).sync();
            await h.db.customStatement('UPDATE sync_state SET cursor = 0');
          }
          expect(
            [
              for (final r in await rows(
                'SELECT id, recovered_at, lost_at FROM bloodstains ORDER BY id',
              ))
                (r['id'], iso(r['recovered_at']), iso(r['lost_at'])),
            ],
            [
              for (final e in c['expect'] as List)
                (e['id'], iso(e['recovered_at']), iso(e['lost_at'])),
            ],
          );
        });
      }
    }
  });
}

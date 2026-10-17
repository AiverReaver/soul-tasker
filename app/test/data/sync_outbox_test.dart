import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/sync_dao.dart';
import 'package:hearthrise/data/tables.dart' show kUserSettingsId;
import 'package:hearthrise/data/visit_dao.dart';

import 'harness.dart';

void main() {
  late Harness h;
  late SyncDao sync;
  setUp(() {
    h = Harness();
    sync = SyncDao(h.db);
  });
  tearDown(() => h.db.close());

  Future<List<(String, SyncOp)>> queued() async => [
    for (final e in await sync.pending()) (e.tbl, e.op),
  ];

  Future<String> saveBoss() => h.bosses.saveBoss(
    const BossDraft(
      title: 'The Garage',
      resetOnFail: ResetOnFail.nothing,
      phases: [
        PhaseDraft(
          name: 'Clear',
          tasks: [
            TaskDraft(title: 'Sweep'),
            TaskDraft(title: 'Bins'),
          ],
        ),
        PhaseDraft(
          name: 'Build',
          tasks: [TaskDraft(title: 'Shelves')],
        ),
      ],
    ),
  );

  test('a fresh database has an empty outbox', () async {
    expect(await sync.pending(), isEmpty);
  });

  test('a new boss queues one upsert per row', () async {
    await saveBoss();
    final rows = await queued();
    int count(String t) => rows.where((r) => r.$1 == t).length;
    expect(count('bosses'), greaterThanOrEqualTo(1));
    expect(count('phases'), greaterThanOrEqualTo(2));
    expect(count('tasks'), greaterThanOrEqualTo(3));
    expect(rows.map((r) => r.$2), everyElement(SyncOp.upsert));
    // One distinct row id per record.
    final ids = {for (final e in await sync.pending()) '${e.tbl}/${e.rowId}'};
    expect(ids, hasLength(6));
  });

  test('editing queues an upsert; deleting queues every cascade', () async {
    final id = await saveBoss();
    final view = (await h.bosses.loadBoss(id))!;
    await sync.ack([for (final e in await sync.pending()) e.seq]);

    await h.db.customStatement(
      "UPDATE bosses SET title = 'The Shed' WHERE id = ?",
      [id],
    );
    expect(await queued(), [('bosses', SyncOp.upsert)]);
    await sync.ack([for (final e in await sync.pending()) e.seq]);

    await h.bosses.deleteBoss(id);
    final deletes = {
      for (final e in await sync.pending())
        if (e.op == SyncOp.delete) e.rowId,
    };
    expect(deletes, {
      id,
      for (final p in view.phases) p.phase.id,
      for (final t in view.allTasks) t.task.id,
    });
  });

  test('nothing is queued while applying a pull', () async {
    await sync.setApplying(true);
    await saveBoss();
    await sync.setApplying(false);
    expect(await sync.pending(), isEmpty);
  });

  test('per-device and tester tables queue nothing (D9, D10)', () async {
    await VisitDao(h.db, h.clock.call).record();
    await h.settings.setOnboarded(true);
    await h.db.customStatement("UPDATE sync_state SET last_error = 'x'");
    await h.db.customStatement(
      "INSERT INTO signal_events (id, kind, day, at) "
      "VALUES ('s1', 0, '2026-10-13', '2026-10-13T12:00:00.000')",
    );
    expect(await sync.pending(), isEmpty);
  });

  test('synced settings, day logs and day plans are queued', () async {
    await h.settings.setHaptics(false);
    await h.db.customStatement(
      "INSERT INTO day_logs (day, kind, at, updated_at) VALUES "
      "('2026-10-13', 2, '2026-10-13T12:00:00.000', "
      "'2026-10-13T12:00:00.000')",
    );
    await h.db.customStatement(
      "INSERT INTO day_plans (day, task_ids, updated_at) VALUES "
      "('2026-10-14', '[]', '2026-10-13T12:00:00.000')",
    );
    expect(
      {for (final e in await sync.pending()) '${e.tbl}/${e.rowId}'},
      {
        'user_settings/$kUserSettingsId',
        'day_logs/2026-10-13:2',
        'day_plans/2026-10-14',
      },
    );
  });

  test('a write that throws in a transaction leaves no outbox row', () async {
    await expectLater(
      h.db.transaction(() async {
        await saveBoss();
        throw StateError('boom');
      }),
      throwsStateError,
    );
    expect(await sync.pending(), isEmpty);
  });

  test('a delete keeps the clock time after the row is gone', () async {
    final id = await saveBoss();
    await sync.ack([for (final e in await sync.pending()) e.seq]);
    h.clock.now = DateTime(2026, 10, 20, 9, 30);
    await h.bosses.deleteBoss(id);
    final entry = (await sync.pending()).firstWhere(
      (e) => e.tbl == 'bosses' && e.rowId == id,
    );
    expect(entry.op, SyncOp.delete);
    expect(entry.at, DateTime(2026, 10, 20, 9, 30));
    expect(await h.bosses.loadBoss(id), isNull);
  });

  test('ack removes only the captured seqs (D14)', () async {
    final id = await saveBoss();
    final captured = [for (final e in await sync.pending()) e.seq];
    // An edit while the push is in flight.
    await h.db.customStatement(
      "UPDATE bosses SET title = 'The Shed' WHERE id = ?",
      [id],
    );
    await sync.ack(captured);
    final left = await sync.pending();
    expect(left, hasLength(1));
    expect(left.single.rowId, id);
  });

  test('a quarantined entry is skipped but kept', () async {
    await h.settings.setHaptics(false);
    final entry = (await sync.pending()).single;
    await sync.quarantine(entry.seq, 'bad field');
    expect(await sync.pending(), isEmpty);
    expect(await sync.quarantined(), hasLength(1));
  });
}

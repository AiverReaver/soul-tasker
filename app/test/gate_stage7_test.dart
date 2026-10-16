@Tags(['sync-gate'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:hearthrise/core/deadlines.dart';
import 'package:hearthrise/data/account_api.dart';
import 'package:hearthrise/data/account_service.dart';
import 'package:hearthrise/data/bloodstain_dao.dart';
import 'package:hearthrise/data/boss_draft.dart';
import 'package:hearthrise/data/boss_view.dart';
import 'package:hearthrise/data/commitment_dao.dart';
import 'package:hearthrise/data/day_dao.dart';
import 'package:hearthrise/data/ember_dao.dart';
import 'package:hearthrise/data/enums.dart';
import 'package:hearthrise/data/flask_dao.dart';
import 'package:hearthrise/data/health_dao.dart';
import 'package:hearthrise/data/http_account_api.dart';
import 'package:hearthrise/data/http_sync_api.dart';
import 'package:hearthrise/data/sync_dao.dart';
import 'package:hearthrise/data/sync_schema.dart';
import 'package:hearthrise/data/sync_service.dart';
import 'package:hearthrise/data/sync_sql.dart';
import 'package:hearthrise_api/hearthrise_api.dart' show HearthriseApi;

import 'data/harness.dart';
import 'support/fake_account.dart';

// The Stage 7 gate, scripted (STAGE7_PLAN.md step 11, gate items 1 to 3):
// two in-memory app databases, the real server and real PostgreSQL. Run it
// with tool/gate_stage7.sh, which starts the server and sets the variables.
final _url = Platform.environment['GATE_BASE_URL'];
final _tokens = (Platform.environment['GATE_ID_TOKENS'] ?? '').split(',');
const _needsServer = 'Run tool/gate_stage7.sh: it starts the real server.';

/// One phone: its own database and clock, signed in to the real server
/// through the same services the app uses.
class Phone {
  Phone(this.name, String idToken) : h = Harness() {
    gateway = FakeAuthGateway()..idToken = idToken;
    account = AccountService(
      db: h.db,
      gateway: gateway,
      api: HttpAccountApi(_dio),
      runSync: () => service!.sync(),
      currentSession: () => session,
      setSession: (s) {
        session = s;
        service = s == null
            ? null
            : SyncService(
                db: h.db,
                api: HttpSyncApi(
                  HearthriseApi(dio: _dio(s.token)).getSyncApi(),
                ),
                clock: h.clock.call,
                appVersion: 'gate',
              );
      },
    );
    commits = CommitmentDao(h.db, h.clock.call);
    health = HealthDao(h.db, h.clock.call, h.attempts);
    days = DayDao(h.db, h.clock.call, h.attempts);
    embers = EmberDao(h.db, h.clock.call);
    stains = BloodstainDao(h.db, h.clock.call);
    flasks = FlaskDao(h.db, h.clock.call);
  }

  final String name;
  final Harness h;
  late final FakeAuthGateway gateway;
  late final AccountService account;
  late final CommitmentDao commits;
  late final HealthDao health;
  late final DayDao days;
  late final EmberDao embers;
  late final BloodstainDao stains;
  late final FlaskDao flasks;
  AccountSession? session;
  SyncService? service;

  static Dio _dio([String? token]) => Dio(
    BaseOptions(
      baseUrl: _url!,
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
    ),
  );

  /// Sets this phone's clock to October [day], [hour]:[minute].
  void at(int day, int hour, [int minute = 0]) =>
      h.clock.now = DateTime(2026, 10, day, hour, minute);

  Future<SignInResult> signIn() =>
      account.signIn(confirmBackup: (_) async => true);

  Future<SyncOutcome> sync() => service!.sync();

  Future<String> boss(String title, List<(String, Weight)> tasks) =>
      h.bosses.saveBoss(
        BossDraft(
          title: title,
          resetOnFail: ResetOnFail.nothing,
          standalone: [
            for (final (t, w) in tasks) TaskDraft(title: t, weight: w),
          ],
        ),
      );

  Future<String> taskId(String bossId, String title) async =>
      taskNamedIn(await h.reload(bossId), title);

  String taskNamedIn(BossView view, String title) =>
      view.allTasks.firstWhere((t) => t.task.title == title).task.id;

  Future<int> pending() async => (await SyncDao(h.db).pending()).length;

  /// Every synced table, rows in key order, times as microseconds so a
  /// local and a server spelling of one instant compare equal.
  Future<Map<String, List<Map<String, Object?>>>> dump() async => {
    for (final table in kSyncedTables.keys) table: await _rows(table),
  };

  Future<List<Map<String, Object?>>> _rows(String table) async {
    final id = kSyncedTables[table]!.replaceAll('{r}', table);
    final result = await h.db
        .customSelect('SELECT * FROM $table ORDER BY $id')
        .get();
    final types = kSyncColumns[table]!;
    return [
      for (final r in result)
        {
          for (final MapEntry(key: col, value: v) in r.data.entries)
            col:
                v != null &&
                    (types[col] == 'timestamptz' || col == 'updated_at')
                ? DateTime.parse(v as String).toUtc().microsecondsSinceEpoch
                : v,
        },
    ];
  }

  Future<Set<String>> ids(String table) async => {
    for (final r in await h.db.customSelect('SELECT id FROM $table').get())
      r.read<String>('id'),
  };
}

/// Syncs in [order] first, then keeps going round until nothing is queued
/// and a full pass changes nothing, so merge results that were queued
/// during a pull reach every phone.
Future<void> converge(List<Phone> order) async {
  for (var round = 0; round < 8; round++) {
    for (final p in order) {
      expect(await p.sync(), SyncOutcome.synced, reason: p.name);
    }
    if (round >= 1) {
      var queued = 0;
      for (final p in order) {
        queued += await p.pending();
      }
      if (queued == 0) return;
    }
  }
  fail('the phones did not settle');
}

void main() {
  var run = 0;
  String nextToken() => _tokens[run++ % _tokens.length];

  group('gate item 1: two phones offline, then merged', () {
    for (final aFirst in [true, false]) {
      test('synced ${aFirst ? 'A then B' : 'B then A'}', () async {
        final token = nextToken();
        final a = Phone('A', token);
        final b = Phone('B', token);
        addTearDown(a.h.db.close);
        addTearDown(b.h.db.close);
        a.at(13, 12);
        b.at(13, 12);

        // --- Online: one account, one starting world. -------------------
        await a.signIn();
        final x = await a.boss('Garage', [
          ('g1', Weight.light),
          ('g2', Weight.light),
        ]);
        final y = await a.boss('Studies', [
          ('s1', Weight.light),
          ('s2', Weight.heavy),
        ]);
        final z = await a.boss('Taxes', [('z1', Weight.light)]);
        await converge([a]);
        await b.signIn();
        expect(await b.ids('bosses'), {x, y, z});

        // Day 14, morning: A promises s2 for 09:00 and leaves a bloodstain
        // on Studies; both phones then go offline.
        final s2 = await a.taskId(y, 's2');
        a.at(14, 8);
        await a.commits.commit(s2, DeadlinePreset.oneHour);
        a.at(14, 8, 10);
        final s0 = await a.stains.drop(bossId: y, amount: 3);
        await converge([a, b]);
        expect(await b.ids('commitments'), hasLength(1));
        expect(await b.ids('bloodstains'), {s0});

        // --- Offline, day 14. -------------------------------------------
        // B edits the title of the boss A is about to defeat.
        b.at(14, 9);
        final garage = await b.h.reload(x);
        await b.h.bosses.saveBoss(
          BossDraft.fromView(garage).copyWith(title: 'Garage, B\'s edit'),
        );

        // A: the deadline passes, two strikes defeat Garage, a bloodstain on
        // Taxes, the Studies stain is recovered, a bonfire, a relic note.
        a.at(14, 9, 30);
        await a.health.resolveDue();
        a.at(14, 9, 40);
        await a.h.attempts.strike(await a.taskId(x, 'g1'));
        await a.h.attempts.strike(await a.taskId(x, 'g2'));
        await a.h.bosses.setStatus(x, BossStatus.defeated);
        a.at(14, 10);
        final sa = await a.stains.drop(bossId: z, amount: 2);
        a.at(14, 10, 30);
        expect(await a.stains.recover(s0), isTrue);
        a.at(14, 20);
        expect(await a.days.rest(lesson: 'Start before nine.'), isTrue);
        final relicId = (await a.h.relics.idForBoss(x))!;
        await a.h.relics.setInscription(relicId, 'Swept clean.');

        // B: one strike, the same deadline passes, newer bloodstains on both
        // Taxes and Studies, and a flask to cover the day.
        b.at(14, 10);
        await b.h.attempts.strike(await b.taskId(y, 's1'));
        b.at(14, 10, 15);
        await b.health.resolveDue();
        b.at(14, 11);
        final sb = await b.stains.drop(bossId: z, amount: 2);
        b.at(14, 11, 30);
        final s1 = await b.stains.drop(bossId: y, amount: 3);
        b.at(14, 21);
        expect(await b.days.skipToday(), isTrue);

        // Day 15 passes untouched. On day 16 both phones judge it.
        for (final p in [a, b]) {
          p.at(16, 9);
          await p.health.resolveDue();
          expect(await p.days.resolve(), greaterThan(0), reason: p.name);
        }

        final relicBefore =
            (await a.h.db.customSelect('SELECT * FROM relics').getSingle())
                .data;

        // Everything either phone has, before they meet.
        final before = <String, Set<String>>{
          for (final t in ['ember_events', 'health_events', 'flask_events'])
            t: {...await a.ids(t), ...await b.ids(t)},
        };

        // --- Back online, in either order. ------------------------------
        await converge(aFirst ? [a, b] : [b, a]);

        // Row for row equal on every synced table.
        expect(await a.dump(), await b.dump());

        // Embers, health and flasks are the sum of both phones' events.
        for (final t in before.keys) {
          expect(await a.ids(t), before[t], reason: '$t on A');
          expect(await b.ids(t), before[t], reason: '$t on B');
        }
        expect(await a.embers.tally(), await b.embers.tally());
        expect(
          await a.health.health('2026-10-14'),
          await b.health.health('2026-10-14'),
        );
        expect(
          await a.health.health('2026-10-16'),
          await b.health.health('2026-10-16'),
        );
        expect(await a.flasks.count(), await b.flasks.count());

        // The deadline both phones missed cost health once, not twice.
        final misses = await a.h.db
            .customSelect(
              'SELECT COUNT(*) AS c FROM health_events WHERE reason = ? '
              'AND commitment_id IS NOT NULL',
              variables: [Variable(HealthReason.miss.index)],
            )
            .getSingle();
        expect(misses.data['c'], 1);

        // The relic exists once; only its inscription changed.
        for (final p in [a, b]) {
          final relics = await p.h.db
              .customSelect('SELECT * FROM relics')
              .get();
          expect(relics, hasLength(1), reason: p.name);
          expect(relics.single.read<String>('id'), relicId);
          // Unchanged but for its own inscription, even though B edited the
          // boss it was made from.
          expect(relics.single.data, relicBefore, reason: p.name);
          expect(relics.single.read<String>('inscription'), 'Swept clean.');
        }

        // The missed day: one fall per boss, one counted attempt each.
        for (final p in [a, b]) {
          final falls = await p.h.db
              .customSelect(
                'SELECT boss_id, COUNT(*) AS c FROM attempts '
                'WHERE outcome = ? GROUP BY boss_id',
                variables: [Variable(Outcome.fallen.index)],
              )
              .get();
          final byBoss = {
            for (final r in falls) r.read<String>('boss_id'): r.read<int>('c'),
          };
          expect(byBoss[y], 1, reason: '${p.name}: Studies');
          expect(byBoss[z], 1, reason: '${p.name}: Taxes');
          for (final MapEntry(key: bossId, value: n) in byBoss.entries) {
            final boss = (await p.h.reload(bossId)).boss;
            expect(boss.attemptNumber, 1 + n, reason: '${p.name} $bossId');
          }
        }

        // Bloodstains: Taxes keeps the newer one; on Studies the recovery
        // stands and the newer drop is the one that is active.
        for (final p in [a, b]) {
          Future<(bool, bool)> state(String id) async {
            final r =
                (await p.h.db
                        .customSelect(
                          'SELECT recovered_at, lost_at FROM bloodstains WHERE id = ?',
                          variables: [Variable(id)],
                        )
                        .getSingle())
                    .data;
            return (r['recovered_at'] != null, r['lost_at'] != null);
          }

          expect(await state(sa), (false, true), reason: '${p.name} Sa');
          expect(await state(sb), (false, false), reason: '${p.name} Sb');
          expect(await state(s0), (true, false), reason: '${p.name} S0');
          expect(await state(s1), (false, false), reason: '${p.name} S1');
        }
      });
    }
  }, skip: _url == null ? _needsServer : false);

  group('gate item 2: edits and deletes across two phones', () {
    for (final aFirst in [true, false]) {
      test('synced ${aFirst ? 'A then B' : 'B then A'}', () async {
        final token = nextToken();
        final a = Phone('A', token);
        final b = Phone('B', token);
        addTearDown(a.h.db.close);
        addTearDown(b.h.db.close);
        a.at(13, 12);
        b.at(13, 12);
        await a.signIn();
        final both = await a.boss('Shared', [('u1', Weight.light)]);
        final early = await a.boss('Edited before the delete', [
          ('e1', Weight.light),
          ('e2', Weight.light),
        ]);
        final late = await a.boss('Edited after the delete', [
          ('l1', Weight.light),
        ]);
        await converge([a]);
        await b.signIn();
        await converge([a, b]);

        Future<void> rename(Phone p, String id, String title) async {
          final view = await p.h.reload(id);
          await p.h.bosses.saveBoss(
            BossDraft.fromView(view).copyWith(title: title),
          );
        }

        // Both edit one boss: the later edit wins on both phones.
        a.at(14, 10);
        await rename(a, both, 'Shared, by A');
        b.at(14, 11);
        await rename(b, both, 'Shared, by B');

        // B edits a boss before A deletes it; and edits another after.
        b.at(14, 11);
        await rename(b, early, 'B was early');
        a.at(14, 12);
        await a.h.bosses.deleteBoss(early);
        await a.h.bosses.deleteBoss(late);
        b.at(14, 13);
        await rename(b, late, 'B was late');

        await converge(aFirst ? [a, b] : [b, a]);

        for (final p in [a, b]) {
          expect(await p.ids('bosses'), {both}, reason: p.name);
          expect(
            await p.ids('tasks'),
            hasLength(1),
            reason: '${p.name} children',
          );
          expect(
            (await p.h.reload(both)).boss.title,
            'Shared, by B',
            reason: p.name,
          );
          expect(await p.pending(), 0, reason: '${p.name} outbox');
        }
        expect(await a.dump(), await b.dump());
      });
    }
  }, skip: _url == null ? _needsServer : false);

  test(
    'gate item 3: a phone with local data meets an account with data',
    () async {
      final token = nextToken();
      final a = Phone('A', token);
      final c = Phone('C', token);
      addTearDown(a.h.db.close);
      addTearDown(c.h.db.close);
      a.at(13, 12);
      c.at(13, 12);
      await a.signIn();
      final fromA = await a.boss('From A', [('a1', Weight.heavy)]);
      await converge([a]);

      // C has been used offline, on its own, and only now signs in.
      final fromC = await c.boss('From C', [('c1', Weight.light)]);
      await c.h.attempts.strike(await c.taskId(fromC, 'c1'));
      final result = await c.signIn();
      expect(result.outcome, SignInOutcome.signedIn);
      expect(result.showMergeNotice, isTrue);
      await converge([a, c]);

      for (final p in [a, c]) {
        expect(await p.ids('bosses'), {fromA, fromC}, reason: p.name);
        expect(await p.ids('tasks'), hasLength(2), reason: p.name);
        expect(await p.ids('ember_events'), hasLength(1), reason: p.name);
      }
      expect(await a.dump(), await c.dump());
    },
    skip: _url == null ? _needsServer : false,
  );
}

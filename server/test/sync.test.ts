import { readFileSync } from 'node:fs';
import { afterEach, beforeEach, describe, expect, test } from 'vitest';
import { testApp } from './helpers.ts';
import { SYNCED_COLUMNS } from '../src/tables.ts';

type Change = {
  table: string;
  id: string;
  op: 'upsert' | 'delete';
  updatedAt?: string;
  deletedAt?: string;
  row?: Record<string, unknown>;
};
type Result = { table: string; id: string; status: 'applied' | 'ignored' | 'rejected'; reason?: string };
type Pulled = Change & { seq: number; deviceId: string };

const T0 = '2026-10-16T09:00:00.000Z';
const T1 = '2026-10-16T10:00:00.000Z';
const T2 = '2026-10-16T11:00:00.000Z';
const NOW = new Date('2026-10-16T12:00:00Z');

/** A full payload with plain defaults, so tests name only what matters. */
function row(table: string, values: Record<string, unknown> = {}) {
  const defaults: Record<string, unknown> = {};
  for (const [col, type] of Object.entries(SYNCED_COLUMNS[table]!)) {
    defaults[col] = { text: 'x', integer: 0, boolean: false, timestamptz: T0, jsonb: [] }[type];
  }
  return { ...defaults, ...values };
}

const upsert = (
  table: string,
  id: string,
  values: Record<string, unknown> = {},
  updatedAt: string | undefined = T0,
): Change => ({ table, id, op: 'upsert', updatedAt, row: row(table, values) });
const event = (table: string, id: string, values: Record<string, unknown> = {}): Change => ({
  table,
  id,
  op: 'upsert',
  row: row(table, values),
});
const del = (table: string, id: string, deletedAt = T1): Change => ({ table, id, op: 'delete', deletedAt });

let t: Awaited<ReturnType<typeof testApp>>;
let token: string;
beforeEach(async () => {
  t = await testApp({ now: () => NOW });
  token = (await t.signIn()).token;
});
afterEach(() => t.close());

async function push(changes: Change[], deviceId = 'dev-a', as = token) {
  const res = await t.app.inject({
    method: 'POST',
    url: '/v1/sync/push',
    headers: { authorization: `Bearer ${as}` },
    payload: { deviceId, changes },
  });
  expect(res.statusCode, res.body).toBe(200);
  return (res.json() as { results: Result[] }).results;
}

async function pull(since = 0, as = token) {
  const res = await t.app.inject({
    method: 'GET',
    url: `/v1/sync/pull?since=${since}`,
    headers: { authorization: `Bearer ${as}` },
  });
  expect(res.statusCode, res.body).toBe(200);
  return res.json() as { changes: Pulled[]; cursor: number; hasMore: boolean };
}

async function current(table: string, id: string) {
  const all = (await pull()).changes.filter((c) => c.table === table && c.id === id);
  return all.at(-1);
}

const statuses = (results: Result[]) => results.map((r) => r.status);

test('push and pull need a session', async () => {
  const res = await t.app.inject({ method: 'GET', url: '/v1/sync/pull?since=0' });
  expect(res.statusCode).toBe(401);
  const res2 = await t.app.inject({
    method: 'POST',
    url: '/v1/sync/push',
    payload: { deviceId: 'd', changes: [] },
  });
  expect(res2.statusCode).toBe(401);
});

describe('push then pull', () => {
  test('new rows come back in seq order; the cursor then has nothing', async () => {
    const results = await push([
      upsert('bosses', 'b1', { title: 'The Garage' }),
      upsert('phases', 'p1', { boss_id: 'b1' }),
      upsert('attempts', 'a1', { boss_id: 'b1' }),
    ]);
    expect(statuses(results)).toEqual(['applied', 'applied', 'applied']);
    const page = await pull(0);
    expect(page.changes.map((c) => `${c.table}/${c.id}`)).toEqual(['bosses/b1', 'phases/p1', 'attempts/a1']);
    const seqs = page.changes.map((c) => c.seq);
    expect(seqs).toEqual([...seqs].sort((a, b) => a - b));
    expect(new Set(seqs).size).toBe(3);
    expect(page.cursor).toBe(seqs.at(-1));
    expect(page.hasMore).toBe(false);
    const boss = page.changes[0]!;
    expect(boss.op).toBe('upsert');
    expect(boss.deviceId).toBe('dev-a');
    expect(boss.row?.title).toBe('The Garage');
    expect(new Date(boss.updatedAt!).toISOString()).toBe(T0);
    expect((await pull(page.cursor)).changes).toEqual([]);
  });

  test('timestamps keep microseconds', async () => {
    await push([upsert('bosses', 'b1', {}, '2026-10-16T09:00:00.123456Z')]);
    const boss = await current('bosses', 'b1');
    expect(boss!.updatedAt).toMatch(/09:00:00\.123456/);
  });
});

describe('last write wins (D5)', () => {
  test('an older edit is acknowledged but not applied; a newer one wins', async () => {
    await push([upsert('bosses', 'b1', { title: 'One' }, T1)]);
    expect(statuses(await push([upsert('bosses', 'b1', { title: 'Old' }, T0)], 'dev-b'))).toEqual(['ignored']);
    expect((await current('bosses', 'b1'))!.row!.title).toBe('One');
    expect(statuses(await push([upsert('bosses', 'b1', { title: 'New' }, T2)], 'dev-b'))).toEqual(['applied']);
    const boss = await current('bosses', 'b1');
    expect(boss!.row!.title).toBe('New');
    expect(boss!.deviceId).toBe('dev-b');
  });

  test.each([
    ['a first', ['dev-a', 'dev-b']],
    ['b first', ['dev-b', 'dev-a']],
  ])('equal times break on device id (%s)', async (_, order) => {
    for (const device of order) {
      await push([upsert('bosses', 'b1', { title: device }, T1)], device);
    }
    expect((await current('bosses', 'b1'))!.row!.title).toBe('dev-b');
    // The loser pushed again changes nothing.
    expect(statuses(await push([upsert('bosses', 'b1', { title: 'dev-a' }, T1)], 'dev-a'))).toEqual(['ignored']);
    expect((await current('bosses', 'b1'))!.row!.title).toBe('dev-b');
  });
});

describe('attempts are last write wins', () => {
  test('a lesson added later on one phone reaches the server', async () => {
    await push([upsert('bosses', 'b1'), upsert('attempts', 'a1', { boss_id: 'b1', lesson: null }, T0)]);
    // The other phone wrote the same fall (a system id) without a lesson.
    expect(statuses(await push([upsert('attempts', 'a1', { boss_id: 'b1', lesson: null }, T0)], 'dev-0'))).toEqual([
      'ignored',
    ]);
    expect(statuses(await push([upsert('attempts', 'a1', { boss_id: 'b1', lesson: 'Promise less.' }, T1)], 'dev-b'))).toEqual(
      ['applied'],
    );
    expect((await current('attempts', 'a1'))!.row!.lesson).toBe('Promise less.');
    expect(statuses(await push([upsert('attempts', 'a1', { boss_id: 'b1', lesson: null }, T0)]))).toEqual(['ignored']);
  });

  test('an attempt without updatedAt is malformed', async () => {
    const [r] = await push([event('attempts', 'a1', { boss_id: 'b1' })]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'malformed' });
  });
});

describe('events (D5, D6)', () => {
  test('the same event from two phones is stored once', async () => {
    await push([event('ember_events', 'e1', { amount: 3 })], 'dev-a');
    expect(statuses(await push([event('ember_events', 'e1', { amount: 3 })], 'dev-b'))).toEqual(['ignored']);
    const embers = (await pull()).changes.filter((c) => c.table === 'ember_events');
    expect(embers).toHaveLength(1);
    expect(embers[0]!.deviceId).toBe('dev-a');
  });

  test('an event pushed again with changed fields is ignored', async () => {
    await push([event('health_events', 'h1', { amount: -2 })]);
    expect(statuses(await push([event('health_events', 'h1', { amount: -9 })]))).toEqual(['ignored']);
    expect((await current('health_events', 'h1'))!.row!.amount).toBe(-2);
  });
});

describe('tombstones (D5)', () => {
  test('a delete beats an earlier and a later edit', async () => {
    await push([upsert('bosses', 'b1', {}, T0)]);
    expect(statuses(await push([del('bosses', 'b1', T1)], 'dev-a'))).toEqual(['applied']);
    expect(statuses(await push([upsert('bosses', 'b1', { title: 'early' }, T0)], 'dev-b'))).toEqual(['ignored']);
    expect(statuses(await push([upsert('bosses', 'b1', { title: 'late' }, T2)], 'dev-b'))).toEqual(['ignored']);
    const boss = await current('bosses', 'b1');
    expect(boss!.op).toBe('delete');
    expect(boss!.row).toBeUndefined();
  });

  test('a delete for an id never seen still blocks it', async () => {
    expect(statuses(await push([del('tasks', 't9')]))).toEqual(['applied']);
    expect(statuses(await push([upsert('tasks', 't9', {}, T2)]))).toEqual(['ignored']);
    expect(statuses(await push([del('tasks', 't9')]))).toEqual(['ignored']);
  });

  test('a child of a deleted boss is acknowledged and changes nothing', async () => {
    await push([upsert('bosses', 'b1'), del('bosses', 'b1')]);
    const before = (await pull()).cursor;
    expect(statuses(await push([upsert('tasks', 't1', { boss_id: 'b1', phase_id: null }, T2)], 'dev-b'))).toEqual([
      'ignored',
    ]);
    expect(statuses(await push([upsert('attempts', 'a1', { boss_id: 'b1' })], 'dev-b'))).toEqual(['ignored']);
    expect((await pull(before)).changes).toEqual([]);
  });

  test('an event inserted after its tombstone stays deleted', async () => {
    await push([del('ember_events', 'e1')]);
    expect(statuses(await push([event('ember_events', 'e1')]))).toEqual(['ignored']);
    expect((await current('ember_events', 'e1'))!.op).toBe('delete');
  });

  test('deleting a boss tombstones what the app cascades; a relic keeps its row', async () => {
    await push([
      upsert('bosses', 'b1'),
      upsert('phases', 'p1', { boss_id: 'b1' }),
      upsert('tasks', 't1', { boss_id: 'b1', phase_id: 'p1' }),
      upsert('tasks', 't2', { boss_id: 'b1', phase_id: null }),
      upsert('commitments', 'c1', { boss_id: 'b1', task_id: 't1' }),
      upsert('attempts', 'a1', { boss_id: 'b1', task_id: 't1', phase_id: 'p1' }),
      event('health_events', 'h1', { commitment_id: 'c1' }),
      event('ember_events', 'e1', { boss_id: 'b1', task_id: 't1' }),
      upsert('relics', 'r1', { boss_id: 'b1' }),
      upsert('bloodstains', 's1', { boss_id: 'b1', recovered_at: null, lost_at: null }),
      upsert('bosses', 'b2'),
      upsert('phases', 'p2', { boss_id: 'b2' }),
    ]);
    await push([del('bosses', 'b1')]);
    const latest = new Map<string, Pulled>();
    for (const c of (await pull()).changes) latest.set(`${c.table}/${c.id}`, c);
    for (const key of ['bosses/b1', 'phases/p1', 'tasks/t1', 'tasks/t2', 'commitments/c1', 'attempts/a1', 'bloodstains/s1']) {
      expect(latest.get(key)?.op, key).toBe('delete');
    }
    expect(latest.get('relics/r1')?.op).toBe('upsert');
    expect(latest.get('relics/r1')?.row?.boss_id).toBeNull();
    expect(latest.get('health_events/h1')?.row?.commitment_id).toBeNull();
    expect(latest.get('ember_events/e1')?.row?.boss_id).toBeNull();
    expect(latest.get('ember_events/e1')?.row?.task_id).toBeNull();
    expect(latest.get('phases/p2')?.op).toBe('upsert');
  });

  test("a tombstone's payload columns are null in the database", async () => {
    await push([upsert('bosses', 'b1', { title: 'Secret' }), del('bosses', 'b1')]);
    const { rows } = await t.db.pool.query('SELECT * FROM bosses');
    expect(rows).toHaveLength(1);
    const r = rows[0];
    for (const col of Object.keys(SYNCED_COLUMNS.bosses!)) expect(r[col], col).toBeNull();
    expect(r.updated_at).toBeNull();
    expect(r.deleted_at).not.toBeNull();
  });

  test('settings, day logs and day plans cannot be deleted', async () => {
    const results = await push([del('user_settings', 'user'), del('day_logs', '2026-10-16:0'), del('day_plans', '2026-10-16')]);
    expect(results.map((r) => [r.status, r.reason])).toEqual([
      ['rejected', 'malformed'],
      ['rejected', 'malformed'],
      ['rejected', 'malformed'],
    ]);
  });
});

describe('seq (D13)', () => {
  test('a mixed batch pushed twice adds nothing and is acknowledged again', async () => {
    const batch = [
      upsert('bosses', 'b1'),
      event('ember_events', 'e1'),
      del('tasks', 't1'),
      upsert('user_settings', 'user', { rollover_hour: 4 }),
    ];
    const first = await push(batch);
    expect(statuses(first)).toEqual(['applied', 'applied', 'applied', 'applied']);
    const before = await pull();
    const second = await push(batch);
    expect(statuses(second)).toEqual(['ignored', 'ignored', 'ignored', 'ignored']);
    const after = await pull();
    expect(after.changes).toEqual(before.changes);
    const { rows } = await t.db.pool.query('SELECT last_seq FROM users');
    expect(Number(rows[0].last_seq)).toBe(before.cursor);
  });

  test('a pull never skips a change from a push still in flight', async () => {
    let release!: () => void;
    const held = new Promise<void>((r) => (release = r));
    let entered!: () => void;
    const inside = new Promise<void>((r) => (entered = r));
    t.hooks.beforeCommit = async () => {
      t.hooks.beforeCommit = undefined;
      entered();
      await held;
    };
    const slow = push([upsert('bosses', 'slow')]);
    await inside;
    const fast = push([upsert('bosses', 'fast')], 'dev-b');
    // The slow push holds the user's lock: nothing is visible yet.
    const during = await pull(0);
    expect(during.changes).toEqual([]);
    release();
    await Promise.all([slow, fast]);
    const after = await pull(during.cursor);
    expect(after.changes.map((c) => c.id)).toEqual(['slow', 'fast']);
  });
});

describe('validation', () => {
  test('an updatedAt more than 24 h ahead is rejected for that record only', async () => {
    const ahead = new Date(NOW.getTime() + 25 * 3_600_000).toISOString();
    const near = new Date(NOW.getTime() + 23 * 3_600_000).toISOString();
    const results = await push([upsert('bosses', 'b1', {}, ahead), upsert('bosses', 'b2', {}, near)]);
    expect(results.map((r) => [r.id, r.status, r.reason])).toEqual([
      ['b1', 'rejected', 'clock'],
      ['b2', 'applied', undefined],
    ]);
  });

  test.each([
    ['an unknown table', { table: 'visits', id: 'v1', op: 'upsert', row: {} }],
    ['an unknown column', { ...upsert('bosses', 'x'), row: { ...row('bosses'), extra: 1 } }],
    ['a missing column', { ...upsert('bosses', 'x'), row: { title: 'only' } }],
    ['a wrong type', upsert('bosses', 'x', { status: 'two' })],
    ['a bad date', upsert('bosses', 'x', { created_at: 'yesterday' })],
    ['no updatedAt on a mutable table', { table: 'bosses', id: 'x', op: 'upsert', row: row('bosses') }],
    ['an empty id', upsert('bosses', '')],
    ['bad task ids', upsert('day_plans', '2026-10-16', { task_ids: [1, 2] })],
  ])('%s is reported as malformed and the rest lands', async (_, bad) => {
    const results = await push([bad as Change, upsert('bosses', 'good')]);
    expect(results[0]).toMatchObject({ status: 'rejected', reason: 'malformed' });
    expect(results[1]!.status).toBe('applied');
  });
});

describe('a defeat is final (extends Stage 5 D2 across phones)', () => {
  const DEFEATED = 2;
  const defeated = (title: string, at: string, when = at) =>
    upsert('bosses', 'b1', { title, status: DEFEATED, defeated_at: when }, at);
  const edited = (title: string, at: string) => upsert('bosses', 'b1', { title, status: 0, defeated_at: null }, at);

  async function boss() {
    return (await current('bosses', 'b1'))!;
  }
  const iso = (v: unknown) => (v == null ? null : new Date(v as string).toISOString());

  test.each([
    ['the edit is newer', T2, T1],
    ['the defeat is newer', T1, T2],
  ])('an edit and a defeat keep both, in either order (%s)', async (_, editAt, defeatAt) => {
    for (const order of [0, 1]) {
      await t.db.pool.query('DELETE FROM bosses');
      const batches = [[edited('Edited by B', editAt)], [defeated('Garage', defeatAt)]];
      for (const [i, batch] of (order === 0 ? batches : [...batches].reverse()).entries()) {
        const results = await push(batch, `dev-${i}`);
        expect(statuses(results)).not.toContain('rejected');
      }
      const b = await boss();
      expect(b.row!.status, `order ${order}`).toBe(DEFEATED);
      expect(iso(b.row!.defeated_at)).toBe(defeatAt);
      // The other columns follow last write wins.
      expect(b.row!.title).toBe(editAt === T2 ? 'Edited by B' : 'Garage');
    }
  });

  test('an older defeat still lands on a newer undefeated row, and is announced to pull', async () => {
    await push([edited('Edited by B', T2)], 'dev-b');
    const before = (await boss()).seq;
    const results = await push([defeated('Garage', T1)], 'dev-a');
    expect(statuses(results)).toEqual(['applied']);
    const b = await boss();
    expect(b.seq).toBeGreaterThan(before);
    expect(b.row!.status).toBe(DEFEATED);
    expect(b.row!.title).toBe('Edited by B');
    expect(b.updatedAt && new Date(b.updatedAt).toISOString()).toBe(T2);
  });

  test('a defeat replayed changes nothing and allocates no seq', async () => {
    await push([defeated('Garage', T1)]);
    const before = (await boss()).seq;
    expect(statuses(await push([defeated('Garage', T1)]))).toEqual(['ignored']);
    expect((await boss()).seq).toBe(before);
  });

  test('two defeats keep the earliest defeated_at, in either order', async () => {
    for (const order of [0, 1]) {
      await t.db.pool.query('DELETE FROM bosses');
      const batches = [[defeated('Garage', T1)], [defeated('Garage', T2)]];
      for (const [i, batch] of (order === 0 ? batches : [...batches].reverse()).entries()) {
        await push(batch, `dev-${i}`);
      }
      expect(iso((await boss()).row!.defeated_at), `order ${order}`).toBe(T1);
    }
  });

  test('other statuses still follow last write wins', async () => {
    await push([upsert('bosses', 'b1', { status: 1 }, T1)]);
    await push([upsert('bosses', 'b1', { status: 0 }, T2)]);
    expect((await boss()).row!.status).toBe(0);
  });
});

describe('accounts are separate', () => {
  test("A never sees B's rows; A pushing B's id makes A's own row", async () => {
    const other = (await t.signIn({ sub: 'google-sub-2', email: 'b@example.com' })).token;
    await push([upsert('bosses', 'b1', { title: 'B owns this' }, T0)], 'dev-b', other);
    expect((await pull(0)).changes).toEqual([]);
    await push([upsert('bosses', 'b1', { title: 'A owns this' }, T0)]);
    expect((await current('bosses', 'b1'))!.row!.title).toBe('A owns this');
    const theirs = (await pull(0, other)).changes;
    expect(theirs.map((c) => c.row?.title)).toEqual(['B owns this']);
  });
});

test('pages hold 500 rows and say when there are more', async () => {
  const changes = Array.from({ length: 501 }, (_, i) => event('flask_events', `f${i}`));
  await push(changes.slice(0, 250));
  await push(changes.slice(250));
  const first = await pull(0);
  expect(first.changes).toHaveLength(500);
  expect(first.hasMore).toBe(true);
  const second = await pull(first.cursor);
  expect(second.changes.map((c) => c.id)).toEqual(['f500']);
  expect(second.hasMore).toBe(false);
});

describe('bloodstains (D11, D19)', () => {
  type Fixture = {
    cases: {
      name: string;
      batches: Record<string, string | null>[][];
      expect: { id: string; recovered_at: string | null; lost_at: string | null }[];
    }[];
  };
  const fixture = JSON.parse(
    readFileSync(new URL('./fixtures/bloodstains.json', import.meta.url), 'utf8'),
  ) as Fixture;

  const stain = (r: Record<string, string | null>): Change => ({
    table: 'bloodstains',
    id: r.id!,
    op: 'upsert',
    updatedAt: r.updated_at ?? r.created_at!,
    row: row('bloodstains', {
      boss_id: 'b1',
      task_id: null,
      attempt_id: null,
      amount: 4,
      recovered_at: null,
      lost_at: null,
      ...Object.fromEntries(Object.entries(r).filter(([k]) => k !== 'id' && k !== 'updated_at')),
    }),
  });

  for (const c of fixture.cases) {
    for (const order of [c.batches, [...c.batches].reverse()]) {
      test(`${c.name} (${order === c.batches ? 'in order' : 'reversed'})`, async () => {
        for (const [i, batch] of order.entries()) {
          const results = await push(batch.map(stain), `dev-${i}`);
          expect(results.map((r) => r.status)).not.toContain('rejected');
        }
        const latest = new Map<string, Pulled>();
        for (const ch of (await pull()).changes) if (ch.table === 'bloodstains') latest.set(ch.id, ch);
        const iso = (v: unknown) => (v == null ? null : new Date(v as string).toISOString());
        expect(
          [...latest.values()]
            .map((ch) => ({ id: ch.id, recovered_at: iso(ch.row!.recovered_at), lost_at: iso(ch.row!.lost_at) }))
            .sort((a, b) => a.id.localeCompare(b.id)),
        ).toEqual(c.expect);
      });
    }
  }

  test.each([
    ['recovery first', 0],
    ['loss first', 1],
  ])('updated_at is the latest of its own times, whatever the order (%s)', async (_, first) => {
    const recovered = { id: 's1', created_at: T0, recovered_at: T1, updated_at: T1 };
    const lost = { id: 's1', created_at: T0, lost_at: T2, updated_at: T2 };
    const batches = [[recovered], [lost]];
    for (const [i, batch] of [batches[first]!, batches[1 - first]!].entries()) {
      await push(batch.map(stain), `dev-${i}`);
    }
    const latest = (await pull()).changes.filter((c) => c.table === 'bloodstains').at(-1)!;
    expect(latest.row!.lost_at).toBeNull();
    expect(new Date(latest.updatedAt!).toISOString()).toBe(T1);
  });

  test('a second active bloodstain on one boss fails the unique index', async () => {
    await push([stain({ id: 's1', created_at: T0 })]);
    const { rows } = await t.db.pool.query('SELECT user_id FROM bloodstains');
    await expect(
      t.db.pool.query(
        `INSERT INTO bloodstains (user_id, id, boss_id, amount, created_at, device_id, seq)
         VALUES ($1, 's2', 'b1', 1, now(), 'x', 99)`,
        [rows[0].user_id],
      ),
    ).rejects.toThrow(/one_active_bloodstain/);
  });
});

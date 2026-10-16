import { afterEach, beforeEach, expect, test } from 'vitest';
import { testApp } from './helpers.ts';
import { SYNCED_COLUMNS } from '../src/tables.ts';

// Stage 7 gate, server side (plan step 11): two devices' offline batches,
// pushed directly in both orders, leave the same rows.

type Change = {
  table: string;
  id: string;
  op: 'upsert' | 'delete';
  updatedAt?: string;
  deletedAt?: string;
  row?: Record<string, unknown>;
};
type Pulled = Change & { seq: number };

const NOW = new Date('2026-10-20T00:00:00Z');
const at = (hour: number, minute = 0) =>
  new Date(Date.UTC(2026, 9, 14, hour, minute)).toISOString();

function row(table: string, values: Record<string, unknown>) {
  const defaults: Record<string, unknown> = {};
  for (const [col, type] of Object.entries(SYNCED_COLUMNS[table]!)) {
    defaults[col] = { text: 'x', integer: 0, boolean: false, timestamptz: at(8), jsonb: [] }[type];
  }
  return { ...defaults, ...values };
}
const up = (table: string, id: string, updated: string, values: Record<string, unknown> = {}): Change => ({
  table,
  id,
  op: 'upsert',
  updatedAt: updated,
  row: row(table, values),
});
const ev = (table: string, id: string, values: Record<string, unknown> = {}): Change => ({
  table,
  id,
  op: 'upsert',
  row: row(table, values),
});
/** A bloodstain with no recovery or loss unless given. */
const stain = (id: string, updated: string, values: Record<string, unknown>): Change =>
  up('bloodstains', id, updated, { recovered_at: null, lost_at: null, ...values });
const del = (table: string, id: string, deletedAt: string): Change => ({ table, id, op: 'delete', deletedAt });

// What the two phones agreed on before going offline.
const shared: Change[] = [
  up('bosses', 'garage', at(8), { title: 'Garage' }),
  up('bosses', 'taxes', at(8), { title: 'Taxes' }),
  up('bosses', 'temp', at(8), { title: 'Temp' }),
  up('tasks', 'g1', at(8), { boss_id: 'garage', title: 'g1' }),
  up('tasks', 't1', at(8), { boss_id: 'temp', title: 't1' }),
  stain('s0', at(8, 10), { boss_id: 'taxes', created_at: at(8, 10) }),
];

// A: strikes, defeats, banks, recovers the bloodstain, deletes Temp.
const batchA: Change[] = [
  ev('ember_events', 'e-a', { kind: 0, amount: 2 }),
  ev('ember_events', 'bank-a', { kind: 1, amount: 2 }),
  up('bosses', 'garage', at(9, 40), { title: 'Garage', status: 2, defeated_at: at(9, 40) }),
  up('relics', 'relic', at(9, 41), { boss_id: 'garage', name: 'Relic of Garage', inscription: 'Swept clean.' }),
  ev('health_events', 'miss-1', { amount: -4, reason: 0 }),
  ev('flask_events', 'bonfire-14', { kind: 1, amount: 1, reason: 3 }),
  stain('s0', at(10, 30), {
    boss_id: 'taxes',
    created_at: at(8, 10),
    recovered_at: at(10, 30),
  }),
  stain('sa', at(10), { boss_id: 'taxes', created_at: at(10) }),
  del('bosses', 'temp', at(12)),
];

// B: another strike, the same missed deadline, a newer bloodstain, a title
// edit, and edits to Temp before and after A deleted it.
const batchB: Change[] = [
  ev('ember_events', 'e-b', { kind: 0, amount: 1 }),
  ev('health_events', 'miss-1', { amount: -4, reason: 0 }),
  up('bosses', 'garage', at(9), { title: "Garage, B's edit" }),
  stain('s0', at(11, 30), { boss_id: 'taxes', created_at: at(8, 10), lost_at: at(11, 30) }),
  stain('sb', at(11, 30), { boss_id: 'taxes', created_at: at(11, 30) }),
  up('bosses', 'temp', at(11), { title: 'Temp, edited early' }),
  up('tasks', 't1', at(13), { boss_id: 'temp', title: 't1, edited late' }),
  ev('flask_events', 'skip-14', { kind: 0, amount: 1, reason: 0 }),
];

let t: Awaited<ReturnType<typeof testApp>>;
beforeEach(async () => {
  t = await testApp({ now: () => NOW });
});
afterEach(() => t.close());

/** Both batches, in the given order, as a fresh account; the final row of every id. */
async function finalRows(order: ['A' | 'B', 'A' | 'B']) {
  const token = (await t.signIn({ sub: `sub-${order.join('')}` })).token;
  const send = async (device: string, changes: Change[]) => {
    const res = await t.app.inject({
      method: 'POST',
      url: '/v1/sync/push',
      headers: { authorization: `Bearer ${token}` },
      payload: { deviceId: device, changes },
    });
    expect(res.statusCode, res.body).toBe(200);
    const { results } = res.json() as { results: { status: string }[] };
    expect(results.map((r) => r.status)).not.toContain('rejected');
  };
  await send('dev-shared', shared);
  for (const who of order) await send(who === 'A' ? 'dev-a' : 'dev-b', who === 'A' ? batchA : batchB);
  const res = await t.app.inject({
    method: 'GET',
    url: '/v1/sync/pull?since=0',
    headers: { authorization: `Bearer ${token}` },
  });
  const latest = new Map<string, Pulled>();
  for (const c of (res.json() as { changes: Pulled[] }).changes) latest.set(`${c.table}/${c.id}`, c);
  const iso = (v: unknown) => (typeof v === 'string' && /^\d{4}-/.test(v) ? new Date(v).toISOString() : v);
  return [...latest.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, c]) => [
      key,
      c.op,
      c.updatedAt ? iso(c.updatedAt) : null,
      c.row ? Object.fromEntries(Object.entries(c.row).map(([k, v]) => [k, iso(v)])) : null,
    ]);
}

test('the same two batches give the same rows in either order', async () => {
  const ab = await finalRows(['A', 'B']);
  const ba = await finalRows(['B', 'A']);
  expect(ab).toEqual(ba);
  const byKey = new Map(ab.map((r) => [r[0] as string, r]));
  // Events are the sum of both devices; the missed deadline counts once.
  for (const id of ['ember_events/e-a', 'ember_events/e-b', 'ember_events/bank-a', 'health_events/miss-1']) {
    expect(byKey.get(id)?.[1], id).toBe('upsert');
  }
  expect(ab.filter((r) => (r[0] as string).startsWith('health_events/'))).toHaveLength(1);
  // Delete wins over an earlier and a later edit; its child goes too.
  expect(byKey.get('bosses/temp')?.[1]).toBe('delete');
  expect(byKey.get('tasks/t1')?.[1]).toBe('delete');
  // The recovery stands and the newer bloodstain is the active one.
  expect(byKey.get('bloodstains/s0')?.[3]).toMatchObject({ recovered_at: at(10, 30), lost_at: null });
  expect(byKey.get('bloodstains/sa')?.[3]).toMatchObject({ lost_at: at(11, 30) });
  expect(byKey.get('bloodstains/sb')?.[3]).toMatchObject({ lost_at: null, recovered_at: null });
});

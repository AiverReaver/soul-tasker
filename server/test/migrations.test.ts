import { afterAll, beforeAll, describe, expect, test } from 'vitest';
import { testDb } from './helpers.ts';
import { SYNCED_TABLES, EVENT_TABLES } from '../src/tables.ts';

describe('migrations', () => {
  let db: Awaited<ReturnType<typeof testDb>>;
  beforeAll(async () => {
    db = await testDb();
  });
  afterAll(() => db.drop());

  async function columns(table: string) {
    const { rows } = await db.pool.query<{ column_name: string }>(
      `SELECT column_name FROM information_schema.columns
       WHERE table_schema = $1 AND table_name = $2`,
      [db.schema, table],
    );
    return rows.map((r) => r.column_name);
  }

  async function indexes(table: string) {
    const { rows } = await db.pool.query<{ indexname: string; indexdef: string }>(
      'SELECT indexname, indexdef FROM pg_indexes WHERE schemaname = $1 AND tablename = $2',
      [db.schema, table],
    );
    return rows;
  }

  test('users and sessions exist', async () => {
    expect(await columns('users')).toEqual(
      expect.arrayContaining(['id', 'google_sub', 'email', 'last_seq', 'created_at']),
    );
    expect(await columns('sessions')).toEqual(
      expect.arrayContaining(['token_hash', 'user_id', 'expires_at']),
    );
    const userIdx = await indexes('users');
    expect(userIdx.some((i) => /UNIQUE.*\(google_sub\)/.test(i.indexdef))).toBe(true);
  });

  test.each(Object.keys(SYNCED_TABLES))('%s has the sync columns and keys', async (table) => {
    const cols = await columns(table);
    expect(cols).toEqual(
      expect.arrayContaining(['user_id', 'id', 'device_id', 'seq', 'deleted_at']),
    );
    expect(cols).toEqual(expect.arrayContaining(SYNCED_TABLES[table]!));
    if (EVENT_TABLES.has(table)) {
      expect(cols).not.toContain('updated_at');
    } else {
      expect(cols).toContain('updated_at');
    }
    const idx = await indexes(table);
    expect(idx.some((i) => /PRIMARY|pkey/.test(i.indexname) && /\(user_id, id\)/.test(i.indexdef))).toBe(true);
    expect(idx.some((i) => /\(user_id, seq\)/.test(i.indexdef))).toBe(true);
  });

  test('bloodstains have the one-active partial unique index (D11)', async () => {
    const idx = await indexes('bloodstains');
    const one = idx.find((i) => i.indexname === 'one_active_bloodstain');
    expect(one?.indexdef).toMatch(/UNIQUE.*\(user_id, boss_id\).*WHERE/);
    expect(one?.indexdef).toMatch(/recovered_at IS NULL/);
    expect(one?.indexdef).toMatch(/lost_at IS NULL/);
    expect(one?.indexdef).toMatch(/deleted_at IS NULL/);
  });

  test('payload columns are nullable, so a tombstone can drop them', async () => {
    const { rows } = await db.pool.query<{ column_name: string }>(
      `SELECT column_name FROM information_schema.columns
       WHERE table_schema = $1 AND table_name = 'bosses' AND is_nullable = 'NO'`,
      [db.schema],
    );
    expect(rows.map((r) => r.column_name).sort()).toEqual(['device_id', 'id', 'seq', 'user_id']);
  });
});

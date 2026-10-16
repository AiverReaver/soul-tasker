import { afterEach, beforeEach, describe, expect, test } from 'vitest';
import { CLIENT_ID, testApp } from './helpers.ts';

// Stage 7 plan D17: deleting an account from the app and from the web.

const NOW = new Date('2026-10-16T12:00:00Z');
const T0 = '2026-10-16T09:00:00.000Z';

let t: Awaited<ReturnType<typeof testApp>>;
beforeEach(async () => {
  t = await testApp({ now: () => NOW });
});
afterEach(() => t.close());

/** One boss and one flask event, pushed as the signed-in user. */
async function seed(token: string) {
  const boss = {
    title: 'x',
    defeat_meaning: null,
    status: 0,
    attempt_number: 1,
    reset_on_fail: 0,
    is_pinned: false,
    target_date: null,
    last_fought_at: null,
    open_from_attempt: 1,
    created_at: T0,
    defeated_at: null,
  };
  const res = await t.app.inject({
    method: 'POST',
    url: '/v1/sync/push',
    headers: { authorization: `Bearer ${token}` },
    payload: {
      deviceId: 'dev',
      changes: [
        { table: 'bosses', id: 'b1', op: 'upsert', updatedAt: T0, row: boss },
        { table: 'bosses', id: 'b2', op: 'upsert', updatedAt: T0, row: boss },
        { table: 'bosses', id: 'b2', op: 'delete', deletedAt: T0 },
      ],
    },
  });
  expect(res.statusCode).toBe(200);
}

const count = async (table: string) =>
  Number((await t.db.pool.query(`SELECT COUNT(*) FROM ${table}`)).rows[0].count);

describe('DELETE /v1/account (in the app)', () => {
  test('removes every row, tombstone and session of that user only', async () => {
    const a = await t.signIn();
    const b = await t.signIn({ sub: 'google-sub-2', email: 'b@example.com' });
    await seed(a.token);
    await seed(b.token);

    const res = await t.app.inject({
      method: 'DELETE',
      url: '/v1/account',
      headers: { authorization: `Bearer ${a.token}` },
    });
    expect(res.statusCode).toBe(204);

    const left = await t.db.pool.query('SELECT user_id FROM bosses');
    expect(left.rows.map((r) => r.user_id)).toEqual([b.user.id, b.user.id]);
    expect(await count('users')).toBe(1);
    expect(await count('sessions')).toBe(1);
  });

  test('the old token is a 401 afterwards, and with no token nothing happens', async () => {
    const a = await t.signIn();
    await t.app.inject({
      method: 'DELETE',
      url: '/v1/account',
      headers: { authorization: `Bearer ${a.token}` },
    });
    const again = await t.app.inject({
      method: 'DELETE',
      url: '/v1/account',
      headers: { authorization: `Bearer ${a.token}` },
    });
    expect(again.statusCode).toBe(401);
    const pull = await t.app.inject({
      method: 'GET',
      url: '/v1/sync/pull?since=0',
      headers: { authorization: `Bearer ${a.token}` },
    });
    expect(pull.statusCode).toBe(401);

    const b = await t.signIn({ sub: 'google-sub-2' });
    await seed(b.token);
    const none = await t.app.inject({ method: 'DELETE', url: '/v1/account' });
    expect(none.statusCode).toBe(401);
    expect(await count('users')).toBe(1);
    expect(await count('bosses')).toBe(2);
  });
});

describe('/account/delete (on the web)', () => {
  const post = (payload: unknown) =>
    t.app.inject({ method: 'POST', url: '/account/delete', payload: payload as object });

  test('GET serves the page and sets no cookie', async () => {
    const res = await t.app.inject({ method: 'GET', url: '/account/delete' });
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toMatch(/text\/html/);
    expect(res.headers['set-cookie']).toBeUndefined();
    expect(res.body).toContain('accounts.google.com/gsi/client');
    expect(res.body).toContain(CLIENT_ID);
    expect(res.body).toContain('Delete my account');
  });

  test('a fresh valid ID token with a confirm removes that user', async () => {
    const a = await t.signIn();
    const b = await t.signIn({ sub: 'google-sub-2', email: 'b@example.com' });
    await seed(a.token);
    await seed(b.token);

    const res = await post({ idToken: await t.google.sign(), confirm: true });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ deleted: true });

    const left = await t.db.pool.query('SELECT user_id FROM bosses');
    expect(left.rows.every((r) => r.user_id === b.user.id)).toBe(true);
    expect(await count('users')).toBe(1);

    const pull = await t.app.inject({
      method: 'GET',
      url: '/v1/sync/pull?since=0',
      headers: { authorization: `Bearer ${a.token}` },
    });
    expect(pull.statusCode).toBe(401);
  });

  test.each([
    ['no token', async () => ({ confirm: true })],
    ['no confirm', async () => ({ idToken: await t.google.sign() })],
    ['confirm false', async () => ({ idToken: await t.google.sign(), confirm: false })],
    ['a bad signature', async () => ({ idToken: await t.google.sign({}, { key: 'other' }), confirm: true })],
    ['a wrong audience', async () => ({ idToken: await t.google.sign({ aud: 'someone-else' }), confirm: true })],
    [
      'an iat older than 5 minutes',
      async () => ({
        idToken: await t.google.sign({ iat: Math.floor(NOW.getTime() / 1000) - 301 }),
        confirm: true,
      }),
    ],
    ['an unverified email', async () => ({ idToken: await t.google.sign({ email_verified: false }), confirm: true })],
  ])('%s deletes nothing', async (_, make) => {
    const a = await t.signIn();
    await seed(a.token);
    const res = await post(await make());
    expect([400, 401]).toContain(res.statusCode);
    expect(await count('users')).toBe(1);
    expect(await count('bosses')).toBe(2);
    expect(await count('sessions')).toBe(1);
  });

  test("a valid token for someone else deletes only that someone's data", async () => {
    const a = await t.signIn();
    await seed(a.token);
    const res = await post({
      idToken: await t.google.sign({ sub: 'google-sub-9', email: 'z@example.com' }),
      confirm: true,
    });
    // Nobody has that account: nothing to delete, and A is untouched.
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ deleted: false });
    expect(await count('users')).toBe(1);
    expect(await count('bosses')).toBe(2);
  });

  test('an iat just inside 5 minutes is accepted', async () => {
    await t.signIn();
    const res = await post({
      idToken: await t.google.sign({ iat: Math.floor(NOW.getTime() / 1000) - 299 }),
      confirm: true,
    });
    expect(res.statusCode).toBe(200);
    expect(await count('users')).toBe(0);
  });
});

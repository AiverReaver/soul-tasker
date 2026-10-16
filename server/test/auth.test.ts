import { createHash } from 'node:crypto';
import { afterEach, beforeEach, describe, expect, test } from 'vitest';
import { testApp } from './helpers.ts';

describe('POST /v1/auth/google (D4)', () => {
  let t: Awaited<ReturnType<typeof testApp>>;
  beforeEach(async () => {
    t = await testApp();
  });
  afterEach(() => t.close());

  async function post(idToken: string) {
    return t.app.inject({ method: 'POST', url: '/v1/auth/google', payload: { idToken } });
  }

  test('a valid token creates a user and returns a session token', async () => {
    const res = await post(await t.google.sign());
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.token).toMatch(/^[A-Za-z0-9_-]{43}$/);
    expect(body.user.email).toBe('ash@example.com');
    const { rows } = await t.db.pool.query('SELECT google_sub, email FROM users');
    expect(rows).toEqual([{ google_sub: 'google-sub-1', email: 'ash@example.com' }]);
  });

  test('the same sub again finds the same user', async () => {
    const first = (await post(await t.google.sign())).json();
    const second = (await post(await t.google.sign({ email: 'new@example.com' }))).json();
    expect(second.user.id).toBe(first.user.id);
    expect(second.token).not.toBe(first.token);
    const { rows } = await t.db.pool.query('SELECT email FROM users');
    expect(rows).toEqual([{ email: 'new@example.com' }]);
  });

  test.each([
    ['a bad signature', () => t.google.sign({}, { key: 'other' })],
    ['a wrong audience', () => t.google.sign({ aud: 'someone-else' })],
    ['a wrong issuer', () => t.google.sign({ iss: 'https://evil.example.com' })],
    ['an expired token', () => t.google.sign({ iat: 1_000 }, { expiresIn: 2_000 })],
    ['an unverified email', () => t.google.sign({ email_verified: false })],
    ['no subject', () => t.google.sign({ sub: '' })],
    ['garbage', async () => 'not-a-jwt'],
  ])('%s gets 401 and creates nobody', async (_, make) => {
    const res = await post(await make());
    expect(res.statusCode).toBe(401);
    const { rows } = await t.db.pool.query('SELECT * FROM users');
    expect(rows).toEqual([]);
  });

  test('the old Google issuer without https is accepted', async () => {
    const res = await post(await t.google.sign({ iss: 'accounts.google.com' }));
    expect(res.statusCode).toBe(200);
  });

  test('a missing body gets 400', async () => {
    const res = await t.app.inject({ method: 'POST', url: '/v1/auth/google', payload: {} });
    expect(res.statusCode).toBe(400);
  });

  test('only the hash of the session token is stored', async () => {
    const { token } = await t.signIn();
    const { rows } = await t.db.pool.query<{ token_hash: Buffer }>(
      'SELECT token_hash FROM sessions',
    );
    expect(rows).toHaveLength(1);
    expect(rows[0]!.token_hash.equals(createHash('sha256').update(token).digest())).toBe(true);
    expect(rows[0]!.token_hash.toString('utf8')).not.toContain(token);
  });
});

describe('sessions', () => {
  let now = new Date('2026-10-16T12:00:00Z');
  let t: Awaited<ReturnType<typeof testApp>>;
  beforeEach(async () => {
    now = new Date('2026-10-16T12:00:00Z');
    t = await testApp({ now: () => now });
  });
  afterEach(() => t.close());

  const logout = (token?: string) =>
    t.app.inject({
      method: 'POST',
      url: '/v1/auth/logout',
      headers: token ? { authorization: `Bearer ${token}` } : {},
    });

  async function expiry() {
    const { rows } = await t.db.pool.query<{ expires_at: Date }>('SELECT expires_at FROM sessions');
    return rows[0]?.expires_at;
  }

  test('a session lasts 60 days and is renewed on use', async () => {
    const { token } = await t.signIn();
    expect(await expiry()).toEqual(new Date('2026-12-15T12:00:00Z'));
    now = new Date('2026-11-01T12:00:00Z');
    const me = await t.app.inject({
      method: 'GET',
      url: '/v1/me',
      headers: { authorization: `Bearer ${token}` },
    });
    expect(me.statusCode).toBe(200);
    expect(me.json().email).toBe('ash@example.com');
    expect(await expiry()).toEqual(new Date('2026-12-31T12:00:00Z'));
  });

  test('an unknown, missing or expired token gets 401', async () => {
    const { token } = await t.signIn();
    expect((await logout('nope')).statusCode).toBe(401);
    expect((await logout()).statusCode).toBe(401);
    now = new Date('2026-12-16T12:00:00Z');
    expect((await logout(token)).statusCode).toBe(401);
  });

  test('logout ends the session', async () => {
    const { token } = await t.signIn();
    expect((await logout(token)).statusCode).toBe(204);
    expect(await expiry()).toBeUndefined();
    expect((await logout(token)).statusCode).toBe(401);
  });
});

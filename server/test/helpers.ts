import { randomUUID } from 'node:crypto';
import pg from 'pg';
import { exportJWK, generateKeyPair, createLocalJWKSet, SignJWT } from 'jose';
import type { JWTPayload } from 'jose';
import { buildApp } from '../src/app.ts';
import type { SyncHooks } from '../src/sync.ts';
import { runMigrations } from '../src/migrate.ts';

export const TEST_DATABASE_URL =
  process.env.TEST_DATABASE_URL ??
  'postgres://hearthrise:hearthrise@localhost:54329/hearthrise';

export const CLIENT_ID = 'test-web-client.apps.googleusercontent.com';

/** A fresh schema with every migration applied, for one test file. */
export async function testDb() {
  const schema = `t_${randomUUID().replaceAll('-', '')}`;
  await runMigrations({ databaseUrl: TEST_DATABASE_URL, schema });
  const pool = new pg.Pool({
    connectionString: TEST_DATABASE_URL,
    options: `-c search_path=${schema}`,
  });
  return {
    pool,
    schema,
    async drop() {
      await pool.end();
      const admin = new pg.Client({ connectionString: TEST_DATABASE_URL });
      await admin.connect();
      await admin.query(`DROP SCHEMA ${schema} CASCADE`);
      await admin.end();
    },
  };
}

/** Signs Google-like ID tokens with a key only the test knows, dated by
 * [now] so they match the app's clock. */
export async function fakeGoogle(now: () => Date = () => new Date()) {
  const kid = 'test-key';
  const { privateKey, publicKey } = await generateKeyPair('RS256');
  const other = await generateKeyPair('RS256');
  const jwk = { ...(await exportJWK(publicKey)), kid, alg: 'RS256' };
  const jwks = createLocalJWKSet({ keys: [jwk] });

  async function sign(
    claims: JWTPayload & Record<string, unknown> = {},
    opts: { key?: 'good' | 'other'; expiresIn?: string | number } = {},
  ) {
    const base = Math.floor(now().getTime() / 1000);
    return new SignJWT({
      email: 'ash@example.com',
      email_verified: true,
      ...claims,
    })
      .setProtectedHeader({ alg: 'RS256', kid })
      .setIssuer((claims.iss as string) ?? 'https://accounts.google.com')
      .setAudience((claims.aud as string) ?? CLIENT_ID)
      .setSubject((claims.sub as string) ?? 'google-sub-1')
      .setIssuedAt((claims.iat as number) ?? base)
      .setExpirationTime(opts.expiresIn ?? base + 3600)
      .sign(opts.key === 'other' ? other.privateKey : privateKey);
  }

  return { jwks, sign };
}

/** The app on a fresh schema, with fake Google keys. */
export async function testApp(opts: { now?: () => Date } = {}) {
  const db = await testDb();
  const google = await fakeGoogle(opts.now);
  const hooks: SyncHooks = {};
  const app = await buildApp({
    pool: db.pool,
    googleClientId: CLIENT_ID,
    jwks: google.jwks,
    now: opts.now,
    hooks,
  });
  return {
    app,
    hooks,
    db,
    google,
    async signIn(claims: Record<string, unknown> = {}) {
      const res = await app.inject({
        method: 'POST',
        url: '/v1/auth/google',
        payload: { idToken: await google.sign(claims) },
      });
      return res.json() as { token: string; user: { id: string } };
    },
    async close() {
      await app.close();
      await db.drop();
    },
  };
}

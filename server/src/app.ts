import Fastify from 'fastify';
import swagger from '@fastify/swagger';
import type { FastifyReply, FastifyRequest } from 'fastify';
import type { TypeBoxTypeProvider } from '@fastify/type-provider-typebox';
import type pg from 'pg';
import type { JWTVerifyGetKey } from 'jose';
import pkg from '../package.json' with { type: 'json' };
import { hashToken, newSessionToken, sessionExpiry, verifyGoogleIdToken } from './auth.ts';
import { deletePage } from './delete_page.ts';
import { syncRoutes } from './sync.ts';
import { AuthGoogleRequest, DeleteAccountRequest, ErrorBody, Health, SCHEMAS, Session, User, ref } from './schemas.ts';
import type { Static } from '@fastify/type-provider-typebox';
import type { SyncHooks } from './sync.ts';

declare module 'fastify' {
  interface FastifyRequest {
    /** Set by `authenticate`; every query filters on it. */
    userId: string;
  }
}

export type AppOptions = {
  pool: pg.Pool;
  /** The Web OAuth client id: the audience of every ID token. */
  googleClientId: string;
  jwks: JWTVerifyGetKey;
  now?: () => Date;
  logger?: boolean;
  hooks?: SyncHooks;
};

export async function buildApp(opts: AppOptions) {
  const { pool } = opts;
  const now = opts.now ?? (() => new Date());
  // Times leave as ISO 8601 in UTC, microseconds kept.
  pool.on('connect', (client) => {
    client.query("SET TIME ZONE 'UTC'").catch(() => {});
  });
  const app = Fastify({ logger: opts.logger ?? false }).withTypeProvider<TypeBoxTypeProvider>();
  app.decorateRequest('userId', '');
  // The spec comes from these schemas, so it cannot drift from the code (D2).
  await app.register(swagger, {
    openapi: {
      openapi: '3.1.0',
      info: { title: 'Hearthrise API', version: pkg.version },
      components: { securitySchemes: { session: { type: 'http', scheme: 'bearer' } } },
    },
    refResolver: {
      buildLocalReference: (json, _base, _fragment, i) => (json.$id as string | undefined) ?? `def-${i}`,
    },
  });
  for (const schema of SCHEMAS) app.addSchema(schema);

  /** Bearer session check; renews the session on use (D4). */
  async function authenticate(req: FastifyRequest, reply: FastifyReply) {
    const header = req.headers.authorization ?? '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : '';
    if (!token) return reply.code(401).send({ error: 'unauthorized' });
    const at = now();
    const { rows } = await pool.query<{ user_id: string }>(
      `UPDATE sessions SET expires_at = $3
       WHERE token_hash = $1 AND expires_at > $2
       RETURNING user_id`,
      [hashToken(token), at, sessionExpiry(at)],
    );
    if (rows.length === 0) return reply.code(401).send({ error: 'unauthorized' });
    req.userId = rows[0]!.user_id;
  }

  app.get(
    '/v1/health',
    { schema: { operationId: 'health', tags: ['health'], response: { 200: ref(Health) } } },
    async () => ({ status: 'ok', version: pkg.version }),
  );

  app.post(
    '/v1/auth/google',
    {
      schema: {
        operationId: 'authGoogle',
        tags: ['auth'],
        body: ref(AuthGoogleRequest),
        response: { 200: ref(Session), 401: ref(ErrorBody) },
      },
    },
    async (req, reply) => {
      const at = now();
      const body = req.body as Static<typeof AuthGoogleRequest>;
      const identity = await verifyGoogleIdToken(body.idToken, {
        jwks: opts.jwks,
        audience: opts.googleClientId,
        now: at,
      });
      if (!identity) return reply.code(401).send({ error: 'invalid id token' });
      const { rows } = await pool.query<{ id: string; email: string }>(
        `INSERT INTO users (google_sub, email) VALUES ($1, $2)
         ON CONFLICT (google_sub) DO UPDATE SET email = EXCLUDED.email
         RETURNING id, email`,
        [identity.sub, identity.email],
      );
      const user = rows[0]!;
      const token = newSessionToken();
      const expiresAt = sessionExpiry(at);
      await pool.query('INSERT INTO sessions (token_hash, user_id, expires_at) VALUES ($1, $2, $3)', [
        hashToken(token),
        user.id,
        expiresAt,
      ]);
      return { token, expiresAt: expiresAt.toISOString(), user };
    },
  );

  app.post(
    '/v1/auth/logout',
    {
      preHandler: authenticate,
      schema: {
        operationId: 'logout',
        tags: ['auth'],
        security: [{ session: [] }],
        response: { 204: { type: 'null', description: 'Signed out' }, 401: ref(ErrorBody) },
      },
    },
    async (req, reply) => {
      const token = req.headers.authorization!.slice(7);
      await pool.query('DELETE FROM sessions WHERE token_hash = $1', [hashToken(token)]);
      return reply.code(204).send(null);
    },
  );

  app.get(
    '/v1/me',
    {
      preHandler: authenticate,
      schema: {
        operationId: 'me',
        tags: ['auth'],
        security: [{ session: [] }],
        response: { 200: ref(User), 401: ref(ErrorBody) },
      },
    },
    async (req) => {
      const { rows } = await pool.query<{ id: string; email: string }>(
        'SELECT id, email FROM users WHERE id = $1',
        [req.userId],
      );
      return rows[0]!;
    },
  );

  app.delete(
    '/v1/account',
    {
      preHandler: authenticate,
      schema: {
        operationId: 'deleteAccount',
        tags: ['account'],
        security: [{ session: [] }],
        response: { 204: { type: 'null', description: 'Account deleted' }, 401: ref(ErrorBody) },
      },
    },
    async (req, reply) => {
      // Every table references users with ON DELETE CASCADE: rows,
      // tombstones and sessions go with the user (D17).
      await pool.query('DELETE FROM users WHERE id = $1', [req.userId]);
      return reply.code(204).send(null);
    },
  );

  app.get('/account/delete', { schema: { hide: true } }, async (_req, reply) =>
    reply.type('text/html; charset=utf-8').send(deletePage(opts.googleClientId)),
  );

  app.post(
    '/account/delete',
    { schema: { hide: true, body: ref(DeleteAccountRequest) } },
    async (req, reply) => {
      const body = req.body as Static<typeof DeleteAccountRequest>;
      if (body.confirm !== true) return reply.code(400).send({ error: 'confirm is required' });
      const at = now();
      const identity = await verifyGoogleIdToken(body.idToken, {
        jwks: opts.jwks,
        audience: opts.googleClientId,
        now: at,
      });
      // A fresh sign-in is the re-authentication: the token must have been
      // issued in the last 5 minutes (D17).
      if (!identity || at.getTime() - identity.issuedAt.getTime() > 5 * 60_000) {
        return reply.code(401).send({ error: 'sign in again' });
      }
      const { rowCount } = await pool.query('DELETE FROM users WHERE google_sub = $1', [identity.sub]);
      return { deleted: (rowCount ?? 0) > 0 };
    },
  );

  syncRoutes(app, { pool, now, hooks: opts.hooks ?? {}, authenticate });

  await app.ready();
  return app;
}

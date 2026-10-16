import Fastify from 'fastify';
import type { FastifyReply, FastifyRequest } from 'fastify';
import { Type } from '@fastify/type-provider-typebox';
import type { TypeBoxTypeProvider } from '@fastify/type-provider-typebox';
import type pg from 'pg';
import type { JWTVerifyGetKey } from 'jose';
import pkg from '../package.json' with { type: 'json' };
import { hashToken, newSessionToken, sessionExpiry, verifyGoogleIdToken } from './auth.ts';

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
};

const ErrorBody = Type.Object({ error: Type.String() });
const User = Type.Object({ id: Type.String(), email: Type.String() });

export async function buildApp(opts: AppOptions) {
  const { pool } = opts;
  const now = opts.now ?? (() => new Date());
  const app = Fastify({ logger: opts.logger ?? false }).withTypeProvider<TypeBoxTypeProvider>();
  app.decorateRequest('userId', '');

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
    { schema: { response: { 200: Type.Object({ status: Type.String(), version: Type.String() }) } } },
    async () => ({ status: 'ok', version: pkg.version }),
  );

  app.post(
    '/v1/auth/google',
    {
      schema: {
        body: Type.Object({ idToken: Type.String({ minLength: 1 }) }),
        response: {
          200: Type.Object({ token: Type.String(), expiresAt: Type.String(), user: User }),
          401: ErrorBody,
        },
      },
    },
    async (req, reply) => {
      const at = now();
      const identity = await verifyGoogleIdToken(req.body.idToken, {
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
    { preHandler: authenticate, schema: { response: { 204: Type.Null(), 401: ErrorBody } } },
    async (req, reply) => {
      const token = req.headers.authorization!.slice(7);
      await pool.query('DELETE FROM sessions WHERE token_hash = $1', [hashToken(token)]);
      return reply.code(204).send(null);
    },
  );

  app.get(
    '/v1/me',
    { preHandler: authenticate, schema: { response: { 200: User, 401: ErrorBody } } },
    async (req) => {
      const { rows } = await pool.query<{ id: string; email: string }>(
        'SELECT id, email FROM users WHERE id = $1',
        [req.userId],
      );
      return rows[0]!;
    },
  );

  await app.ready();
  return app;
}

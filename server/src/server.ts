import pg from 'pg';
import { buildApp } from './app.ts';
import { googleJwks } from './auth.ts';

function required(name: string) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is not set`);
  return value;
}

const pool = new pg.Pool({ connectionString: required('DATABASE_URL') });
const app = await buildApp({
  pool,
  googleClientId: required('GOOGLE_WEB_CLIENT_ID'),
  jwks: googleJwks(),
  logger: true,
});
await app.listen({ host: '0.0.0.0', port: Number(process.env.PORT ?? 8080) });

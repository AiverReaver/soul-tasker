import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import pg from 'pg';
import { createLocalJWKSet } from 'jose';
import { buildApp } from './app.ts';

/**
 * The OpenAPI spec the routes describe. Builds the app without touching a
 * database: the pool never connects.
 */
export async function buildOpenApi() {
  const pool = new pg.Pool();
  const app = await buildApp({
    pool,
    googleClientId: 'spec-only',
    jwks: createLocalJWKSet({ keys: [] }),
  });
  const spec = JSON.parse(JSON.stringify(app.swagger()));
  await app.close();
  await pool.end();
  return spec;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const out = fileURLToPath(new URL('../openapi.json', import.meta.url));
  writeFileSync(out, `${JSON.stringify(await buildOpenApi(), null, 2)}\n`);
  console.log(`wrote ${out}`);
}

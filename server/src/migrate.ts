import { fileURLToPath } from 'node:url';
import { runner } from 'node-pg-migrate';

const dir = fileURLToPath(new URL('../migrations', import.meta.url));

/** Runs every pending migration. [schema] is for tests, one per file. */
export async function runMigrations(opts: { databaseUrl: string; schema?: string }) {
  await runner({
    databaseUrl: opts.databaseUrl,
    dir,
    direction: 'up',
    migrationsTable: 'pgmigrations',
    schema: opts.schema,
    createSchema: opts.schema !== undefined,
    // The lock is per database; test schemas never share one.
    noLock: opts.schema !== undefined,
    log: () => {},
  });
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) throw new Error('DATABASE_URL is not set');
  await runMigrations({ databaseUrl });
}

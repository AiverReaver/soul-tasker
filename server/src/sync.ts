import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import { Type } from '@fastify/type-provider-typebox';
import type { TypeBoxTypeProvider } from '@fastify/type-provider-typebox';
import type pg from 'pg';
import { EVENT_TABLES, NATURAL_KEY_TABLES, REFERENCES, SYNCED_COLUMNS } from './tables.ts';
import { ErrorBody, PullResponse, PushRequest, PushResponse, ref } from './schemas.ts';

/** Seams for tests: [beforeCommit] runs inside each push transaction. */
export type SyncHooks = { beforeCommit?: () => Promise<void> };

/** A client time further ahead than this is refused for that record (D13). */
const MAX_AHEAD_MS = 24 * 3_600_000;
export const PAGE_SIZE = 500;

type Change = {
  table: string;
  id: string;
  op: 'upsert' | 'delete';
  updatedAt?: string;
  deletedAt?: string;
  row?: Record<string, unknown>;
};
type Result = {
  table: string;
  id: string;
  status: 'applied' | 'ignored' | 'rejected';
  reason?: 'clock' | 'malformed';
  message?: string;
};

class Rejected extends Error {
  constructor(
    readonly reason: 'clock' | 'malformed',
    message: string,
  ) {
    super(message);
  }
}

const ISO = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$/;
const isTime = (v: unknown) => typeof v === 'string' && ISO.test(v) && !Number.isNaN(Date.parse(v));

/** Checks one change against the table's columns. Throws [Rejected]. */
function validate(change: Change, now: Date) {
  const columns = SYNCED_COLUMNS[change.table];
  if (!columns) throw new Rejected('malformed', `unknown table ${change.table}`);
  if (!change.id || change.id.length > 200) throw new Rejected('malformed', 'bad id');
  if (change.op === 'delete') {
    if (NATURAL_KEY_TABLES.has(change.table)) throw new Rejected('malformed', `${change.table} is never deleted`);
    if (change.deletedAt !== undefined && !isTime(change.deletedAt)) throw new Rejected('malformed', 'bad deletedAt');
    return;
  }
  const row = change.row;
  if (!row) throw new Rejected('malformed', 'upsert without row');
  const keys = Object.keys(row);
  const expected = Object.keys(columns);
  if (keys.length !== expected.length || !expected.every((k) => k in row)) {
    throw new Rejected('malformed', `columns must be exactly ${expected.join(', ')}`);
  }
  for (const [col, type] of Object.entries(columns)) {
    const v = row[col];
    if (v === null) continue;
    const ok =
      type === 'text'
        ? typeof v === 'string'
        : type === 'integer'
          ? Number.isInteger(v)
          : type === 'boolean'
            ? typeof v === 'boolean'
            : type === 'timestamptz'
              ? isTime(v)
              : Array.isArray(v) && v.every((x) => typeof x === 'string');
    if (!ok) throw new Rejected('malformed', `bad ${col}`);
  }
  if (!EVENT_TABLES.has(change.table)) {
    if (!isTime(change.updatedAt)) throw new Rejected('malformed', 'bad updatedAt');
    if (Date.parse(change.updatedAt!) - now.getTime() > MAX_AHEAD_MS) {
      throw new Rejected('clock', 'updatedAt is more than 24 h ahead');
    }
  }
}

/** One push: every change for one user, in one transaction (D13). */
class Push {
  constructor(
    private readonly db: pg.PoolClient,
    private readonly userId: string,
    private readonly deviceId: string,
    private readonly now: Date,
  ) {}

  private async nextSeq() {
    const { rows } = await this.db.query<{ last_seq: string }>(
      'UPDATE users SET last_seq = last_seq + 1 WHERE id = $1 RETURNING last_seq',
      [this.userId],
    );
    return rows[0]!.last_seq;
  }

  private dbValue(table: string, col: string, v: unknown) {
    return SYNCED_COLUMNS[table]![col] === 'jsonb' && v !== null ? JSON.stringify(v) : v;
  }

  /** Whether the row is a tombstone, or undefined when there is no row. */
  private async isDead(table: string, id: string, lock = false) {
    const { rows } = await this.db.query<{ dead: boolean }>(
      `SELECT deleted_at IS NOT NULL AS dead FROM ${table} WHERE user_id = $1 AND id = $2${lock ? ' FOR UPDATE' : ''}`,
      [this.userId, id],
    );
    return rows[0]?.dead;
  }

  async apply(change: Change): Promise<Result['status']> {
    const dead = await this.isDead(change.table, change.id, true);
    if (dead) return 'ignored';
    if (change.op === 'delete') {
      await this.tombstone(change.table, change.id, dead !== undefined, change.deletedAt ?? this.now.toISOString());
      return 'applied';
    }
    const row = { ...change.row! };
    for (const ref of REFERENCES) {
      if (ref.table !== change.table || row[ref.column] == null) continue;
      if (await this.isDead(ref.parent, row[ref.column] as string)) {
        // The parent is gone: a child is dropped, a link is cleared.
        if (ref.onDelete === 'cascade') return 'ignored';
        row[ref.column] = null;
      }
    }
    if (change.table === 'bloodstains') return this.bloodstain(change, row, dead !== undefined);
    if (change.table === 'bosses' && dead !== undefined) return this.boss(change, row);
    if (EVENT_TABLES.has(change.table)) {
      if (dead !== undefined) return 'ignored';
      await this.insert(change.table, change.id, row, undefined);
      return 'applied';
    }
    if (dead === undefined) {
      await this.insert(change.table, change.id, row, change.updatedAt);
      return 'applied';
    }
    // Last write wins by (updatedAt, deviceId), compared in SQL so
    // microseconds count.
    const { rows } = await this.db.query<{ newer: boolean }>(
      `SELECT ($3::timestamptz, $4::text) > (updated_at, device_id) AS newer
       FROM ${change.table} WHERE user_id = $1 AND id = $2`,
      [this.userId, change.id, change.updatedAt, this.deviceId],
    );
    if (!rows[0]!.newer) return 'ignored';
    await this.update(change.table, change.id, row, change.updatedAt);
    return 'applied';
  }

  private async insert(table: string, id: string, row: Record<string, unknown>, updatedAt: string | undefined) {
    const cols = Object.keys(SYNCED_COLUMNS[table]!);
    const meta = updatedAt === undefined ? [] : ['updated_at'];
    const values = [
      this.userId,
      id,
      ...cols.map((c) => this.dbValue(table, c, row[c])),
      ...(updatedAt === undefined ? [] : [updatedAt]),
      this.deviceId,
      await this.nextSeq(),
    ];
    const names = ['user_id', 'id', ...cols, ...meta, 'device_id', 'seq'];
    await this.db.query(
      `INSERT INTO ${table} (${names.join(', ')}) VALUES (${names.map((_, i) => `$${i + 1}`).join(', ')})`,
      values,
    );
  }

  private async update(table: string, id: string, row: Record<string, unknown>, updatedAt: string | undefined) {
    const cols = Object.keys(SYNCED_COLUMNS[table]!);
    const sets = [...cols, ...(updatedAt === undefined ? [] : ['updated_at']), 'device_id', 'seq'];
    const values = [
      ...cols.map((c) => this.dbValue(table, c, row[c])),
      ...(updatedAt === undefined ? [] : [updatedAt]),
      this.deviceId,
      await this.nextSeq(),
    ];
    await this.db.query(
      `UPDATE ${table} SET ${sets.map((c, i) => `${c} = $${i + 3}`).join(', ')} WHERE user_id = $1 AND id = $2`,
      [this.userId, id, ...values],
    );
  }

  /** Keeps only id, time, device and seq, then reaches the children. */
  private async tombstone(table: string, id: string, exists: boolean, deletedAt: string) {
    const seq = await this.nextSeq();
    if (exists) {
      const cols = [...Object.keys(SYNCED_COLUMNS[table]!), ...(EVENT_TABLES.has(table) ? [] : ['updated_at'])];
      await this.db.query(
        `UPDATE ${table} SET ${cols.map((c) => `${c} = NULL`).join(', ')},
           deleted_at = $3, device_id = $4, seq = $5
         WHERE user_id = $1 AND id = $2`,
        [this.userId, id, deletedAt, this.deviceId, seq],
      );
    } else {
      await this.db.query(
        `INSERT INTO ${table} (user_id, id, deleted_at, device_id, seq) VALUES ($1, $2, $3, $4, $5)`,
        [this.userId, id, deletedAt, this.deviceId, seq],
      );
    }
    for (const ref of REFERENCES) {
      if (ref.parent !== table) continue;
      const { rows } = await this.db.query<{ id: string }>(
        `SELECT id FROM ${ref.table}
         WHERE user_id = $1 AND ${ref.column} = $2 AND deleted_at IS NULL
         ORDER BY id FOR UPDATE`,
        [this.userId, id],
      );
      for (const child of rows) {
        if (ref.onDelete === 'cascade') {
          // An earlier reference may have tombstoned it already.
          if (!(await this.isDead(ref.table, child.id))) {
            await this.tombstone(ref.table, child.id, true, deletedAt);
          }
        } else {
          await this.db.query(
            `UPDATE ${ref.table} SET ${ref.column} = NULL, seq = $3 WHERE user_id = $1 AND id = $2`,
            [this.userId, child.id, await this.nextSeq()],
          );
        }
      }
    }
  }

  /**
   * A boss merges by last write wins, except that a defeat is final across
   * phones (Stage 5 D2, extended): if either version is defeated the result
   * is defeated, with the earliest defeated_at. The other columns follow
   * last write wins, so a title edited on another phone is kept too.
   */
  private async boss(change: Change, row: Record<string, unknown>): Promise<Result['status']> {
    const DEFEATED = 2;
    const { rows } = await this.db.query<{
      status: number;
      defeated_at: string | null;
      newer: boolean;
      earlier: boolean;
    }>(
      `SELECT status, to_jsonb(defeated_at) #>> '{}' AS defeated_at,
         ($3::timestamptz, $4::text) > (updated_at, device_id) AS newer,
         $5::timestamptz < defeated_at AS earlier
       FROM bosses WHERE user_id = $1 AND id = $2`,
      [this.userId, change.id, change.updatedAt, this.deviceId, row.defeated_at ?? null],
    );
    const stored = rows[0]!;
    const storedDefeated = stored.status === DEFEATED;
    const incomingDefeated = row.status === DEFEATED;
    if (stored.newer) {
      if (storedDefeated) {
        row.status = DEFEATED;
        if (!(incomingDefeated && stored.earlier)) row.defeated_at = stored.defeated_at;
      }
      await this.update('bosses', change.id, row, change.updatedAt);
      return 'applied';
    }
    // Older than what is stored: only a defeat it adds, or an earlier one,
    // is taken, and nothing else of it.
    if (incomingDefeated && (!storedDefeated || stored.earlier)) {
      await this.db.query(
        `UPDATE bosses SET status = $3, defeated_at = $4::timestamptz, seq = $5
         WHERE user_id = $1 AND id = $2`,
        [this.userId, change.id, DEFEATED, row.defeated_at, await this.nextSeq()],
      );
      return 'applied';
    }
    return 'ignored';
  }

  /**
   * A bloodstain's updated_at is not a last-write-wins key (its fields merge,
   * D19); it is the latest of its own times, so every phone and the server
   * store the same value whatever order the pushes arrive in.
   */
  private async stainTime(id: string) {
    await this.db.query(
      `UPDATE bloodstains SET updated_at = GREATEST(created_at, recovered_at, lost_at)
       WHERE user_id = $1 AND id = $2`,
      [this.userId, id],
    );
  }

  /**
   * Field merge (D19), then one active per boss (D11): the newest active
   * stays, the rest are lost at its time. Losers are written before the
   * winner, so the partial unique index never sees two.
   */
  private async bloodstain(change: Change, row: Record<string, unknown>, exists: boolean): Promise<Result['status']> {
    const u = this.userId;
    let merged: { boss_id: string; created_at: string; recovered_at: string | null; lost_at: string | null; changed: boolean };
    if (exists) {
      const { rows } = await this.db.query(
        `SELECT boss_id, to_jsonb(created_at) #>> '{}' AS created_at,
           to_jsonb(rec) #>> '{}' AS recovered_at,
           to_jsonb(CASE WHEN rec IS NULL THEN LEAST(lost_at, $4::timestamptz) END) #>> '{}' AS lost_at,
           rec IS DISTINCT FROM recovered_at
             OR (CASE WHEN rec IS NULL THEN LEAST(lost_at, $4::timestamptz) END) IS DISTINCT FROM lost_at AS changed
         FROM (SELECT *, LEAST(recovered_at, $3::timestamptz) AS rec FROM bloodstains
               WHERE user_id = $1 AND id = $2) b`,
        [u, change.id, row.recovered_at, row.lost_at],
      );
      merged = rows[0];
    } else {
      merged = {
        boss_id: row.boss_id as string,
        created_at: row.created_at as string,
        recovered_at: row.recovered_at as string | null,
        lost_at: row.recovered_at == null ? (row.lost_at as string | null) : null,
        changed: true,
      };
    }
    const isActive = merged.recovered_at == null && merged.lost_at == null;
    const { rows: others } = await this.db.query<{ id: string }>(
      `SELECT id FROM bloodstains
       WHERE user_id = $1 AND boss_id = $2 AND id <> $3
         AND recovered_at IS NULL AND lost_at IS NULL AND deleted_at IS NULL
       FOR UPDATE`,
      [u, merged.boss_id, change.id],
    );
    if (others.length > 0 || isActive) {
      const { rows } = await this.db.query<{ id: string; created_at: string }>(
        `SELECT id, to_jsonb(created_at) #>> '{}' AS created_at FROM (
           SELECT id, created_at FROM bloodstains WHERE user_id = $1 AND id = ANY($2::text[])
           UNION ALL SELECT $3, $4::timestamptz WHERE $5
         ) c ORDER BY created_at DESC, id DESC LIMIT 1`,
        [u, others.map((o) => o.id), change.id, merged.created_at, isActive],
      );
      const winner = rows[0]!;
      for (const loser of others) {
        if (loser.id === winner.id) continue;
        await this.db.query(
          `UPDATE bloodstains SET lost_at = $3, updated_at = GREATEST(created_at, $3), seq = $4
           WHERE user_id = $1 AND id = $2`,
          [u, loser.id, winner.created_at, await this.nextSeq()],
        );
      }
      if (isActive && winner.id !== change.id) {
        merged = { ...merged, lost_at: winner.created_at, changed: true };
      }
    }
    if (!exists) {
      await this.insert(
        'bloodstains',
        change.id,
        { ...row, lost_at: merged.lost_at, recovered_at: merged.recovered_at },
        change.updatedAt,
      );
      await this.stainTime(change.id);
      return 'applied';
    }
    if (!merged.changed) return 'ignored';
    await this.db.query(
      `UPDATE bloodstains SET recovered_at = $3, lost_at = $4, device_id = $5, seq = $6
       WHERE user_id = $1 AND id = $2`,
      [u, change.id, merged.recovered_at, merged.lost_at, this.deviceId, await this.nextSeq()],
    );
    await this.stainTime(change.id);
    return 'applied';
  }
}

const META = ['user_id', 'id', 'device_id', 'seq', 'deleted_at', 'updated_at'];

function pullSql() {
  const parts = Object.keys(SYNCED_COLUMNS).map(
    (table) =>
      `SELECT '${table}' AS tbl, id, seq, device_id,
         ${EVENT_TABLES.has(table) ? 'NULL' : "to_jsonb(updated_at) #>> '{}'"} AS updated_at,
         to_jsonb(deleted_at) #>> '{}' AS deleted_at,
         to_jsonb(t) - ARRAY[${META.map((m) => `'${m}'`).join(', ')}] AS row
       FROM ${table} t WHERE user_id = $1 AND seq > $2`,
  );
  return `SELECT * FROM (${parts.join('\nUNION ALL\n')}) c ORDER BY seq LIMIT $3`;
}
const PULL_SQL = pullSql();

export function syncRoutes(
  app: FastifyInstance,
  deps: {
    pool: pg.Pool;
    now: () => Date;
    hooks: SyncHooks;
    authenticate: (req: FastifyRequest, reply: FastifyReply) => Promise<unknown>;
  },
) {
  const r = app.withTypeProvider<TypeBoxTypeProvider>();

  r.post(
    '/v1/sync/push',
    {
      preHandler: deps.authenticate,
      schema: {
        operationId: 'syncPush',
        tags: ['sync'],
        security: [{ session: [] }],
        body: ref(PushRequest),
        response: { 200: ref(PushResponse), 401: ref(ErrorBody) },
      },
    },
    async (req) => {
      // Validated against PushRequest; its $ref items type as unknown.
      const body = req.body as { deviceId: string; changes: Change[] };
      const now = deps.now();
      const db = await deps.pool.connect();
      const results: Result[] = [];
      try {
        await db.query('BEGIN');
        // Pushes for one user run one at a time, so seq order is commit
        // order and a pull cannot skip a change (D13).
        await db.query('SELECT pg_advisory_xact_lock(hashtextextended($1, 0))', [req.userId]);
        const push = new Push(db, req.userId, body.deviceId, now);
        for (const change of body.changes) {
          const base = { table: change.table, id: change.id };
          try {
            validate(change, now);
            await db.query('SAVEPOINT change');
            results.push({ ...base, status: await push.apply(change) });
            await db.query('RELEASE SAVEPOINT change');
          } catch (e) {
            if (e instanceof Rejected) {
              results.push({ ...base, status: 'rejected', reason: e.reason, message: e.message });
            } else {
              await db.query('ROLLBACK TO SAVEPOINT change');
              req.log.warn({ err: e, table: change.table }, 'push change failed');
              results.push({ ...base, status: 'rejected', reason: 'malformed', message: 'could not be stored' });
            }
          }
        }
        await deps.hooks.beforeCommit?.();
        await db.query('COMMIT');
      } catch (e) {
        await db.query('ROLLBACK');
        throw e;
      } finally {
        db.release();
      }
      return { results };
    },
  );

  r.get(
    '/v1/sync/pull',
    {
      preHandler: deps.authenticate,
      schema: {
        operationId: 'syncPull',
        tags: ['sync'],
        security: [{ session: [] }],
        querystring: Type.Object({ since: Type.Integer({ minimum: 0 }) }),
        response: { 200: ref(PullResponse), 401: ref(ErrorBody) },
      },
    },
    async (req) => {
      const { rows } = await deps.pool.query(PULL_SQL, [req.userId, req.query.since, PAGE_SIZE + 1]);
      const page = rows.slice(0, PAGE_SIZE);
      const changes = page.map((c) => {
        const deleted = c.deleted_at != null;
        return {
          table: c.tbl as string,
          id: c.id as string,
          op: deleted ? ('delete' as const) : ('upsert' as const),
          seq: Number(c.seq),
          deviceId: c.device_id as string,
          ...(c.updated_at == null ? {} : { updatedAt: c.updated_at as string }),
          ...(deleted ? { deletedAt: c.deleted_at as string } : { row: c.row as Record<string, unknown> }),
        };
      });
      return {
        changes,
        cursor: changes.at(-1)?.seq ?? req.query.since,
        hasMore: rows.length > PAGE_SIZE,
      };
    },
  );
}

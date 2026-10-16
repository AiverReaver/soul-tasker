// The synced app tables (Stage 7 plan section 5), in snake_case like the
// app's SQLite. Every table also has user_id, id, device_id, seq and
// deleted_at; mutable ones have updated_at. Payload columns are nullable so
// a tombstone can keep only its id (D5).

export type ColumnType = 'text' | 'integer' | 'boolean' | 'timestamptz' | 'jsonb';

const t = 'text';
const i = 'integer';
const b = 'boolean';
const ts = 'timestamptz';

export const SYNCED_COLUMNS: Record<string, Record<string, ColumnType>> = {
  bosses: {
    title: t,
    defeat_meaning: t,
    status: i,
    attempt_number: i,
    reset_on_fail: i,
    is_pinned: b,
    target_date: ts,
    last_fought_at: ts,
    open_from_attempt: i,
    created_at: ts,
    defeated_at: ts,
  },
  phases: { boss_id: t, name: t, position: i, open_from_attempt: i, created_at: ts },
  tasks: {
    boss_id: t,
    phase_id: t,
    title: t,
    weight: i,
    recurrence: i,
    position: i,
    is_split: b,
    daily_deadline_minutes: i,
    created_at: ts,
  },
  attempts: {
    boss_id: t,
    task_id: t,
    boss_attempt: i,
    outcome: i,
    cause: i,
    phase_id: t,
    lesson: t,
    weight: i,
    day: t,
    at: ts,
  },
  commitments: {
    task_id: t,
    boss_id: t,
    day: t,
    deadline: ts,
    extensions: i,
    remind: b,
    outcome: i,
    resolved_at: ts,
    created_at: ts,
  },
  health_events: { amount: i, reason: i, commitment_id: t, day: t, at: ts },
  ember_events: { kind: i, amount: i, boss_id: t, task_id: t, day: t, at: ts },
  flask_events: { kind: i, amount: i, reason: i, day: t, at: ts },
  relics: {
    boss_id: t,
    name: t,
    emblem: i,
    attempts: i,
    days: i,
    effort: i,
    story: t,
    inscription: t,
    defeated_day: t,
    created_at: ts,
  },
  bloodstains: {
    boss_id: t,
    task_id: t,
    attempt_id: t,
    amount: i,
    created_at: ts,
    recovered_at: ts,
    lost_at: ts,
  },
  day_logs: { day: t, kind: i, lesson: t, at: ts },
  day_plans: { day: t, task_ids: 'jsonb' },
  user_settings: {
    tap_mode: b,
    default_reset_on_fail: i,
    haptics: b,
    rollover_hour: i,
    reminder_enabled: b,
    reminder_minutes: i,
    first_day: t,
    sound: b,
  },
};

/** Insert-once tables (D5): never updated, so no updated_at. Attempts are
 * not among them: a lesson can be added to a fall later, so they merge by
 * last write wins like other records. */
export const EVENT_TABLES = new Set(['health_events', 'ember_events', 'flask_events']);

/** Payload column names per synced table. */
export const SYNCED_TABLES: Record<string, string[]> = Object.fromEntries(
  Object.entries(SYNCED_COLUMNS).map(([table, cols]) => [table, Object.keys(cols)]),
);

/** Natural-key tables are only ever upserted, never deleted (D5). */
export const NATURAL_KEY_TABLES = new Set(['user_settings', 'day_logs', 'day_plans']);

export type Reference = {
  table: string;
  column: string;
  parent: string;
  onDelete: 'cascade' | 'setNull';
};

/** The app's foreign keys, so a deleted parent reaches its children here
 * the way SQLite's cascades reach them on the phone (D5). */
export const REFERENCES: Reference[] = [
  { table: 'phases', column: 'boss_id', parent: 'bosses', onDelete: 'cascade' },
  { table: 'tasks', column: 'boss_id', parent: 'bosses', onDelete: 'cascade' },
  { table: 'tasks', column: 'phase_id', parent: 'phases', onDelete: 'cascade' },
  { table: 'attempts', column: 'boss_id', parent: 'bosses', onDelete: 'cascade' },
  { table: 'attempts', column: 'task_id', parent: 'tasks', onDelete: 'setNull' },
  { table: 'attempts', column: 'phase_id', parent: 'phases', onDelete: 'setNull' },
  { table: 'commitments', column: 'task_id', parent: 'tasks', onDelete: 'cascade' },
  { table: 'commitments', column: 'boss_id', parent: 'bosses', onDelete: 'cascade' },
  { table: 'health_events', column: 'commitment_id', parent: 'commitments', onDelete: 'setNull' },
  { table: 'ember_events', column: 'boss_id', parent: 'bosses', onDelete: 'setNull' },
  { table: 'ember_events', column: 'task_id', parent: 'tasks', onDelete: 'setNull' },
  { table: 'relics', column: 'boss_id', parent: 'bosses', onDelete: 'setNull' },
  { table: 'bloodstains', column: 'boss_id', parent: 'bosses', onDelete: 'cascade' },
  { table: 'bloodstains', column: 'task_id', parent: 'tasks', onDelete: 'setNull' },
  { table: 'bloodstains', column: 'attempt_id', parent: 'attempts', onDelete: 'setNull' },
];

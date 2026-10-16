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

/** Insert-once tables (D5): never updated, so no updated_at. */
export const EVENT_TABLES = new Set(['attempts', 'health_events', 'ember_events', 'flask_events']);

/** Payload column names per synced table. */
export const SYNCED_TABLES: Record<string, string[]> = Object.fromEntries(
  Object.entries(SYNCED_COLUMNS).map(([table, cols]) => [table, Object.keys(cols)]),
);

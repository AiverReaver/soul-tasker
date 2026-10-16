-- Up Migration
-- Stage 7 plan section 5. Generated once from src/tables.ts; edit both
-- together. Never edit after it ships: add a new migration instead.

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  google_sub text NOT NULL UNIQUE,
  email text NOT NULL,
  -- The last seq given to one of this user's rows (D13).
  last_seq bigint NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Opaque session tokens; only the SHA-256 is kept (D4).
CREATE TABLE sessions (
  token_hash bytea PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  expires_at timestamptz NOT NULL
);
CREATE INDEX sessions_user ON sessions (user_id);

CREATE TABLE bosses (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  title text,
  defeat_meaning text,
  status integer,
  attempt_number integer,
  reset_on_fail integer,
  is_pinned boolean,
  target_date timestamptz,
  last_fought_at timestamptz,
  open_from_attempt integer,
  created_at timestamptz,
  defeated_at timestamptz,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX bosses_seq ON bosses (user_id, seq);

CREATE TABLE phases (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  boss_id text,
  name text,
  position integer,
  open_from_attempt integer,
  created_at timestamptz,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX phases_seq ON phases (user_id, seq);

CREATE TABLE tasks (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  boss_id text,
  phase_id text,
  title text,
  weight integer,
  recurrence integer,
  position integer,
  is_split boolean,
  daily_deadline_minutes integer,
  created_at timestamptz,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX tasks_seq ON tasks (user_id, seq);

CREATE TABLE attempts (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  boss_id text,
  task_id text,
  boss_attempt integer,
  outcome integer,
  cause integer,
  phase_id text,
  lesson text,
  weight integer,
  day text,
  at timestamptz,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX attempts_seq ON attempts (user_id, seq);

CREATE TABLE commitments (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  task_id text,
  boss_id text,
  day text,
  deadline timestamptz,
  extensions integer,
  remind boolean,
  outcome integer,
  resolved_at timestamptz,
  created_at timestamptz,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX commitments_seq ON commitments (user_id, seq);

CREATE TABLE health_events (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  amount integer,
  reason integer,
  commitment_id text,
  day text,
  at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX health_events_seq ON health_events (user_id, seq);

CREATE TABLE ember_events (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  kind integer,
  amount integer,
  boss_id text,
  task_id text,
  day text,
  at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX ember_events_seq ON ember_events (user_id, seq);

CREATE TABLE flask_events (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  kind integer,
  amount integer,
  reason integer,
  day text,
  at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX flask_events_seq ON flask_events (user_id, seq);

CREATE TABLE relics (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  boss_id text,
  name text,
  emblem integer,
  attempts integer,
  days integer,
  effort integer,
  story text,
  inscription text,
  defeated_day text,
  created_at timestamptz,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX relics_seq ON relics (user_id, seq);

CREATE TABLE bloodstains (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  boss_id text,
  task_id text,
  attempt_id text,
  amount integer,
  created_at timestamptz,
  recovered_at timestamptz,
  lost_at timestamptz,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX bloodstains_seq ON bloodstains (user_id, seq);

CREATE TABLE day_logs (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  day text,
  kind integer,
  lesson text,
  at timestamptz,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX day_logs_seq ON day_logs (user_id, seq);

CREATE TABLE day_plans (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  day text,
  task_ids jsonb,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX day_plans_seq ON day_plans (user_id, seq);

CREATE TABLE user_settings (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  id text NOT NULL,
  tap_mode boolean,
  default_reset_on_fail integer,
  haptics boolean,
  rollover_hour integer,
  reminder_enabled boolean,
  reminder_minutes integer,
  first_day text,
  sound boolean,
  updated_at timestamptz,
  device_id text NOT NULL,
  seq bigint NOT NULL,
  deleted_at timestamptz,
  PRIMARY KEY (user_id, id)
);
CREATE INDEX user_settings_seq ON user_settings (user_id, seq);

-- At most one active bloodstain per boss, so a bug cannot store two (D11).
CREATE UNIQUE INDEX one_active_bloodstain ON bloodstains (user_id, boss_id)
  WHERE recovered_at IS NULL AND lost_at IS NULL AND deleted_at IS NULL;

-- Down Migration
DROP TABLE user_settings;
DROP TABLE day_plans;
DROP TABLE day_logs;
DROP TABLE bloodstains;
DROP TABLE relics;
DROP TABLE flask_events;
DROP TABLE ember_events;
DROP TABLE health_events;
DROP TABLE commitments;
DROP TABLE attempts;
DROP TABLE tasks;
DROP TABLE phases;
DROP TABLE bosses;
DROP TABLE sessions;
DROP TABLE users;

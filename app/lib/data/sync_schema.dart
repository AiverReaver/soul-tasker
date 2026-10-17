/// The synced tables as the server stores them (Stage 7 plan section 5): the
/// payload columns of each, with the server's type, in the server's order.
/// A push row has exactly these keys. `test/data/sync_schema_test.dart`
/// checks this file against `server/test/fixtures/sync_schema.json`.
const kSyncColumns = <String, Map<String, String>>{
  'bosses': {
    'title': 'text',
    'defeat_meaning': 'text',
    'status': 'integer',
    'attempt_number': 'integer',
    'reset_on_fail': 'integer',
    'is_pinned': 'boolean',
    'target_date': 'timestamptz',
    'last_fought_at': 'timestamptz',
    'open_from_attempt': 'integer',
    'created_at': 'timestamptz',
    'defeated_at': 'timestamptz',
  },
  'phases': {
    'boss_id': 'text',
    'name': 'text',
    'position': 'integer',
    'open_from_attempt': 'integer',
    'created_at': 'timestamptz',
  },
  'tasks': {
    'boss_id': 'text',
    'phase_id': 'text',
    'title': 'text',
    'weight': 'integer',
    'recurrence': 'integer',
    'position': 'integer',
    'is_split': 'boolean',
    'daily_deadline_minutes': 'integer',
    'created_at': 'timestamptz',
  },
  'attempts': {
    'boss_id': 'text',
    'task_id': 'text',
    'boss_attempt': 'integer',
    'outcome': 'integer',
    'cause': 'integer',
    'phase_id': 'text',
    'lesson': 'text',
    'weight': 'integer',
    'day': 'text',
    'at': 'timestamptz',
  },
  'commitments': {
    'task_id': 'text',
    'boss_id': 'text',
    'day': 'text',
    'deadline': 'timestamptz',
    'extensions': 'integer',
    'remind': 'boolean',
    'outcome': 'integer',
    'resolved_at': 'timestamptz',
    'created_at': 'timestamptz',
  },
  'health_events': {
    'amount': 'integer',
    'reason': 'integer',
    'commitment_id': 'text',
    'day': 'text',
    'at': 'timestamptz',
  },
  'ember_events': {
    'kind': 'integer',
    'amount': 'integer',
    'boss_id': 'text',
    'task_id': 'text',
    'day': 'text',
    'at': 'timestamptz',
  },
  'flask_events': {
    'kind': 'integer',
    'amount': 'integer',
    'reason': 'integer',
    'day': 'text',
    'at': 'timestamptz',
  },
  'relics': {
    'boss_id': 'text',
    'name': 'text',
    'emblem': 'integer',
    'attempts': 'integer',
    'days': 'integer',
    'effort': 'integer',
    'story': 'text',
    'inscription': 'text',
    'defeated_day': 'text',
    'created_at': 'timestamptz',
  },
  'bloodstains': {
    'boss_id': 'text',
    'task_id': 'text',
    'attempt_id': 'text',
    'amount': 'integer',
    'created_at': 'timestamptz',
    'recovered_at': 'timestamptz',
    'lost_at': 'timestamptz',
  },
  'day_logs': {
    'day': 'text',
    'kind': 'integer',
    'lesson': 'text',
    'at': 'timestamptz',
  },
  'day_plans': {'day': 'text', 'task_ids': 'jsonb'},
  'user_settings': {
    'tap_mode': 'boolean',
    'default_reset_on_fail': 'integer',
    'haptics': 'boolean',
    'rollover_hour': 'integer',
    'reminder_enabled': 'boolean',
    'reminder_minutes': 'integer',
    'first_day': 'text',
    'sound': 'boolean',
  },
};

/// Insert-once tables: no `updated_at`, never changed after the insert.
const kEventTables = {'health_events', 'ember_events', 'flask_events'};

/// Tables keyed by their data, only ever upserted.
const kNaturalKeyTables = {'user_settings', 'day_logs', 'day_plans'};

/// A foreign key, so a deleted parent reaches its children here the way the
/// server and SQLite's cascades do (Stage 7 plan D5).
typedef SyncReference = ({
  String table,
  String column,
  String parent,
  bool cascade,
});

const kSyncReferences = <SyncReference>[
  (table: 'phases', column: 'boss_id', parent: 'bosses', cascade: true),
  (table: 'tasks', column: 'boss_id', parent: 'bosses', cascade: true),
  (table: 'tasks', column: 'phase_id', parent: 'phases', cascade: true),
  (table: 'attempts', column: 'boss_id', parent: 'bosses', cascade: true),
  (table: 'attempts', column: 'task_id', parent: 'tasks', cascade: false),
  (table: 'attempts', column: 'phase_id', parent: 'phases', cascade: false),
  (table: 'commitments', column: 'task_id', parent: 'tasks', cascade: true),
  (table: 'commitments', column: 'boss_id', parent: 'bosses', cascade: true),
  (
    table: 'health_events',
    column: 'commitment_id',
    parent: 'commitments',
    cascade: false,
  ),
  (table: 'ember_events', column: 'boss_id', parent: 'bosses', cascade: false),
  (table: 'ember_events', column: 'task_id', parent: 'tasks', cascade: false),
  (table: 'relics', column: 'boss_id', parent: 'bosses', cascade: false),
  (table: 'bloodstains', column: 'boss_id', parent: 'bosses', cascade: true),
  (table: 'bloodstains', column: 'task_id', parent: 'tasks', cascade: false),
  (
    table: 'bloodstains',
    column: 'attempt_id',
    parent: 'attempts',
    cascade: false,
  ),
];

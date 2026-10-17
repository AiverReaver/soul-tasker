import { readFileSync } from 'node:fs';
import { expect, test } from 'vitest';
import { EVENT_TABLES, NATURAL_KEY_TABLES, REFERENCES, SYNCED_COLUMNS } from '../src/tables.ts';

const fixture = JSON.parse(readFileSync(new URL('./fixtures/sync_schema.json', import.meta.url), 'utf8'));

// The app's sync service reads the same file (app/test/data/sync_schema_test.dart).
test('the synced tables equal the shared fixture the app checks against', () => {
  expect(SYNCED_COLUMNS).toEqual(fixture.columns);
  expect([...EVENT_TABLES].sort()).toEqual([...fixture.events].sort());
  expect([...NATURAL_KEY_TABLES].sort()).toEqual([...fixture.naturalKey].sort());
  expect(REFERENCES).toEqual(fixture.references);
});

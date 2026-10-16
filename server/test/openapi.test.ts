import { readFileSync } from 'node:fs';
import { Validator } from '@seriousme/openapi-schema-validator';
import { expect, test } from 'vitest';
import { buildOpenApi } from '../src/openapi.ts';

const committed = JSON.parse(readFileSync(new URL('../openapi.json', import.meta.url), 'utf8'));

test('the spec built from the routes equals the committed openapi.json (D3)', async () => {
  // If this fails, run `npm run openapi` and then `app/tool/gen_api_client.sh`.
  expect(await buildOpenApi()).toEqual(committed);
});

test('the spec is valid OpenAPI 3.1', async () => {
  const spec = await buildOpenApi();
  expect(spec.openapi).toMatch(/^3\.1\./);
  const result = await new Validator().validate(spec);
  expect(result.errors ?? []).toEqual([]);
  expect(result.valid).toBe(true);
});

test('the sync models are named components', async () => {
  const names = Object.keys((await buildOpenApi()).components.schemas);
  expect(names).toEqual(
    expect.arrayContaining(['ChangeDto', 'PulledChangeDto', 'PushRequest', 'PushResponse', 'PushResult', 'PullResponse']),
  );
});

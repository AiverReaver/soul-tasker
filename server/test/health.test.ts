import { afterAll, beforeAll, expect, test } from 'vitest';
import { testApp } from './helpers.ts';
import pkg from '../package.json' with { type: 'json' };

let t: Awaited<ReturnType<typeof testApp>>;
beforeAll(async () => {
  t = await testApp();
});
afterAll(() => t.close());

test('GET /v1/health returns 200 and the version', async () => {
  const res = await t.app.inject({ method: 'GET', url: '/v1/health' });
  expect(res.statusCode).toBe(200);
  expect(res.json()).toEqual({ status: 'ok', version: pkg.version });
});

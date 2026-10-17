// The real server for the app's scripted gate (Stage 7 plan step 11): real
// Fastify, real PostgreSQL, a fresh schema, and fake Google keys so the gate
// can sign in. Prints one JSON line with its URL and some ID tokens, then
// serves until killed. Started by app/tool/gate_stage7.sh.
import { createServer } from 'node:net';
import { buildApp } from '../src/app.ts';
import { CLIENT_ID, fakeGoogle, testDb } from './helpers.ts';

// A fixed clock keeps the gate's 2026 dates inside the server's 24 h window.
const NOW = new Date('2026-10-20T00:00:00Z');
const now = () => NOW;

const db = await testDb();
const google = await fakeGoogle(now);
const app = await buildApp({ pool: db.pool, googleClientId: CLIENT_ID, jwks: google.jwks, now });

const free = await new Promise<number>((resolve) => {
  const s = createServer();
  s.listen(0, '127.0.0.1', () => {
    const port = (s.address() as { port: number }).port;
    s.close(() => resolve(port));
  });
});
await app.listen({ host: '127.0.0.1', port: free });

// One Google account per scripted run; each token works for any number of
// sign-ins, so two devices share an account.
const tokens: string[] = [];
for (let i = 1; i <= 8; i++) {
  tokens.push(await google.sign({ sub: `gate-sub-${i}`, email: `gate${i}@example.com` }, { expiresIn: Math.floor(NOW.getTime() / 1000) + 3600 }));
}
console.log(JSON.stringify({ url: `http://127.0.0.1:${free}`, tokens }));

async function stop() {
  await app.close();
  await db.drop();
  process.exit(0);
}
process.on('SIGTERM', stop);
process.on('SIGINT', stop);

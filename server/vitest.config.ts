import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Each file migrates its own schema in one shared PostgreSQL.
    testTimeout: 20_000,
    hookTimeout: 60_000,
  },
});

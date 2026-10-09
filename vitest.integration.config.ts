import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

// Testes contra um Postgres real. Exige TEST_DATABASE_URL.
export default defineConfig({
  resolve: {
    alias: { "@": fileURLToPath(new URL("./src", import.meta.url)) },
  },
  test: {
    include: ["test/integration/**/*.test.ts"],
    environment: "node",
    globalSetup: ["test/integration/global-setup.ts"],
    testTimeout: 30_000,
    hookTimeout: 120_000,
  },
});

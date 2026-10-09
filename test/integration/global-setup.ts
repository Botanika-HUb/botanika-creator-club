import { execFileSync } from "node:child_process";
import pg from "pg";
import type { TestProject } from "vitest/node";

/**
 * Cada execução cria um schema próprio e descartável no banco de teste,
 * aplica as migrações reais com `prisma migrate deploy` e apaga o schema no fim.
 * Nada fora desse schema é tocado.
 */

declare module "vitest" {
  export interface ProvidedContext {
    testDatabaseUrl: string;
    testSchema: string;
  }
}

export function withSchema(url: string, schema: string): string {
  const u = new URL(url);
  u.searchParams.set("schema", schema);
  return u.toString();
}

export default function setup(project: TestProject) {
  const base = process.env.TEST_DATABASE_URL;
  if (!base) {
    throw new Error(
      "TEST_DATABASE_URL não definido. Ex.: postgresql://creator:creator@localhost:5432/creator_club_test",
    );
  }
  const schema = `it_${Date.now()}_${process.pid}`;

  execFileSync("npx", ["prisma", "migrate", "deploy"], {
    env: { ...process.env, DATABASE_URL: withSchema(base, schema) },
    stdio: "pipe",
  });

  project.provide("testDatabaseUrl", base);
  project.provide("testSchema", schema);

  return async () => {
    const client = new pg.Client({ connectionString: base });
    await client.connect();
    await client.query(`DROP SCHEMA IF EXISTS "${schema}" CASCADE`);
    await client.end();
  };
}

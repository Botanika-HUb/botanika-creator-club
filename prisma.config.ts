import { defineConfig } from "prisma/config";

// DATABASE_URL: conexão usada pela aplicação e pelas migrações.
// Em produção (Supabase) as migrações usam a conexão direta (porta 5432), não o pooler.
export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: { path: "prisma/migrations" },
  datasource: { url: process.env.DATABASE_URL ?? "" },
});

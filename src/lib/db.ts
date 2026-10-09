import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@/generated/prisma/client";

/** Cria um cliente Prisma para a URL dada (Postgres via driver `pg`). */
export function createPrismaClient(connectionString: string): PrismaClient {
  if (!connectionString) throw new Error("DATABASE_URL não configurado.");
  return new PrismaClient({ adapter: new PrismaPg({ connectionString }) });
}

// Um cliente por processo; em dev o hot reload reaproveita o mesmo.
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export function db(): PrismaClient {
  globalForPrisma.prisma ??= createPrismaClient(process.env.DATABASE_URL ?? "");
  return globalForPrisma.prisma;
}

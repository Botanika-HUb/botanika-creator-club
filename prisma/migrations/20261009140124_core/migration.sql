-- CreateEnum
CREATE TYPE "IntegrationKind" AS ENUM ('SHOPIFY', 'AUTENTIQUE', 'WHATSAPP');

-- CreateEnum
CREATE TYPE "IntegrationStatus" AS ENUM ('DISCONNECTED', 'CONNECTED', 'ERROR');

-- CreateEnum
CREATE TYPE "StaffRole" AS ENUM ('SUPER_ADMIN', 'GESTAO', 'ENVIO', 'PAGAMENTO', 'HUNTER');

-- CreateEnum
CREATE TYPE "CreatorCategory" AS ENUM ('INFLUENCER', 'UGC', 'PRESCRITOR');

-- CreateEnum
CREATE TYPE "CreatorStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'DEACTIVATED');

-- CreateEnum
CREATE TYPE "CouponKind" AS ENUM ('CREATOR', 'PROMO');

-- CreateEnum
CREATE TYPE "LedgerType" AS ENUM ('COMMISSION', 'REVERSAL', 'WITHDRAWAL', 'ADJUSTMENT', 'OPENING_BALANCE');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('NF_PIX', 'ALELO');

-- CreateEnum
CREATE TYPE "WithdrawalStatus" AS ENUM ('REQUESTED', 'PAID', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "WebhookStatus" AS ENUM ('RECEIVED', 'PROCESSED', 'FAILED', 'IGNORED');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('PENDING', 'RUNNING', 'DONE', 'FAILED');

-- CreateEnum
CREATE TYPE "ActorType" AS ENUM ('USER', 'SYSTEM', 'WEBHOOK', 'JOB');

-- CreateTable
CREATE TABLE "Brand" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "timezone" TEXT NOT NULL DEFAULT 'America/Sao_Paulo',
    "currency" TEXT NOT NULL DEFAULT 'BRL',
    "storeUrl" TEXT,
    "primaryColor" TEXT NOT NULL DEFAULT '#2f6b3f',
    "defaultCommissionBps" INTEGER NOT NULL DEFAULT 1500,
    "defaultDiscountBps" INTEGER NOT NULL DEFAULT 500,
    "withdrawalMinCents" INTEGER NOT NULL DEFAULT 50000,
    "withdrawalWindowStartDay" INTEGER NOT NULL DEFAULT 10,
    "withdrawalWindowEndDay" INTEGER NOT NULL DEFAULT 15,
    "commissionHoldDays" INTEGER NOT NULL DEFAULT 0,
    "nfInstructions" TEXT,
    "legacyId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Brand_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BrandIntegration" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "kind" "IntegrationKind" NOT NULL,
    "status" "IntegrationStatus" NOT NULL DEFAULT 'DISCONNECTED',
    "externalId" TEXT,
    "secretEncrypted" TEXT,
    "scopes" TEXT,
    "apiVersion" TEXT,
    "lastSyncAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BrandIntegration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "disabledAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RoleGrant" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "brandId" TEXT,
    "role" "StaffRole" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RoleGrant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CreatorAccount" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "cpf" TEXT,
    "cnpj" TEXT,
    "pixKey" TEXT,
    "legacyId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CreatorAccount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Creator" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "categories" "CreatorCategory"[],
    "status" "CreatorStatus" NOT NULL DEFAULT 'ACTIVE',
    "activatedAt" TIMESTAMP(3),
    "deactivatedAt" TIMESTAMP(3),
    "source" TEXT,
    "legacyId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Creator_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CommissionPolicy" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "rateBps" INTEGER NOT NULL,
    "validFrom" TIMESTAMP(3) NOT NULL,
    "validTo" TIMESTAMP(3),
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CommissionPolicy_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Coupon" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "kind" "CouponKind" NOT NULL,
    "shopifyId" TEXT,
    "discountBps" INTEGER,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "legacyId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Coupon_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CouponAssignment" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "couponId" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "validFrom" TIMESTAMP(3) NOT NULL,
    "validTo" TIMESTAMP(3),
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CouponAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Order" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "shopifyId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAtShop" TIMESTAMP(3) NOT NULL,
    "paidAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "financialStatus" TEXT NOT NULL,
    "test" BOOLEAN NOT NULL DEFAULT false,
    "taxesIncluded" BOOLEAN,
    "subtotalCents" INTEGER NOT NULL,
    "totalCents" INTEGER NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'BRL',
    "discountCodes" TEXT[],
    "shopifyUpdatedAt" TIMESTAMP(3) NOT NULL,
    "syncedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OrderLine" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "shopifyId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "discountedTotalCents" INTEGER NOT NULL,

    CONSTRAINT "OrderLine_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OrderAttribution" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "couponId" TEXT NOT NULL,
    "rateBps" INTEGER,
    "rule" TEXT NOT NULL,
    "evidenceCodes" TEXT[],
    "decidedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OrderAttribution_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LedgerEntry" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "type" "LedgerType" NOT NULL,
    "amountCents" INTEGER NOT NULL,
    "orderId" TEXT,
    "withdrawalId" TEXT,
    "baseCents" INTEGER,
    "rateBps" INTEGER,
    "availableAt" TIMESTAMP(3) NOT NULL,
    "idempotencyKey" TEXT NOT NULL,
    "note" TEXT,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LedgerEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Withdrawal" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "amountCents" INTEGER NOT NULL,
    "method" "PaymentMethod" NOT NULL DEFAULT 'NF_PIX',
    "status" "WithdrawalStatus" NOT NULL DEFAULT 'REQUESTED',
    "nfFileId" TEXT,
    "idempotencyKey" TEXT NOT NULL,
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decidedAt" TIMESTAMP(3),
    "decidedById" TEXT,
    "note" TEXT,

    CONSTRAINT "Withdrawal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "File" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "bucket" TEXT NOT NULL,
    "path" TEXT NOT NULL,
    "mime" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "sha256" TEXT NOT NULL,
    "uploadedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "File_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WebhookEvent" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "topic" TEXT NOT NULL,
    "webhookId" TEXT NOT NULL,
    "resourceId" TEXT,
    "payloadHash" TEXT NOT NULL,
    "status" "WebhookStatus" NOT NULL DEFAULT 'RECEIVED',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,
    "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" TIMESTAMP(3),

    CONSTRAINT "WebhookEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Job" (
    "id" TEXT NOT NULL,
    "brandId" TEXT,
    "type" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "dedupeKey" TEXT,
    "status" "JobStatus" NOT NULL DEFAULT 'PENDING',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "maxAttempts" INTEGER NOT NULL DEFAULT 8,
    "runAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lockedUntil" TIMESTAMP(3),
    "lockedBy" TEXT,
    "lastError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),

    CONSTRAINT "Job_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SyncRun" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "cursor" TIMESTAMP(3),
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),
    "ordersSeen" INTEGER NOT NULL DEFAULT 0,
    "ordersFixed" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,

    CONSTRAINT "SyncRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "brandId" TEXT,
    "actorType" "ActorType" NOT NULL,
    "actorId" TEXT,
    "action" TEXT NOT NULL,
    "entity" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "before" JSONB,
    "after" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Click" (
    "id" TEXT NOT NULL,
    "brandId" TEXT NOT NULL,
    "couponId" TEXT NOT NULL,
    "ipHash" TEXT,
    "userAgent" TEXT,
    "referrer" TEXT,
    "landing" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Click_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Brand_slug_key" ON "Brand"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "Brand_legacyId_key" ON "Brand"("legacyId");

-- CreateIndex
CREATE UNIQUE INDEX "BrandIntegration_brandId_kind_key" ON "BrandIntegration"("brandId", "kind");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "RoleGrant_userId_idx" ON "RoleGrant"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "RoleGrant_userId_brandId_role_key" ON "RoleGrant"("userId", "brandId", "role");

-- CreateIndex
CREATE UNIQUE INDEX "CreatorAccount_userId_key" ON "CreatorAccount"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "CreatorAccount_email_key" ON "CreatorAccount"("email");

-- CreateIndex
CREATE UNIQUE INDEX "CreatorAccount_legacyId_key" ON "CreatorAccount"("legacyId");

-- CreateIndex
CREATE INDEX "Creator_brandId_status_idx" ON "Creator"("brandId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Creator_brandId_accountId_key" ON "Creator"("brandId", "accountId");

-- CreateIndex
CREATE UNIQUE INDEX "Creator_id_brandId_key" ON "Creator"("id", "brandId");

-- CreateIndex
CREATE UNIQUE INDEX "Creator_brandId_legacyId_key" ON "Creator"("brandId", "legacyId");

-- CreateIndex
CREATE INDEX "CommissionPolicy_creatorId_validFrom_idx" ON "CommissionPolicy"("creatorId", "validFrom");

-- CreateIndex
CREATE UNIQUE INDEX "Coupon_brandId_code_key" ON "Coupon"("brandId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "Coupon_id_brandId_key" ON "Coupon"("id", "brandId");

-- CreateIndex
CREATE INDEX "CouponAssignment_couponId_validFrom_idx" ON "CouponAssignment"("couponId", "validFrom");

-- CreateIndex
CREATE INDEX "CouponAssignment_creatorId_idx" ON "CouponAssignment"("creatorId");

-- CreateIndex
CREATE INDEX "Order_brandId_shopifyUpdatedAt_idx" ON "Order"("brandId", "shopifyUpdatedAt");

-- CreateIndex
CREATE INDEX "Order_brandId_createdAtShop_idx" ON "Order"("brandId", "createdAtShop");

-- CreateIndex
CREATE UNIQUE INDEX "Order_brandId_shopifyId_key" ON "Order"("brandId", "shopifyId");

-- CreateIndex
CREATE UNIQUE INDEX "Order_id_brandId_key" ON "Order"("id", "brandId");

-- CreateIndex
CREATE UNIQUE INDEX "OrderLine_orderId_shopifyId_key" ON "OrderLine"("orderId", "shopifyId");

-- CreateIndex
CREATE UNIQUE INDEX "OrderAttribution_orderId_key" ON "OrderAttribution"("orderId");

-- CreateIndex
CREATE INDEX "OrderAttribution_brandId_creatorId_idx" ON "OrderAttribution"("brandId", "creatorId");

-- CreateIndex
CREATE UNIQUE INDEX "OrderAttribution_orderId_brandId_key" ON "OrderAttribution"("orderId", "brandId");

-- CreateIndex
CREATE UNIQUE INDEX "LedgerEntry_idempotencyKey_key" ON "LedgerEntry"("idempotencyKey");

-- CreateIndex
CREATE INDEX "LedgerEntry_brandId_creatorId_createdAt_idx" ON "LedgerEntry"("brandId", "creatorId", "createdAt");

-- CreateIndex
CREATE INDEX "LedgerEntry_orderId_idx" ON "LedgerEntry"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "Withdrawal_idempotencyKey_key" ON "Withdrawal"("idempotencyKey");

-- CreateIndex
CREATE INDEX "Withdrawal_brandId_status_idx" ON "Withdrawal"("brandId", "status");

-- CreateIndex
CREATE INDEX "Withdrawal_creatorId_idx" ON "Withdrawal"("creatorId");

-- CreateIndex
CREATE UNIQUE INDEX "Withdrawal_id_brandId_key" ON "Withdrawal"("id", "brandId");

-- CreateIndex
CREATE UNIQUE INDEX "File_bucket_path_key" ON "File"("bucket", "path");

-- CreateIndex
CREATE INDEX "WebhookEvent_status_receivedAt_idx" ON "WebhookEvent"("status", "receivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "WebhookEvent_brandId_webhookId_key" ON "WebhookEvent"("brandId", "webhookId");

-- CreateIndex
CREATE UNIQUE INDEX "Job_dedupeKey_key" ON "Job"("dedupeKey");

-- CreateIndex
CREATE INDEX "Job_status_runAt_idx" ON "Job"("status", "runAt");

-- CreateIndex
CREATE INDEX "SyncRun_brandId_startedAt_idx" ON "SyncRun"("brandId", "startedAt");

-- CreateIndex
CREATE INDEX "AuditLog_brandId_createdAt_idx" ON "AuditLog"("brandId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_entity_entityId_idx" ON "AuditLog"("entity", "entityId");

-- CreateIndex
CREATE INDEX "Click_couponId_createdAt_idx" ON "Click"("couponId", "createdAt");

-- AddForeignKey
ALTER TABLE "BrandIntegration" ADD CONSTRAINT "BrandIntegration_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoleGrant" ADD CONSTRAINT "RoleGrant_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoleGrant" ADD CONSTRAINT "RoleGrant_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreatorAccount" ADD CONSTRAINT "CreatorAccount_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Creator" ADD CONSTRAINT "Creator_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Creator" ADD CONSTRAINT "Creator_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "CreatorAccount"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CommissionPolicy" ADD CONSTRAINT "CommissionPolicy_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CommissionPolicy" ADD CONSTRAINT "CommissionPolicy_creatorId_brandId_fkey" FOREIGN KEY ("creatorId", "brandId") REFERENCES "Creator"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Coupon" ADD CONSTRAINT "Coupon_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CouponAssignment" ADD CONSTRAINT "CouponAssignment_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CouponAssignment" ADD CONSTRAINT "CouponAssignment_couponId_brandId_fkey" FOREIGN KEY ("couponId", "brandId") REFERENCES "Coupon"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CouponAssignment" ADD CONSTRAINT "CouponAssignment_creatorId_brandId_fkey" FOREIGN KEY ("creatorId", "brandId") REFERENCES "Creator"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Order" ADD CONSTRAINT "Order_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderLine" ADD CONSTRAINT "OrderLine_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderLine" ADD CONSTRAINT "OrderLine_orderId_brandId_fkey" FOREIGN KEY ("orderId", "brandId") REFERENCES "Order"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderAttribution" ADD CONSTRAINT "OrderAttribution_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderAttribution" ADD CONSTRAINT "OrderAttribution_orderId_brandId_fkey" FOREIGN KEY ("orderId", "brandId") REFERENCES "Order"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderAttribution" ADD CONSTRAINT "OrderAttribution_creatorId_brandId_fkey" FOREIGN KEY ("creatorId", "brandId") REFERENCES "Creator"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderAttribution" ADD CONSTRAINT "OrderAttribution_couponId_brandId_fkey" FOREIGN KEY ("couponId", "brandId") REFERENCES "Coupon"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LedgerEntry" ADD CONSTRAINT "LedgerEntry_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LedgerEntry" ADD CONSTRAINT "LedgerEntry_creatorId_brandId_fkey" FOREIGN KEY ("creatorId", "brandId") REFERENCES "Creator"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LedgerEntry" ADD CONSTRAINT "LedgerEntry_orderId_brandId_fkey" FOREIGN KEY ("orderId", "brandId") REFERENCES "Order"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LedgerEntry" ADD CONSTRAINT "LedgerEntry_withdrawalId_brandId_fkey" FOREIGN KEY ("withdrawalId", "brandId") REFERENCES "Withdrawal"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Withdrawal" ADD CONSTRAINT "Withdrawal_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Withdrawal" ADD CONSTRAINT "Withdrawal_creatorId_brandId_fkey" FOREIGN KEY ("creatorId", "brandId") REFERENCES "Creator"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Withdrawal" ADD CONSTRAINT "Withdrawal_nfFileId_fkey" FOREIGN KEY ("nfFileId") REFERENCES "File"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "File" ADD CONSTRAINT "File_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WebhookEvent" ADD CONSTRAINT "WebhookEvent_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SyncRun" ADD CONSTRAINT "SyncRun_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Click" ADD CONSTRAINT "Click_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Click" ADD CONSTRAINT "Click_couponId_brandId_fkey" FOREIGN KEY ("couponId", "brandId") REFERENCES "Coupon"("id", "brandId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- ════════════════════════════════════════════════════════════════════════════
-- Travas de integridade que o Prisma não expressa. Valem mesmo para quem
-- escrever direto no banco. Datas são TIMESTAMP(3) em UTC (padrão do Prisma).
-- ════════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Marca: valores de configuração dentro de faixas válidas.
ALTER TABLE "Brand"
  ADD CONSTRAINT "Brand_defaultCommissionBps_range" CHECK ("defaultCommissionBps" BETWEEN 0 AND 10000),
  ADD CONSTRAINT "Brand_defaultDiscountBps_range" CHECK ("defaultDiscountBps" BETWEEN 0 AND 10000),
  ADD CONSTRAINT "Brand_withdrawalMinCents_nonneg" CHECK ("withdrawalMinCents" >= 0),
  ADD CONSTRAINT "Brand_withdrawalWindow_valid" CHECK (
    "withdrawalWindowStartDay" BETWEEN 1 AND 31
    AND "withdrawalWindowEndDay" BETWEEN 1 AND 31
    AND "withdrawalWindowStartDay" <= "withdrawalWindowEndDay"),
  ADD CONSTRAINT "Brand_commissionHoldDays_nonneg" CHECK ("commissionHoldDays" >= 0);

-- Papel por marca: um mesmo papel não se repete.
-- Só SUPER_ADMIN pode valer para todas as marcas.
-- Por marca a unicidade vem do @@unique do schema; para papéis globais (brandId NULL),
-- um índice parcial, que o Prisma não tenta recriar nem apagar.
CREATE UNIQUE INDEX "RoleGrant_global_user_role_key"
  ON "RoleGrant" ("userId", "role") WHERE "brandId" IS NULL;
ALTER TABLE "RoleGrant"
  ADD CONSTRAINT "RoleGrant_global_only_super_admin" CHECK ("brandId" IS NOT NULL OR "role" = 'SUPER_ADMIN');

-- Taxa de comissão: faixa válida, período coerente e sem sobreposição por creator.
ALTER TABLE "CommissionPolicy"
  ADD CONSTRAINT "CommissionPolicy_rateBps_range" CHECK ("rateBps" BETWEEN 0 AND 10000),
  ADD CONSTRAINT "CommissionPolicy_period_valid" CHECK ("validTo" IS NULL OR "validTo" > "validFrom"),
  ADD CONSTRAINT "CommissionPolicy_no_overlap" EXCLUDE USING gist (
    "creatorId" WITH =,
    tsrange("validFrom", "validTo", '[)') WITH &&
  );

-- Cupom: código em maiúsculas, desconto em faixa válida.
ALTER TABLE "Coupon"
  ADD CONSTRAINT "Coupon_code_uppercase" CHECK ("code" = upper(btrim("code")) AND "code" <> ''),
  ADD CONSTRAINT "Coupon_discountBps_range" CHECK ("discountBps" IS NULL OR "discountBps" BETWEEN 0 AND 10000);

-- Dona do cupom: período coerente e no máximo uma dona por vez.
ALTER TABLE "CouponAssignment"
  ADD CONSTRAINT "CouponAssignment_period_valid" CHECK ("validTo" IS NULL OR "validTo" > "validFrom"),
  ADD CONSTRAINT "CouponAssignment_no_overlap" EXCLUDE USING gist (
    "couponId" WITH =,
    tsrange("validFrom", "validTo", '[)') WITH &&
  );

-- Atribuição: taxa congelada em faixa válida.
ALTER TABLE "OrderAttribution"
  ADD CONSTRAINT "OrderAttribution_rateBps_range" CHECK ("rateBps" IS NULL OR "rateBps" BETWEEN 0 AND 10000);

-- Extrato: sinal coerente com o tipo, valor nunca zero, referências obrigatórias.
ALTER TABLE "LedgerEntry"
  ADD CONSTRAINT "LedgerEntry_amount_nonzero" CHECK ("amountCents" <> 0),
  ADD CONSTRAINT "LedgerEntry_sign_by_type" CHECK (
    ("type" = 'COMMISSION' AND "amountCents" > 0)
    OR ("type" = 'REVERSAL' AND "amountCents" < 0)
    OR ("type" = 'WITHDRAWAL' AND "amountCents" < 0)
    OR ("type" IN ('ADJUSTMENT', 'OPENING_BALANCE'))),
  ADD CONSTRAINT "LedgerEntry_order_required" CHECK (
    "type" NOT IN ('COMMISSION', 'REVERSAL') OR "orderId" IS NOT NULL),
  ADD CONSTRAINT "LedgerEntry_withdrawal_required" CHECK (
    "type" <> 'WITHDRAWAL' OR "withdrawalId" IS NOT NULL),
  ADD CONSTRAINT "LedgerEntry_rateBps_range" CHECK ("rateBps" IS NULL OR "rateBps" BETWEEN 0 AND 10000);

-- Saque: valor positivo e no máximo um saque em aberto por creator.
ALTER TABLE "Withdrawal"
  ADD CONSTRAINT "Withdrawal_amount_positive" CHECK ("amountCents" > 0),
  ADD CONSTRAINT "Withdrawal_decided_consistent" CHECK (
    ("status" = 'REQUESTED') = ("decidedAt" IS NULL));
CREATE UNIQUE INDEX "Withdrawal_one_open_per_creator"
  ON "Withdrawal" ("creatorId") WHERE "status" = 'REQUESTED';

-- Pedido: valores não negativos.
ALTER TABLE "Order"
  ADD CONSTRAINT "Order_amounts_nonneg" CHECK ("subtotalCents" >= 0 AND "totalCents" >= 0);

-- Extrato e auditoria só recebem inserções. Correção é um lançamento novo.
CREATE FUNCTION forbid_update_delete() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% é somente inserção: % não permitido', TG_TABLE_NAME, TG_OP
    USING ERRCODE = 'restrict_violation';
END;
$$;

CREATE TRIGGER "LedgerEntry_append_only"
  BEFORE UPDATE OR DELETE ON "LedgerEntry"
  FOR EACH ROW EXECUTE FUNCTION forbid_update_delete();

CREATE TRIGGER "AuditLog_append_only"
  BEFORE UPDATE OR DELETE ON "AuditLog"
  FOR EACH ROW EXECUTE FUNCTION forbid_update_delete();

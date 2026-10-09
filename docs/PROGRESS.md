# Progresso — Creator Club v2

> **Fonte da verdade do andamento.** Ler este arquivo inteiro no início de toda sessão.
> Atualizar ao fim de cada tarefa, no mesmo commit da tarefa.

## Onde estamos

- **Fase atual:** Lançamento 1 (creators já ativas da Botanika) → E1 Base do projeto
- **Próxima tarefa:** E1.2 — schema Prisma do núcleo (ver "Fila de tarefas")
- **Bloqueios:** contas Supabase e Vercel da empresa (só para E1.4 em diante)

## Fila de tarefas (uma por vez, nesta ordem)

Legenda: `[ ]` a fazer · `[~]` em andamento · `[x]` feito · `[!]` bloqueado

### E1 — Base do projeto
- [x] **E1.1** Esqueleto Next.js (App Router, TypeScript, Tailwind) junto do núcleo de domínio; `npm test`, `npm run typecheck` e `npm run build` passando.
- [ ] **E1.2** Schema Prisma do núcleo (Brand, BrandIntegration, User, RoleGrant, CreatorAccount, Creator, CommissionPolicy, Coupon, Order, OrderLine, OrderAttribution, LedgerEntry, Withdrawal, File, WebhookEvent, Job, SyncRun, AuditLog, Click) com migração inicial e restrições (únicos, FKs `Restrict`, índice parcial de saque aberto). Testes de integração contra Postgres local.
- [ ] **E1.3** CI no GitHub Actions: instalar, typecheck, testes (com Postgres de serviço), build.
- [!] **E1.4** Staging: projeto Supabase (sa-east-1) e Vercel (gru1) em contas da empresa; deploy automático da `main`. *Bloqueado: contas.*

### Depois de E1 (detalhar quando chegar lá)
E2 Login e papéis · E3 Sync Shopify · E4 Cupons e creators atuais · E5 Atribuição e extrato no banco ·
E6 Saldo de abertura e conferência · E7 Portal da creator · E8 Saques · E9 Corte.
Detalhe de cada uma no plano: https://claude.ai/code/artifact/903360ba-744d-409e-97e8-dc11dbe57f52

## Checkpoints (mais recente primeiro)

### CP-02 — 2026-10-09 — Esqueleto do app (E1.1)
- **Feito:** Next.js 16.3.8 + React 19.3.0 + Tailwind 4 junto do núcleo de domínio; layout em pt-BR,
  página "Em construção", `GET /api/health` (liveness), cabeçalhos de segurança, alias `@/` em app e testes.
- **Verificado:** 32 testes; `npm run typecheck` e `npm run build` passando a partir de clone limpo
  (sem `.next/`); app subiu com `next start`: `/api/health` 200 com JSON, `/` 200, `X-Frame-Options: DENY`,
  sem `X-Powered-By`.
- **Decisão técnica:** `next-env.d.ts` fora do Git; `typecheck` roda `next typegen` antes do `tsc`
  (sem isso o typecheck quebra em clone limpo, ex.: CI).

### CP-01 — 2026-10-09 — Núcleo de domínio
- **Feito:** regras de dinheiro em `src/domain` (centavos/bps, cupom novo só letras ≤8, taxa com vigência,
  atribuição first_creator_code_v1, comissão incremental idempotente por versão do pedido, saldo com
  retenção/reserva sem corte em zero, regras de saque 10–15 em São Paulo).
- **Verificado:** 31 testes passando; typecheck limpo.
- **Commit:** `d46660a`.
- **Pendências registradas:** D-HOLD usa 0 dias até decisão.

## Como retomar em um chat novo

Cole isto no início do chat:

> Projeto Creator Club v2, repositório `Botanika-HUb/botanika-creator-club`.
> Leia `CLAUDE.md`, `docs/PROGRESS.md` e `docs/DECISIONS.md` antes de qualquer coisa.
> Faça só a "Próxima tarefa" de `docs/PROGRESS.md`, uma por vez, e atualize o arquivo ao terminar.

# Creator Club v2

Plataforma de gestão de creators da Botanika: vendas atribuídas por cupom, extrato de comissão e saque.

## Estado

Esqueleto do app Next.js (`src/app`) e núcleo de domínio (`src/domain`) com as regras de dinheiro e testes.
Ainda sem banco, login ou integração com o Shopify: esses entram nas entregas E1.2–E3 do plano.
Andamento detalhado em [`docs/PROGRESS.md`](docs/PROGRESS.md).

| Módulo | O que faz |
| --- | --- |
| `money.ts` | Centavos, pontos-base, arredondamento meio centavo para cima, leitura de valores do Shopify |
| `coupon.ts` | Regra de cupom novo: só letras, até 8 |
| `policy.ts` | Taxa de comissão com vigência; recusa sobreposição |
| `attribution.ts` | Qual creator leva o pedido (primeiro cupom CREATOR; PROMO nunca) |
| `commission.ts` | Lançamento incremental e idempotente por versão do pedido |
| `ledger.ts` | Saldo: total, retido, reservado e disponível (pode ser negativo) |
| `withdrawal.ts` | Janela 10–15 em São Paulo, mínimo, saldo e saque em aberto |

## Rodar

```bash
npm install
npm test
npm run typecheck
npm run build
npm run dev   # http://localhost:3000 · saúde em /api/health
```

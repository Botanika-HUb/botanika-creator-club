# Decisões — Creator Club v2

> Registro curto do que já foi decidido e do que está em aberto.
> Decisão nova ou mudada = nova linha com data. Nunca apagar linha antiga; marcar como substituída.

## Decididas

| ID | Data | Decisão | Quem |
| --- | --- | --- | --- |
| D-SCOPE | 2026-10-09 | Lançamento 1 atende só creators **já ativas** da Botanika (portal, saldo correto, saque). Onboarding de novas vem no L2. | Pedro |
| D-SEP | 2026-10-09 | Sistema **separado** do AllianceOS; compartilha dados com ele depois, por eventos. | Pedro |
| D-CONTRACT | 2026-10-09 | Até o Autentique entrar, contrato marcado à mão na pipeline com o **PDF assinado anexado**. | Pedro |
| D-STACK | 2026-10-09 | Next.js + TypeScript + Prisma + Postgres (Supabase Pro, sa-east-1) + Vercel (gru1). Repositório próprio. | Pedro |
| D-MONEY | 2026-10-08 | Centavos inteiros e pontos-base; extrato só de inserções; nada é apagado. | Plano |
| D-ATTR | 2026-10-08 | Primeiro cupom CREATOR da lista do pedido leva tudo; PROMO nunca atribui; atribuição gravada uma vez. | Plano |
| D-RATECHG | 2026-10-08 | Mudança de taxa vale só para pedidos pagos depois dela. | Plano |
| D-AUTH | 2026-10-08 | Login por convite (Supabase Auth); sem "reivindicar cupom"; "entrar como" fora do escopo. | Plano |
| D-ORDERS | 2026-10-09 | Guardar **todos** os pedidos (poucos campos), não só os com cupom. | Plano |
| D-QUEUE | 2026-10-09 | Webhook grava evento + tarefa no Postgres na mesma transação antes de responder; worker processa. | Plano |

## Em aberto (usar a proposta até haver resposta; marcar no código `// DECISÃO-ABERTA: <id>`)

| ID | Pergunta | Proposta em uso | Precisa antes de |
| --- | --- | --- | --- |
| D-HOLD | Dias de retenção da comissão | 0 dias | E5 |
| D-NEG | Estorno depois de saque pago | Saldo negativo abate do próximo | E5 |
| D-MONTH | Comissão conta pela data do pedido ou do pagamento | Data do pagamento | E5 |
| D-OPEN | Saldo inicial: reconstrução ou abertura | Abertura aprovada pelo Pagamento | E6 |
| D-HIST | Desde quando importar pedidos | Desde o primeiro cupom de creator | E3 |
| D-TAX | Loja usa preço com imposto incluso (`taxesIncluded`)? | Verificar num pedido real | E3 |
| D-RATE | Comissão padrão por marca (15% ou 10%) | 15% na Botanika | E4 |
| D-CLASS | Quem classifica cupons CREATOR/PROMO e confirma a dona | Ana | E4 |
| D-PAY | Quem tem papel Pagamento | Juci e Pâmela | E2 |
| D-NF | Código de serviço e descrição da NF | — | E8 |
| D-MIN | R$ 500 é mínimo por solicitação | Sim, por solicitação | E8 |
| D-ACCT | Donos das contas Supabase/Vercel | Contas da empresa, Pedro dono | E1.4 |

# Creator Club v2 — regras do projeto

Plataforma própria de gestão de creators da Botanika (multi-marca; só Botanika ligada no início).
Sistema separado do AllianceOS; depois compartilha dados com ele por eventos.
Plano vivo: https://claude.ai/code/artifact/903360ba-744d-409e-97e8-dc11dbe57f52

## Escopo atual (lançamento 1)

Creators **já ativas** da Botanika: portal com vendas, saldo correto, extrato, cupom, link e saque.
Onboarding de novas creators, Hunter, UGC, alertas e Autentique vêm depois.

## Regras de dinheiro (não negociáveis)

- Valores em **centavos inteiros**; taxas em **pontos-base** (1500 = 15%). Nunca `Float`.
- Saldo = soma do extrato (`LedgerEntry`). O extrato só recebe inserções; correção é novo lançamento.
- Nada é apagado: creator e cupom ganham status; FKs financeiras com `Restrict`.
- Atribuição: primeiro código CREATOR da lista do pedido leva o pedido; PROMO nunca atribui.
  Decidida uma vez e gravada com a lista de códigos como evidência.
- Taxa: a vigente no **pagamento** do pedido (`CommissionPolicy`), congelada na atribuição.
- Comissão incremental: `devido − lançado`; chave de idempotência inclui a versão do pedido.
- Base: subtotal atual dos produtos (`currentSubtotalPriceSet`), só pedidos `PAID`/`PARTIALLY_REFUNDED`,
  não cancelados, não teste. Conferir `taxesIncluded` da loja antes de fechar a regra.
- Saldo pode ficar negativo; nunca cortar em zero.
- Datas em UTC; "dia"/"mês"/janela de saque em `America/Sao_Paulo`.

## Arquitetura

- Nenhuma tela consulta o Shopify. Shopify só por webhook, reconciliação, carga histórica e ações de cupom.
- Webhook: valida HMAC, grava evento + tarefa na fila do Postgres na mesma transação, depois responde 200.
  Nada roda "depois da resposta".
- Todo cupom gravado no Shopify (criar ou editar) leva `combinesWith` com order/product/shipping = true.
- Login por convite; não existe "reivindicar cupom". "Entrar como" fora do escopo.

## Decisões em aberto (marcar no código com `// DECISÃO-ABERTA: <id>`)

- D-HOLD dias de retenção da comissão — padrão 0 até decidir.
- D-NEG estorno depois de saque pago — proposta: saldo negativo abate do próximo.
- D-MONTH mês da venda — proposta: data do pagamento.
- D-OPEN saldo de abertura vs. reconstrução — proposta: abertura aprovada pelo Pagamento.

## Comandos

- `npm test` — testes (Vitest)
- `npm run typecheck` — checagem de tipos

## Convenções

UI e textos em português do Brasil; código e nomes de tabelas em inglês.
Mudanças pequenas, cada uma com teste.

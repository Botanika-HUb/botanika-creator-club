import { describe, expect, it } from "vitest";
import { InMemoryPipeline, T, assignments, order, policies } from "./helpers";

const pipeline = () => new InMemoryPipeline(assignments, policies);

describe("crédito de comissão", () => {
  it("pedido pago de R$ 200,00 a 15% gera +R$ 30,00", () => {
    const p = pipeline();
    const entry = p.process(order({ id: "o1" }));
    expect(entry).toMatchObject({ type: "COMMISSION", amountCents: 3_000, baseCents: 20_000, rateBps: 1500 });
    expect(p.balanceOf("ana")).toBe(3_000);
  });

  it("reprocessar a mesma versão não duplica", () => {
    const p = pipeline();
    const o = order({ id: "o1" });
    p.process(o);
    expect(p.process(o)).toBeNull();
    expect(p.ledger).toHaveLength(1);
  });

  it("Pix pendente não gera crédito; quando paga, gera uma vez", () => {
    const p = pipeline();
    const pending = order({ id: "o2", financialStatus: "PENDING", paidAt: null, version: T("2026-09-01T12:00:00Z") });
    expect(p.process(pending)).toBeNull();
    const paid = order({ id: "o2", paidAt: T("2026-09-01T12:10:00Z"), version: T("2026-09-01T12:10:00Z") });
    expect(p.process(paid)?.amountCents).toBe(3_000);
    expect(p.balanceOf("ana")).toBe(3_000);
  });

  it("Pix expirado nunca gera crédito", () => {
    const p = pipeline();
    expect(p.process(order({ id: "o3", financialStatus: "EXPIRED", paidAt: null }))).toBeNull();
    expect(p.process(order({ id: "o3b", financialStatus: "VOIDED", paidAt: null }))).toBeNull();
    expect(p.ledger).toHaveLength(0);
  });

  it("pedido de teste não gera crédito", () => {
    const p = pipeline();
    expect(p.process(order({ id: "o4", test: true }))).toBeNull();
  });
});

describe("estornos e ajustes", () => {
  it("reembolso parcial gera só a diferença; estorno total zera o pedido", () => {
    const p = pipeline();
    p.process(order({ id: "o5" }));
    const partial = p.process(
      order({ id: "o5", financialStatus: "PARTIALLY_REFUNDED", subtotalCents: 15_000, version: T("2026-09-03T10:00:00Z") }),
    );
    expect(partial).toMatchObject({ type: "REVERSAL", amountCents: -750 });
    const full = p.process(
      order({ id: "o5", financialStatus: "REFUNDED", subtotalCents: 0, version: T("2026-09-05T10:00:00Z") }),
    );
    expect(full).toMatchObject({ type: "REVERSAL", amountCents: -2_250 });
    expect(p.balanceOf("ana")).toBe(0);
  });

  it("cancelamento depois de pago estorna o crédito", () => {
    const p = pipeline();
    p.process(order({ id: "o6" }));
    const cancelled = p.process(
      order({ id: "o6", cancelledAt: T("2026-09-02T09:00:00Z"), version: T("2026-09-02T09:00:00Z") }),
    );
    expect(cancelled?.amountCents).toBe(-3_000);
    expect(p.balanceOf("ana")).toBe(0);
  });

  it("webhook atrasado de uma versão já processada não mexe no saldo", () => {
    const p = pipeline();
    const v1 = order({ id: "o7" });
    const v2 = order({ id: "o7", financialStatus: "PARTIALLY_REFUNDED", subtotalCents: 10_000, version: T("2026-09-04T10:00:00Z") });
    p.process(v1);
    p.process(v2);
    // O worker só aplica versões mais novas; mesmo que a antiga chegasse aqui,
    // a chave da versão 1 já existe e nada é lançado de novo.
    expect(p.process(v1)).toBeNull();
    expect(p.balanceOf("ana")).toBe(1_500);
  });
});

describe("atribuição", () => {
  it("dois cupons de creator: só a primeira da lista recebe", () => {
    const p = pipeline();
    p.process(order({ id: "o8", discountCodes: ["bia", "ANA"], subtotalCents: 100_000 }));
    expect(p.balanceOf("bia")).toBe(10_000);
    expect(p.balanceOf("ana")).toBe(0);
  });

  it("cupom PROMO antes do cupom da creator não rouba o pedido", () => {
    const p = pipeline();
    p.process(order({ id: "o9", discountCodes: ["BOTANIKA", "ANA"] }));
    expect(p.attributions.get("o9")?.creatorId).toBe("ana");
    expect(p.attributions.get("o9")?.evidenceCodes).toEqual(["BOTANIKA", "ANA"]);
  });

  it("pedido só com cupom PROMO não é de ninguém", () => {
    const p = pipeline();
    expect(p.process(order({ id: "o10", discountCodes: ["BOTANIKA"] }))).toBeNull();
    expect(p.attributions.has("o10")).toBe(false);
  });

  it("atribuição não muda se o pedido for editado depois", () => {
    const p = pipeline();
    p.process(order({ id: "o11", discountCodes: ["ANA"] }));
    p.process(order({ id: "o11", discountCodes: ["BIA"], version: T("2026-09-02T10:00:00Z") }));
    expect(p.attributions.get("o11")?.creatorId).toBe("ana");
  });
});

describe("taxa com vigência", () => {
  it("usa a taxa vigente no pagamento, não a atual", () => {
    const p = pipeline();
    // Bia: 10% até 15/09 (00h em São Paulo), 15% depois.
    p.process(order({ id: "o12", discountCodes: ["BIA"], paidAt: T("2026-09-14T20:00:00Z"), version: T("2026-09-14T20:00:00Z") }));
    p.process(order({ id: "o13", discountCodes: ["BIA"], paidAt: T("2026-09-16T12:00:00Z"), version: T("2026-09-16T12:00:00Z") }));
    expect(p.ledger.map((e) => e.amountCents)).toEqual([2_000, 3_000]);
  });

  it("reembolso depois da troca de taxa usa a taxa congelada do pedido", () => {
    const p = pipeline();
    p.process(order({ id: "o14", discountCodes: ["BIA"], paidAt: T("2026-09-10T12:00:00Z"), version: T("2026-09-10T12:00:00Z") }));
    const refund = p.process(
      order({ id: "o14", discountCodes: ["BIA"], financialStatus: "PARTIALLY_REFUNDED", subtotalCents: 10_000, paidAt: T("2026-09-10T12:00:00Z"), version: T("2026-09-20T12:00:00Z") }),
    );
    expect(refund).toMatchObject({ amountCents: -1_000, rateBps: 1000 });
  });

  it("sem taxa cadastrada para a data, falha em vez de chutar", () => {
    const p = pipeline();
    expect(() =>
      p.process(order({ id: "o15", createdAt: T("2026-09-01T00:00:00Z"), paidAt: T("2025-12-31T12:00:00Z") })),
    ).toThrow(/sem taxa de comissão vigente/);
  });
});

describe("retenção", () => {
  it("crédito fica disponível só depois dos dias de retenção; débito vale na hora", () => {
    const p = new InMemoryPipeline(assignments, policies, 7);
    const credit = p.process(order({ id: "o16" }));
    expect(credit?.availableAt.toISOString()).toBe("2026-09-08T12:00:00.000Z");
    const refund = p.process(
      order({ id: "o16", financialStatus: "REFUNDED", subtotalCents: 0, version: T("2026-09-02T12:00:00Z") }),
      T("2026-09-02T12:00:05Z"),
    );
    expect(refund?.availableAt.toISOString()).toBe("2026-09-02T12:00:05.000Z");
  });
});

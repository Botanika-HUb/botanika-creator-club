import { normalizeCouponCode, type CouponKind } from "./coupon";

/**
 * Atribuição de pedido a uma creator.
 *
 * Regra first_creator_code_v1:
 *  1. Ler os códigos de desconto do pedido, na ordem devolvida pelo Shopify.
 *  2. Manter só os que eram cupom CREATOR da marca na data do pedido.
 *     Cupom PROMO (ex.: BOTANIKA) nunca atribui.
 *  3. O primeiro que sobrar leva o pedido inteiro.
 *
 * A ordem devolvida pelo Shopify é uma convenção, não prova de qual cupom foi
 * aplicado primeiro; por isso a lista usada fica gravada como evidência.
 * A atribuição é decidida uma vez e gravada: trocar cupom ou status da creator
 * depois não move pedidos antigos.
 */

export const ATTRIBUTION_RULE = "first_creator_code_v1";

export type CouponAssignment = {
  couponId: string;
  brandId: string;
  code: string;
  kind: CouponKind;
  /** Dona do cupom; obrigatória para CREATOR, nula para PROMO. */
  creatorId: string | null;
  validFrom: Date;
  validTo: Date | null;
};

export type AttributionInput = {
  brandId: string;
  discountCodes: readonly string[];
  orderCreatedAt: Date;
};

export type Attribution = {
  couponId: string;
  creatorId: string;
  code: string;
  rule: typeof ATTRIBUTION_RULE;
  /** Códigos do pedido no momento da decisão (evidência). */
  evidenceCodes: string[];
};

function isValidAt(a: CouponAssignment, at: Date): boolean {
  return a.validFrom <= at && (a.validTo === null || at < a.validTo);
}

export function attributeOrder(
  order: AttributionInput,
  assignments: readonly CouponAssignment[],
): Attribution | null {
  const evidenceCodes = order.discountCodes.map(normalizeCouponCode);

  for (const code of evidenceCodes) {
    const assignment = assignments.find(
      (a) =>
        a.brandId === order.brandId &&
        normalizeCouponCode(a.code) === code &&
        isValidAt(a, order.orderCreatedAt),
    );
    if (!assignment || assignment.kind !== "CREATOR") continue;
    if (!assignment.creatorId) {
      throw new Error(`cupom CREATOR ${assignment.code} sem dona definida`);
    }
    return {
      couponId: assignment.couponId,
      creatorId: assignment.creatorId,
      code,
      rule: ATTRIBUTION_RULE,
      evidenceCodes,
    };
  }
  return null;
}

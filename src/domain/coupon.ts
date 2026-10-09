/**
 * Regras de código de cupom.
 * Cupom novo: só letras A–Z, de 1 a 8 caracteres, sem números.
 * Cupons legados (importados da loja) não passam por esta validação.
 */

export const NEW_COUPON_MAX_LENGTH = 8;

export type CouponKind = "CREATOR" | "PROMO";

/** Forma canônica para comparar códigos: maiúsculas, sem espaços nas pontas. */
export function normalizeCouponCode(code: string): string {
  return code.trim().toUpperCase();
}

export type CouponCodeError = "VAZIO" | "LONGO_DEMAIS" | "CARACTERE_INVALIDO";

/**
 * Valida o código que a creator escolhe para um cupom novo. Acentos são
 * removidos ("JOÃO" vira "JOAO"); qualquer outro caractere fora de A–Z é erro.
 */
export function validateNewCouponCode(
  input: string,
): { ok: true; code: string } | { ok: false; error: CouponCodeError } {
  const code = normalizeCouponCode(input.normalize("NFD").replace(/[̀-ͯ]/g, ""));
  if (code.length === 0) return { ok: false, error: "VAZIO" };
  if (!/^[A-Z]+$/.test(code)) return { ok: false, error: "CARACTERE_INVALIDO" };
  if (code.length > NEW_COUPON_MAX_LENGTH) return { ok: false, error: "LONGO_DEMAIS" };
  return { ok: true, code };
}

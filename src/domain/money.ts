/**
 * Dinheiro sempre em centavos inteiros (BRL) e taxas em pontos-base (1500 = 15%).
 * Nunca usar Float para valores financeiros.
 */

export type Cents = number;
export type Bps = number;

export const BPS_DENOMINATOR = 10_000;

export function assertCents(value: number, label = "valor"): asserts value is Cents {
  if (!Number.isSafeInteger(value)) {
    throw new RangeError(`${label} precisa ser um inteiro em centavos: ${value}`);
  }
}

export function assertBps(value: number, label = "taxa"): asserts value is Bps {
  if (!Number.isInteger(value) || value < 0 || value > BPS_DENOMINATOR) {
    throw new RangeError(`${label} precisa estar entre 0 e 10000 pontos-base: ${value}`);
  }
}

/**
 * Aplica uma taxa a uma base, arredondando meio centavo para cima.
 * Só aceita base >= 0: comissão negativa nasce de ajuste, nunca de base negativa.
 */
export function applyRate(baseCents: Cents, rateBps: Bps): Cents {
  assertCents(baseCents, "base");
  assertBps(rateBps);
  if (baseCents < 0) throw new RangeError(`base não pode ser negativa: ${baseCents}`);
  const product = BigInt(baseCents) * BigInt(rateBps);
  const denominator = BigInt(BPS_DENOMINATOR);
  const rounded = (product * 2n + denominator) / (denominator * 2n);
  return Number(rounded);
}

/** Converte "123.45" (formato do Shopify) para centavos sem passar por Float. */
export function parseDecimalToCents(amount: string): Cents {
  // Aceita casas extras só se forem zeros ("12.300"); nunca trunca centavos.
  const match = /^(-)?(\d+)(?:\.(\d{1,2})0*)?$/.exec(amount.trim());
  if (!match) throw new RangeError(`valor monetário inválido: "${amount}"`);
  const [, sign, units, fraction = ""] = match;
  const cents = Number(units) * 100 + Number(fraction.padEnd(2, "0"));
  const result = sign ? -cents : cents;
  assertCents(result);
  return result;
}

export function formatBRL(cents: Cents): string {
  return new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(cents / 100);
}

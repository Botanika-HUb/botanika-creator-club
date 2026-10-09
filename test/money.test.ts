import { describe, expect, it } from "vitest";
import { applyRate, parseDecimalToCents } from "../src/domain";

describe("applyRate", () => {
  it("calcula 15% de R$ 200,00", () => {
    expect(applyRate(20_000, 1500)).toBe(3_000);
  });

  it("arredonda meio centavo para cima", () => {
    // 0,05 × 10% = 0,005 → 0,01
    expect(applyRate(5, 1000)).toBe(1);
    // 0,04 × 10% = 0,004 → 0,00
    expect(applyRate(4, 1000)).toBe(0);
    // 333,33 × 15% = 49,9995 → 50,00
    expect(applyRate(33_333, 1500)).toBe(5_000);
  });

  it("recusa base negativa, fracionária ou taxa fora de 0–100%", () => {
    expect(() => applyRate(-1, 1500)).toThrow();
    expect(() => applyRate(10.5, 1500)).toThrow();
    expect(() => applyRate(100, 10_001)).toThrow();
  });
});

describe("parseDecimalToCents", () => {
  it("converte valores do Shopify sem Float", () => {
    expect(parseDecimalToCents("123.45")).toBe(12_345);
    expect(parseDecimalToCents("0.1")).toBe(10);
    expect(parseDecimalToCents("10")).toBe(1_000);
    expect(parseDecimalToCents("12.300")).toBe(1_230);
    expect(parseDecimalToCents("-5.00")).toBe(-500);
  });

  it("recusa valores que perderiam centavos", () => {
    expect(() => parseDecimalToCents("1.234")).toThrow();
    expect(() => parseDecimalToCents("abc")).toThrow();
    expect(() => parseDecimalToCents("1,23")).toThrow();
  });
});

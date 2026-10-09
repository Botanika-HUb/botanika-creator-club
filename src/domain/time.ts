/**
 * Datas são gravadas em UTC; tudo que é "dia" ou "mês" de negócio é calculado
 * no fuso da marca (padrão America/Sao_Paulo).
 */

export const DEFAULT_TIMEZONE = "America/Sao_Paulo";

export type LocalDate = { year: number; month: number; day: number };

export function localDate(at: Date, timeZone: string = DEFAULT_TIMEZONE): LocalDate {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(at);
  const get = (type: string) => Number(parts.find((p) => p.type === type)?.value);
  return { year: get("year"), month: get("month"), day: get("day") };
}

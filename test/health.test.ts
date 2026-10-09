import { describe, expect, it } from "vitest";
import { GET } from "@/app/api/health/route";

describe("GET /api/health", () => {
  it("responde ok em JSON", async () => {
    const res = GET();
    expect(res.status).toBe(200);
    const body = (await res.json()) as { ok: boolean; app: string; time: string };
    expect(body.ok).toBe(true);
    expect(body.app).toBe("creator-club");
    expect(Number.isNaN(Date.parse(body.time))).toBe(false);
  });
});

// Liveness: só confirma que o app responde. A checagem de banco, fila e
// sincronização (readiness) entra quando essas peças existirem (E1.2 / E3).
export const dynamic = "force-dynamic";

export function GET(): Response {
  return Response.json({ ok: true, app: "creator-club", time: new Date().toISOString() });
}

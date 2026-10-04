// Respostas HTTP padronizadas das Edge Functions do BookNest (JSON, sem cache).

export type CorpoErro = { erro: string; mensagem?: string };

export function json(status: number, corpo: unknown): Response {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' },
  });
}

export function erro(status: number, codigo: string, mensagem?: string): Response {
  const corpo: CorpoErro = mensagem ? { erro: codigo, mensagem } : { erro: codigo };
  return json(status, corpo);
}

/** Recusa métodos diferentes do esperado (405) — devolve null quando o método é aceito. */
export function exigeMetodo(req: Request, ...metodos: string[]): Response | null {
  return metodos.includes(req.method) ? null : erro(405, 'metodo_nao_permitido');
}

/** Lê o corpo JSON (objeto). Corpo vazio vira {}; corpo inválido → null. */
export async function lerJson(req: Request): Promise<Record<string, unknown> | null> {
  const texto = await req.text();
  if (texto.trim() === '') return {};
  try {
    const v = JSON.parse(texto);
    return v !== null && typeof v === 'object' && !Array.isArray(v) ? v as Record<string, unknown> : null;
  } catch {
    return null;
  }
}

/** Erro de regra vindo do banco (raise exception '<codigo>' using errcode = 'P0001' / '22023'). */
export function codigoDoBanco(e: unknown): string | null {
  const err = e as { code?: string; message?: string } | null;
  if (!err || (err.code !== 'P0001' && err.code !== '22023' && err.code !== '28000')) return null;
  return err.message ?? null;
}

export const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

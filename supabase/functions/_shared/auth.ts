// Autorização das Edge Functions (config.toml: verify_jwt = true só nas funções do usuário).
//  * usuário: JWT do Supabase Auth no cabeçalho Authorization (Bearer) — conferido de novo aqui
//    (assinatura pelo Auth) e o `sub` vira o id do usuário;
//  * agendador (pg_cron + pg_net): chave secreta no cabeçalho `apikey`;
//  * webhook do RevenueCat: segredo próprio no cabeçalho Authorization.

/** Compara dois textos em tempo constante (não vaza, pelo tempo, quantos caracteres batem). */
export function iguaisEmTempoConstante(a: string, b: string): boolean {
  const ea = new TextEncoder().encode(a);
  const eb = new TextEncoder().encode(b);
  let dif = ea.length ^ eb.length;
  for (let i = 0; i < Math.max(ea.length, eb.length); i++) dif |= (ea[i] ?? 0) ^ (eb[i] ?? 0);
  return dif === 0;
}

export function tokenBearer(req: Request): string | null {
  const h = req.headers.get('Authorization') ?? '';
  const m = /^Bearer\s+(\S+)$/i.exec(h);
  return m ? m[1] : null;
}

/** Confere o JWT do usuário. `verificar` devolve o `sub` (id do usuário) ou null se inválido. */
export async function usuarioDoPedido(
  req: Request,
  verificar: (jwt: string) => Promise<string | null>,
): Promise<string | null> {
  const jwt = tokenBearer(req);
  if (!jwt) return null;
  try {
    return await verificar(jwt);
  } catch {
    return null;
  }
}

/** A chave do cabeçalho `apikey` é uma das chaves aceitas (agendador)? */
export function chaveDoAgendadorValida(req: Request, aceitas: readonly string[]): boolean {
  const recebida = req.headers.get('apikey') ?? '';
  if (recebida === '') return false;
  let ok = false;
  for (const c of aceitas) if (c && iguaisEmTempoConstante(recebida, c)) ok = true;
  return ok;
}

/** O cabeçalho Authorization é exatamente o segredo configurado (webhook do RevenueCat)? */
export function segredoValido(req: Request, segredo: string | undefined): boolean {
  if (!segredo) return false;
  return iguaisEmTempoConstante(req.headers.get('Authorization') ?? '', segredo);
}

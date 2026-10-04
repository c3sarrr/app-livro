// Variáveis de ambiente das Edge Functions. No Supabase hospedado: SUPABASE_URL, SUPABASE_DB_URL,
// SUPABASE_SECRET_KEYS (JSON com as chaves secretas por nome) e SUPABASE_JWKS; no local (CLI):
// SUPABASE_SECRET_KEY (uma chave só). Segredos próprios do BookNest: supabase/functions/.env.example.

export function exigir(nome: string): string {
  const v = Deno.env.get(nome);
  if (!v) throw new Error(`variável de ambiente ausente: ${nome}`);
  return v;
}

/** Chaves secretas do projeto. Com nome: só a chave com esse nome (ex.: "agendador"). */
export function chavesSecretas(nome?: string): string[] {
  const json = Deno.env.get('SUPABASE_SECRET_KEYS');
  if (json) {
    try {
      const mapa = JSON.parse(json) as Record<string, string>;
      if (nome) return mapa[nome] ? [mapa[nome]] : [];
      return Object.values(mapa).filter((v) => typeof v === 'string' && v !== '');
    } catch {
      return [];
    }
  }
  const unica = Deno.env.get('SUPABASE_SECRET_KEY') ?? Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  return unica ? [unica] : [];
}

/**
 * Chaves aceitas do agendador (pg_cron + pg_net). Qualquer chave secreta do projeto serve — quem tem
 * uma já tem acesso total ao projeto, então restringir a uma chave nomeada não protege mais nada.
 * No local, o gateway entrega a chave legada (service_role) no lugar da `sb_secret_…`.
 */
export function chavesDoAgendador(): string[] {
  const legadas = ['SUPABASE_SECRET_KEY', 'SUPABASE_INTERNAL_SECRET_KEY', 'SUPABASE_SERVICE_ROLE_KEY']
    .map((n) => Deno.env.get(n)).filter((v): v is string => !!v);
  return [...new Set([...chavesSecretas(), ...legadas])];
}

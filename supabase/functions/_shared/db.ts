// Conexão direta ao Postgres (SUPABASE_DB_URL) — as funções de banco das Edge Functions ficam em
// `private` (migration funcoes_de_servico), fora da API. `prepare: false` para funcionar atrás do
// pooler em modo transação; poucas conexões por instância.
import postgres from 'npm:postgres@3.4.9';

export type Sql = ReturnType<typeof postgres>;

let conexao: Sql | null = null;

export function sql(): Sql {
  if (!conexao) {
    // BOOKNEST_DB_URL só no local: o nome do contêiner do banco (supabase_db_booknest) tem "_" e o
    // resolvedor do Deno não o aceita — functions/.env aponta para host.docker.internal:54322.
    const url = Deno.env.get('BOOKNEST_DB_URL') ?? Deno.env.get('SUPABASE_DB_URL');
    if (!url) throw new Error('variável de ambiente ausente: SUPABASE_DB_URL');
    conexao = postgres(url, { prepare: false, max: 2, idle_timeout: 20, connect_timeout: 10 });
  }
  return conexao;
}

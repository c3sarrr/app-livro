// Cliente administrativo (Auth admin e Storage) e verificação do JWT do usuário.
import { createClient, type SupabaseClient } from 'npm:@supabase/supabase-js@2.117.2';
import { chavesSecretas, exigir } from './env.ts';

let admin: SupabaseClient | null = null;

export function clienteAdmin(): SupabaseClient {
  if (!admin) {
    const chave = chavesSecretas()[0];
    if (!chave) throw new Error('sem chave secreta do projeto');
    admin = createClient(exigir('SUPABASE_URL'), chave, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
  }
  return admin;
}

/** Verifica o JWT do usuário no Auth e devolve o id (sub) — null se inválido/expirado. */
export async function verificarJwt(jwt: string): Promise<string | null> {
  const { data, error } = await clienteAdmin().auth.getClaims(jwt);
  if (error || !data?.claims?.sub) return null;
  return String(data.claims.sub);
}

/**
 * Como [verificarJwt], mas pergunta ao Auth (`/user`): recusa também a sessão já encerrada (logout,
 * "sair de todos") e o usuário que não existe mais. Para ações destrutivas (excluir a conta).
 */
export async function verificarSessao(jwt: string): Promise<string | null> {
  const { data, error } = await clienteAdmin().auth.getUser(jwt);
  if (error || !data?.user?.id) return null;
  return data.user.id;
}

/** Cliente com o JWT do próprio usuário (a RLS e auth.uid() valem como no app). */
export function clienteDoUsuario(jwt: string): SupabaseClient {
  const publicas = Deno.env.get('SUPABASE_PUBLISHABLE_KEYS');
  let chave = Deno.env.get('SUPABASE_PUBLISHABLE_KEY') ?? Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  if (publicas) {
    try {
      chave = Object.values(JSON.parse(publicas) as Record<string, string>)[0] ?? chave;
    } catch { /* mantém a chave única */ }
  }
  if (!chave) throw new Error('sem chave pública do projeto');
  return createClient(exigir('SUPABASE_URL'), chave, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { headers: { Authorization: `Bearer ${jwt}` } },
  });
}

/** Lista (recursivamente) os arquivos de uma pasta do Storage. */
export async function listarArquivos(bucket: string, pasta: string): Promise<string[]> {
  const st = clienteAdmin().storage.from(bucket);
  const saida: string[] = [];
  const pendentes = [pasta.replace(/\/$/, '')];
  while (pendentes.length > 0) {
    const atual = pendentes.pop()!;
    for (let offset = 0;; offset += 1000) {
      const { data, error } = await st.list(atual, { limit: 1000, offset });
      if (error) throw error;
      for (const item of data ?? []) {
        const caminho = `${atual}/${item.name}`;
        if (item.id === null) pendentes.push(caminho); // pasta
        else saida.push(caminho);
      }
      if ((data ?? []).length < 1000) break;
    }
  }
  return saida;
}

/** Apaga todos os arquivos de uma pasta do Storage (pela API — o SQL é bloqueado). */
export async function apagarPasta(bucket: string, pasta: string): Promise<number> {
  const arquivos = await listarArquivos(bucket, pasta);
  for (let i = 0; i < arquivos.length; i += 500) {
    const { error } = await clienteAdmin().storage.from(bucket).remove(arquivos.slice(i, i + 500));
    if (error) throw error;
  }
  return arquivos.length;
}

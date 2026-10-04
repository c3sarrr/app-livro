import { exigir } from '../_shared/env.ts';
import { apagarPasta, clienteAdmin, verificarSessao } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';

Deno.serve(criarHandler({
  // sessão conferida no Auth (um token de sessão já encerrada não exclui a conta)
  verificarJwt: verificarSessao,
  // página web de pedido de exclusão (G05; hospedagem na Q9) — ex.: https://booknest.app.br
  origemWeb: Deno.env.get('EXCLUSAO_WEB_ORIGEM') ?? null,
  async apagarAssinante(userId) {
    const chave = Deno.env.get('REVENUECAT_API_KEY');
    if (!chave) return; // ambiente sem RevenueCat (local)
    const r = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${chave}` },
      signal: AbortSignal.timeout(5000),
    });
    if (!r.ok && r.status !== 404) throw new Error(`RevenueCat respondeu ${r.status}`);
  },
  apagarEbooks: (userId) => apagarPasta('ebooks', userId),
  async apagarUsuario(userId) {
    exigir('SUPABASE_URL');
    const { error } = await clienteAdmin().auth.admin.deleteUser(userId);
    if (error) throw error;
  },
}));

import { exigir } from '../_shared/env.ts';
import { apagarPasta, clienteAdmin, verificarJwt } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';

Deno.serve(criarHandler({
  verificarJwt,
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

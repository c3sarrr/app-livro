// "Conferir agora" (D-229): o JWT da pessoa → a API REST do RevenueCat → o mesmo SQL do webhook.
import { sql } from '../_shared/db.ts';
import { exigir } from '../_shared/env.ts';
import { verificarJwt } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';

Deno.serve(criarHandler({
  verificarJwt,
  async cota(userId) {
    const [r] = await sql()`select private.consume_quota(${userId}, 'pro_sync', 30) as ok`;
    return r.ok === true;
  },
  async assinante(appUserId) {
    const resp = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`, {
      headers: { Authorization: `Bearer ${exigir('REVENUECAT_API_KEY')}`, Accept: 'application/json' },
      signal: AbortSignal.timeout(5000),
    });
    if (!resp.ok) throw new Error(`RevenueCat respondeu ${resp.status}`);
    return (await resp.json()).subscriber ?? null;
  },
  async aplicar(userId, assinaturas, buscadoEm) {
    // o retorno é o public.entitlement_of: {pro, active_until} (com stale: true se o estado buscado era velho)
    const [r] = await sql()`select private.rc_apply_subscriber(${userId}, ${
      sql().json(assinaturas as never)
    }, now(), ${buscadoEm}) as estado`;
    return { pro: r.estado?.pro === true, active_until: r.estado?.active_until ?? null };
  },
}));

import { sql } from '../_shared/db.ts';
import { exigir } from '../_shared/env.ts';
import { criarHandler } from './handler.ts';

const handler = criarHandler({
  segredo: Deno.env.get('REVENUECAT_WEBHOOK_AUTH'),
  async inicioDoEvento(evento) {
    const [r] = await sql()`select private.rc_begin_event(${sql().json(evento as never)}) as estado`;
    return r.estado;
  },
  async fimDoEvento(id, erroTexto) {
    await sql()`select private.rc_finish_event(${id}, ${erroTexto ?? null})`;
  },
  async assinante(appUserId) {
    const resp = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`, {
      headers: { Authorization: `Bearer ${exigir('REVENUECAT_API_KEY')}`, Accept: 'application/json' },
      signal: AbortSignal.timeout(5000),
    });
    if (!resp.ok) throw new Error(`RevenueCat respondeu ${resp.status}`);
    return (await resp.json()).subscriber ?? null;
  },
  async aplicar(userId, assinaturas, quando, buscadoEm) {
    const [r] = await sql()`select private.rc_apply_subscriber(${userId}, ${
      sql().json(assinaturas as never)
    }, ${quando}, ${buscadoEm}) as estado`;
    return r.estado;
  },
});

Deno.serve(handler);

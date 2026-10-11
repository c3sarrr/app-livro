// G02 · S5 — Edge Function `revenuecat-webhook` (Anexo 04 §5). Deno/TypeScript, roda no Supabase.
//
//   1. Authorization = segredo configurado no RevenueCat (comparação em tempo constante) — senão 401.
//   2. Idempotência por event.id em billing.webhook_events: já processado → 200; falhou antes → reprocessa.
//   3. Não confia na ordem: busca o estado ATUAL do assinante na API REST do RevenueCat e reconcilia.
//   4. upsert billing.subscriptions (loja + transação original) e billing.entitlements (active_until com a
//      carência; sandbox libera mas fica marcado — D-48).
//   5. private.refresh_sync_access() (concede/revoga o bucket do PowerSync; revogação 7 dias depois).
//   6. processed_at; erro → grava `error` e responde 500 (o RevenueCat reenvia).
// Variáveis: REVENUECAT_WEBHOOK_AUTH, REVENUECAT_API_KEY, REVENUECAT_API_BASE (padrão api.revenuecat.com),
// SUPABASE_DB_URL, CONTAS_TESTE (ids separados por vírgula, para o alerta de sandbox em conta real).
import postgres from 'postgres';
import { type AssinanteRC, type EventoRC, LojaNaoSuportada, reconciliar } from './reconciliar.ts';

export interface Dependencias {
  sql: postgres.Sql;
  segredo: string;
  rcBase: string;
  rcChave: string;
  contasTeste: Set<string>;
  agora?: () => Date;
  alerta?: (msg: string, dados: Record<string, unknown>) => void;
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const resposta = (status: number, corpo: unknown) =>
  new Response(JSON.stringify(corpo), { status, headers: { 'content-type': 'application/json' } });

function iguais(a: string, b: string) {
  const ea = new TextEncoder().encode(a);
  const eb = new TextEncoder().encode(b);
  let dif = ea.length ^ eb.length;
  for (let i = 0; i < Math.max(ea.length, eb.length); i++) dif |= (ea[i] ?? 0) ^ (eb[i] ?? 0);
  return dif === 0;
}

/** Usuários afetados pelo evento (TRANSFER move compras entre ids). Ids anônimos do RevenueCat são ignorados. */
export function usuariosDoEvento(ev: EventoRC): string[] {
  const ids = ev.type === 'TRANSFER'
    ? [...(ev.transferred_from ?? []), ...(ev.transferred_to ?? [])]
    : [ev.app_user_id ?? ''];
  return [...new Set(ids.filter((i) => UUID.test(i)))];
}

async function buscarAssinante(d: Dependencias, uid: string): Promise<AssinanteRC> {
  const r = await fetch(`${d.rcBase}/v1/subscribers/${encodeURIComponent(uid)}`, {
    headers: { authorization: `Bearer ${d.rcChave}`, accept: 'application/json' },
    signal: AbortSignal.timeout(1500),
  });
  if (!r.ok) throw new Error(`revenuecat_${r.status}`);
  return await r.json();
}

export function criarHandler(d: Dependencias) {
  const agora = d.agora ?? (() => new Date());
  return async (req: Request): Promise<Response> => {
    const t0 = performance.now();
    if (req.method !== 'POST') return resposta(405, { erro: 'metodo' });
    if (!iguais(req.headers.get('authorization') ?? '', `Bearer ${d.segredo}`)) {
      return resposta(401, { erro: 'nao_autorizado' });
    }
    let corpo: { event?: EventoRC };
    try {
      corpo = await req.json();
    } catch {
      return resposta(400, { erro: 'json_invalido' });
    }
    const ev = corpo.event;
    if (!ev?.id || !ev?.type) return resposta(400, { erro: 'evento_invalido' });

    const [reg] = await d.sql<{ processed_at: Date | null }[]>`
      insert into billing.webhook_events (event_id, event_type, app_user_id, payload)
      values (${ev.id}, ${ev.type}, ${ev.app_user_id ?? null}, ${d.sql.json(corpo as postgres.JSONValue)})
      on conflict (event_id) do update set event_type = excluded.event_type
      returning processed_at`;
    if (reg.processed_at) return resposta(200, { status: 'duplicado' });

    try {
      const notas: string[] = [];
      if (ev.type !== 'TEST') {
        for (const uid of usuariosDoEvento(ev)) {
          const [existe] = await d.sql`select 1 as ok from auth.users where id = ${uid}`;
          if (!existe) {
            notas.push(`usuario_inexistente:${uid}`); // conta excluída: nada a gravar
            continue;
          }
          const estado = await buscarAssinante(d, uid);
          const [linha] = await d
            .sql`select 1 as ok from billing.entitlements where user_id = ${uid} and entitlement = 'pro'`;
          let r;
          try {
            r = reconciliar(estado, ev, agora(), !!linha);
          } catch (e) {
            if (e instanceof LojaNaoSuportada) {
              notas.push(`loja_nao_suportada:${e.message}`);
              continue;
            }
            throw e;
          }
          if (r.ativoAte === null) continue;
          await d.sql.begin(async (tx) => {
            let subId: string | null = null;
            if (r.assinatura) {
              const s = r.assinatura;
              const [x] = await tx<{ id: string }[]>`
                insert into billing.subscriptions (user_id, store, product_id, period_type, status, will_renew,
                  current_period_starts_at, current_period_ends_at, grace_period_ends_at, original_transaction_id,
                  environment, last_event_at)
                values (${uid}, ${s.loja}, ${s.produto}, ${s.periodo}, ${s.status}, ${s.renova}, ${s.inicio},
                  ${s.fim}, ${s.carenciaAte}, ${s.transacaoOriginal}, ${r.ambiente},
                  ${new Date(ev.event_timestamp_ms ?? agora().getTime())})
                on conflict (store, original_transaction_id) do update set
                  user_id = excluded.user_id, product_id = excluded.product_id, period_type = excluded.period_type,
                  status = excluded.status, will_renew = excluded.will_renew,
                  current_period_starts_at = excluded.current_period_starts_at,
                  current_period_ends_at = excluded.current_period_ends_at,
                  grace_period_ends_at = excluded.grace_period_ends_at, environment = excluded.environment,
                  last_event_at = greatest(billing.subscriptions.last_event_at, excluded.last_event_at),
                  updated_at = now()
                returning id`;
              subId = x.id;
            }
            await tx`
              insert into billing.entitlements (user_id, entitlement, active_until, environment, source_subscription_id)
              values (${uid}, 'pro', ${r.ativoAte}, ${r.ambiente}, ${subId})
              on conflict (user_id, entitlement) do update set active_until = excluded.active_until,
                environment = excluded.environment,
                source_subscription_id = coalesce(excluded.source_subscription_id, billing.entitlements.source_subscription_id),
                updated_at = now()`;
            await tx`select private.refresh_sync_access()`;
          });
          if (r.ambiente === 'sandbox' && !d.contasTeste.has(uid)) {
            d.alerta?.('sandbox_em_conta_real', { uid, evento: ev.id });
          }
        }
      }
      await d.sql`update billing.webhook_events set processed_at = now(), error = ${
        notas.length ? notas.join(';') : null
      }
                  where event_id = ${ev.id}`;
      return resposta(200, { status: 'processado', ms: Math.round(performance.now() - t0), notas });
    } catch (e) {
      await d.sql`update billing.webhook_events set error = ${String(e)} where event_id = ${ev.id}`;
      return resposta(500, { erro: 'falha_temporaria' });
    }
  };
}

if (import.meta.main) {
  const env = (k: string) => {
    const v = Deno.env.get(k);
    if (!v) throw new Error(`variável ${k} ausente`);
    return v;
  };
  Deno.serve(
    criarHandler({
      sql: postgres(env('SUPABASE_DB_URL'), { max: 3, prepare: false }),
      segredo: env('REVENUECAT_WEBHOOK_AUTH'),
      rcBase: Deno.env.get('REVENUECAT_API_BASE') ?? 'https://api.revenuecat.com',
      rcChave: env('REVENUECAT_API_KEY'),
      contasTeste: new Set((Deno.env.get('CONTAS_TESTE') ?? '').split(',').filter(Boolean)),
      alerta: (msg, dados) => console.warn(JSON.stringify({ alerta: msg, ...dados })),
    }),
  );
}

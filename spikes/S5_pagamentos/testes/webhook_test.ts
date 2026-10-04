// G02 · S5 — a Edge Function revenuecat-webhook contra o Postgres local (SQL de referência) e uma API
// REST do RevenueCat simulada. Casos do Anexo 04 §9 que dependem do backend: compra (sandbox e produção),
// teste grátis, cancelar, carência por falha de cobrança, expirar, reembolso, troca mensal→anual,
// transferência, webhook duplicado, fora de ordem, falha temporária e reenvio, segredo errado, evento TEST.
import postgres from 'postgres';
import assert from 'node:assert/strict';
import { criarHandler } from '../supabase/functions/revenuecat-webhook/index.ts';
import type { AssinanteRC } from '../supabase/functions/revenuecat-webhook/reconciliar.ts';

const URL_DB = Deno.env.get('S5_DB_URL')!;
const SEGREDO = 'segredo-de-teste-local';
const sql = postgres(URL_DB, { max: 4, onnotice: () => {} });

// ---- API REST do RevenueCat simulada (estado atual por assinante) ----
const assinantes = new Map<string, AssinanteRC>();
let rcFora = false;
let chamadasRc = 0;
const rc = Deno.serve({ port: 0, onListen: () => {} }, (req) => {
  chamadasRc++;
  if (rcFora) return new Response('indisponível', { status: 503 });
  if (req.headers.get('authorization') !== 'Bearer chave-secreta-rc') {
    return new Response('', { status: 401 });
  }
  const id = decodeURIComponent(new URL(req.url).pathname.split('/').pop()!);
  const a = assinantes.get(id) ??
    { subscriber: { original_app_user_id: id, entitlements: {}, subscriptions: {} } };
  return Response.json({ request_date: new Date().toISOString(), ...a });
});
const rcBase = `http://127.0.0.1:${rc.addr.port}`;

const alertas: string[] = [];
const tempos: number[] = [];
const contasTeste = new Set<string>();
const handler = criarHandler({
  sql,
  segredo: SEGREDO,
  rcBase,
  rcChave: 'chave-secreta-rc',
  contasTeste,
  alerta: (m) => alertas.push(m),
});

async function enviar(evento: Record<string, unknown>, segredo = SEGREDO) {
  const t0 = performance.now();
  const r = await handler(
    new Request('http://local/revenuecat-webhook', {
      method: 'POST',
      headers: { authorization: `Bearer ${segredo}`, 'content-type': 'application/json' },
      body: JSON.stringify({ api_version: '1.0', event: evento }),
    }),
  );
  tempos.push(performance.now() - t0);
  return { status: r.status, corpo: await r.json() };
}

const dia = 86_400_000;
const iso = (ms: number) => new Date(ms).toISOString();
let seq = 0;
function evento(tipo: string, uid: string, extra: Record<string, unknown> = {}) {
  return {
    id: `evt-${++seq}-${crypto.randomUUID()}`,
    type: tipo,
    app_user_id: uid,
    original_app_user_id: uid,
    aliases: [uid],
    product_id: 'booknest_pro_mensal',
    entitlement_ids: ['pro'],
    period_type: 'NORMAL',
    purchased_at_ms: Date.now(),
    expiration_at_ms: Date.now() + 30 * dia,
    environment: 'SANDBOX',
    store: 'APP_STORE',
    transaction_id: `tx-${seq}`,
    original_transaction_id: `orig-${uid.slice(0, 8)}`,
    event_timestamp_ms: Date.now(),
    currency: 'BRL',
    price: 9.99,
    ...extra,
  };
}

function estado(uid: string, s: Partial<{
  produto: string;
  expira: number | null;
  carencia: number | null;
  sandbox: boolean;
  loja: string;
  periodo: string;
  cancelado: number | null;
  reembolso: number | null;
  falhaCobranca: number | null;
  semEntitlement: boolean;
}> = {}) {
  const produto = s.produto ?? 'booknest_pro_mensal';
  const expira = s.expira === undefined ? Date.now() + 30 * dia : s.expira;
  assinantes.set(uid, {
    subscriber: {
      original_app_user_id: uid,
      entitlements: s.semEntitlement ? {} : {
        pro: {
          expires_date: expira === null ? null : iso(s.reembolso ?? expira),
          grace_period_expires_date: s.carencia ? iso(s.carencia) : null,
          product_identifier: produto,
          purchase_date: iso(Date.now() - dia),
        },
      },
      subscriptions: {
        [produto]: {
          expires_date: expira === null ? null : iso(expira),
          purchase_date: iso(Date.now() - dia),
          original_purchase_date: iso(Date.now() - 40 * dia),
          period_type: s.periodo ?? 'normal',
          store: s.loja ?? 'app_store',
          is_sandbox: s.sandbox ?? true,
          unsubscribe_detected_at: s.cancelado ? iso(s.cancelado) : null,
          billing_issues_detected_at: s.falhaCobranca ? iso(s.falhaCobranca) : null,
          grace_period_expires_date: s.carencia ? iso(s.carencia) : null,
          refunded_at: s.reembolso ? iso(s.reembolso) : null,
        },
      },
    },
  });
}

async function novoUsuario() {
  const id = crypto.randomUUID();
  await sql`insert into auth.users (id, email) values (${id}, ${id + '@s5.local'})`;
  return id;
}

async function situacao(uid: string) {
  const [e] =
    await sql`select active_until, environment, active_until > now() as pro from billing.entitlements where user_id = ${uid}`;
  const [s] =
    await sql`select status, will_renew, product_id, period_type, store from billing.subscriptions where user_id = ${uid}`;
  const [a] = await sql`select granted from billing.sync_access where user_id = ${uid}`;
  const [c] = await sql`select private.can_sync(${uid}) as pode`;
  return {
    pro: e?.pro ?? false,
    ambiente: e?.environment,
    assinatura: s,
    bucket: a?.granted ?? false,
    podeSubir: c.pode,
  };
}

const resultados: Record<string, unknown> = {};
const opts = { sanitizeResources: false, sanitizeOps: false };

Deno.test('segredo errado → 401 e nada gravado', opts, async () => {
  const uid = await novoUsuario();
  const ev = evento('INITIAL_PURCHASE', uid);
  const r = await enviar(ev, 'errado');
  assert.deepStrictEqual(r.status, 401);
  assert.deepStrictEqual(
    (await sql`select count(*)::int n from billing.webhook_events where event_id = ${ev.id}`)[0].n,
    0,
  );
  resultados.segredo_errado = 401;
});

Deno.test(
  'compra inicial em sandbox (teste grátis) libera o Pro e o bucket; marcada sandbox',
  opts,
  async () => {
    const uid = await novoUsuario();
    estado(uid, { periodo: 'trial', expira: Date.now() + 7 * dia });
    const r = await enviar(evento('INITIAL_PURCHASE', uid, { period_type: 'TRIAL' }));
    assert.deepStrictEqual(r.status, 200);
    const s = await situacao(uid);
    assert.deepStrictEqual([s.pro, s.ambiente, s.bucket, s.podeSubir], [true, 'sandbox', true, true]);
    assert.deepStrictEqual([s.assinatura.status, s.assinatura.period_type, s.assinatura.store], [
      'active',
      'trial',
      'app_store',
    ]);
    assert.ok(alertas.includes('sandbox_em_conta_real'), 'alerta de sandbox em conta que não é de teste');
    resultados.compra_sandbox = { ...s, alerta: true };
  },
);

Deno.test('compra em produção (Play) e conta de teste sem alerta', opts, async () => {
  const uid = await novoUsuario();
  contasTeste.add(uid);
  alertas.length = 0;
  estado(uid, {
    loja: 'play_store',
    sandbox: false,
    produto: 'booknest_pro:anual',
    expira: Date.now() + 365 * dia,
  });
  const r = await enviar(
    evento('INITIAL_PURCHASE', uid, {
      store: 'PLAY_STORE',
      environment: 'PRODUCTION',
      product_id: 'booknest_pro:anual',
    }),
  );
  assert.deepStrictEqual(r.status, 200);
  const s = await situacao(uid);
  assert.deepStrictEqual([s.pro, s.ambiente, s.assinatura.store, s.assinatura.product_id], [
    true,
    'production',
    'play_store',
    'booknest_pro:anual',
  ]);
  assert.deepStrictEqual(alertas.length, 0);
  resultados.compra_producao = s;
});

Deno.test('webhook duplicado é processado uma vez só', opts, async () => {
  const uid = await novoUsuario();
  estado(uid);
  const ev = evento('RENEWAL', uid);
  const antes = chamadasRc;
  const r1 = await enviar(ev);
  const r2 = await enviar(ev);
  assert.deepStrictEqual([r1.corpo.status, r2.corpo.status], ['processado', 'duplicado']);
  assert.deepStrictEqual(chamadasRc - antes, 1, 'a 2ª entrega nem consulta o RevenueCat');
  resultados.duplicado = { primeira: r1.corpo.status, segunda: r2.corpo.status };
});

Deno.test('fora de ordem: EXPIRATION antigo chega depois da renovação → continua Pro', opts, async () => {
  const uid = await novoUsuario();
  estado(uid); // estado atual: renovado, expira daqui a 30 dias
  const renovacao = evento('RENEWAL', uid, { event_timestamp_ms: Date.now() });
  const expiracaoVelha = evento('EXPIRATION', uid, {
    event_timestamp_ms: Date.now() - 2 * dia,
    expiration_reason: 'BILLING_ERROR',
  });
  await enviar(renovacao);
  await enviar(expiracaoVelha); // chega atrasado
  const s = await situacao(uid);
  assert.deepStrictEqual([s.pro, s.assinatura.status], [true, 'active']);
  resultados.fora_de_ordem = s;
});

Deno.test('cancelamento: continua Pro até o fim do período, sem renovar', opts, async () => {
  const uid = await novoUsuario();
  estado(uid, { cancelado: Date.now() });
  await enviar(evento('CANCELLATION', uid, { cancel_reason: 'UNSUBSCRIBE' }));
  const s = await situacao(uid);
  assert.deepStrictEqual([s.pro, s.assinatura.status, s.assinatura.will_renew], [true, 'cancelled', false]);
  resultados.cancelamento = s;
});

Deno.test('falha de cobrança com carência: Pro até o fim da carência', opts, async () => {
  const uid = await novoUsuario();
  estado(uid, {
    expira: Date.now() - 3_600_000,
    carencia: Date.now() + 6 * dia,
    falhaCobranca: Date.now() - 3_600_000,
  });
  await enviar(evento('BILLING_ISSUE', uid, { grace_period_expiration_at_ms: Date.now() + 6 * dia }));
  const s = await situacao(uid);
  assert.deepStrictEqual([s.pro, s.assinatura.status], [true, 'in_grace_period']);
  // carência acabou sem pagamento → retentativa de cobrança, sem Pro
  estado(uid, {
    expira: Date.now() - 7 * dia,
    carencia: Date.now() - 3_600_000,
    falhaCobranca: Date.now() - 7 * dia,
  });
  await enviar(evento('EXPIRATION', uid, { expiration_reason: 'BILLING_ERROR' }));
  const s2 = await situacao(uid);
  assert.deepStrictEqual([s2.pro, s2.assinatura.status, s2.podeSubir, s2.bucket], [
    false,
    'in_billing_retry',
    false,
    true,
  ]);
  resultados.carencia = { durante: s, depois: s2 };
});

Deno.test('reembolso: Pro cai na hora; upload bloqueado; bucket mantido 7 dias', opts, async () => {
  const uid = await novoUsuario();
  estado(uid);
  await enviar(evento('INITIAL_PURCHASE', uid));
  estado(uid, { reembolso: Date.now() - 1000 });
  await enviar(evento('CANCELLATION', uid, { cancel_reason: 'CUSTOMER_SUPPORT' }));
  const s = await situacao(uid);
  assert.deepStrictEqual([s.pro, s.assinatura.status, s.podeSubir, s.bucket], [
    false,
    'refunded',
    false,
    true,
  ]);
  // 7 dias depois (pg_cron refresh_sync_access): bucket revogado
  await sql`update billing.entitlements set active_until = now() - interval '8 days' where user_id = ${uid}`;
  await sql`select private.refresh_sync_access()`;
  assert.deepStrictEqual((await situacao(uid)).bucket, false);
  resultados.reembolso = { na_hora: s, sete_dias_depois_bucket: false };
});

Deno.test('troca mensal → anual atualiza produto e validade', opts, async () => {
  const uid = await novoUsuario();
  estado(uid);
  await enviar(evento('INITIAL_PURCHASE', uid));
  estado(uid, { produto: 'booknest_pro_anual', expira: Date.now() + 365 * dia });
  await enviar(
    evento('PRODUCT_CHANGE', uid, { product_id: 'booknest_pro_anual', new_product_id: 'booknest_pro_anual' }),
  );
  const [e] = await sql`select active_until from billing.entitlements where user_id = ${uid}`;
  assert.ok(new Date(e.active_until).getTime() > Date.now() + 300 * dia);
  const subs =
    await sql`select product_id from billing.subscriptions where user_id = ${uid} order by updated_at desc`;
  assert.deepStrictEqual(subs[0].product_id, 'booknest_pro_anual');
  resultados.troca_de_plano = { produto: subs[0].product_id, assinaturas_registradas: subs.length };
});

Deno.test('expiração: sem Pro e upload bloqueado na hora; bucket ainda vale (7 dias)', opts, async () => {
  const uid = await novoUsuario();
  estado(uid);
  await enviar(evento('INITIAL_PURCHASE', uid));
  estado(uid, { expira: Date.now() - 1000, cancelado: Date.now() - 10 * dia });
  await enviar(evento('EXPIRATION', uid, { expiration_reason: 'UNSUBSCRIBE' }));
  const s = await situacao(uid);
  assert.deepStrictEqual([s.pro, s.assinatura.status, s.podeSubir, s.bucket], [
    false,
    'expired',
    false,
    true,
  ]);
  resultados.expiracao = s;
});

Deno.test('transferência: a compra sai de um usuário e vai para outro', opts, async () => {
  const de = await novoUsuario();
  const para = await novoUsuario();
  estado(de);
  await enviar(evento('INITIAL_PURCHASE', de));
  estado(de, { semEntitlement: true });
  estado(para);
  const r = await enviar({
    ...evento('TRANSFER', '', {}),
    app_user_id: undefined,
    transferred_from: [de],
    transferred_to: [para],
  });
  assert.deepStrictEqual(r.status, 200);
  const [sDe, sPara] = [await situacao(de), await situacao(para)];
  assert.deepStrictEqual([sDe.pro, sPara.pro], [false, true]);
  resultados.transferencia = { origem_pro: sDe.pro, destino_pro: sPara.pro };
});

Deno.test('RevenueCat fora do ar: 500, erro gravado; reenvio processa', opts, async () => {
  const uid = await novoUsuario();
  estado(uid);
  const ev = evento('INITIAL_PURCHASE', uid);
  rcFora = true;
  const r1 = await enviar(ev);
  rcFora = false;
  const [reg] = await sql`select processed_at, error from billing.webhook_events where event_id = ${ev.id}`;
  assert.deepStrictEqual([r1.status, reg.processed_at, reg.error !== null], [500, null, true]);
  const r2 = await enviar(ev); // o RevenueCat reenvia o mesmo evento
  assert.deepStrictEqual([r2.status, r2.corpo.status], [200, 'processado']);
  assert.deepStrictEqual((await situacao(uid)).pro, true);
  resultados.falha_e_reenvio = { primeira: 500, reenvio: 'processado' };
});

Deno.test('evento TEST do painel e conta excluída: 200 sem mexer em nada', opts, async () => {
  const r = await enviar(evento('TEST', crypto.randomUUID()));
  assert.deepStrictEqual(r.status, 200);
  const fantasma = crypto.randomUUID();
  estado(fantasma);
  const r2 = await enviar(evento('RENEWAL', fantasma));
  assert.deepStrictEqual([r2.status, r2.corpo.notas[0]], [200, `usuario_inexistente:${fantasma}`]);
  resultados.test_e_conta_excluida = { test: 200, conta_excluida: r2.corpo.notas[0].split(':')[0] };
});

Deno.test('tempo de resposta < 2 s (Anexo 04 §5.7)', opts, async () => {
  const ord = [...tempos].sort((a, b) => a - b);
  const p = (q: number) => Number(ord[Math.min(ord.length - 1, Math.round((ord.length - 1) * q))].toFixed(1));
  resultados.tempo_ms = { chamadas: ord.length, p50: p(0.5), p95: p(0.95), max: p(1) };
  assert.ok(p(1) < 2000);
  await Deno.writeTextFile('dados/resultado_s5.json', JSON.stringify(resultados, null, 1) + '\n');
  await rc.shutdown();
  await sql.end();
});

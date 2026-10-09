import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler, type Dependencias } from './handler.ts';

function fakes(sobrescrever: Partial<Dependencias> = {}) {
  const chamadas: string[] = [];
  const d: Dependencias = {
    segredo: 'Bearer segredo-do-webhook',
    inicioDoEvento: (e) => {
      chamadas.push(`inicio:${e.id}`);
      return Promise.resolve('new');
    },
    fimDoEvento: (id, erro) => {
      chamadas.push(`fim:${id}:${erro ?? 'ok'}`);
      return Promise.resolve();
    },
    assinante: (u) => {
      chamadas.push(`assinante:${u}`);
      return Promise.resolve({
        subscriptions: {
          'booknest_pro:mensal': {
            store: 'play_store',
            purchase_date: '2026-10-01T00:00:00Z',
            expires_date: '2099-01-01T00:00:00Z',
          },
        },
      });
    },
    aplicar: (u, subs) => {
      chamadas.push(`aplicar:${u}:${subs.length}`);
      return Promise.resolve({ pro: true });
    },
    ...sobrescrever,
  };
  return { handler: criarHandler(d), chamadas };
}

const USUARIO = '00000000-0000-7000-8000-00000000000a';
const pedido = (corpo: unknown, auth = 'Bearer segredo-do-webhook', metodo = 'POST') =>
  new Request('http://local/revenuecat-webhook', {
    method: metodo,
    headers: { Authorization: auth, 'Content-Type': 'application/json' },
    body: metodo === 'POST' ? JSON.stringify(corpo) : undefined,
  });
const evento = (tipo = 'RENEWAL', app = USUARIO) => ({
  api_version: '1.0',
  event: { id: 'evt-1', type: tipo, app_user_id: app, event_timestamp_ms: 1790000000000 },
});

Deno.test('segredo errado → 401 e nada é gravado', async () => {
  const { handler, chamadas } = fakes();
  assertEquals((await handler(pedido(evento(), 'Bearer outro'))).status, 401);
  assertEquals((await handler(pedido(evento(), ''))).status, 401);
  assertEquals(chamadas, []);
});

Deno.test('sem segredo configurado, tudo é recusado', async () => {
  const { handler } = fakes({ segredo: undefined });
  assertEquals((await handler(pedido(evento()))).status, 401);
});

Deno.test('só POST', async () => {
  const { handler } = fakes();
  assertEquals((await handler(pedido(null, 'Bearer segredo-do-webhook', 'GET'))).status, 405);
});

Deno.test('evento novo: consulta o RevenueCat, aplica e marca', async () => {
  const { handler, chamadas } = fakes();
  const r = await handler(pedido(evento()));
  assertEquals(r.status, 200);
  assertEquals(await r.json(), { status: 'processado', pro: true });
  assertEquals(chamadas, ['inicio:evt-1', `assinante:${USUARIO}`, `aplicar:${USUARIO}:1`, 'fim:evt-1:ok']);
});

Deno.test('evento repetido já processado: 200 sem refazer', async () => {
  const { handler, chamadas } = fakes({ inicioDoEvento: () => Promise.resolve('done') });
  const r = await handler(pedido(evento()));
  assertEquals([r.status, (await r.json()).status], [200, 'duplicado']);
  assertEquals(chamadas, []);
});

Deno.test('evento de teste do painel e usuário anônimo do RevenueCat: ignorados com 200', async () => {
  for (const e of [evento('TEST'), evento('INITIAL_PURCHASE', '$RCAnonymousID:abc')]) {
    const { handler, chamadas } = fakes();
    const r = await handler(pedido(e));
    assertEquals([r.status, (await r.json()).status], [200, 'ignorado']);
    assertEquals(chamadas, ['inicio:evt-1', 'fim:evt-1:ok']);
  }
});

Deno.test('falha ao consultar o RevenueCat: grava o erro e responde 500 (o RevenueCat reenvia)', async () => {
  const { handler, chamadas } = fakes({
    assinante: () => Promise.reject(new Error('RevenueCat respondeu 503')),
  });
  assertEquals((await handler(pedido(evento()))).status, 500);
  assertEquals(chamadas.at(-1), 'fim:evt-1:RevenueCat respondeu 503');
});

Deno.test('corpo sem evento → 400', async () => {
  const { handler } = fakes();
  assertEquals((await handler(pedido({ api_version: '1.0' }))).status, 400);
});

// ------------------------------------------------------------ revisão da G04 (#2 e #10)
const U2 = '00000000-0000-7000-8000-00000000000b';

Deno.test('TRANSFER (sem app_user_id): aplica o estado de cada conta de origem e de destino', async () => {
  const { handler, chamadas } = fakes();
  const r = await handler(pedido({
    api_version: '1.0',
    event: {
      id: 'evt-1',
      type: 'TRANSFER',
      transferred_from: [USUARIO, '$RCAnonymousID:abc'],
      transferred_to: [U2, USUARIO],
      event_timestamp_ms: 1790000000000,
    },
  }));
  assertEquals([r.status, await r.json()], [200, { status: 'processado', usuarios: 2 }]);
  assertEquals(chamadas, [
    'inicio:evt-1',
    `assinante:${USUARIO}`,
    `aplicar:${USUARIO}:1`,
    `assinante:${U2}`,
    `aplicar:${U2}:1`,
    'fim:evt-1:ok',
  ]);
});

Deno.test('TRANSFER só entre ids anônimos do RevenueCat: ignorado com 200', async () => {
  const { handler, chamadas } = fakes();
  const r = await handler(pedido({
    event: {
      id: 'evt-1',
      type: 'TRANSFER',
      transferred_from: ['$RCAnonymousID:a'],
      transferred_to: ['$RCAnonymousID:b'],
    },
  }));
  assertEquals([r.status, (await r.json()).status], [200, 'ignorado']);
  assertEquals(chamadas, ['inicio:evt-1', 'fim:evt-1:ok']);
});

Deno.test('a hora da busca no RevenueCat vai para o banco (estado buscado antes não sobrescreve o mais novo)', async () => {
  const horas: number[] = [];
  let relogio = 1790000000000;
  const { handler } = fakes({
    agora: () => relogio,
    assinante: () => {
      relogio += 250; // a resposta chega depois
      return Promise.resolve({ subscriptions: {} });
    },
    aplicar: (_u, _s, _q, buscadoEm) => {
      horas.push(buscadoEm.getTime());
      return Promise.resolve({ pro: false });
    },
  });
  assertEquals((await handler(pedido(evento()))).status, 200);
  assertEquals(horas, [1790000000000]); // a hora de ANTES da busca
});

Deno.test('conta que não existe mais no app (unknown_user): ignorada com 200, sem reenvio', async () => {
  const { handler, chamadas } = fakes({
    aplicar: () => Promise.reject(Object.assign(new Error('unknown_user'), { code: 'P0001' })),
  });
  const r = await handler(pedido(evento()));
  assertEquals([r.status, (await r.json()).status], [200, 'ignorado']);
  assertEquals(chamadas.at(-1), 'fim:evt-1:ok');
});

// ------------------------------------------------------------ G22.1: a matriz do Anexo 04 §9 (o fluxo de cada evento)
Deno.test('cada evento da matriz busca e aplica o estado da conta (o tipo não decide nada)', async () => {
  for (
    const tipo of [
      'INITIAL_PURCHASE', // compra mensal ou anual; teste grátis
      'RENEWAL',
      'CANCELLATION', // renovação desligada; reembolso (o refunded_at vem no estado)
      'UNCANCELLATION',
      'EXPIRATION',
      'BILLING_ISSUE', // carência e nova tentativa de cobrança
      'PRODUCT_CHANGE', // mensal → anual
    ]
  ) {
    const { handler, chamadas } = fakes();
    const r = await handler(pedido(evento(tipo)));
    assertEquals([tipo, r.status], [tipo, 200]);
    assertEquals(chamadas, ['inicio:evt-1', `assinante:${USUARIO}`, `aplicar:${USUARIO}:1`, 'fim:evt-1:ok']);
  }
});

Deno.test('restaurar em outro aparelho, a mesma conta: dois eventos, o mesmo estado aplicado à mesma conta', async () => {
  const aplicados: string[] = [];
  const { handler } = fakes({
    aplicar: (u, subs) => {
      aplicados.push(`${u}:${JSON.stringify(subs)}`);
      return Promise.resolve({ pro: true });
    },
  });
  const outro = { api_version: '1.0', event: { ...evento('INITIAL_PURCHASE').event, id: 'evt-2' } };
  assertEquals((await handler(pedido(evento('RENEWAL')))).status, 200);
  assertEquals((await handler(pedido(outro))).status, 200);
  assertEquals(aplicados.length, 2);
  assertEquals(aplicados[0], aplicados[1]);
});

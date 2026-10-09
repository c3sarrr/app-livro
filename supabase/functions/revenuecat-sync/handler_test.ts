import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler, type Dependencias } from './handler.ts';

const USUARIO = '00000000-0000-7000-8000-00000000000a';
const ASSINANTE = {
  subscriptions: {
    booknest_pro_mensal: {
      store: 'test_store',
      purchase_date: '2026-10-09T12:00:00Z',
      expires_date: '2099-01-01T00:00:00Z',
      period_type: 'trial',
      is_sandbox: true,
    },
  },
};

function fakes(sobrescrever: Partial<Dependencias> = {}) {
  const chamadas: string[] = [];
  const d: Dependencias = {
    verificarJwt: (jwt) => Promise.resolve(jwt === 'jwt-valido' ? USUARIO : null),
    cota: (u) => {
      chamadas.push(`cota:${u}`);
      return Promise.resolve(true);
    },
    assinante: (u) => {
      chamadas.push(`assinante:${u}`);
      return Promise.resolve(ASSINANTE);
    },
    aplicar: (u, subs) => {
      chamadas.push(`aplicar:${u}:${subs.length}:${subs[0]?.environment}`);
      return Promise.resolve({ pro: true, active_until: '2099-01-01T00:00:00+00:00' });
    },
    agora: () => Date.parse('2026-10-09T12:00:01Z'),
    ...sobrescrever,
  };
  return { handler: criarHandler(d), chamadas };
}

const pedido = (jwt?: string, metodo = 'POST') =>
  new Request('http://local/revenuecat-sync', {
    method: metodo,
    headers: jwt ? { Authorization: `Bearer ${jwt}` } : {},
  });

Deno.test('sem sessão ou com sessão inválida → 401, sem ir ao RevenueCat', async () => {
  const { handler, chamadas } = fakes();
  assertEquals((await handler(pedido())).status, 401);
  assertEquals((await handler(pedido('outro'))).status, 401);
  assertEquals(chamadas, []);
});

Deno.test('só POST', async () => {
  const { handler } = fakes();
  assertEquals((await handler(pedido('jwt-valido', 'GET'))).status, 405);
});

Deno.test('aplica o estado da PRÓPRIA conta e devolve o Pro', async () => {
  const { handler, chamadas } = fakes();
  const r = await handler(pedido('jwt-valido'));
  assertEquals(r.status, 200);
  assertEquals(await r.json(), { pro: true, active_until: '2099-01-01T00:00:00+00:00' });
  assertEquals(chamadas, [`cota:${USUARIO}`, `assinante:${USUARIO}`, `aplicar:${USUARIO}:1:sandbox`]);
});

Deno.test('acima da cota do dia → 429, sem ir ao RevenueCat', async () => {
  const { handler, chamadas } = fakes({ cota: () => Promise.resolve(false) });
  assertEquals((await handler(pedido('jwt-valido'))).status, 429);
  assertEquals(chamadas.filter((c) => c.startsWith('assinante')), []);
});

Deno.test('o RevenueCat fora do ar → 502 (o app tenta de novo), nada aplicado', async () => {
  const { handler, chamadas } = fakes({
    assinante: () => Promise.reject(new Error('RevenueCat respondeu 503')),
  });
  assertEquals((await handler(pedido('jwt-valido'))).status, 502);
  assertEquals(chamadas.filter((c) => c.startsWith('aplicar')), []);
});

Deno.test('a conta que não existe mais no app (unknown_user) → 404', async () => {
  // o que o banco levanta de verdade: `raise exception 'unknown_user' using errcode = 'P0001'` (revisao_g04)
  const e = Object.assign(new Error('unknown_user'), { code: 'P0001' });
  const { handler } = fakes({ aplicar: () => Promise.reject(e) });
  assertEquals((await handler(pedido('jwt-valido'))).status, 404);
});

Deno.test('assinante sem assinatura: aplica a lista vazia (tira o Pro)', async () => {
  let aplicadas = -1;
  const { handler } = fakes({
    assinante: () => Promise.resolve({ subscriptions: {} }),
    aplicar: (_u, subs) => {
      aplicadas = subs.length;
      return Promise.resolve({ pro: false, active_until: null });
    },
  });
  const r = await handler(pedido('jwt-valido'));
  assertEquals(await r.json(), { pro: false, active_until: null });
  assertEquals(aplicadas, 0);
});

Deno.test('o corpo não escolhe a conta: só a do JWT', async () => {
  const { handler, chamadas } = fakes();
  await handler(
    new Request('http://local/revenuecat-sync', {
      method: 'POST',
      headers: { Authorization: 'Bearer jwt-valido' },
      body: JSON.stringify({ app_user_id: 'outra-conta' }),
    }),
  );
  assertEquals(chamadas, [`cota:${USUARIO}`, `assinante:${USUARIO}`, `aplicar:${USUARIO}:1:sandbox`]);
});

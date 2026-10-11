import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler, type Dependencias } from './handler.ts';

const USUARIO = '00000000-0000-7000-8000-00000000000a';
const pedido = (corpo: unknown, jwt = 'jwt-valido') =>
  new Request('http://local/delete-account', {
    method: 'POST',
    headers: { Authorization: `Bearer ${jwt}` },
    body: JSON.stringify(corpo),
  });
function fakes(s: Partial<Dependencias> = {}) {
  const passos: string[] = [];
  const h = criarHandler({
    verificarJwt: (j) => Promise.resolve(j === 'jwt-valido' ? USUARIO : null),
    apagarAssinante: (u) => {
      passos.push(`revenuecat:${u}`);
      return Promise.resolve();
    },
    apagarEbooks: (u) => {
      passos.push(`storage:${u}`);
      return Promise.resolve(2);
    },
    apagarUsuario: (u) => {
      passos.push(`auth:${u}`);
      return Promise.resolve();
    },
    ...s,
  });
  return { h, passos };
}

Deno.test('apaga na ordem RevenueCat → Storage → Auth, só a conta de quem pede', async () => {
  const { h, passos } = fakes();
  const r = await h(pedido({ confirmar: true }));
  assertEquals([r.status, await r.json()], [200, { excluida: true, ebooks_apagados: 2 }]);
  assertEquals(passos, [`revenuecat:${USUARIO}`, `storage:${USUARIO}`, `auth:${USUARIO}`]);
});

Deno.test('sem confirmação explícita → 400 e nada é apagado; sem login → 401', async () => {
  const { h, passos } = fakes();
  assertEquals((await h(pedido({}))).status, 400);
  assertEquals((await h(pedido({ confirmar: 'sim' }))).status, 400);
  assertEquals((await h(pedido({ confirmar: true }, 'forjado'))).status, 401);
  assertEquals(passos, []);
});

Deno.test('RevenueCat fora do ar → 502 e a conta NÃO é apagada', async () => {
  const { h, passos } = fakes({ apagarAssinante: () => Promise.reject(new Error('503')) });
  assertEquals((await h(pedido({ confirmar: true }))).status, 502);
  assertEquals(passos, []);
});

Deno.test('falha no Storage não impede a exclusão (a fila do banco limpa depois)', async () => {
  const { h, passos } = fakes({ apagarEbooks: () => Promise.reject(new Error('storage')) });
  assertEquals((await h(pedido({ confirmar: true }))).status, 200);
  assertEquals(passos.at(-1), `auth:${USUARIO}`);
});

// G05 — página web de pedido de exclusão (exigência do Google Play): o navegador só chama a função se
// a origem da página estiver liberada (EXCLUSAO_WEB_ORIGEM). Qualquer outra origem fica sem CORS.
const ORIGEM = 'https://booknest.example';
const doNavegador = (metodo: string, origem: string, corpo?: unknown) =>
  new Request('http://local/delete-account', {
    method: metodo,
    headers: {
      Origin: origem,
      Authorization: 'Bearer jwt-valido',
      'Access-Control-Request-Method': 'POST',
      'Access-Control-Request-Headers': 'authorization, apikey, content-type',
    },
    body: corpo === undefined ? undefined : JSON.stringify(corpo),
  });

Deno.test('página web (origem liberada): preflight 204 com CORS e a resposta também leva CORS', async () => {
  const { h, passos } = fakes({ origemWeb: ORIGEM });
  const pre = await h(doNavegador('OPTIONS', ORIGEM));
  assertEquals(pre.status, 204);
  assertEquals(pre.headers.get('Access-Control-Allow-Origin'), ORIGEM);
  assertEquals(pre.headers.get('Access-Control-Allow-Methods'), 'POST, OPTIONS');
  assertEquals(
    pre.headers.get('Access-Control-Allow-Headers'),
    'authorization, apikey, content-type, x-client-info',
  );
  assertEquals(pre.headers.get('Vary'), 'Origin');
  assertEquals(passos, []);
  const r = await h(doNavegador('POST', ORIGEM, { confirmar: true }));
  assertEquals(r.status, 200);
  assertEquals(r.headers.get('Access-Control-Allow-Origin'), ORIGEM);
  const negado = await h(doNavegador('POST', ORIGEM, {}));
  assertEquals(negado.status, 400);
  assertEquals(negado.headers.get('Access-Control-Allow-Origin'), ORIGEM);
});

Deno.test('outra origem, ou nenhuma liberada: sem CORS (o app nativo não usa CORS e segue igual)', async () => {
  const liberada = fakes({ origemWeb: ORIGEM }).h;
  const outra = await liberada(doNavegador('OPTIONS', 'https://golpe.example'));
  assertEquals(outra.status, 405);
  assertEquals(outra.headers.get('Access-Control-Allow-Origin'), null);
  const semOrigem = fakes().h;
  const pre = await semOrigem(doNavegador('OPTIONS', ORIGEM));
  assertEquals(pre.status, 405);
  assertEquals(pre.headers.get('Access-Control-Allow-Origin'), null);
  const r = await semOrigem(doNavegador('POST', ORIGEM, { confirmar: true }));
  assertEquals(r.status, 200);
  assertEquals(r.headers.get('Access-Control-Allow-Origin'), null);
});

Deno.test('falha ao apagar no Auth → 500 (com CORS para a página web), sem estourar a função', async () => {
  const { h, passos } = fakes({
    origemWeb: ORIGEM,
    apagarUsuario: () => Promise.reject(new Error('auth fora do ar')),
  });
  const r = await h(doNavegador('POST', ORIGEM, { confirmar: true }));
  assertEquals(r.status, 500);
  assertEquals(await r.json(), { erro: 'falha_na_exclusao' });
  assertEquals(r.headers.get('Access-Control-Allow-Origin'), ORIGEM);
  assertEquals(passos, [`revenuecat:${USUARIO}`, `storage:${USUARIO}`]);
});

Deno.test('verificação da sessão que falha (ex.: Auth fora do ar) → 401 com CORS, nada apagado', async () => {
  const { h, passos } = fakes({ origemWeb: ORIGEM, verificarJwt: () => Promise.reject(new Error('rede')) });
  const r = await h(doNavegador('POST', ORIGEM, { confirmar: true }));
  assertEquals(r.status, 401);
  assertEquals(r.headers.get('Access-Control-Allow-Origin'), ORIGEM);
  assertEquals(passos, []);
});

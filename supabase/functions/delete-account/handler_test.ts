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

import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler, type Dependencias } from './handler.ts';

const pedido = (jwt = 'jwt-valido', metodo = 'POST') =>
  new Request('http://local/export-data', { method: metodo, headers: { Authorization: `Bearer ${jwt}` } });
const fakes = (s: Partial<Dependencias> = {}) =>
  criarHandler({
    verificarJwt: (j) => Promise.resolve(j === 'jwt-valido' ? '00000000-0000-7000-8000-00000000000a' : null),
    exportar: (j) => Promise.resolve({ dados: { format_version: 1, jwt_usado: j } }),
    hoje: () => '2026-10-04',
    ...s,
  });

Deno.test('exporta com o JWT do próprio usuário e devolve um arquivo JSON', async () => {
  const r = await fakes()(pedido());
  assertEquals(r.status, 200);
  assertEquals(
    r.headers.get('Content-Disposition'),
    'attachment; filename="booknest-meus-dados-2026-10-04.json"',
  );
  assertEquals(await r.json(), { format_version: 1, jwt_usado: 'jwt-valido' });
});

Deno.test('sem login → 401; só POST', async () => {
  assertEquals((await fakes()(pedido('outro'))).status, 401);
  assertEquals((await fakes()(pedido('jwt-valido', 'GET'))).status, 405);
});

Deno.test('cota diária → 429; erro do banco → 500', async () => {
  assertEquals(
    (await fakes({ exportar: () => Promise.resolve({ erro: 'quota_exceeded' }) })(pedido())).status,
    429,
  );
  assertEquals((await fakes({ exportar: () => Promise.resolve({ erro: 'boom' }) })(pedido())).status, 500);
});

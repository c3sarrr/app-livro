import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { caminhoRelativo, criarHandler, type Dependencias, VALIDADE_S } from './handler.ts';

const USUARIO = '00000000-0000-7000-8000-00000000000a';
const LIVRO = '01927a00-0000-7000-8000-000000000a01';
const CAMINHO = `${USUARIO}/${LIVRO}/${'a'.repeat(64)}.epub`;
const pedido = (corpo: unknown, jwt = 'jwt-valido', metodo = 'POST') =>
  new Request('http://local/ebook-download-url', {
    method: metodo,
    headers: { Authorization: `Bearer ${jwt}` },
    body: metodo === 'POST' ? JSON.stringify(corpo) : undefined,
  });
const erroDoBanco = (codigo: string) => Object.assign(new Error(codigo), { code: 'P0001' });

function fakes(s: Partial<Dependencias> = {}) {
  const pedidos: [string, number][] = [];
  const h = criarHandler({
    verificarJwt: (jwt) => Promise.resolve(jwt === 'jwt-valido' ? USUARIO : null),
    caminho: (u, l) => Promise.resolve(u === USUARIO && l === LIVRO ? CAMINHO : 'x'),
    urlAssinada: (c, v) => {
      pedidos.push([c, v]);
      return Promise.resolve(`http://kong:8000/storage/v1/object/sign/ebooks/${c}?token=t`);
    },
    ...s,
  });
  return { h, pedidos };
}

Deno.test('Pro dono do livro: URL de vida curta (5 min) para o caminho que o banco conferiu', async () => {
  const { h, pedidos } = fakes();
  const r = await h(pedido({ user_book_id: LIVRO }));
  assertEquals(r.status, 200);
  // relativo: o endereço interno do runtime (kong:8000) não vai para o app
  assertEquals(await r.json(), {
    path: CAMINHO,
    signed_path: `/storage/v1/object/sign/ebooks/${CAMINHO}?token=t`,
    expires_in: 300,
  });
  assertEquals(pedidos, [[CAMINHO, VALIDADE_S]]);
  assertEquals(VALIDADE_S <= 300, true);
});

Deno.test('sem login → 401; livro inválido → 400; outro método → 405 (nada assinado)', async () => {
  const { h, pedidos } = fakes();
  assertEquals((await h(pedido({ user_book_id: LIVRO }, 'forjado'))).status, 401);
  assertEquals((await h(pedido({ user_book_id: 'x' }))).status, 400);
  assertEquals((await h(pedido({}, 'jwt-valido', 'GET'))).status, 405);
  assertEquals(pedidos, []);
});

Deno.test('regras do banco viram o código HTTP certo e não emitem URL', async () => {
  for (
    const [codigo, status] of [['pro_required', 403], ['book_not_found', 404], [
      'file_not_found',
      404,
    ]] as const
  ) {
    const { h, pedidos } = fakes({ caminho: () => Promise.reject(erroDoBanco(codigo)) });
    const r = await h(pedido({ user_book_id: LIVRO }));
    assertEquals([r.status, (await r.json()).erro, pedidos.length], [status, codigo, 0]);
  }
});

Deno.test('caminhoRelativo: de URL absoluta ou relativa, só caminho + token', () => {
  assertEquals(
    caminhoRelativo('https://abc.supabase.co/storage/v1/object/sign/ebooks/a/b.epub?token=x'),
    '/storage/v1/object/sign/ebooks/a/b.epub?token=x',
  );
  assertEquals(caminhoRelativo('/storage/v1/object/sign/x?token=y'), '/storage/v1/object/sign/x?token=y');
});

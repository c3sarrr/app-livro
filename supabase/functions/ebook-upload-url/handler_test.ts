import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler, type Dependencias } from './handler.ts';

const USUARIO = '00000000-0000-7000-8000-00000000000a';
const LIVRO = '01927a00-0000-7000-8000-000000000a01';
const SHA = 'a'.repeat(64);
const pedido = (corpo: unknown, jwt = 'jwt-valido') =>
  new Request('http://local/ebook-upload-url', {
    method: 'POST',
    headers: { Authorization: `Bearer ${jwt}` },
    body: JSON.stringify(corpo),
  });
const erroDoBanco = (codigo: string) => Object.assign(new Error(codigo), { code: 'P0001' });

function fakes(s: Partial<Dependencias> = {}) {
  const d: Dependencias = {
    verificarJwt: (jwt) => Promise.resolve(jwt === 'jwt-valido' ? USUARIO : null),
    reservar: (u, l, sha) => Promise.resolve(`${u}/${l}/${sha}.epub`),
    urlAssinada: (c) => Promise.resolve({ signedUrl: `http://storage/upload/${c}?token=t`, token: 't' }),
    ...s,
  };
  return criarHandler(d);
}

Deno.test('Pro com o livro certo: devolve o caminho e a URL assinada', async () => {
  const r = await fakes()(pedido({ user_book_id: LIVRO, sha256: SHA.toUpperCase(), bytes: 1048576 }));
  assertEquals(r.status, 200);
  const j = await r.json();
  assertEquals(j.path, `${USUARIO}/${LIVRO}/${SHA}.epub`);
  assertEquals(j.token, 't');
});

Deno.test('sem login → 401; pedido malformado → 400', async () => {
  assertEquals((await fakes()(pedido({ user_book_id: LIVRO, sha256: SHA, bytes: 1 }, 'x'))).status, 401);
  for (
    const c of [{ user_book_id: 'x', sha256: SHA, bytes: 1 }, {
      user_book_id: LIVRO,
      sha256: 'curto',
      bytes: 1,
    }, { user_book_id: LIVRO, sha256: SHA, bytes: 0 }]
  ) {
    assertEquals((await fakes()(pedido(c))).status, 400);
  }
});

Deno.test('regras do banco viram o código HTTP certo (e não emitem URL)', async () => {
  const casos: [string, number][] = [['pro_required', 403], ['book_not_found', 404], ['sha_mismatch', 409], [
    'quota_exceeded',
    413,
  ]];
  for (const [codigo, status] of casos) {
    let emitiu = false;
    const h = fakes({
      reservar: () => Promise.reject(erroDoBanco(codigo)),
      urlAssinada: () => {
        emitiu = true;
        return Promise.resolve({ signedUrl: '', token: '' });
      },
    });
    const r = await h(pedido({ user_book_id: LIVRO, sha256: SHA, bytes: 10 }));
    assertEquals([r.status, (await r.json()).erro, emitiu], [status, codigo, false]);
  }
});

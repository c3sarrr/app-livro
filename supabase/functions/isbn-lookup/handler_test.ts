import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { COTA_GRATIS, COTA_PRO, criarHandler, type Dependencias } from './handler.ts';

const USUARIO = '00000000-0000-7000-8000-00000000000b';
const livro = {
  isbn13: '9788535910667',
  title: 'Dom Casmurro',
  subtitle: null,
  authors: ['Machado de Assis'],
  publisher: null,
  published_year: 1899,
  pages: null,
  language: null,
  cover_url: null,
  source: 'brasilapi' as const,
};

function fakes(s: Partial<Dependencias> = {}) {
  const cotas: number[] = [];
  const logs: Record<string, unknown>[] = [];
  const d: Dependencias = {
    verificarJwt: (jwt) => Promise.resolve(jwt === 'jwt-valido' ? USUARIO : null),
    ehPro: () => Promise.resolve(false),
    consumirCota: (_u, limite) => {
      cotas.push(limite);
      return Promise.resolve(true);
    },
    fontes: () => [() => Promise.resolve(livro)],
    registrar: (e) => logs.push(e),
    ...s,
  };
  return { handler: criarHandler(d), cotas, logs };
}
const pedido = (isbn: unknown, jwt = 'jwt-valido') =>
  new Request('http://local/isbn-lookup', {
    method: 'POST',
    headers: { Authorization: `Bearer ${jwt}` },
    body: JSON.stringify({ isbn }),
  });

Deno.test('sem login → 401; ISBN inválido → 400 (sem gastar cota)', async () => {
  const { handler, cotas } = fakes();
  assertEquals((await handler(pedido('9788535910667', 'forjado'))).status, 401);
  assertEquals((await handler(pedido('123'))).status, 400);
  assertEquals(cotas, []);
});

Deno.test('achou: 200 com o livro; Grátis usa a cota de 30, Pro a de 150', async () => {
  const g = fakes();
  const r = await g.handler(pedido('85-359-1066-2'));
  assertEquals(r.status, 200);
  assertEquals((await r.json()).livro.title, 'Dom Casmurro');
  assertEquals(g.cotas, [COTA_GRATIS]);
  const p = fakes({ ehPro: () => Promise.resolve(true) });
  await p.handler(pedido('9788535910667'));
  assertEquals(p.cotas, [COTA_PRO]);
});

Deno.test('cota esgotada → 429 sem consultar fonte nenhuma', async () => {
  let consultou = false;
  const { handler } = fakes({
    consumirCota: () => Promise.resolve(false),
    fontes: () => [() => {
      consultou = true;
      return Promise.resolve(livro);
    }],
  });
  assertEquals((await handler(pedido('9788535910667'))).status, 429);
  assertEquals(consultou, false);
});

Deno.test('não achou → 404; fontes fora do ar → 503', async () => {
  assertEquals(
    (await fakes({ fontes: () => [() => Promise.resolve(null)] }).handler(pedido('9788535910667'))).status,
    404,
  );
  assertEquals(
    (await fakes({ fontes: () => [() => Promise.reject(new Error('x'))] }).handler(pedido('9788535910667')))
      .status,
    503,
  );
});

Deno.test('log estruturado: região, prefixo e fontes tentadas — sem a conta e sem o ISBN inteiro', async () => {
  const { handler, logs } = fakes({
    fontes: () => [
      Object.assign(() => Promise.reject(new Error('fora')), { nome: 'brasilapi:br' }),
      Object.assign(() => Promise.resolve({ ...livro, provider: 'cbl' }), { nome: 'brasilapi:global' }),
    ],
  });
  assertEquals((await handler(pedido('9788535910667'))).status, 200);
  assertEquals(logs.length, 1);
  const e = logs[0];
  assertEquals([e.fn, e.regiao, e.prefixo, e.resultado, e.provider], [
    'isbn-lookup',
    'BR',
    '97885',
    'encontrado',
    'cbl',
  ]);
  assertEquals(
    (e.tentativas as { fonte: string; resultado: string }[]).map((t) => `${t.fonte}=${t.resultado}`),
    [
      'brasilapi:br=falhou',
      'brasilapi:global=achou',
    ],
  );
  const texto = JSON.stringify(e);
  assertEquals(texto.includes(USUARIO) || texto.includes('9788535910667'), false);
});

Deno.test('as fontes são escolhidas pelo ISBN pedido (já normalizado)', async () => {
  const pedidos: string[] = [];
  const { handler } = fakes({
    fontes: (isbn) => {
      pedidos.push(isbn);
      return [() => Promise.resolve(livro)];
    },
  });
  await handler(pedido('85-359-1066-2'));
  assertEquals(pedidos, ['9788535910667']);
});

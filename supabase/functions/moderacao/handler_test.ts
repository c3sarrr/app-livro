import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler, type Dependencias } from './handler.ts';

const MODERADORA = '00000000-0000-7000-8000-0000000000a1';
const OUTRA = '00000000-0000-7000-8000-0000000000b2';
const DENUNCIA = '00000000-0000-7000-8000-00000000d001';
const ORIGEM = 'https://moderacao.booknest.app.br';

const pedido = (corpo: unknown, jwt: string | null = 'jwt-moderadora', origem?: string, metodo = 'POST') =>
  new Request('http://local/moderacao', {
    method: metodo,
    headers: {
      ...(jwt ? { Authorization: `Bearer ${jwt}` } : {}),
      ...(origem ? { Origin: origem } : {}),
    },
    body: metodo === 'POST' ? JSON.stringify(corpo) : undefined,
  });

function fakes(s: Partial<Dependencias> = {}) {
  const decisoes: string[] = [];
  const h = criarHandler({
    origemWeb: ORIGEM,
    verificarJwt: (j) =>
      Promise.resolve(j === 'jwt-moderadora' ? MODERADORA : j === 'jwt-outra' ? OUTRA : null),
    ehModerador: (id) => Promise.resolve(id === MODERADORA),
    fila: () =>
      Promise.resolve([{ id: DENUNCIA, target_type: 'club_post', content: 'texto', sla_breached: true }]),
    decidir: (denuncia, decisao, moderadora, nota) => {
      decisoes.push(`${denuncia}:${decisao}:${moderadora}:${nota}`);
      return Promise.resolve();
    },
    ...s,
  });
  return { h, decisoes };
}

Deno.test('a fila: a moderadora lê as denúncias abertas com o conteúdo', async () => {
  const { h } = fakes();
  const r = await h(pedido({ acao: 'fila' }));
  assertEquals([r.status, await r.json()], [200, {
    itens: [{ id: DENUNCIA, target_type: 'club_post', content: 'texto', sla_breached: true }],
  }]);
});

Deno.test('sem login → 401; login de quem não modera → 403; nada é decidido', async () => {
  const { h, decisoes } = fakes();
  assertEquals((await h(pedido({ acao: 'fila' }, null))).status, 401);
  assertEquals((await h(pedido({ acao: 'fila' }, 'forjado'))).status, 401);
  const r = await h(pedido({ acao: 'decidir', report: DENUNCIA, decision: 'hide' }, 'jwt-outra'));
  assertEquals([r.status, await r.json()], [403, { erro: 'nao_moderador' }]);
  assertEquals(decisoes, []);
});

Deno.test('decidir: esconder ou manter, com a nota e o id de quem decidiu', async () => {
  const { h, decisoes } = fakes();
  const r1 = await h(pedido({ acao: 'decidir', report: DENUNCIA, decision: 'hide', note: '  Ofensa.  ' }));
  const r2 = await h(pedido({ acao: 'decidir', report: DENUNCIA, decision: 'dismiss' }));
  assertEquals([r1.status, r2.status], [200, 200]);
  assertEquals(decisoes, [
    `${DENUNCIA}:hide:${MODERADORA}:Ofensa.`,
    `${DENUNCIA}:dismiss:${MODERADORA}:null`,
  ]);
});

Deno.test('pedido inválido → 400 (decisão, denúncia, ação, corpo)', async () => {
  const { h, decisoes } = fakes();
  const codigos = async (corpo: unknown) => {
    const r = await h(pedido(corpo));
    return [r.status, ((await r.json()) as { erro: string }).erro];
  };
  assertEquals(await codigos({ acao: 'decidir', report: DENUNCIA, decision: 'apagar' }), [
    400,
    'decisao_invalida',
  ]);
  assertEquals(await codigos({ acao: 'decidir', report: 'x', decision: 'hide' }), [400, 'denuncia_invalida']);
  assertEquals(await codigos({ acao: 'outra' }), [400, 'acao_invalida']);
  assertEquals(await codigos('texto'), [400, 'acao_invalida']);
  assertEquals(decisoes, []);
});

Deno.test('denúncia já decidida por outra pessoa → 409', async () => {
  const { h } = fakes({ decidir: () => Promise.reject({ code: 'P0001', message: 'report_not_open' }) });
  const r = await h(pedido({ acao: 'decidir', report: DENUNCIA, decision: 'hide' }));
  assertEquals([r.status, await r.json()], [409, { erro: 'ja_decidida' }]);
});

Deno.test('falha do banco → 500, sem estourar sem resposta', async () => {
  const { h } = fakes({ fila: () => Promise.reject(new Error('banco fora')) });
  assertEquals((await h(pedido({ acao: 'fila' }))).status, 500);
});

Deno.test('só POST (e o OPTIONS da página)', async () => {
  const { h } = fakes();
  assertEquals((await h(pedido(null, 'jwt-moderadora', undefined, 'GET'))).status, 405);
});

Deno.test('CORS só para a origem da página do painel', async () => {
  const { h } = fakes();
  const pre = await h(
    new Request('http://local/moderacao', { method: 'OPTIONS', headers: { Origin: ORIGEM } }),
  );
  assertEquals([pre.status, pre.headers.get('Access-Control-Allow-Origin')], [204, ORIGEM]);
  const daPagina = await h(pedido({ acao: 'fila' }, 'jwt-moderadora', ORIGEM));
  assertEquals(daPagina.headers.get('Access-Control-Allow-Origin'), ORIGEM);
  const deOutra = await h(pedido({ acao: 'fila' }, 'jwt-moderadora', 'https://outro.site'));
  assertEquals(deOutra.headers.get('Access-Control-Allow-Origin'), null);
});

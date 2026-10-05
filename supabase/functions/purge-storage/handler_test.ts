import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler } from './handler.ts';

const pedido = (chave = 'k') =>
  new Request('http://local/purge-storage', { method: 'POST', headers: { apikey: chave } });

Deno.test('apaga a pasta de cada conta da fila e marca; falha fica registrada para tentar de novo', async () => {
  const log: string[] = [];
  const h = criarHandler({
    chavesAceitas: ['k'],
    reservar: () =>
      Promise.resolve([{ user_id: 'u1', reason: 'retention' }, { user_id: 'u2', reason: 'account_deleted' }]),
    apagarPasta: (u) => u === 'u2' ? Promise.reject(new Error('storage 500')) : Promise.resolve(3),
    concluir: (u, e) => {
      log.push(`${u}:${e ?? 'ok'}`);
      return Promise.resolve();
    },
    reservarAvulsos: () => Promise.resolve([]),
    apagarArquivos: () => Promise.resolve(),
    concluirAvulso: () => Promise.resolve(),
  });
  assertEquals((await h(pedido('x'))).status, 401);
  assertEquals(await (await h(pedido())).json(), {
    contas: 1,
    arquivos: 3,
    falhas: 1,
    avulsos: 0,
    falhas_avulsos: 0,
  });
  assertEquals(log, ['u1:ok', 'u2:storage 500']);
});

Deno.test('G06: arquivos avulsos (livro apagado ou trocado) saem em lote; falha do lote fica registrada', async () => {
  const caminhos = Array.from({ length: 150 }, (_, i) => `u/l${i}/x.epub`);
  const montar = (falhar: boolean) => {
    const log: string[] = [];
    const h = criarHandler({
      chavesAceitas: ['k'],
      reservar: () => Promise.resolve([]),
      apagarPasta: () => Promise.resolve(0),
      concluir: () => Promise.resolve(),
      reservarAvulsos: (n) => Promise.resolve(caminhos.slice(0, n)),
      apagarArquivos: (cs) => {
        log.push(`apagar ${cs.length}`);
        return falhar ? Promise.reject(new Error('storage 503')) : Promise.resolve();
      },
      concluirAvulso: (c, e) => {
        if (c === 'u/l0/x.epub') log.push(`${c}:${e ?? 'ok'}`);
        return Promise.resolve();
      },
    });
    return { h, log };
  };
  const ok = montar(false);
  assertEquals((await (await ok.h(pedido())).json()).avulsos, 100);
  assertEquals(ok.log, ['apagar 100', 'u/l0/x.epub:ok']);
  const ruim = montar(true);
  assertEquals((await (await ruim.h(pedido())).json()).falhas_avulsos, 100);
  assertEquals(ruim.log, ['apagar 100', 'u/l0/x.epub:storage 503']);
});

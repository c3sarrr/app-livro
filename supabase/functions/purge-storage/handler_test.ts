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
  });
  assertEquals((await h(pedido('x'))).status, 401);
  assertEquals(await (await h(pedido())).json(), { contas: 1, arquivos: 3, falhas: 1 });
  assertEquals(log, ['u1:ok', 'u2:storage 500']);
});

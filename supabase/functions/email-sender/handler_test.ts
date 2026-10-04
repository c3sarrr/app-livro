import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { criarHandler, type Dependencias, type EmailPendente } from './handler.ts';
import { montar } from './modelos.ts';

const pedido = (chave = 'chave-agendador') =>
  new Request('http://local/email-sender', { method: 'POST', headers: { apikey: chave } });
function fakes(fila: EmailPendente[], s: Partial<Dependencias> = {}) {
  const log: string[] = [];
  const h = criarHandler({
    chavesAceitas: ['chave-agendador'],
    configurado: true,
    reservar: () => {
      log.push('reservar');
      return Promise.resolve(fila);
    },
    concluir: (id, e) => {
      log.push(`concluir:${id}:${e ?? 'ok'}`);
      return Promise.resolve();
    },
    enviar: (para, assunto) => {
      log.push(`enviar:${para}:${assunto}`);
      return Promise.resolve();
    },
    ...s,
  });
  return { h, log };
}

Deno.test('só o agendador chama (apikey); sem e-mail configurado não gasta tentativas', async () => {
  const a = fakes([]);
  assertEquals((await a.h(pedido('outra'))).status, 401);
  assertEquals((await a.h(new Request('http://local/email-sender', { method: 'POST' }))).status, 401);
  const b = fakes([], { configurado: false });
  assertEquals((await b.h(pedido())).status, 503);
  assertEquals([...a.log, ...b.log], []);
});

Deno.test('envia a fila e marca cada e-mail; sem endereço ou modelo desconhecido = falha registrada', async () => {
  const { h, log } = fakes([
    {
      id: '1',
      email: 'ana@exemplo.com',
      template: 'retention_warning',
      payload: { purge_after: '2027-10-04T00:00:00Z' },
    },
    { id: '2', email: null, template: 'welcome', payload: {} },
    { id: '3', email: 'bia@exemplo.com', template: 'inventado', payload: {} },
  ]);
  const r = await h(pedido());
  assertEquals(await r.json(), { enviados: 1, falhas: 2 });
  assertEquals(log, [
    'reservar',
    'enviar:ana@exemplo.com:Seus dados de leitura na nuvem serão apagados',
    'concluir:1:ok',
    'concluir:2:sem_email',
    'concluir:3:modelo_desconhecido:inventado',
  ]);
});

Deno.test('erro do provedor fica registrado (a fila tenta de novo, até 5 vezes)', async () => {
  const { h, log } = fakes([{ id: '9', email: 'x@exemplo.com', template: 'welcome', payload: {} }], {
    enviar: () => Promise.reject(new Error('resend 500')),
  });
  assertEquals(await (await h(pedido())).json(), { enviados: 0, falhas: 1 });
  assertEquals(log.at(-1), 'concluir:9:resend 500');
});

Deno.test('modelos: data do purge no fuso de Brasília', () => {
  assertEquals(
    montar('retention_warning', { purge_after: '2027-10-04T02:00:00Z' })!.texto.includes('03/10/2027'),
    true,
  );
  assertEquals(montar('nao_existe', {}), null);
});

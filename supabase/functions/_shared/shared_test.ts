import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import {
  chaveDoAgendadorValida,
  iguaisEmTempoConstante,
  segredoValido,
  tokenBearer,
  usuarioDoPedido,
} from './auth.ts';
import { codigoDoBanco, lerJson } from './http.ts';

const req = (h: Record<string, string>, corpo?: string) =>
  new Request('http://local/x', { method: 'POST', headers: h, body: corpo });

Deno.test('comparação em tempo constante', () => {
  assertEquals([
    iguaisEmTempoConstante('abc', 'abc'),
    iguaisEmTempoConstante('abc', 'abd'),
    iguaisEmTempoConstante('abc', 'abcd'),
    iguaisEmTempoConstante('', ''),
  ], [true, false, false, true]);
});

Deno.test('JWT do usuário: só "Bearer <token>"; verificação que falha = sem usuário', async () => {
  assertEquals(tokenBearer(req({ Authorization: 'Bearer abc.def' })), 'abc.def');
  assertEquals(tokenBearer(req({ Authorization: 'abc.def' })), null);
  assertEquals(await usuarioDoPedido(req({ Authorization: 'Bearer t' }), () => Promise.resolve('u1')), 'u1');
  assertEquals(
    await usuarioDoPedido(req({ Authorization: 'Bearer t' }), () => Promise.reject(new Error('jwks'))),
    null,
  );
  assertEquals(await usuarioDoPedido(req({}), () => Promise.resolve('u1')), null);
});

Deno.test('chave do agendador e segredo do webhook', () => {
  assertEquals(chaveDoAgendadorValida(req({ apikey: 'k2' }), ['k1', 'k2']), true);
  assertEquals(chaveDoAgendadorValida(req({ apikey: '' }), ['']), false);
  assertEquals(chaveDoAgendadorValida(req({}), ['k1']), false);
  assertEquals(segredoValido(req({ Authorization: 's' }), 's'), true);
  assertEquals(segredoValido(req({ Authorization: 's' }), undefined), false);
});

Deno.test('corpo JSON e erros de regra do banco', async () => {
  assertEquals(await lerJson(req({}, '')), {});
  assertEquals(await lerJson(req({}, '[1]')), null);
  assertEquals(await lerJson(req({}, '{x')), null);
  assertEquals(codigoDoBanco(Object.assign(new Error('pro_required'), { code: 'P0001' })), 'pro_required');
  assertEquals(codigoDoBanco(Object.assign(new Error('boom'), { code: '57014' })), null);
});

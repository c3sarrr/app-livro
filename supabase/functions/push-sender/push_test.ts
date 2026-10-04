import { deepStrictEqual as assertEquals, ok } from 'node:assert/strict';
import { enviar, jwtDaConta, limparCache, tokenDeAcesso } from './fcm.ts';
import { criarHandler } from './handler.ts';
import { mensagem, type Pendente } from './textos.ts';

async function contaDeTeste() {
  const par = await crypto.subtle.generateKey(
    {
      name: 'RSASSA-PKCS1-v1_5',
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: 'SHA-256',
    },
    true,
    ['sign', 'verify'],
  );
  const der = new Uint8Array(await crypto.subtle.exportKey('pkcs8', par.privateKey));
  // chave gerada AGORA (não é segredo); o cabeçalho PEM é montado para a varredura de segredos
  // (gitleaks) não confundir o código com uma chave colada no arquivo
  const cabecalho = (lado: 'BEGIN' | 'END') => `-----${lado} PRIVATE KEY-----`;
  const pem = `${cabecalho('BEGIN')}\n${btoa(String.fromCharCode(...der))}\n${cabecalho('END')}\n`;
  return {
    conta: {
      project_id: 'booknest-teste',
      client_email: 'push@booknest-teste.iam.gserviceaccount.com',
      private_key: pem,
    },
    publica: par.publicKey,
  };
}

Deno.test('JWT da conta de serviço: RS256 válido com escopo do FCM e validade de 1 h', async () => {
  const { conta, publica } = await contaDeTeste();
  const jwt = await jwtDaConta(conta, 1790000000);
  const [h, c, s] = jwt.split('.');
  const dec = (x: string) => JSON.parse(atob(x.replace(/-/g, '+').replace(/_/g, '/')));
  assertEquals(dec(h), { alg: 'RS256', typ: 'JWT' });
  assertEquals([dec(c).scope, dec(c).exp - dec(c).iat, dec(c).iss], [
    'https://www.googleapis.com/auth/firebase.messaging',
    3600,
    conta.client_email,
  ]);
  const assinatura = Uint8Array.from(
    atob(s.replace(/-/g, '+').replace(/_/g, '/') + '=='.slice(0, (4 - s.length % 4) % 4)),
    (x) => x.charCodeAt(0),
  );
  ok(
    await crypto.subtle.verify(
      'RSASSA-PKCS1-v1_5',
      publica,
      assinatura,
      new TextEncoder().encode(`${h}.${c}`),
    ),
  );
});

Deno.test('token de acesso é pedido uma vez e reaproveitado até perto de expirar', async () => {
  limparCache();
  const { conta } = await contaDeTeste();
  let pedidos = 0;
  const buscar = (() => {
    pedidos++;
    return Promise.resolve(new Response(JSON.stringify({ access_token: `t${pedidos}`, expires_in: 3600 })));
  }) as typeof fetch;
  assertEquals(await tokenDeAcesso(conta, buscar, 1000), 't1');
  assertEquals(await tokenDeAcesso(conta, buscar, 1000 + 3000), 't1');
  assertEquals(await tokenDeAcesso(conta, buscar, 1000 + 3550), 't2');
});

Deno.test('envio: 200 = ok; token não registrado = inválido; 5xx = erro', async () => {
  const resp = (status: number, corpo: unknown) =>
    (() => Promise.resolve(new Response(JSON.stringify(corpo), { status }))) as typeof fetch;
  const m = { titulo: 'BookNest', corpo: 'x', dados: {} };
  assertEquals(await enviar('p', 'a', 'tok', m, resp(200, { name: 'x' })), 'ok');
  assertEquals(
    await enviar('p', 'a', 'tok', m, resp(404, { error: { status: 'NOT_FOUND' } })),
    'token_invalido',
  );
  assertEquals(
    await enviar('p', 'a', 'tok', m, resp(400, { error: { status: 'INVALID_ARGUMENT' } })),
    'token_invalido',
  );
  let lancou = false;
  try {
    await enviar('p', 'a', 'tok', m, resp(503, { error: { status: 'UNAVAILABLE' } }));
  } catch {
    lancou = true;
  }
  assertEquals(lancou, true);
});

const pendente = (s: Partial<Pendente> = {}): Pendente => ({
  notification_id: 'n1',
  type: 'post_like',
  actor_handle: 'ana',
  club_name: null,
  payload: {},
  tokens: ['t1'],
  ...s,
});

Deno.test('textos por tipo de notificação', () => {
  assertEquals(mensagem(pendente()).corpo, '@ana curtiu sua resenha');
  assertEquals(
    mensagem(pendente({ type: 'follow', payload: { accepted: true } })).corpo,
    '@ana aceitou seu pedido para seguir',
  );
  assertEquals(
    mensagem(pendente({ type: 'club_meeting', actor_handle: null, club_name: 'Leitoras de Capitu' })).corpo,
    'O encontro de Leitoras de Capitu é amanhã',
  );
  assertEquals(mensagem(pendente()).dados, { notification_id: 'n1', type: 'post_like' });
});

Deno.test('handler: só o agendador; sem FCM não marca nada; token inválido é descartado', async () => {
  const log: string[] = [];
  const base = {
    chavesAceitas: ['k'],
    configurado: true,
    reservar: () => {
      log.push('reservar');
      return Promise.resolve([pendente({ tokens: ['bom', 'velho'] })]);
    },
    enviar: (t: string) => Promise.resolve(t === 'bom' ? 'ok' as const : 'token_invalido' as const),
    descartarToken: (t: string) => {
      log.push(`descartar:${t}`);
      return Promise.resolve();
    },
  };
  const pedido = (k = 'k') =>
    new Request('http://local/push-sender', { method: 'POST', headers: { apikey: k } });
  assertEquals((await criarHandler(base)(pedido('x'))).status, 401);
  assertEquals((await criarHandler({ ...base, configurado: false })(pedido())).status, 503);
  assertEquals(log, []);
  assertEquals(await (await criarHandler(base)(pedido())).json(), { enviados: 1, invalidos: 1, falhas: 0 });
  assertEquals(log, ['reservar', 'descartar:velho']);
});

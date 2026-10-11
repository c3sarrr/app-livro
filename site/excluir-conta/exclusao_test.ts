// Página web de pedido de exclusão (G05 — exigência do Google Play): a lógica sem o navegador.
import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { configurada, criarExclusao } from './exclusao.js';

type Chamada = { url: string; metodo: string; corpo: unknown; cabecalhos: Record<string, string> };

function servidor(respostas: Record<string, [number, unknown]>, semRede = false) {
  const chamadas: Chamada[] = [];
  const f = (url: string | URL | Request, init?: RequestInit): Promise<Response> => {
    const u = String(url);
    const cab = Object.fromEntries(new Headers(init?.headers).entries());
    chamadas.push({
      url: u,
      metodo: init?.method ?? 'GET',
      corpo: init?.body ? JSON.parse(String(init.body)) : null,
      cabecalhos: cab,
    });
    if (semRede) return Promise.reject(new TypeError('Failed to fetch'));
    const caminho = new URL(u).pathname;
    const [status, corpo] = respostas[caminho] ?? [404, { msg: 'nao programado' }];
    return Promise.resolve(
      new Response(corpo === null ? null : JSON.stringify(corpo), {
        status,
        headers: { 'Content-Type': 'application/json' },
      }),
    );
  };
  return { f, chamadas };
}

const URL_BASE = 'https://projeto.supabase.co';
const CHAVE = 'sb_publishable_teste';
const OK = {
  '/auth/v1/otp': [200, {}] as [number, unknown],
  '/auth/v1/verify': [200, { access_token: 'jwt-da-conta', token_type: 'bearer' }] as [number, unknown],
  '/functions/v1/delete-account': [200, { excluida: true, ebooks_apagados: 0 }] as [number, unknown],
};

Deno.test('configurada: URL https (ou o Supabase local) e chave pública preenchidas', () => {
  assertEquals(configurada({ supabaseUrl: URL_BASE, chavePublica: CHAVE }), true);
  assertEquals(configurada({ supabaseUrl: 'http://127.0.0.1:54321', chavePublica: CHAVE }), true);
  assertEquals(configurada({ supabaseUrl: '<url>', chavePublica: CHAVE }), false);
  assertEquals(configurada({ supabaseUrl: URL_BASE, chavePublica: '<chave>' }), false);
  assertEquals(configurada({ supabaseUrl: 'http://projeto.supabase.co', chavePublica: CHAVE }), false);
});

Deno.test('pedir o código: não cria conta (create_user false) e manda a chave pública', async () => {
  const s = servidor(OK);
  const x = criarExclusao({ supabaseUrl: URL_BASE, chavePublica: CHAVE }, s.f);
  assertEquals(await x.pedirCodigo('  Leitora@Exemplo.com '), { ok: true });
  assertEquals(s.chamadas.length, 1);
  assertEquals(s.chamadas[0].url, `${URL_BASE}/auth/v1/otp`);
  assertEquals(s.chamadas[0].metodo, 'POST');
  assertEquals(s.chamadas[0].corpo, { email: 'leitora@exemplo.com', create_user: false });
  assertEquals(s.chamadas[0].cabecalhos['apikey'], CHAVE);
});

Deno.test('e-mail sem conta, também no formato antigo de erro do Auth (code numérico): resposta igual', async () => {
  for (
    const corpo of [
      { code: 422, error_code: 'otp_disabled', msg: 'Signups not allowed for otp' },
      { code: 400, error_code: 'user_not_found', msg: 'x' },
      { error: 'invalid_request', error_description: 'x' },
    ]
  ) {
    const s = servidor({ ...OK, '/auth/v1/otp': [corpo.code === 400 ? 400 : 422, corpo] });
    const x = criarExclusao({ supabaseUrl: URL_BASE, chavePublica: CHAVE }, s.f);
    assertEquals(await x.pedirCodigo('ninguem@exemplo.com'), { ok: true }, JSON.stringify(corpo));
    assertEquals(s.chamadas[0].cabecalhos['x-supabase-api-version'], '2024-01-01');
  }
});

Deno.test('e-mail sem conta: a resposta é a mesma de quem tem conta (não revela quem é cliente)', async () => {
  const s = servidor({
    ...OK,
    '/auth/v1/otp': [422, { code: 'otp_disabled', msg: 'Signups not allowed for otp' }],
  });
  const x = criarExclusao({ supabaseUrl: URL_BASE, chavePublica: CHAVE }, s.f);
  assertEquals(await x.pedirCodigo('ninguem@exemplo.com'), { ok: true });
});

Deno.test('e-mail inválido não vai para a rede; limite e falhas viram erros curtos', async () => {
  const s = servidor({ '/auth/v1/otp': [429, { code: 'over_email_send_rate_limit' }] });
  const x = criarExclusao({ supabaseUrl: URL_BASE, chavePublica: CHAVE }, s.f);
  assertEquals(await x.pedirCodigo('leitora@'), { erro: 'email_invalido' });
  assertEquals(s.chamadas.length, 0);
  assertEquals(await x.pedirCodigo('leitora@exemplo.com'), { erro: 'muitas_tentativas' });
  const caiu = servidor({}, true);
  const y = criarExclusao({ supabaseUrl: URL_BASE, chavePublica: CHAVE }, caiu.f);
  assertEquals(await y.pedirCodigo('leitora@exemplo.com'), { erro: 'rede' });
});

Deno.test('excluir: confere o código e chama delete-account com o JWT da própria conta e {confirmar: true}', async () => {
  const s = servidor(OK);
  const x = criarExclusao({ supabaseUrl: URL_BASE, chavePublica: CHAVE }, s.f);
  assertEquals(await x.excluir('leitora@exemplo.com', ' 123 456 '), { ok: true });
  assertEquals(s.chamadas.map((c) => new URL(c.url).pathname), [
    '/auth/v1/verify',
    '/functions/v1/delete-account',
  ]);
  assertEquals(s.chamadas[0].corpo, { email: 'leitora@exemplo.com', token: '123456', type: 'email' });
  assertEquals(s.chamadas[1].corpo, { confirmar: true });
  assertEquals(s.chamadas[1].cabecalhos['authorization'], 'Bearer jwt-da-conta');
});

Deno.test('código errado, fora do formato ou vencido → codigo_invalido; nada é excluído', async () => {
  const s = servidor({ ...OK, '/auth/v1/verify': [403, { code: 'otp_expired' }] });
  const x = criarExclusao({ supabaseUrl: URL_BASE, chavePublica: CHAVE }, s.f);
  assertEquals(await x.excluir('leitora@exemplo.com', '12a'), { erro: 'codigo_invalido' });
  assertEquals(s.chamadas.length, 0);
  assertEquals(await x.excluir('leitora@exemplo.com', '000000'), { erro: 'codigo_invalido' });
  assertEquals(s.chamadas.map((c) => new URL(c.url).pathname), ['/auth/v1/verify']);
});

Deno.test('falha na exclusão (ex.: RevenueCat fora do ar → 502) → erro servidor', async () => {
  const s = servidor({ ...OK, '/functions/v1/delete-account': [502, { erro: 'revenuecat_indisponivel' }] });
  const x = criarExclusao({ supabaseUrl: URL_BASE, chavePublica: CHAVE }, s.f);
  assertEquals(await x.excluir('leitora@exemplo.com', '123456'), { erro: 'servidor' });
});

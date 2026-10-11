// Painel de moderação (G21.2, D-52/D-220): a lógica sem o navegador.
import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { configurada, criarPainel, linhas } from './painel.js';

type Chamada = { caminho: string; corpo: unknown; cabecalhos: Record<string, string> };

function servidor(respostas: Record<string, [number, unknown] | [number, unknown][]>, semRede = false) {
  const chamadas: Chamada[] = [];
  const f = (url: string | URL | Request, init?: RequestInit): Promise<Response> => {
    const caminho = new URL(String(url)).pathname;
    chamadas.push({
      caminho,
      corpo: init?.body ? JSON.parse(String(init.body)) : null,
      cabecalhos: Object.fromEntries(new Headers(init?.headers).entries()),
    });
    if (semRede) return Promise.reject(new TypeError('Failed to fetch'));
    const r = respostas[caminho];
    const [status, corpo] = Array.isArray(r?.[0])
      ? (r as [number, unknown][]).shift()!
      : (r as [number, unknown]) ??
        [404, {}];
    return Promise.resolve(new Response(JSON.stringify(corpo), { status }));
  };
  return { f, chamadas };
}

const CFG = { supabaseUrl: 'https://projeto.supabase.co', chavePublica: 'sb_publishable_teste' };
const FILA = [
  {
    id: 'd1',
    target_type: 'club_post',
    reason: 'spam',
    content: 'O post do Caio.',
    age_hours: 25,
    sla_breached: true,
  },
  {
    id: 'd2',
    target_type: 'club_post_reply',
    reason: 'harassment',
    content: 'A resposta.',
    age_hours: 2,
    sla_breached: false,
  },
];

Deno.test('configurada: URL https (ou o Supabase local) e a chave pública', () => {
  assertEquals(configurada(CFG), true);
  assertEquals(configurada({ supabaseUrl: 'http://127.0.0.1:54321', chavePublica: 'x' }), true);
  assertEquals(configurada({ supabaseUrl: '<url>', chavePublica: 'x' }), false);
  assertEquals(configurada({ supabaseUrl: CFG.supabaseUrl, chavePublica: '<chave>' }), false);
});

Deno.test('entrar: código no e-mail sem criar conta, depois o JWT só na memória', async () => {
  const s = servidor({
    '/auth/v1/otp': [200, {}],
    '/auth/v1/verify': [200, { access_token: 'jwt-da-moderadora' }],
    '/functions/v1/moderacao': [200, { itens: FILA }],
  });
  const p = criarPainel(CFG, s.f);
  assertEquals(await p.pedirCodigo(' Ana@Exemplo.com '), { ok: true });
  assertEquals(s.chamadas[0].corpo, { email: 'ana@exemplo.com', create_user: false });
  assertEquals(await p.entrar('ana@exemplo.com', '123 456'), { ok: true });
  assertEquals(await p.fila(), { itens: FILA });
  assertEquals(s.chamadas[2].corpo, { acao: 'fila' });
  assertEquals(s.chamadas[2].cabecalhos.authorization, 'Bearer jwt-da-moderadora');
});

Deno.test('decidir: esconder e manter mandam a decisão e a nota', async () => {
  const s = servidor({
    '/auth/v1/verify': [200, { access_token: 'jwt' }],
    '/functions/v1/moderacao': [200, { decidida: true }],
  });
  const p = criarPainel(CFG, s.f);
  await p.entrar('ana@exemplo.com', '123456');
  assertEquals(await p.decidir('d1', 'hide', 'Ofensa.'), { ok: true });
  assertEquals(await p.decidir('d2', 'dismiss', ''), { ok: true });
  assertEquals(s.chamadas.slice(1).map((c) => c.corpo), [
    { acao: 'decidir', report: 'd1', decision: 'hide', note: 'Ofensa.' },
    { acao: 'decidir', report: 'd2', decision: 'dismiss', note: '' },
  ]);
});

Deno.test('erros: já decidida (409), conta que não modera (403), sessão vencida (401), sem rede', async () => {
  const s = servidor({
    '/auth/v1/verify': [200, { access_token: 'jwt' }],
    '/functions/v1/moderacao': [[409, { erro: 'ja_decidida' }], [403, { erro: 'nao_moderador' }], [401, {}]],
  });
  const p = criarPainel(CFG, s.f);
  await p.entrar('ana@exemplo.com', '123456');
  assertEquals(await p.decidir('d1', 'hide', ''), { erro: 'ja_decidida' });
  assertEquals(await p.fila(), { erro: 'nao_moderador' });
  assertEquals(await p.fila(), { erro: 'sessao' });
  const semRede = criarPainel(CFG, servidor({}, true).f);
  assertEquals(await semRede.pedirCodigo('ana@exemplo.com'), { erro: 'rede' });
});

Deno.test('sem entrar, nada chama a função; código que não é de 6 dígitos nem vai ao Auth', async () => {
  const s = servidor({});
  const p = criarPainel(CFG, s.f);
  assertEquals(await p.fila(), { erro: 'sessao' });
  assertEquals(await p.entrar('ana@exemplo.com', '12'), { erro: 'codigo_invalido' });
  assertEquals(s.chamadas, []);
});

Deno.test('linhas: o tipo e o motivo em português, a idade e a marca de prazo vencido', () => {
  assertEquals(linhas(FILA), [
    {
      id: 'd1',
      tipo: 'Post no clube',
      motivo: 'Spam',
      texto: 'O post do Caio.',
      idade: 'há 25 h',
      atrasada: true,
    },
    {
      id: 'd2',
      tipo: 'Resposta no clube',
      motivo: 'Assédio',
      texto: 'A resposta.',
      idade: 'há 2 h',
      atrasada: false,
    },
  ]);
  assertEquals(
    linhas([{ id: 'x', target_type: 'profile', reason: 'other', content: null, age_hours: 0 }])[0],
    {
      id: 'x',
      tipo: 'Perfil',
      motivo: 'Outro',
      texto: '(conteúdo já removido)',
      idade: 'há menos de 1 h',
      atrasada: false,
    },
  );
});

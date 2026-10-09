// Painel de moderação pela web (G21.2 — D-52, D-220): quem modera entra com o código do e-mail da própria
// conta, vê a fila de denúncias abertas (com o conteúdo e o prazo de 24 h) e decide (esconder ou manter)
// pela Edge Function `moderacao`. Sem dependências: só `fetch`. O JWT fica só na memória da página.

const EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

/** A página só funciona com a URL do projeto (https, ou o Supabase local) e a chave PÚBLICA. */
export function configurada(cfg) {
  const url = String(cfg?.supabaseUrl ?? '');
  const chave = String(cfg?.chavePublica ?? '');
  const urlOk = url.startsWith('https://') || /^http:\/\/(127\.0\.0\.1|localhost):\d+$/.test(url);
  return urlOk && chave !== '' && !chave.startsWith('<') && !url.includes('<');
}

const TIPOS = {
  post: 'Resenha ou citação',
  post_comment: 'Comentário',
  club: 'Clube',
  club_post: 'Post no clube',
  club_post_reply: 'Resposta no clube',
  profile: 'Perfil',
};
const MOTIVOS = {
  spam: 'Spam',
  harassment: 'Assédio',
  hate: 'Ódio',
  sexual: 'Conteúdo sexual',
  spoiler: 'Spoiler',
  other: 'Outro',
};

/** A fila (já na ordem da mais antiga) em linhas para a tabela. */
export function linhas(itens) {
  return (itens ?? []).map((i) => ({
    id: i.id,
    tipo: TIPOS[i.target_type] ?? i.target_type,
    motivo: MOTIVOS[i.reason] ?? i.reason,
    texto: i.content ?? '(conteúdo já removido)',
    idade: Number(i.age_hours) >= 1 ? `há ${Number(i.age_hours)} h` : 'há menos de 1 h',
    atrasada: i.sla_breached === true,
  }));
}

async function lerCorpo(r) {
  try {
    return await r.json();
  } catch {
    return {};
  }
}

/**
 * @param {{supabaseUrl: string, chavePublica: string}} cfg
 * @param {typeof fetch} [f]
 */
export function criarPainel(cfg, f = globalThis.fetch.bind(globalThis)) {
  const base = cfg.supabaseUrl.replace(/\/+$/, '');
  let jwt = null;

  async function post(caminho, corpo, comJwt) {
    const cabecalhos = {
      apikey: cfg.chavePublica,
      'Content-Type': 'application/json',
      'X-Supabase-Api-Version': '2024-01-01',
    };
    if (comJwt) cabecalhos.Authorization = `Bearer ${jwt}`;
    try {
      const r = await f(`${base}${caminho}`, {
        method: 'POST',
        headers: cabecalhos,
        body: JSON.stringify(corpo),
      });
      return { status: r.status, corpo: await lerCorpo(r) };
    } catch {
      return { status: 0, corpo: {} };
    }
  }

  const erroDaFuncao = (r) =>
    r.status === 401
      ? { erro: 'sessao' }
      : r.status === 403
      ? { erro: 'nao_moderador' }
      : r.status === 409
      ? { erro: 'ja_decidida' }
      : r.status === 0
      ? { erro: 'rede' }
      : { erro: 'servidor' };

  async function funcao(corpo) {
    if (!jwt) return { status: 401, corpo: {} };
    return await post('/functions/v1/moderacao', corpo, true);
  }

  return {
    /** Envia o código para o e-mail (não cria conta). */
    async pedirCodigo(emailBruto) {
      const email = String(emailBruto ?? '').trim().toLowerCase();
      if (!EMAIL.test(email)) return { erro: 'email_invalido' };
      const r = await post('/auth/v1/otp', { email, create_user: false });
      if (r.status === 0) return { erro: 'rede' };
      return r.status === 429 ? { erro: 'muitas_tentativas' } : { ok: true };
    },

    /** Confere o código e guarda o JWT só na memória. */
    async entrar(emailBruto, codigoBruto) {
      const email = String(emailBruto ?? '').trim().toLowerCase();
      const token = String(codigoBruto ?? '').replace(/\s/g, '');
      if (!EMAIL.test(email)) return { erro: 'email_invalido' };
      if (!/^\d{6}$/.test(token)) return { erro: 'codigo_invalido' };
      const v = await post('/auth/v1/verify', { email, token, type: 'email' });
      if (v.status === 0) return { erro: 'rede' };
      if (v.status !== 200 || typeof v.corpo?.access_token !== 'string') return { erro: 'codigo_invalido' };
      jwt = v.corpo.access_token;
      return { ok: true };
    },

    async fila() {
      const r = await funcao({ acao: 'fila' });
      return r.status === 200 ? { itens: r.corpo?.itens ?? [] } : erroDaFuncao(r);
    },

    /** decisao: 'hide' (esconder) ou 'dismiss' (manter). */
    async decidir(denuncia, decisao, nota) {
      const r = await funcao({ acao: 'decidir', report: denuncia, decision: decisao, note: nota ?? '' });
      return r.status === 200 ? { ok: true } : erroDaFuncao(r);
    },
  };
}

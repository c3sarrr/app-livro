// Pedido de exclusão de conta pela web (G05 — exigência do Google Play): sem o app, a pessoa recebe um
// código no e-mail da conta e confirma; a página chama a MESMA Edge Function `delete-account` do app,
// com o JWT da própria conta. Sem dependências: só `fetch`.

const EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

/** A página só funciona com a URL do projeto (https, ou o Supabase local) e a chave PÚBLICA. */
export function configurada(cfg) {
  const url = String(cfg?.supabaseUrl ?? '');
  const chave = String(cfg?.chavePublica ?? '');
  const urlOk = url.startsWith('https://') || /^http:\/\/(127\.0\.0\.1|localhost):\d+$/.test(url);
  return urlOk && chave !== '' && !chave.startsWith('<') && !url.includes('<');
}

function normalizarEmail(bruto) {
  const e = String(bruto ?? '').trim().toLowerCase();
  return EMAIL.test(e) && e.length <= 254 ? e : null;
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
export function criarExclusao(cfg, f = globalThis.fetch.bind(globalThis)) {
  const base = cfg.supabaseUrl.replace(/\/+$/, '');

  async function post(caminho, corpo, jwt) {
    // a versão da API fixa o formato dos erros do Auth (`code` em texto)
    const cabecalhos = {
      apikey: cfg.chavePublica,
      'Content-Type': 'application/json',
      'X-Supabase-Api-Version': '2024-01-01',
    };
    if (jwt) cabecalhos.Authorization = `Bearer ${jwt}`;
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

  const erroComum = (status) =>
    status === 0 ? { erro: 'rede' } : status === 429 ? { erro: 'muitas_tentativas' } : { erro: 'servidor' };

  return {
    /** Envia o código. Mesma resposta com ou sem conta (não revela quem usa o BookNest). */
    async pedirCodigo(emailBruto) {
      const email = normalizarEmail(emailBruto);
      if (!email) return { erro: 'email_invalido' };
      const r = await post('/auth/v1/otp', { email, create_user: false });
      if (r.status >= 200 && r.status < 300) return { ok: true };
      const codigo = typeof r.corpo?.code === 'string' ? r.corpo.code : r.corpo?.error_code;
      if (codigo === 'email_address_invalid') return { erro: 'email_invalido' };
      // Qualquer outra recusa 4xx (e-mail sem conta, cadastro fechado…) responde igual ao sucesso:
      // a página não revela quem tem conta. Só o limite de pedidos e as falhas aparecem.
      if (r.status >= 400 && r.status < 500 && r.status !== 429) return { ok: true };
      return erroComum(r.status);
    },

    /** Confere o código e exclui a conta (imediato e definitivo). */
    async excluir(emailBruto, codigoBruto) {
      const email = normalizarEmail(emailBruto);
      if (!email) return { erro: 'email_invalido' };
      const token = String(codigoBruto ?? '').replace(/\s/g, '');
      if (!/^\d{6}$/.test(token)) return { erro: 'codigo_invalido' };
      const v = await post('/auth/v1/verify', { email, token, type: 'email' });
      if (v.status === 403 || v.status === 401 || (v.status === 400 && v.corpo?.code !== undefined)) {
        return { erro: 'codigo_invalido' };
      }
      const jwt = v.corpo?.access_token;
      if (v.status !== 200 || typeof jwt !== 'string') return erroComum(v.status);
      const d = await post('/functions/v1/delete-account', { confirmar: true }, jwt);
      if (d.status === 200) return { ok: true };
      return erroComum(d.status);
    },
  };
}

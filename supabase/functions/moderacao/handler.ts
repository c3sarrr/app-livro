// Edge Function `moderacao` (D-52, D-220): o painel de moderação (site/moderacao/) lê a fila de denúncias
// e decide. Só quem está em private.moderators: a sessão é conferida no Auth e o id, na lista. Tudo por
// POST, como a exclusão de conta (o CORS libera só a origem da página): {"acao": "fila"} devolve as
// denúncias abertas com o conteúdo; {"acao": "decidir", "report", "decision": "hide"|"dismiss", "note"}
// decide pelo private.moderate_report. Responde JSON (o domínio padrão das Edge Functions não serve HTML).
import { usuarioDoPedido } from '../_shared/auth.ts';
import { codigoDoBanco, corsPara, erro, exigeMetodo, json, lerJson, UUID } from '../_shared/http.ts';

export type Decisao = 'hide' | 'dismiss';

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  ehModerador(id: string): Promise<boolean>;
  fila(): Promise<unknown[]>;
  decidir(denuncia: string, decisao: Decisao, moderadora: string, nota: string | null): Promise<void>;
  /** Origem da página do painel (CORS); sem ela, a página não chama a função. */
  origemWeb?: string | null;
};

export function criarHandler(d: Dependencias) {
  const responder = criarPainel(d);
  return async (req: Request): Promise<Response> => {
    const cors = corsPara(req, d.origemWeb);
    if (req.method === 'OPTIONS' && cors) return new Response(null, { status: 204, headers: cors });
    let r: Response;
    try {
      r = await responder(req);
    } catch {
      r = erro(500, 'falha_na_moderacao'); // nunca estoura sem resposta (e sem CORS, para a página)
    }
    if (cors) { for (const [k, v] of Object.entries(cors)) r.headers.set(k, v); }
    return r;
  };
}

function criarPainel(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    const id = await usuarioDoPedido(req, d.verificarJwt);
    if (!id) return erro(401, 'nao_autenticado');
    if (!(await d.ehModerador(id))) return erro(403, 'nao_moderador');
    const c = await lerJson(req);
    if (c?.acao === 'fila') return json(200, { itens: await d.fila() });
    if (c?.acao !== 'decidir') return erro(400, 'acao_invalida');
    if (typeof c.report !== 'string' || !UUID.test(c.report)) return erro(400, 'denuncia_invalida');
    if (c.decision !== 'hide' && c.decision !== 'dismiss') return erro(400, 'decisao_invalida');
    const nota = typeof c.note === 'string' && c.note.trim() !== '' ? c.note.trim().slice(0, 1000) : null;
    try {
      await d.decidir(c.report, c.decision, id, nota);
    } catch (e) {
      if (codigoDoBanco(e) === 'report_not_open') return erro(409, 'ja_decidida');
      throw e;
    }
    return json(200, { decidida: true });
  };
}

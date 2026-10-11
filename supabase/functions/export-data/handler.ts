// Edge Function `export-data` (LGPD — portabilidade; D-24): devolve, em JSON, tudo o que o SERVIDOR
// guarda sobre quem pede (public.export_my_data, como o próprio usuário — RLS e cota de 3/dia).
// O que só existe no aparelho (Grátis) o app exporta localmente.
import { usuarioDoPedido } from '../_shared/auth.ts';
import { erro, exigeMetodo, json } from '../_shared/http.ts';

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  exportar(jwt: string): Promise<{ dados?: unknown; erro?: string }>;
  hoje?: () => string;
};

export function criarHandler(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    const usuario = await usuarioDoPedido(req, d.verificarJwt);
    if (!usuario) return erro(401, 'nao_autenticado');
    const jwt = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
    const r = await d.exportar(jwt);
    if (r.erro === 'quota_exceeded') return erro(429, 'limite_diario_de_exportacoes');
    if (r.erro || r.dados == null) return erro(500, 'falha_na_exportacao');
    const resp = json(200, r.dados);
    const dia = (d.hoje ?? (() => new Date().toISOString().slice(0, 10)))();
    resp.headers.set('Content-Disposition', `attachment; filename="booknest-meus-dados-${dia}.json"`);
    return resp;
  };
}

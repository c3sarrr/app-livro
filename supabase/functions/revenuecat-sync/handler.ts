// Edge Function `revenuecat-sync` ("conferir agora", D-229 — docs/progresso/G22.md §1): com a sessão da pessoa,
// busca o estado DELA na API do RevenueCat e aplica pelo mesmo SQL do webhook (private.rc_apply_subscriber), com a
// hora da busca (um estado mais velho que o último aplicado é ignorado pelo banco). Até 30 por dia por conta.
import { usuarioDoPedido } from '../_shared/auth.ts';
import { codigoDoBanco, erro, exigeMetodo, json } from '../_shared/http.ts';
import { type Assinatura, type AssinaturaRc, normalizarAssinante } from '../revenuecat-webhook/revenuecat.ts';

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  cota(userId: string): Promise<boolean>;
  assinante(appUserId: string): Promise<{ subscriptions?: Record<string, AssinaturaRc> } | null>;
  aplicar(
    userId: string,
    assinaturas: Assinatura[],
    buscadoEm: Date,
  ): Promise<{ pro: boolean; active_until: string | null }>;
  agora?: () => number;
};

export function criarHandler(d: Dependencias) {
  const agora = d.agora ?? Date.now;
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    const usuario = await usuarioDoPedido(req, d.verificarJwt);
    if (!usuario) return erro(401, 'nao_autenticado');
    let dentroDaCota: boolean;
    try {
      dentroDaCota = await d.cota(usuario);
    } catch (e) {
      // a conta excluída com o JWT ainda válido: a cota grava com chave estrangeira para auth.users (revisão, m1)
      if ((e as { code?: string } | null)?.code === '23503') return erro(404, 'conta_inexistente');
      return erro(500, 'falha_na_cota');
    }
    if (!dentroDaCota) return erro(429, 'limite_diario');
    const buscadoEm = new Date(agora());
    let assinante: Awaited<ReturnType<Dependencias['assinante']>>;
    try {
      assinante = await d.assinante(usuario);
    } catch {
      return erro(502, 'revenuecat_indisponivel');
    }
    try {
      const r = await d.aplicar(usuario, normalizarAssinante(assinante, agora()), buscadoEm);
      return json(200, { pro: r.pro, active_until: r.active_until });
    } catch (e) {
      if (codigoDoBanco(e) === 'unknown_user') return erro(404, 'conta_inexistente');
      return erro(500, 'falha_ao_aplicar');
    }
  };
}

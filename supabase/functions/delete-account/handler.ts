// Edge Function `delete-account` (Anexo 04 §8; G05 liga a tela): exclusão IMEDIATA da conta, mesmo
// dentro dos 12 meses de retenção (LGPD). Ordem: assinante no RevenueCat → e-books no Storage →
// usuário no Auth (o DELETE em cascata apaga perfil, social, assinatura e dados pessoais; a fila de
// limpeza do Storage cobre o que sobrar). Se o RevenueCat falhar, nada é apagado (o app tenta de novo).
import { usuarioDoPedido } from '../_shared/auth.ts';
import { erro, exigeMetodo, json, lerJson } from '../_shared/http.ts';

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  apagarAssinante(userId: string): Promise<void>;
  apagarEbooks(userId: string): Promise<number>;
  apagarUsuario(userId: string): Promise<void>;
};

export function criarHandler(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    const usuario = await usuarioDoPedido(req, d.verificarJwt);
    if (!usuario) return erro(401, 'nao_autenticado');
    const c = await lerJson(req);
    if (c?.confirmar !== true) return erro(400, 'confirmacao_obrigatoria');
    try {
      await d.apagarAssinante(usuario);
    } catch {
      return erro(502, 'revenuecat_indisponivel');
    }
    let ebooks = 0;
    try {
      ebooks = await d.apagarEbooks(usuario);
    } catch {
      // segue: a fila private.storage_purge_queue (gatilho na exclusão do usuário) apaga depois
    }
    await d.apagarUsuario(usuario);
    return json(200, { excluida: true, ebooks_apagados: ebooks });
  };
}

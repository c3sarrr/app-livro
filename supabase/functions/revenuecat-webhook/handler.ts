// Edge Function `revenuecat-webhook` (Anexo 04 §5). Fluxo:
// 1. Authorization = segredo configurado no RevenueCat (senão 401);
// 2. idempotência por event.id (billing.webhook_events): 'done' → 200 sem refazer;
// 3. estado ATUAL de cada assinante na API do RevenueCat (não confia na ordem dos eventos) — no
//    TRANSFER (que não traz app_user_id) são as contas de `transferred_from` e `transferred_to`;
// 4. grava assinaturas + direito "pro" + acesso ao sync (private.rc_apply_subscriber) com a hora da
//    busca: um estado buscado antes do último aplicado é ignorado pelo banco (webhooks em paralelo);
// 5. marca o evento; em erro grava o erro e responde 500 (o RevenueCat reenvia). Conta que não
//    existe mais no app (unknown_user) é pulada.
import { segredoValido } from '../_shared/auth.ts';
import { codigoDoBanco, erro, exigeMetodo, json, lerJson, UUID } from '../_shared/http.ts';
import { type Assinatura, type AssinaturaRc, normalizarAssinante } from './revenuecat.ts';

export type Dependencias = {
  segredo: string | undefined;
  inicioDoEvento(evento: Record<string, unknown>): Promise<'new' | 'retry' | 'done'>;
  fimDoEvento(id: string, erro?: string): Promise<void>;
  assinante(appUserId: string): Promise<{ subscriptions?: Record<string, AssinaturaRc> } | null>;
  aplicar(
    userId: string,
    assinaturas: Assinatura[],
    quando: Date,
    buscadoEm: Date,
  ): Promise<{ pro: boolean }>;
  agora?: () => number;
};

/** Contas do app (UUID) envolvidas no evento — ids anônimos do RevenueCat ficam de fora. */
export function contasDoEvento(evento: Record<string, unknown>): string[] {
  const lista = (v: unknown) => (Array.isArray(v) ? v : []).map(String);
  const ids = evento.type === 'TRANSFER'
    ? [...lista(evento.transferred_from), ...lista(evento.transferred_to)]
    : [String(evento.app_user_id ?? '')];
  return [...new Set(ids.filter((id) => UUID.test(id)))];
}

export function criarHandler(d: Dependencias) {
  const agora = d.agora ?? Date.now;
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    if (!segredoValido(req, d.segredo)) return erro(401, 'nao_autorizado');
    const corpo = await lerJson(req);
    const evento = corpo?.event as Record<string, unknown> | undefined;
    if (!evento || typeof evento.id !== 'string' || evento.id === '') return erro(400, 'evento_invalido');
    const id = evento.id;

    if (await d.inicioDoEvento(evento) === 'done') return json(200, { status: 'duplicado' });
    try {
      const contas = evento.type === 'TEST' ? [] : contasDoEvento(evento);
      const quando = typeof evento.event_timestamp_ms === 'number'
        ? new Date(evento.event_timestamp_ms)
        : new Date(agora());
      let aplicadas = 0;
      let pro = false;
      for (const conta of contas) {
        const buscadoEm = new Date(agora());
        const assinante = await d.assinante(conta);
        try {
          pro = (await d.aplicar(conta, normalizarAssinante(assinante, agora()), quando, buscadoEm)).pro;
          aplicadas++;
        } catch (e) {
          if (codigoDoBanco(e) !== 'unknown_user') throw e; // conta excluída do app: nada a fazer
        }
      }
      await d.fimDoEvento(id);
      // evento de teste do painel, usuário anônimo do RevenueCat ou conta que não existe mais
      if (aplicadas === 0) return json(200, { status: 'ignorado' });
      return json(
        200,
        evento.type === 'TRANSFER'
          ? { status: 'processado', usuarios: aplicadas }
          : { status: 'processado', pro },
      );
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      await d.fimDoEvento(id, msg.slice(0, 500));
      return erro(500, 'falha_ao_processar');
    }
  };
}

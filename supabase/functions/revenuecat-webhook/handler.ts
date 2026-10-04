// Edge Function `revenuecat-webhook` (Anexo 04 §5). Fluxo:
// 1. Authorization = segredo configurado no RevenueCat (senão 401);
// 2. idempotência por event.id (billing.webhook_events): 'done' → 200 sem refazer;
// 3. estado ATUAL do assinante na API do RevenueCat (não confia na ordem dos eventos);
// 4. grava assinaturas + direito "pro" + acesso ao sync (private.rc_apply_subscriber);
// 5. marca o evento; em erro grava o erro e responde 500 (o RevenueCat reenvia).
import { segredoValido } from '../_shared/auth.ts';
import { erro, exigeMetodo, json, lerJson, UUID } from '../_shared/http.ts';
import { type Assinatura, type AssinaturaRc, normalizarAssinante } from './revenuecat.ts';

export type Dependencias = {
  segredo: string | undefined;
  inicioDoEvento(evento: Record<string, unknown>): Promise<'new' | 'retry' | 'done'>;
  fimDoEvento(id: string, erro?: string): Promise<void>;
  assinante(appUserId: string): Promise<{ subscriptions?: Record<string, AssinaturaRc> } | null>;
  aplicar(userId: string, assinaturas: Assinatura[], quando: Date): Promise<{ pro: boolean }>;
  agora?: () => number;
};

export function criarHandler(d: Dependencias) {
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
      const appUserId = String(evento.app_user_id ?? '');
      if (evento.type === 'TEST' || !UUID.test(appUserId)) {
        // evento de teste do painel ou usuário anônimo do RevenueCat (sem conta no app)
        await d.fimDoEvento(id);
        return json(200, { status: 'ignorado' });
      }
      const assinante = await d.assinante(appUserId);
      const quando = typeof evento.event_timestamp_ms === 'number'
        ? new Date(evento.event_timestamp_ms)
        : new Date((d.agora ?? Date.now)());
      const estado = await d.aplicar(
        appUserId,
        normalizarAssinante(assinante, (d.agora ?? Date.now)()),
        quando,
      );
      await d.fimDoEvento(id);
      return json(200, { status: 'processado', pro: estado.pro });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      await d.fimDoEvento(id, msg.slice(0, 500));
      return erro(500, 'falha_ao_processar');
    }
  };
}

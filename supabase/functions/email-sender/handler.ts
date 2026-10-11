// Edge Function `email-sender` (pg_cron a cada 5 min): envia a fila private.email_outbox pelo
// Resend. Só o agendador chama (chave secreta no cabeçalho apikey).
import { chaveDoAgendadorValida } from '../_shared/auth.ts';
import { erro, exigeMetodo, json } from '../_shared/http.ts';
import { montar } from './modelos.ts';

export type EmailPendente = {
  id: string;
  email: string | null;
  template: string;
  payload: Record<string, unknown>;
};

export type Dependencias = {
  chavesAceitas: string[];
  configurado: boolean;
  reservar(limite: number): Promise<EmailPendente[]>;
  concluir(id: string, erro?: string): Promise<void>;
  enviar(para: string, assunto: string, texto: string): Promise<void>;
};

export function criarHandler(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    if (!chaveDoAgendadorValida(req, d.chavesAceitas)) return erro(401, 'nao_autorizado');
    if (!d.configurado) return erro(503, 'email_nao_configurado'); // não reserva: nenhuma tentativa gasta
    let enviados = 0, falhas = 0;
    for (const e of await d.reservar(50)) {
      const m = montar(e.template, e.payload ?? {});
      try {
        if (!e.email) throw new Error('sem_email');
        if (!m) throw new Error(`modelo_desconhecido:${e.template}`);
        await d.enviar(e.email, m.assunto, m.texto);
        await d.concluir(e.id);
        enviados++;
      } catch (x) {
        await d.concluir(e.id, (x instanceof Error ? x.message : String(x)).slice(0, 300));
        falhas++;
      }
    }
    return json(200, { enviados, falhas });
  };
}

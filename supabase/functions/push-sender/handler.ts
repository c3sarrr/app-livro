// Edge Function `push-sender` (pg_cron a cada minuto): manda o push das notificações novas
// (private.claim_pushes já agrupou: no máximo 1 por pessoa e clube a cada 10 min) e remove os
// aparelhos com token inválido. Só o agendador chama.
import { chaveDoAgendadorValida } from '../_shared/auth.ts';
import { erro, exigeMetodo, json } from '../_shared/http.ts';
import type { Mensagem } from './fcm.ts';
import { mensagem, type Pendente } from './textos.ts';

export type Dependencias = {
  chavesAceitas: string[];
  configurado: boolean;
  reservar(limite: number): Promise<Pendente[]>;
  enviar(token: string, m: Mensagem): Promise<'ok' | 'token_invalido'>;
  descartarToken(token: string): Promise<void>;
};

export function criarHandler(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    if (!chaveDoAgendadorValida(req, d.chavesAceitas)) return erro(401, 'nao_autorizado');
    if (!d.configurado) return erro(503, 'push_nao_configurado'); // não reserva: nada é marcado
    let enviados = 0, invalidos = 0, falhas = 0;
    for (const n of await d.reservar(200)) {
      const m = mensagem(n);
      for (const token of n.tokens ?? []) {
        try {
          if (await d.enviar(token, m) === 'ok') enviados++;
          else {
            await d.descartarToken(token);
            invalidos++;
          }
        } catch {
          falhas++; // erro transitório: o push desta notificação se perde (a lista no app continua)
        }
      }
    }
    return json(200, { enviados, invalidos, falhas });
  };
}

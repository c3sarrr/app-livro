// Edge Function `purge-storage` (pg_cron diário): apaga a pasta "<user_id>/" do bucket "ebooks" de
// quem foi purgado pela retenção ou excluiu a conta (fila private.storage_purge_queue). Só o
// agendador chama. A exclusão é pela API do Storage (o SQL em storage.objects é bloqueado).
import { chaveDoAgendadorValida } from '../_shared/auth.ts';
import { erro, exigeMetodo, json } from '../_shared/http.ts';

export type Dependencias = {
  chavesAceitas: string[];
  reservar(limite: number): Promise<{ user_id: string; reason: string }[]>;
  apagarPasta(userId: string): Promise<number>;
  concluir(userId: string, erro?: string): Promise<void>;
};

export function criarHandler(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    if (!chaveDoAgendadorValida(req, d.chavesAceitas)) return erro(401, 'nao_autorizado');
    let contas = 0, arquivos = 0, falhas = 0;
    for (const item of await d.reservar(20)) {
      try {
        arquivos += await d.apagarPasta(item.user_id);
        await d.concluir(item.user_id);
        contas++;
      } catch (x) {
        await d.concluir(item.user_id, (x instanceof Error ? x.message : String(x)).slice(0, 300));
        falhas++;
      }
    }
    return json(200, { contas, arquivos, falhas });
  };
}

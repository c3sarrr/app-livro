// Edge Function `purge-storage` (pg_cron diário): apaga a pasta "<user_id>/" do bucket "ebooks" de
// quem foi purgado pela retenção ou excluiu a conta (fila private.storage_purge_queue) e, desde a G06,
// os arquivos AVULSOS de livros apagados ou trocados (fila private.ebook_object_deletions — o cliente
// não apaga no bucket). Só o agendador chama. A exclusão é pela API do Storage (o SQL em
// storage.objects é bloqueado).
import { chaveDoAgendadorValida } from '../_shared/auth.ts';
import { erro, exigeMetodo, json } from '../_shared/http.ts';

export type Dependencias = {
  chavesAceitas: string[];
  reservar(limite: number): Promise<{ user_id: string; reason: string }[]>;
  apagarPasta(userId: string): Promise<number>;
  concluir(userId: string, erro?: string): Promise<void>;
  reservarAvulsos(limite: number): Promise<string[]>;
  apagarArquivos(caminhos: string[]): Promise<void>;
  concluirAvulso(caminho: string, erro?: string): Promise<void>;
};

const texto = (x: unknown) => (x instanceof Error ? x.message : String(x)).slice(0, 300);

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
        await d.concluir(item.user_id, texto(x));
        falhas++;
      }
    }
    let avulsos = 0, falhasAvulsos = 0;
    const caminhos = await d.reservarAvulsos(100);
    for (let i = 0; i < caminhos.length; i += 100) {
      const lote = caminhos.slice(i, i + 100);
      let falha: string | undefined;
      try {
        await d.apagarArquivos(lote);
      } catch (x) {
        falha = texto(x);
      }
      for (const c of lote) await d.concluirAvulso(c, falha);
      if (falha) falhasAvulsos += lote.length;
      else avulsos += lote.length;
    }
    return json(200, { contas, arquivos, falhas, avulsos, falhas_avulsos: falhasAvulsos });
  };
}

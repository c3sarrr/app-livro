import { sql } from '../_shared/db.ts';
import { verificarSessao } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';

Deno.serve(criarHandler({
  // sessão conferida no Auth (esconder conteúdo é uma ação forte: sessão encerrada não decide)
  verificarJwt: verificarSessao,
  // a página do painel (site/moderacao/; hospedagem na Q9)
  origemWeb: Deno.env.get('MODERACAO_WEB_ORIGEM') ?? null,
  async ehModerador(id) {
    const [r] = await sql()`select private.is_moderator(${id}::uuid) as ok`;
    return Boolean(r?.ok);
  },
  async fila() {
    const [r] = await sql()`select private.moderation_snapshot(200) as itens`;
    return (r?.itens ?? []) as unknown[];
  },
  async decidir(denuncia, decisao, moderadora, nota) {
    await sql()`select private.moderate_report(${denuncia}::uuid, ${decisao}, ${moderadora}, ${nota})`;
  },
}));

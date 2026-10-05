import { sql } from '../_shared/db.ts';
import { chavesDoAgendador } from '../_shared/env.ts';
import { apagarPasta, clienteAdmin } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';

Deno.serve(criarHandler({
  chavesAceitas: chavesDoAgendador(),
  async reservar(limite) {
    return await sql()`select user_id, reason from private.claim_storage_purges(${limite})` as never;
  },
  apagarPasta: (userId) => apagarPasta('ebooks', userId),
  async concluir(userId, erroTexto) {
    await sql()`select private.finish_storage_purge(${userId}, ${erroTexto ?? null})`;
  },
  async reservarAvulsos(limite) {
    const linhas = await sql()`select path from private.claim_ebook_deletions(${limite})`;
    return linhas.map((l) => l.path as string);
  },
  async apagarArquivos(caminhos) {
    const { error } = await clienteAdmin().storage.from('ebooks').remove(caminhos);
    if (error) throw error;
  },
  async concluirAvulso(caminho, erroTexto) {
    await sql()`select private.finish_ebook_deletion(${caminho}, ${erroTexto ?? null})`;
  },
}));

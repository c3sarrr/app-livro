import { sql } from '../_shared/db.ts';
import { chavesDoAgendador } from '../_shared/env.ts';
import { apagarPasta } from '../_shared/supabase.ts';
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
}));

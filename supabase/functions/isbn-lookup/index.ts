import { sql } from '../_shared/db.ts';
import { verificarJwt } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';
import { fontesPorRegiao } from './provedores.ts';

const chaves = {
  hardcover: Deno.env.get('HARDCOVER_TOKEN') ?? undefined,
  isbndb: Deno.env.get('ISBNDB_KEY') ?? undefined, // pago: só se o volume pedir (ADR-008)
};

Deno.serve(criarHandler({
  verificarJwt,
  async ehPro(userId) {
    const [r] = await sql()`select private.user_is_pro(${userId}) as pro`;
    return r.pro === true;
  },
  async consumirCota(userId, limite) {
    const [r] = await sql()`select private.consume_quota(${userId}, 'isbn_externo', ${limite}) as ok`;
    return r.ok === true;
  },
  async devolverCota(userId) {
    await sql()`select private.refund_quota(${userId}, 'isbn_externo')`;
  },
  fontes: (isbn) => fontesPorRegiao(isbn, fetch, chaves),
}));

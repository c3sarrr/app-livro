import { sql } from '../_shared/db.ts';
import { verificarJwt } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';
import { brasilApi, type Fonte, hardcover, isbndb } from './provedores.ts';

const fontes: Fonte[] = [(isbn) => brasilApi(isbn, fetch)];
const tokenHardcover = Deno.env.get('HARDCOVER_TOKEN');
if (tokenHardcover) fontes.push((isbn) => hardcover(isbn, fetch, tokenHardcover));
const chaveIsbndb = Deno.env.get('ISBNDB_KEY'); // pago: só se o volume pedir (ADR-008)
if (chaveIsbndb) fontes.push((isbn) => isbndb(isbn, fetch, chaveIsbndb));

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
  fontes,
}));

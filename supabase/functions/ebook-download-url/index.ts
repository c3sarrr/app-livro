import { sql } from '../_shared/db.ts';
import { clienteAdmin, verificarJwt } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';

Deno.serve(criarHandler({
  verificarJwt,
  async caminho(userId, livro) {
    const [r] = await sql()`select private.ebook_download_path(${userId}, ${livro}) as caminho`;
    return r.caminho;
  },
  async urlAssinada(caminho, validadeS) {
    const { data, error } = await clienteAdmin().storage.from('ebooks').createSignedUrl(caminho, validadeS);
    if (error || !data) throw error ?? new Error('sem URL assinada');
    return data.signedUrl;
  },
}));

import { sql } from '../_shared/db.ts';
import { clienteAdmin, verificarJwt } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';

Deno.serve(criarHandler({
  verificarJwt,
  async reservar(userId, livro, sha256, bytes) {
    const [r] =
      await sql()`select private.ebook_upload_slot(${userId}, ${livro}, ${sha256}, ${bytes}) as caminho`;
    return r.caminho;
  },
  async urlAssinada(caminho) {
    const { data, error } = await clienteAdmin().storage.from('ebooks').createSignedUploadUrl(caminho, {
      upsert: true,
    });
    if (error || !data) throw error ?? new Error('sem URL assinada');
    return { signedUrl: data.signedUrl, token: data.token };
  },
}));

// Edge Function `ebook-upload-url` (Anexo 02 §6.4): o upload do e-book (Pro, opcional) só acontece
// por URL assinada emitida aqui — o bucket "ebooks" não tem política de INSERT. O banco
// (private.ebook_upload_slot) confere Pro, dono do livro, sha256 e a cota de 2 GiB.
import { usuarioDoPedido } from '../_shared/auth.ts';
import { codigoDoBanco, erro, exigeMetodo, json, lerJson, UUID } from '../_shared/http.ts';

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  reservar(userId: string, livro: string, sha256: string, bytes: number): Promise<string>;
  urlAssinada(caminho: string): Promise<{ signedUrl: string; token: string }>;
};

const HTTP_DO_ERRO: Record<string, number> = {
  pro_required: 403,
  book_not_found: 404,
  sha_mismatch: 409,
  quota_exceeded: 413,
  invalid_file: 400,
};

export function criarHandler(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    const usuario = await usuarioDoPedido(req, d.verificarJwt);
    if (!usuario) return erro(401, 'nao_autenticado');
    const c = await lerJson(req);
    const livro = String(c?.user_book_id ?? '');
    const sha = String(c?.sha256 ?? '').toLowerCase();
    const bytes = Number(c?.bytes);
    if (!UUID.test(livro) || !/^[0-9a-f]{64}$/.test(sha) || !Number.isSafeInteger(bytes) || bytes <= 0) {
      return erro(400, 'pedido_invalido');
    }
    let caminho: string;
    try {
      caminho = await d.reservar(usuario, livro, sha, bytes);
    } catch (e) {
      const codigo = codigoDoBanco(e);
      if (codigo && HTTP_DO_ERRO[codigo]) return erro(HTTP_DO_ERRO[codigo], codigo);
      throw e;
    }
    const u = await d.urlAssinada(caminho);
    return json(200, { path: caminho, signed_url: u.signedUrl, token: u.token });
  };
}

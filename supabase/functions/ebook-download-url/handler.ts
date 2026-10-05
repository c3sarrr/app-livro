// Edge Function `ebook-download-url` (G06 — Anexo 02 §6.4): o e-book da nuvem (Pro) é baixado por uma
// URL assinada de VIDA CURTA emitida aqui — o cliente não tem política no bucket "ebooks" (não gera
// link próprio). O banco (private.ebook_download_path) confere Pro, dono, livro ativo e o arquivo.
// Devolve o caminho RELATIVO da URL assinada (`/storage/v1/object/sign/…?token=…`): o app completa com
// o endereço público do projeto (dentro do runtime o endereço do Supabase pode ser o interno).
import { usuarioDoPedido } from '../_shared/auth.ts';
import { codigoDoBanco, erro, exigeMetodo, json, lerJson, UUID } from '../_shared/http.ts';

/** Validade da URL de download (segundos). */
export const VALIDADE_S = 300;

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  caminho(userId: string, livro: string): Promise<string>;
  urlAssinada(caminho: string, validadeS: number): Promise<string>;
};

/** `/storage/v1/object/sign/…?token=…` de uma URL assinada (absoluta ou já relativa). */
export function caminhoRelativo(url: string): string {
  const u = new URL(url, 'http://relativo.invalid');
  return u.pathname + u.search;
}

const HTTP_DO_ERRO: Record<string, number> = {
  pro_required: 403,
  book_not_found: 404,
  file_not_found: 404,
};

export function criarHandler(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    const usuario = await usuarioDoPedido(req, d.verificarJwt);
    if (!usuario) return erro(401, 'nao_autenticado');
    const c = await lerJson(req);
    const livro = String(c?.user_book_id ?? '');
    if (!UUID.test(livro)) return erro(400, 'pedido_invalido');
    let caminho: string;
    try {
      caminho = await d.caminho(usuario, livro);
    } catch (e) {
      const codigo = codigoDoBanco(e);
      if (codigo && HTTP_DO_ERRO[codigo]) return erro(HTTP_DO_ERRO[codigo], codigo);
      throw e;
    }
    const url = await d.urlAssinada(caminho, VALIDADE_S);
    return json(200, { path: caminho, signed_path: caminhoRelativo(url), expires_in: VALIDADE_S });
  };
}

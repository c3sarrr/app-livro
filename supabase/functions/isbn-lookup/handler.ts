// Edge Function `isbn-lookup` (Anexo 02 §7, camada 4): usuário logado; cota diária de consultas
// externas (Grátis 30, Pro 150 — private.consume_quota); fontes em ordem; nada vai para o catálogo.
import { usuarioDoPedido } from '../_shared/auth.ts';
import { erro, exigeMetodo, json, lerJson } from '../_shared/http.ts';
import { type Fonte, isbn13, procurar } from './provedores.ts';

export const COTA_GRATIS = 30;
export const COTA_PRO = 150;

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  ehPro(userId: string): Promise<boolean>;
  consumirCota(userId: string, limite: number): Promise<boolean>;
  fontes: Fonte[];
};

export function criarHandler(d: Dependencias) {
  return async (req: Request): Promise<Response> => {
    const metodo = exigeMetodo(req, 'POST');
    if (metodo) return metodo;
    const usuario = await usuarioDoPedido(req, d.verificarJwt);
    if (!usuario) return erro(401, 'nao_autenticado');
    const corpo = await lerJson(req);
    const isbn = isbn13(String(corpo?.isbn ?? ''));
    if (!isbn) return erro(400, 'isbn_invalido');
    const limite = (await d.ehPro(usuario)) ? COTA_PRO : COTA_GRATIS;
    if (!(await d.consumirCota(usuario, limite))) {
      return erro(429, 'cota_diaria_esgotada', `limite de ${limite} consultas por dia`);
    }
    const r = await procurar(isbn, d.fontes);
    if (r === 'nao_encontrado') return json(404, { encontrado: false, isbn13: isbn });
    if (r === 'indisponivel') return erro(503, 'fontes_indisponiveis');
    return json(200, { encontrado: true, livro: r });
  };
}

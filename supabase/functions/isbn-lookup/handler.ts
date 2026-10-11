// Edge Function `isbn-lookup` (Anexo 02 §7, camada 5): usuário logado; cota diária de consultas
// externas (Grátis 30, Pro 150 — private.consume_quota); fontes na ordem da região do ISBN (D-73);
// nada vai para o catálogo. Log estruturado por consulta: região, fontes tentadas, resultado e
// tempo — sem o id da conta e só com o prefixo do ISBN (o log não reconstrói a estante de ninguém).
import { usuarioDoPedido } from '../_shared/auth.ts';
import { erro, exigeMetodo, json, lerJson } from '../_shared/http.ts';
import { type Fonte, isbn13, procurar, regiaoDoIsbn, type Tentativa } from './provedores.ts';

export const COTA_GRATIS = 30;
export const COTA_PRO = 150;

export type Dependencias = {
  verificarJwt(jwt: string): Promise<string | null>;
  ehPro(userId: string): Promise<boolean>;
  consumirCota(userId: string, limite: number): Promise<boolean>;
  /** Devolve a consulta quando nenhuma fonte respondeu (falha de terceiros não gasta a cota). */
  devolverCota(userId: string): Promise<void>;
  /** Fontes na ordem para este ISBN (`fontesPorRegiao`). */
  fontes(isbn: string): Fonte[];
  registrar?(evento: Record<string, unknown>): void;
};

/** Log padrão: uma linha JSON por consulta. */
export const registrarNoConsole = (evento: Record<string, unknown>) => console.log(JSON.stringify(evento));

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
    const tentativas: Tentativa[] = [];
    const r = await procurar(isbn, d.fontes(isbn), tentativas);
    (d.registrar ?? registrarNoConsole)({
      fn: 'isbn-lookup',
      regiao: regiaoDoIsbn(isbn),
      prefixo: isbn.slice(0, 5),
      resultado: typeof r === 'string' ? r : 'encontrado',
      provider: typeof r === 'string' ? null : r.provider ?? r.source,
      tentativas,
    });
    if (r === 'nao_encontrado') return json(404, { encontrado: false, isbn13: isbn });
    if (r === 'indisponivel') {
      await d.devolverCota(usuario);
      return erro(503, 'fontes_indisponiveis');
    }
    return json(200, { encontrado: true, livro: r });
  };
}

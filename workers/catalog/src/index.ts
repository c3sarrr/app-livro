// Worker do catálogo do BookNest (G07 · Anexo 02 §7 · ADR-008 · D-73/D-75).
//   GET /v1/isbn/<isbn>                    → livro do catálogo aberto (shards por prefixo no R2), com cache
//   GET /v1/catalog/manifest.json          → versão atual do catalog.db (o app confere toda semana)
//   GET /v1/catalog/<versão>/<arquivo>     → catalog.db.gz ou delta, com Range (download retomável)
// Limite por IP; nenhum dado pessoal: o pedido leva só o ISBN.
import { servirArquivo } from './arquivos';
import { IndiceAusente, indice, livroDe, prefixoDe, procurarNoShard } from './catalogo';
import { normalizarIsbn } from './isbn';

const VERSAO = /^\d{4}-\d{2}-\d{2}\.\d+$/;
const ARQUIVO = /^(catalog\.db\.gz|manifest\.json|delta-\d{4}-\d{2}-\d{2}\.\d+\.jsonl\.gz)$/;

function erro(status: number, codigo: string, extra: Record<string, string> = {}): Response {
  return Response.json({ erro: codigo }, { status, headers: { 'Cache-Control': 'no-store', ...extra } });
}

async function dentroDoLimite(limite: RateLimit, req: Request): Promise<boolean> {
  const ip = req.headers.get('CF-Connecting-IP') ?? 'local';
  const { success } = await limite.limit({ key: ip });
  return success;
}

async function isbn(req: Request, env: Env, ctx: ExecutionContext, bruto: string): Promise<Response> {
  let texto: string;
  try {
    texto = decodeURIComponent(bruto);
  } catch {
    return erro(400, 'isbn_invalido');
  }
  const isbn13 = normalizarIsbn(texto);
  if (!isbn13) return erro(400, 'isbn_invalido');
  if (!(await dentroDoLimite(env.LIMITE_ISBN, req))) return erro(429, 'limite', { 'Retry-After': '60' });
  const ind = await indice(env.CATALOGO);
  // chave do cache: ISBN-13 canônico + versão do catálogo (a versão nova invalida tudo sozinha)
  const chave = new Request(`${new URL(req.url).origin}/v1/isbn/${isbn13}?v=${encodeURIComponent(ind.versao)}`);
  const cache = caches.default;
  const guardada = await cache.match(chave);
  if (guardada) return guardada;
  const prefixo = prefixoDe(ind.prefixos, isbn13);
  const r = prefixo ? await procurarNoShard(env.CATALOGO, prefixo, isbn13) : null;
  const resposta = r
    ? Response.json(
        { encontrado: true, versao: ind.versao, livro: livroDe(r) },
        { headers: { 'Cache-Control': 'public, max-age=86400' } },
      )
    : Response.json(
        { encontrado: false, versao: ind.versao, isbn13 },
        { status: 404, headers: { 'Cache-Control': 'public, max-age=3600' } },
      );
  ctx.waitUntil(cache.put(chave, resposta.clone()));
  return resposta;
}

async function catalogo(req: Request, env: Env, partes: string[]): Promise<Response> {
  if (!(await dentroDoLimite(env.LIMITE_DOWNLOAD, req))) return erro(429, 'limite', { 'Retry-After': '60' });
  if (partes.length === 1 && partes[0] === 'manifest.json') {
    return servirArquivo(req, env.CATALOGO, 'catalog/v1/manifest.json', 'application/json', 'public, max-age=300');
  }
  if (partes.length === 2 && VERSAO.test(partes[0]) && ARQUIVO.test(partes[1])) {
    const tipo = partes[1].endsWith('.json') ? 'application/json' : 'application/gzip';
    return servirArquivo(req, env.CATALOGO, `catalog/v1/${partes[0]}/${partes[1]}`, tipo,
      'public, max-age=31536000, immutable');
  }
  return erro(404, 'nao_encontrado');
}

export default {
  async fetch(req, env, ctx): Promise<Response> {
    const url = new URL(req.url);
    if (req.method !== 'GET' && req.method !== 'HEAD') return erro(405, 'metodo', { Allow: 'GET, HEAD' });
    const partes = url.pathname.split('/').filter((p) => p !== '');
    try {
      if (partes[0] === 'v1' && partes[1] === 'isbn' && partes.length === 3) return await isbn(req, env, ctx, partes[2]);
      if (partes[0] === 'v1' && partes[1] === 'catalog') return await catalogo(req, env, partes.slice(2));
      return erro(404, 'nao_encontrado');
    } catch (e) {
      if (e instanceof IndiceAusente) {
        console.error(JSON.stringify({ message: 'catalogo sem indice', path: url.pathname }));
        return erro(503, 'catalogo_indisponivel', { 'Retry-After': '300' });
      }
      console.error(JSON.stringify({
        message: 'erro inesperado', path: url.pathname, error: e instanceof Error ? e.message : String(e),
      }));
      return erro(500, 'erro_interno');
    }
  },
} satisfies ExportedHandler<Env>;

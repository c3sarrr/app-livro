// G07 — Worker do catálogo no runtime dos Workers (Miniflare): R2 emulado, cache e Range de verdade.
import { createExecutionContext, waitOnExecutionContext } from 'cloudflare:test';
import { env, exports } from 'cloudflare:workers';
import { beforeEach, describe, expect, it } from 'vitest';
import { lerRange } from '../src/arquivos';
import { esquecerIndice, prefixoDe } from '../src/catalogo';
import { normalizarIsbn } from '../src/isbn';
import worker from '../src/index';

const BASE = 'http://catalogo.teste';

/** Pedido como o runtime entrega ao handler (com as propriedades `cf` de entrada). */
function pedido(url: string): Request<unknown, IncomingRequestCfProperties> {
  return new Request(url) as Request<unknown, IncomingRequestCfProperties>;
}

async function gz(texto: string): Promise<ArrayBuffer> {
  const fluxo = new Blob([texto]).stream().pipeThrough(new CompressionStream('gzip'));
  return new Response(fluxo).arrayBuffer();
}

function linha(r: Record<string, unknown>): string {
  return JSON.stringify(Object.fromEntries(Object.entries(r).sort(([a], [b]) => a.localeCompare(b)))) + '\n';
}

const DOM = { i: '9788535902778', t: 'Dom Casmurro', a: ['Machado de Assis'], p: 'Penguin-Companhia', y: 2016, n: 256,
  l: 'por', c: 'ol:8231432', f: 'openlibrary', lic: 'OL-sem-direitos' };
const PP = { i: '9780141439518', t: 'Pride and Prejudice', a: ['Jane Austen'], f: 'openlibrary', lic: 'OL-sem-direitos' };
const OX = { i: '9780199535569', t: 'Pride & Prejudice', a: [], f: 'openlibrary', lic: 'OL-sem-direitos' };

async function publicar(versao = '2026-09-30.1'): Promise<void> {
  // 9780 dividido até 97801414 / 97801995 (como o pipeline faz com prefixos grandes)
  await env.CATALOGO.put('isbn/v1/index.json', JSON.stringify({ formato: 1, versao, prefixos: ['97801414', '97801995', '9788535'] }));
  await env.CATALOGO.put('isbn/v1/9788535.jsonl.gz', await gz(linha({ ...DOM, i: '9788535900002' }) + linha(DOM)));
  await env.CATALOGO.put('isbn/v1/97801414.jsonl.gz', await gz(linha(PP)));
  await env.CATALOGO.put('isbn/v1/97801995.jsonl.gz', await gz(linha(OX)));
  await env.CATALOGO.put('catalog/v1/manifest.json', JSON.stringify({ versao }));
  const db = new Uint8Array(1000).map((_, i) => i % 251);
  await env.CATALOGO.put(`catalog/v1/${versao}/catalog.db.gz`, db);
}

beforeEach(async () => {
  esquecerIndice();
  const lista = await env.CATALOGO.list();
  for (const o of lista.objects) await env.CATALOGO.delete(o.key);
});

describe('ISBN', () => {
  it('normaliza como o pipeline e o app', () => {
    expect(normalizarIsbn('85-359-0277-5')).toBe('9788535902778');
    expect(normalizarIsbn('978-65-5532-123-4')).toBe('9786555321234');
    expect(normalizarIsbn('9786555321230')).toBeNull();
    expect(prefixoDe(new Set(['9780']), '9780141439518')).toBeNull(); // menor que 7 não vale
    expect(prefixoDe(new Set(['9788535', '97801414']), '9780141439518')).toBe('97801414');
  });

  it('acha pelo prefixo mais longo, em fluxo, e devolve os nomes por extenso', async () => {
    await publicar();
    const r = await exports.default.fetch(`${BASE}/v1/isbn/85-359-0277-5`);
    expect(r.status).toBe(200);
    expect(await r.json()).toEqual({
      encontrado: true,
      versao: '2026-09-30.1',
      livro: { isbn13: '9788535902778', title: 'Dom Casmurro', subtitle: null, authors: ['Machado de Assis'],
        publisher: 'Penguin-Companhia', year: 2016, pages: 256, language: 'por', cover_ref: 'ol:8231432',
        source: 'openlibrary', source_license: 'OL-sem-direitos' },
    });
    expect(r.headers.get('Cache-Control')).toBe('public, max-age=86400');
    const r2 = await exports.default.fetch(`${BASE}/v1/isbn/9780199535569`);
    expect(((await r2.json()) as { livro: { title: string } }).livro.title).toBe('Pride & Prejudice');
  });

  it('não achou: 404 (no shard e sem shard do prefixo); ISBN inválido: 400', async () => {
    await publicar();
    const a = await exports.default.fetch(`${BASE}/v1/isbn/9788535910667`);
    expect(a.status).toBe(404);
    expect(await a.json()).toEqual({ encontrado: false, versao: '2026-09-30.1', isbn13: '9788535910667' });
    expect((await exports.default.fetch(`${BASE}/v1/isbn/9783596294336`)).status).toBe(404);
    const c = await exports.default.fetch(`${BASE}/v1/isbn/1234`);
    expect(c.status).toBe(400);
    expect(await c.json()).toEqual({ erro: 'isbn_invalido' });
    expect((await exports.default.fetch(`${BASE}/v1/isbn/%E0%A4%A`)).status).toBe(400);
  });

  it('a resposta fica no cache: o shard sumir depois não muda a resposta da mesma versão', async () => {
    await publicar();
    const ctx = createExecutionContext();
    const req = pedido(`${BASE}/v1/isbn/9780141439518`);
    expect((await worker.fetch(req, env, ctx)).status).toBe(200);
    await waitOnExecutionContext(ctx);
    await env.CATALOGO.delete('isbn/v1/97801414.jsonl.gz');
    const ctx2 = createExecutionContext();
    expect((await worker.fetch(pedido(`${BASE}/v1/isbn/0141439513`), env, ctx2)).status).toBe(200);
    await waitOnExecutionContext(ctx2);
  });

  it('sem índice no R2: 503 (catálogo indisponível), não 500', async () => {
    const r = await exports.default.fetch(`${BASE}/v1/isbn/9780141439518`);
    expect(r.status).toBe(503);
    expect(r.headers.get('Retry-After')).toBe('300');
  });

  it('limite por IP: 429 com Retry-After', async () => {
    await publicar();
    const negado = { limit: async () => ({ success: false }) } as unknown as RateLimit;
    const ctx = createExecutionContext();
    const r = await worker.fetch(pedido(`${BASE}/v1/isbn/9780141439518`), { ...env, LIMITE_ISBN: negado }, ctx);
    await waitOnExecutionContext(ctx);
    expect(r.status).toBe(429);
    expect(r.headers.get('Retry-After')).toBe('60');
    const ctx2 = createExecutionContext();
    const d = await worker.fetch(pedido(`${BASE}/v1/catalog/manifest.json`), { ...env, LIMITE_DOWNLOAD: negado }, ctx2);
    await waitOnExecutionContext(ctx2);
    expect(d.status).toBe(429);
  });
});

describe('download do catalog.db', () => {
  it('manifesto e arquivo inteiro com ETag', async () => {
    await publicar();
    const m = await exports.default.fetch(`${BASE}/v1/catalog/manifest.json`);
    expect(m.status).toBe(200);
    expect(await m.json()).toEqual({ versao: '2026-09-30.1' });
    expect(m.headers.get('Cache-Control')).toBe('public, max-age=300');
    const r = await exports.default.fetch(`${BASE}/v1/catalog/2026-09-30.1/catalog.db.gz`);
    expect(r.status).toBe(200);
    expect(r.headers.get('Content-Length')).toBe('1000');
    expect(r.headers.get('Accept-Ranges')).toBe('bytes');
    expect(r.headers.get('Cache-Control')).toBe('public, max-age=31536000, immutable');
    const corpo = new Uint8Array(await r.arrayBuffer());
    expect(corpo[250]).toBe(250);
    const etag = r.headers.get('ETag')!;
    const n = await exports.default.fetch(`${BASE}/v1/catalog/2026-09-30.1/catalog.db.gz`, { headers: { 'If-None-Match': etag } });
    expect(n.status).toBe(304);
  });

  it('retomada: Range devolve 206 só com o pedaço; If-Range com outro ETag manda inteiro; fora do tamanho 416', async () => {
    await publicar();
    const url = `${BASE}/v1/catalog/2026-09-30.1/catalog.db.gz`;
    const etag = (await exports.default.fetch(url, { method: 'HEAD' })).headers.get('ETag')!;
    const p = await exports.default.fetch(url, { headers: { Range: 'bytes=600-', 'If-Range': etag } });
    expect(p.status).toBe(206);
    expect(p.headers.get('Content-Range')).toBe('bytes 600-999/1000');
    expect(p.headers.get('Content-Length')).toBe('400');
    const b = new Uint8Array(await p.arrayBuffer());
    expect(b.length).toBe(400);
    expect(b[0]).toBe(600 % 251);
    const outro = await exports.default.fetch(url, { headers: { Range: 'bytes=600-', 'If-Range': '"outro"' } });
    expect(outro.status).toBe(200);
    await outro.arrayBuffer();
    const fora = await exports.default.fetch(url, { headers: { Range: 'bytes=5000-' } });
    expect(fora.status).toBe(416);
    expect(fora.headers.get('Content-Range')).toBe('bytes */1000');
  });

  it('só caminhos conhecidos: nada de atravessar pastas do R2', async () => {
    await publicar();
    for (const c of ['/v1/catalog/../isbn/v1/index.json', '/v1/catalog/2026-09-30.1/../../isbn/v1/index.json',
      '/v1/catalog/2026-09-30.1/qualquer.bin', '/v1/catalog/latest/catalog.db.gz', '/isbn/v1/index.json']) {
      const r = await exports.default.fetch(`${BASE}${c}`);
      expect(r.status, c).toBe(404);
    }
    expect((await exports.default.fetch(`${BASE}/v1/isbn/9780141439518`, { method: 'POST' })).status).toBe(405);
  });

  it('lerRange', () => {
    expect(lerRange(null, 10)).toBeNull();
    expect(lerRange('bytes=2-4', 10)).toEqual({ inicio: 2, fim: 4 });
    expect(lerRange('bytes=-3', 10)).toEqual({ inicio: 7, fim: 9 });
    expect(lerRange('bytes=8-100', 10)).toEqual({ inicio: 8, fim: 9 });
    expect(lerRange('bytes=10-', 10)).toBe('invalido');
    expect(lerRange('bytes=0-1,4-5', 10)).toBeNull();
  });
});

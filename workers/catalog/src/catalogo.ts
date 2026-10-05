// Camada da borda do catálogo: índice de prefixos + shards `isbn/v1/<prefixo>.jsonl.gz` no R2.

/** Registro como sai do pipeline (`tools/catalog`): chaves curtas, nulos omitidos. */
export type RegistroShard = {
  i: string;
  t: string;
  s?: string;
  a: string[];
  p?: string;
  y?: number;
  n?: number;
  l?: string;
  c?: string;
  f: string;
  lic: string;
};

/** O livro na resposta da API (nomes por extenso, iguais às colunas do catalog.db). */
export type Livro = {
  isbn13: string;
  title: string;
  subtitle: string | null;
  authors: string[];
  publisher: string | null;
  year: number | null;
  pages: number | null;
  language: string | null;
  cover_ref: string | null;
  source: string;
  source_license: string;
};

export function livroDe(r: RegistroShard): Livro {
  return {
    isbn13: r.i,
    title: r.t,
    subtitle: r.s ?? null,
    authors: r.a,
    publisher: r.p ?? null,
    year: r.y ?? null,
    pages: r.n ?? null,
    language: r.l ?? null,
    cover_ref: r.c ?? null,
    source: r.f,
    source_license: r.lic,
  };
}

export const CHAVE_INDICE = 'isbn/v1/index.json';
const MENOR_PREFIXO = 7;
const MAIOR_PREFIXO = 12;
/** O índice muda uma vez por mês; cada isolate o relê a cada 5 minutos (ou quando o etag muda). */
const VALIDADE_INDICE_MS = 5 * 60 * 1000;

type Indice = { versao: string; prefixos: Set<string>; etag: string; lidoEm: number };

/** Cache do índice por isolate (dado imutável por versão — não é estado de um pedido). */
let indiceEmCache: Indice | null = null;

export class IndiceAusente extends Error {}

export async function indice(bucket: R2Bucket, agora: number = Date.now()): Promise<Indice> {
  const atual = indiceEmCache;
  if (atual && agora - atual.lidoEm < VALIDADE_INDICE_MS) return atual;
  const obj = await bucket.get(CHAVE_INDICE);
  if (!obj) throw new IndiceAusente('índice do catálogo ausente no R2');
  if (atual && obj.httpEtag === atual.etag) {
    await obj.body.cancel();
    indiceEmCache = { ...atual, lidoEm: agora };
    return indiceEmCache;
  }
  const j = (await obj.json()) as { versao: string; prefixos: string[] };
  indiceEmCache = { versao: j.versao, prefixos: new Set(j.prefixos), etag: obj.httpEtag, lidoEm: agora };
  return indiceEmCache;
}

/** Para testes: força reler o índice. */
export function esquecerIndice(): void {
  indiceEmCache = null;
}

/** Prefixo mais longo do índice que casa com o ISBN. */
export function prefixoDe(prefixos: Set<string>, isbn13: string): string | null {
  for (let n = MAIOR_PREFIXO; n >= MENOR_PREFIXO; n--) {
    const p = isbn13.slice(0, n);
    if (prefixos.has(p)) return p;
  }
  return null;
}

/** Lê o shard em fluxo (sem carregar tudo) até achar a linha do ISBN. */
export async function procurarNoShard(bucket: R2Bucket, prefixo: string, isbn13: string): Promise<RegistroShard | null> {
  const obj = await bucket.get(`isbn/v1/${prefixo}.jsonl.gz`);
  if (!obj) return null;
  const marca = `"i":"${isbn13}"`;
  const leitor = obj.body
    .pipeThrough(new DecompressionStream('gzip'))
    .pipeThrough(new TextDecoderStream())
    .getReader();
  let resto = '';
  try {
    for (;;) {
      const { value, done } = await leitor.read();
      if (done) break;
      resto += value;
      let fim = resto.indexOf('\n');
      while (fim >= 0) {
        const linha = resto.slice(0, fim);
        resto = resto.slice(fim + 1);
        if (linha.includes(marca)) {
          const r = JSON.parse(linha) as RegistroShard;
          if (r.i === isbn13) return r;
        }
        fim = resto.indexOf('\n');
      }
    }
    if (resto.includes(marca)) {
      const r = JSON.parse(resto) as RegistroShard;
      if (r.i === isbn13) return r;
    }
    return null;
  } finally {
    await leitor.cancel().catch(() => {});
  }
}

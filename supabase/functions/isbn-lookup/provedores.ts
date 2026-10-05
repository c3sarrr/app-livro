// Fontes externas de ISBN (Anexo 02 §7, camada 5 — último recurso; ADR-008; D-73 cobertura global):
// a REGIÃO do ISBN decide a ordem. Brasil (978-85, 978-65) → BrasilAPI só com a CBL e o Mercado
// Editorial (acham 97 % dos livros brasileiros) → BrasilAPI com Open Library e Google Books →
// Hardcover → ISBNdb (pago; só com chave). Resto do mundo → BrasilAPI com Open Library e Google
// Books → Hardcover → ISBNdb. O resultado vai para a estante da pessoa e o cache do aparelho, NÃO
// para o catálogo compartilhado (termos da CBL/Google/ISBNdb — D-73).

export type Livro = {
  isbn13: string;
  title: string;
  subtitle: string | null;
  authors: string[];
  publisher: string | null;
  published_year: number | null;
  pages: number | null;
  language: string | null;
  cover_url: string | null;
  source: 'brasilapi' | 'hardcover' | 'isbndb';
  /** Quem respondeu dentro da fonte (a BrasilAPI agrega: cbl, mercado-editorial, open-library…). */
  provider?: string | null;
};

export type Regiao = 'BR' | 'MUNDO';

/** Grupo de registro do ISBN: 978-85 e 978-65 = Brasil. */
export function regiaoDoIsbn(isbn: string): Regiao {
  return isbn.startsWith('97885') || isbn.startsWith('97865') ? 'BR' : 'MUNDO';
}

/** Provedores da BrasilAPI por região (parâmetro `providers`). */
export const PROVEDORES_BRASIL = ['cbl', 'mercado-editorial'];
export const PROVEDORES_GLOBAIS = ['open-library', 'google-books'];

export type Buscar = typeof fetch;

/** Converte ISBN-10 em ISBN-13 e confere o dígito; devolve null se inválido. */
export function isbn13(entrada: string): string | null {
  const s = entrada.replace(/[\s-]/g, '').toUpperCase();
  if (/^\d{9}[\dX]$/.test(s)) {
    let soma = 0;
    for (let i = 0; i < 9; i++) soma += (10 - i) * Number(s[i]);
    soma += s[9] === 'X' ? 10 : Number(s[9]);
    if (soma % 11 !== 0) return null;
    return comDigito13('978' + s.slice(0, 9));
  }
  if (/^97[89]\d{10}$/.test(s)) return comDigito13(s.slice(0, 12)) === s ? s : null;
  return null;
}

function comDigito13(doze: string): string {
  let soma = 0;
  for (let i = 0; i < 12; i++) soma += Number(doze[i]) * (i % 2 === 0 ? 1 : 3);
  return doze + String((10 - (soma % 10)) % 10);
}

function texto(v: unknown): string | null {
  return typeof v === 'string' && v.trim() !== '' ? v.trim() : null;
}

function ano(v: unknown): number | null {
  const m = /(\d{4})/.exec(String(v ?? ''));
  return m ? Number(m[1]) : null;
}

function inteiro(v: unknown): number | null {
  const n = Number(v);
  return Number.isInteger(n) && n > 0 ? n : null;
}

/** Resultado de uma fonte: livro, "não achou" (null) ou falha (lança). */
export async function brasilApi(isbn: string, buscar: Buscar, provedores?: string[]): Promise<Livro | null> {
  const filtro = provedores?.length ? `?providers=${provedores.join(',')}` : '';
  const r = await buscar(`https://brasilapi.com.br/api/isbn/v1/${isbn}${filtro}`, {
    signal: AbortSignal.timeout(4000),
  });
  if (r.status === 404) return null;
  if (!r.ok) throw new Error(`brasilapi ${r.status}`);
  const j = await r.json();
  const titulo = texto(j.title);
  if (!titulo) return null;
  return {
    isbn13: isbn,
    title: titulo,
    subtitle: texto(j.subtitle),
    authors: Array.isArray(j.authors)
      ? j.authors.map(texto).filter((a: string | null): a is string => !!a)
      : [],
    publisher: texto(j.publisher),
    published_year: ano(j.year),
    pages: inteiro(j.page_count),
    language: null,
    cover_url: texto(j.cover_url),
    source: 'brasilapi',
    provider: texto(j.provider),
  };
}

export async function hardcover(isbn: string, buscar: Buscar, token: string): Promise<Livro | null> {
  const consulta = `query ($isbn: String!) { editions(where: {isbn_13: {_eq: $isbn}}, limit: 1) {
    title subtitle pages release_date publisher { name } language { language } image { url }
    book { contributions { author { name } } } } }`;
  const r = await buscar('https://api.hardcover.app/v1/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify({ query: consulta, variables: { isbn } }),
    signal: AbortSignal.timeout(4000),
  });
  if (!r.ok) throw new Error(`hardcover ${r.status}`);
  const j = await r.json();
  const e = j?.data?.editions?.[0];
  if (!e || !texto(e.title)) return null;
  return {
    isbn13: isbn,
    title: texto(e.title)!,
    subtitle: texto(e.subtitle),
    authors: (e.book?.contributions ?? []).map((c: { author?: { name?: string } }) => texto(c.author?.name))
      .filter((a: string | null): a is string => !!a),
    publisher: texto(e.publisher?.name),
    published_year: ano(e.release_date),
    pages: inteiro(e.pages),
    language: texto(e.language?.language),
    cover_url: texto(e.image?.url),
    source: 'hardcover',
  };
}

export async function isbndb(isbn: string, buscar: Buscar, chave: string): Promise<Livro | null> {
  const r = await buscar(`https://api2.isbndb.com/book/${isbn}`, {
    headers: { Authorization: chave },
    signal: AbortSignal.timeout(4000),
  });
  if (r.status === 404) return null;
  if (!r.ok) throw new Error(`isbndb ${r.status}`);
  const b = (await r.json())?.book;
  if (!b || !texto(b.title)) return null;
  return {
    isbn13: isbn,
    title: texto(b.title)!,
    subtitle: null,
    authors: Array.isArray(b.authors)
      ? b.authors.map(texto).filter((a: string | null): a is string => !!a)
      : [],
    publisher: texto(b.publisher),
    published_year: ano(b.date_published),
    pages: inteiro(b.pages),
    language: texto(b.language),
    cover_url: texto(b.image),
    source: 'isbndb',
  };
}

export type Fonte = ((isbn: string) => Promise<Livro | null>) & { nome?: string };

/** Dá nome a uma fonte (vai para o log estruturado). */
export function nomeada(nome: string, f: (isbn: string) => Promise<Livro | null>): Fonte {
  return Object.assign(f, { nome });
}

/** Ordem das fontes para o ISBN (D-73). As opcionais entram só com chave configurada. */
export function fontesPorRegiao(
  isbn: string,
  buscar: Buscar,
  chaves: { hardcover?: string; isbndb?: string } = {},
): Fonte[] {
  const fontes: Fonte[] = [];
  if (regiaoDoIsbn(isbn) === 'BR') {
    fontes.push(nomeada('brasilapi:br', (i) => brasilApi(i, buscar, PROVEDORES_BRASIL)));
  }
  fontes.push(nomeada('brasilapi:global', (i) => brasilApi(i, buscar, PROVEDORES_GLOBAIS)));
  const h = chaves.hardcover;
  if (h) fontes.push(nomeada('hardcover', (i) => hardcover(i, buscar, h)));
  const k = chaves.isbndb;
  if (k) fontes.push(nomeada('isbndb', (i) => isbndb(i, buscar, k)));
  return fontes;
}

/** Uma tentativa numa fonte (para o log estruturado). */
export type Tentativa = { fonte: string; resultado: 'achou' | 'nao_achou' | 'falhou'; ms: number };

/** Primeira fonte que achar. Se nenhuma achou e alguma falhou → 'indisponivel' (o app tenta depois). */
export async function procurar(
  isbn: string,
  fontes: Fonte[],
  tentativas: Tentativa[] = [],
  agora: () => number = () => performance.now(),
): Promise<Livro | 'nao_encontrado' | 'indisponivel'> {
  let falhou = false;
  for (const [n, f] of fontes.entries()) {
    const inicio = agora();
    const fonte = f.nome ?? `fonte${n + 1}`;
    try {
      const livro = await f(isbn);
      tentativas.push({ fonte, resultado: livro ? 'achou' : 'nao_achou', ms: Math.round(agora() - inicio) });
      if (livro) return livro;
    } catch {
      tentativas.push({ fonte, resultado: 'falhou', ms: Math.round(agora() - inicio) });
      falhou = true;
    }
  }
  return falhou ? 'indisponivel' : 'nao_encontrado';
}

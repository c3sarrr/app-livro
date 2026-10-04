// Fontes externas de ISBN (Anexo 02 §7, camada 4 — último recurso; ADR-008 / Q24):
// BrasilAPI (dados da CBL, acha 97 % dos livros brasileiros) → Hardcover → ISBNdb (pago; só com
// chave configurada). O resultado vai para a estante da pessoa, NÃO para o catálogo compartilhado
// (termos do ISBNdb/Google).

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
};

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
export async function brasilApi(isbn: string, buscar: Buscar): Promise<Livro | null> {
  const r = await buscar(`https://brasilapi.com.br/api/isbn/v1/${isbn}`, {
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

export type Fonte = (isbn: string) => Promise<Livro | null>;

/** Primeira fonte que achar. Se nenhuma achou e alguma falhou → 'indisponivel' (o app tenta depois). */
export async function procurar(
  isbn: string,
  fontes: Fonte[],
): Promise<Livro | 'nao_encontrado' | 'indisponivel'> {
  let falhou = false;
  for (const f of fontes) {
    try {
      const livro = await f(isbn);
      if (livro) return livro;
    } catch {
      falhou = true;
    }
  }
  return falhou ? 'indisponivel' : 'nao_encontrado';
}

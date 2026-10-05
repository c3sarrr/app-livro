import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import {
  brasilApi,
  type Buscar,
  fontesPorRegiao,
  googleBooks,
  hardcover,
  isbn13,
  isbndb,
  openLibrary,
  procurar,
  regiaoDoIsbn,
  type Tentativa,
} from './provedores.ts';

const resposta = (status: number, corpo: unknown): Buscar => () =>
  Promise.resolve(new Response(JSON.stringify(corpo), { status }));

Deno.test('ISBN: aceita 13 e 10 dígitos (com hífens) e confere o dígito verificador', () => {
  assertEquals(isbn13('978-85-359-1066-7'), '9788535910667');
  assertEquals(isbn13('85-359-1066-2'), '9788535910667'); // o mesmo livro em ISBN-10
  assertEquals(isbn13('9788535910663'), null); // dígito errado
  assertEquals(isbn13('853591066X'), null); // dígito errado no ISBN-10
  assertEquals(isbn13('abc'), null);
  assertEquals(isbn13('0-8044-2957-X'), '9780804429573');
});

Deno.test('BrasilAPI: normaliza o livro; 404 = não achou; 5xx = falha', async () => {
  const livro = await brasilApi(
    '9788535910667',
    resposta(200, {
      isbn: '9788535910667',
      title: 'Dom Casmurro',
      subtitle: null,
      authors: ['Machado de Assis'],
      publisher: 'Companhia das Letras',
      year: 2016,
      page_count: 256,
      cover_url: null,
    }),
  );
  assertEquals(livro?.title, 'Dom Casmurro');
  assertEquals([livro?.authors, livro?.published_year, livro?.pages, livro?.source], [
    ['Machado de Assis'],
    2016,
    256,
    'brasilapi',
  ]);
  assertEquals(await brasilApi('9788535910667', resposta(404, { message: 'ISBN não encontrado' })), null);
  let falhou = false;
  try {
    await brasilApi('9788535910667', resposta(500, {}));
  } catch {
    falhou = true;
  }
  assertEquals(falhou, true);
});

Deno.test('Hardcover e ISBNdb: normalizam o formato de cada um', async () => {
  const h = await hardcover(
    '9780804429573',
    resposta(200, {
      data: {
        editions: [{
          title: 'Livro',
          subtitle: 'Sub',
          pages: 300,
          release_date: '1999-05-01',
          publisher: { name: 'Ed' },
          language: { language: 'English' },
          image: { url: 'https://img/x.jpg' },
          book: { contributions: [{ author: { name: 'Autora A' } }, { author: { name: 'Autor B' } }] },
        }],
      },
    }),
    'tok',
  );
  assertEquals([h?.authors, h?.published_year, h?.language, h?.source], [
    ['Autora A', 'Autor B'],
    1999,
    'English',
    'hardcover',
  ]);
  assertEquals(await hardcover('9780804429573', resposta(200, { data: { editions: [] } }), 'tok'), null);
  const i = await isbndb(
    '9780804429573',
    resposta(200, { book: { title: 'T', authors: ['X'], pages: 10, date_published: '2001' } }),
    'k',
  );
  assertEquals([i?.title, i?.published_year, i?.source], ['T', 2001, 'isbndb']);
});

Deno.test('procurar: primeira fonte que achar; falha + ninguém achou = indisponível', async () => {
  const livro = {
    isbn13: 'x',
    title: 'Achei',
    subtitle: null,
    authors: [],
    publisher: null,
    published_year: null,
    pages: null,
    language: null,
    cover_url: null,
    source: 'hardcover' as const,
  };
  assertEquals(await procurar('x', [() => Promise.resolve(null), () => Promise.resolve(livro)]), livro);
  assertEquals(
    await procurar('x', [() => Promise.reject(new Error('rede')), () => Promise.resolve(livro)]),
    livro,
  );
  assertEquals(await procurar('x', [() => Promise.resolve(null)]), 'nao_encontrado');
  assertEquals(
    await procurar('x', [() => Promise.reject(new Error('rede')), () => Promise.resolve(null)]),
    'indisponivel',
  );
});

Deno.test('região do ISBN (D-73): 978-85 e 978-65 = Brasil; o resto = mundo', () => {
  assertEquals(regiaoDoIsbn('9788535910667'), 'BR');
  assertEquals(regiaoDoIsbn('9786586490008'), 'BR');
  assertEquals(regiaoDoIsbn('9780804429573'), 'MUNDO');
  assertEquals(regiaoDoIsbn('9783161484100'), 'MUNDO');
  assertEquals(regiaoDoIsbn('9791000000015'), 'MUNDO');
});

/** Buscar que registra as URLs e responde 404 (ninguém acha). */
function gravador(status = 404) {
  const urls: string[] = [];
  const buscar: Buscar = (u) => {
    urls.push(String(u));
    return Promise.resolve(new Response('{}', { status }));
  };
  return { urls, buscar };
}

Deno.test('Brasil: CBL/Mercado Editorial primeiro, depois as fontes globais; Hardcover/ISBNdb só com chave', async () => {
  const g = gravador();
  assertEquals(await procurar('9786586490008', fontesPorRegiao('9786586490008', g.buscar)), 'nao_encontrado');
  assertEquals(g.urls, [
    'https://brasilapi.com.br/api/isbn/v1/9786586490008?providers=cbl,mercado-editorial',
    'https://brasilapi.com.br/api/isbn/v1/9786586490008?providers=open-library,google-books',
  ]);
  const comChaves = fontesPorRegiao('9786586490008', g.buscar, { hardcover: 't', isbndb: 'k' });
  assertEquals(comChaves.map((f) => f.nome), ['brasilapi:br', 'brasilapi:global', 'hardcover', 'isbndb']);
});

Deno.test('Mundo: Open Library direto; Google Books só com chave — a BrasilAPI recusa ISBN de fora do Brasil', async () => {
  // medido em 05/10/2026: /api/isbn/v1/9780141439518 → 400 "ISBN inválido", com ou sem `providers`; e o Google
  // Books sem chave respondeu 429 em todas as consultas → sem chave ele fica de fora (senão todo livro estrangeiro
  // ausente do Open Library viraria "indisponível" para sempre, em vez de "não achou")
  const g = gravador();
  assertEquals(await procurar('9780804429573', fontesPorRegiao('9780804429573', g.buscar)), 'indisponivel');
  assertEquals(g.urls, [
    'https://openlibrary.org/api/books?bibkeys=ISBN:9780804429573&format=json&jscmd=data',
  ]);
  const vazio: Buscar = () => Promise.resolve(new Response('{}', { status: 200 }));
  assertEquals(await procurar('9780804429573', fontesPorRegiao('9780804429573', vazio)), 'nao_encontrado');
  const comChaves = fontesPorRegiao('9780804429573', g.buscar, {
    googleBooks: 'gk',
    hardcover: 't',
    isbndb: 'k',
  });
  assertEquals(comChaves.map((f) => f.nome), ['openlibrary', 'googlebooks', 'hardcover', 'isbndb']);
  const g2 = gravador();
  await procurar('9780804429573', fontesPorRegiao('9780804429573', g2.buscar, { googleBooks: 'gk' }));
  assertEquals(g2.urls, [
    'https://openlibrary.org/api/books?bibkeys=ISBN:9780804429573&format=json&jscmd=data',
    'https://www.googleapis.com/books/v1/volumes?q=isbn:9780804429573&maxResults=10&key=gk',
  ]);
  assertEquals(g2.urls.some((u) => u.includes('brasilapi')), false);
});

Deno.test('Open Library (API): normaliza o livro; objeto vazio = não achou; 5xx = falha', async () => {
  const livro = await openLibrary(
    '9780141439518',
    resposta(200, {
      'ISBN:9780141439518': {
        title: 'Pride and Prejudice',
        subtitle: 'A Novel',
        authors: [{ name: 'Jane Austen' }, { name: '' }],
        publishers: [{ name: 'Penguin Classics' }],
        publish_date: 'January 30, 2003',
        number_of_pages: 480,
        cover: { medium: 'https://covers.openlibrary.org/b/id/1-M.jpg' },
      },
    }),
  );
  assertEquals(
    [livro?.title, livro?.subtitle, livro?.authors, livro?.publisher, livro?.published_year, livro?.pages],
    ['Pride and Prejudice', 'A Novel', ['Jane Austen'], 'Penguin Classics', 2003, 480],
  );
  assertEquals([livro?.cover_url, livro?.source], [
    'https://covers.openlibrary.org/b/id/1-M.jpg',
    'openlibrary',
  ]);
  assertEquals(await openLibrary('9780141439518', resposta(200, {})), null);
  assertEquals(
    await openLibrary('9780141439518', resposta(200, { 'ISBN:9780141439518': { title: '' } })),
    null,
  );
  let falhou = false;
  try {
    await openLibrary('9780141439518', resposta(503, {}));
  } catch {
    falhou = true;
  }
  assertEquals(falhou, true);
});

Deno.test('Google Books: confere o ISBN do volume; 0 resultados = não achou; 429 = falha', async () => {
  const volume = (isbns: string[]) => ({
    totalItems: 1,
    items: [{
      volumeInfo: {
        title: 'The Hobbit',
        subtitle: 'or There and Back Again',
        authors: ['J. R. R. Tolkien'],
        publisher: 'Mariner',
        publishedDate: '2012-09-18',
        pageCount: 300,
        imageLinks: { thumbnail: 'http://books.google.com/books/content?id=x' },
        industryIdentifiers: isbns.map((i) => ({
          type: i.length === 13 ? 'ISBN_13' : 'ISBN_10',
          identifier: i,
        })),
      },
    }],
  });
  const livro = await googleBooks('9780547928227', resposta(200, volume(['054792822X', '9780547928227'])));
  assertEquals(
    [livro?.title, livro?.authors, livro?.publisher, livro?.published_year, livro?.pages, livro?.source],
    ['The Hobbit', ['J. R. R. Tolkien'], 'Mariner', 2012, 300, 'googlebooks'],
  );
  assertEquals(livro?.cover_url, 'https://books.google.com/books/content?id=x'); // nunca http
  // ISBN-10 do mesmo livro também vale
  assertEquals(
    (await googleBooks('9780547928227', resposta(200, volume(['054792822X']))))?.title,
    'The Hobbit',
  );
  // a busca do Google às vezes devolve outro livro: sem o ISBN pedido = não achou
  assertEquals(await googleBooks('9780547928227', resposta(200, volume(['9780000000002']))), null);
  // …e às vezes o certo vem depois de outro: vale o primeiro volume que tem o ISBN (revisão 2, achado 3)
  const doisVolumes = volume(['9780547928227']);
  doisVolumes.items.unshift({ ...volume(['9780000000002']).items[0] });
  doisVolumes.items[0].volumeInfo.title = 'Outro livro';
  assertEquals((await googleBooks('9780547928227', resposta(200, doisVolumes)))?.title, 'The Hobbit');
  assertEquals(await googleBooks('9780547928227', resposta(200, { totalItems: 0 })), null);
  let falhou = false;
  try {
    await googleBooks('9780547928227', resposta(429, {}));
  } catch {
    falhou = true;
  }
  assertEquals(falhou, true);
});

Deno.test('BrasilAPI: guarda qual provedor respondeu', async () => {
  const l = await brasilApi(
    '9788535910667',
    resposta(200, { title: 'Dom Casmurro', authors: [], provider: 'cbl' }),
    ['cbl'],
  );
  assertEquals(l?.provider, 'cbl');
});

Deno.test('procurar registra cada tentativa (fonte, resultado, tempo)', async () => {
  const t: Tentativa[] = [];
  let relogio = 0;
  const agora = () => (relogio += 5);
  await procurar(
    'x',
    [
      Object.assign(() => Promise.reject(new Error('x')), { nome: 'a' }),
      () => Promise.resolve(null),
    ],
    t,
    agora,
  );
  assertEquals(t, [
    { fonte: 'a', resultado: 'falhou', ms: 5 },
    { fonte: 'fonte2', resultado: 'nao_achou', ms: 5 },
  ]);
});

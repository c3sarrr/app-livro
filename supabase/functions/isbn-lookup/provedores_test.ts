import { deepStrictEqual as assertEquals } from 'node:assert/strict';
import { brasilApi, type Buscar, hardcover, isbn13, isbndb, procurar } from './provedores.ts';

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

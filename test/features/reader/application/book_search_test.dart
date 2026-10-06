// G12.4 — o núcleo da busca (D-120): sem acento e sem maiúsculas com as posições no texto original (inclusive
// com a marca de um acento decomposto), mínimo de 2 caracteres e limite; o trecho (40 antes, 60 depois, cortados
// em palavra, "…", quebras e objetos viram espaço); a busca em vários textos que para no limite sem ler os
// seguintes; o capítulo de cada posição.
import 'package:app_leitura/features/reader/application/book_search.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sem acento e sem maiúsculas, nas posições do original', () {
    expect(findAll('Ação e AÇÃO; acao.', 'acao'), [(0, 4), (7, 11), (13, 17)]);
    expect(findAll('AÇÃO', 'çã'), [(1, 3)]);
    expect(findAll('Ação', 'AÇÃO'), [(0, 4)]);
    const t = 'para dizer o que foram aqueles olhos de Capitu. Não me acode';
    final (s, e) = findAll(t, 'olhos de capitu').single;
    expect(t.substring(s, e), 'olhos de Capitu');
    expect(findAll('Œuvre Straße ŁÓDŹ', 'lodz'), [(13, 17)]);
  });

  test('acento decomposto: o intervalo cobre a marca', () {
    const t = 'café e cafe';
    expect(findAll(t, 'café'), [(0, 5), (8, 12)]);
    expect(findAll(t, 'CAFE'), [(0, 5), (8, 12)]);
    expect(foldForSearch(t).text, 'cafe e cafe');
  });

  test(
    'menos de 2 caracteres não busca; espaços nas pontas não contam; limite',
    () {
      expect(findAll('aaaa', 'a'), isEmpty);
      expect(findAll('aaaa', ' a '), isEmpty);
      expect(findAll('ab ab ab', ' ab '), hasLength(3));
      expect(findAll('ab ab ab', 'ab', limit: 2), [(0, 2), (3, 5)]);
      expect(findAll('ab ab ab', 'ab', limit: 0), isEmpty);
      expect(findAll('aaaa', 'aa'), [(0, 2), (2, 4)], reason: 'sem sobrepor');
      expect(searchMinChars, 2);
      expect(searchLimit, 500);
    },
  );

  test('trecho: 40 antes (sem a palavra cortada), 60 depois (idem), "…" dos dois lados', () {
    final t = '${'palavras ' * 10}ALVO${' depois' * 15}';
    const s = 90;
    final x = excerptAround(t, s, s + 4);
    expect(x.text, '…${'palavras ' * 4}ALVO${' depois' * 8}…');
    expect(x.text.substring(x.matchStart, x.matchEnd), 'ALVO');
    expect(x.matchStart, 1 + 36);
  });

  test('trecho: corte já na divisa da palavra não perde a palavra; sem corte, sem "…"', () {
    final t = '${'palavra ' * 10}ALVO';
    final x = excerptAround(t, 80, 84);
    expect(x.text, '…${'palavra ' * 5}ALVO');
    final curto = excerptAround('um ALVO aqui', 3, 7);
    expect(curto.text, 'um ALVO aqui');
    expect((curto.matchStart, curto.matchEnd), (3, 7));
  });

  test('trecho: quebras e objetos viram um espaço', () {
    const t = 'antes\n￼do ALVO fim';
    final x = excerptAround(t, 10, 14);
    expect(x.text, 'antes do ALVO fim');
    expect(x.text.substring(x.matchStart, x.matchEnd), 'ALVO');
  });

  test('vários textos: na ordem, para no limite e não lê os seguintes', () {
    final lidos = <int>[];
    const textos = ['aa aa', 'bb', 'aa', 'aa aa aa'];
    String ler(int u) {
      lidos.add(u);
      return textos[u];
    }

    final dois = searchTexts([0, 1, 2, 3], ler, 'aa', limit: 2).toList();
    expect(dois.map((u) => (u.unit, u.hits.length)), [(0, 2)]);
    expect(lidos, [0]);
    lidos.clear();
    final todos = searchTexts([0, 1, 2, 3], ler, 'aa').toList();
    expect(todos.map((u) => (u.unit, u.hits.length)), [(0, 2), (2, 1), (3, 3)]);
    final h = todos.first.hits[1];
    expect((h.start, h.end, h.excerpt), (3, 5, 'aa aa'));
    expect(h.excerpt.substring(h.matchStart, h.matchEnd), 'aa');
    final quatro = searchTexts([0, 1, 2, 3], ler, 'aa', limit: 4).toList();
    expect(quatro.map((u) => (u.unit, u.hits.length)), [
      (0, 2),
      (2, 1),
      (3, 1),
    ]);
    expect(searchTexts([0], ler, 'a'), isEmpty);
  });

  test('capítulo de uma posição: a última folha do sumário até ela; antes da 1ª, "Começo do livro"', () {
    const spine = [
      SpineInfo(path: 'a.xhtml', linear: true, chars: 100),
      SpineInfo(path: 'b.xhtml', linear: true, chars: 100),
      SpineInfo(path: 'c.xhtml', linear: true, chars: 100),
    ];
    final index = BookIndex(
      contentSha256: 'x',
      layout: 'reflowable',
      spine: spine,
      toc: const [
        TocPoint(title: 'Parte', depth: 0, leaf: false, spine: 1, offset: 0),
        TocPoint(title: 'I', depth: 1, leaf: true, spine: 1, offset: 0),
        TocPoint(title: 'II', depth: 1, leaf: true, spine: 2, offset: 50),
      ],
      refPages: RefPageMap.synthetic(const [0]),
      refPageVersion: 1,
    );
    expect(searchChapterAt(index, 10), (leaf: -1, title: 'Começo do livro'));
    expect(searchChapterAt(index, 100), (leaf: 0, title: 'I'));
    expect(searchChapterAt(index, 249), (leaf: 0, title: 'I'));
    expect(searchChapterAt(index, 250), (leaf: 1, title: 'II'));
  });
}

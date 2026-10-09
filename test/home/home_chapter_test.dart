// G20 (R1, D-206) — o "Cap. N de M" da Início pela numeração do livro: contam só os capítulos com numeral; fora de
// um numerado vale o último antes da posição; antes do 1º, nada; sem numeração, as folhas do sumário.
import 'package:app_leitura/features/home/domain/home_chapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // o Dom Casmurro do Gutenberg: 2 de abertura, I…CXLVIII, FIM, INDICE, a licença
  final dom = <String?>[
    null,
    null,
    for (var i = 1; i <= 148; i++) '$i',
    null,
    null,
    null,
  ];

  test(
    'numeração em sequência: a ordem entre os numerados (XXXII = 32 de 148)',
    () {
      expect(homeChapter(dom, chapterIndex: 33, chaptersTotal: 153), (
        chapter: 32,
        total: 148,
      ));
      expect(homeChapter(dom, chapterIndex: 2, chaptersTotal: 153), (
        chapter: 1,
        total: 148,
      ));
    },
  );

  test(
    'antes do 1º numerado, nada (a pílula some); depois do último, o último',
    () {
      expect(homeChapter(dom, chapterIndex: 0, chaptersTotal: 153), isNull);
      expect(homeChapter(dom, chapterIndex: 1, chaptersTotal: 153), isNull);
      expect(homeChapter(dom, chapterIndex: 152, chaptersTotal: 153), (
        chapter: 148,
        total: 148,
      ));
    },
  );

  test('numeração que recomeça por parte: a ordem continua (o 3º da parte 2 é o 13 de 22)', () {
    final partes = <String?>[
      for (var i = 1; i <= 10; i++) '$i',
      for (var i = 1; i <= 12; i++) '$i',
    ];
    expect(homeChapter(partes, chapterIndex: 12, chaptersTotal: 22), (
      chapter: 13,
      total: 22,
    ));
  });

  test('capítulo sem número no meio dos numerados vale o último numerado antes dele', () {
    final meio = <String?>['1', '2', null, '3'];
    expect(homeChapter(meio, chapterIndex: 2, chaptersTotal: 4), (
      chapter: 2,
      total: 3,
    ));
    expect(homeChapter(meio, chapterIndex: 3, chaptersTotal: 4), (
      chapter: 3,
      total: 3,
    ));
  });

  test(
    'sem numeração: as folhas do sumário (chapter_index + 1 de chapters_total)',
    () {
      expect(
        homeChapter(
          const [null, null, null],
          chapterIndex: 1,
          chaptersTotal: 3,
        ),
        (chapter: 2, total: 3),
      );
      expect(homeChapter(const [], chapterIndex: 4, chaptersTotal: 20), (
        chapter: 5,
        total: 20,
      ));
    },
  );

  test('sem posição, ou sem total e sem numeração: nada', () {
    expect(homeChapter(dom, chapterIndex: null, chaptersTotal: 153), isNull);
    expect(homeChapter(const [], chapterIndex: 4, chaptersTotal: null), isNull);
  });
}

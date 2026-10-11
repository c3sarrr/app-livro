// G20 (R1, D-206) — o "Cap. N de M" pela numeração do livro: contam só os capítulos com numeral (os do leitor —
// D-150/D-155/D-156); fora de um numerado vale o último antes da posição; antes do 1º, nada (D-85); sem numeração,
// as folhas do sumário. Era a pílula do herói da Início da v1; desde a T03 o herói mostra a página (D-254) e a
// contagem serve ao capítulo do clube (`clubChapterOf`).

/// "Cap. [chapter] de [total]".
typedef HomeChapter = ({int chapter, int total});

/// [numerals] = o numeral de cada folha do sumário (`chapterNumerals`); [chapterIndex] = a folha da posição
/// (`reading_positions.chapter_index`); [chaptersTotal] = `user_books.chapters_total`. `null` = a pílula some.
HomeChapter? homeChapter(
  List<String?> numerals, {
  required int? chapterIndex,
  required int? chaptersTotal,
}) {
  if (chapterIndex == null) return null;
  final numbered = [
    for (var i = 0; i < numerals.length; i++)
      if (numerals[i] != null) i,
  ];
  if (numbered.isEmpty) {
    return chaptersTotal == null
        ? null
        : (chapter: chapterIndex + 1, total: chaptersTotal);
  }
  // a ordem, entre os numerados, do último que começa na posição ou antes dela
  var n = 0;
  for (final i in numbered) {
    if (i > chapterIndex) break;
    n++;
  }
  return n == 0 ? null : (chapter: n, total: numbered.length);
}

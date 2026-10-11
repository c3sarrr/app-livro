// G13.2 — o que os grifos precisam do livro aberto (EPUB): o sha do conteúdo (âncoras do mesmo arquivo usam
// início/fim), o texto de um item já aberto (citação e reancoragem — Anexo 03 §5) e a página de referência e o
// capítulo de uma posição (os mesmos do marcador — G12).
abstract interface class AnnotationAnchors {
  /// O sha-256 do conteúdo do arquivo aberto.
  String get sha;

  /// O texto canônico do item [spine], se ele já está aberto; `null` = ainda não (ou não existe).
  String? textOf(int spine);

  /// A página de referência e o capítulo do caractere [offset] do item [spine].
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset);
}

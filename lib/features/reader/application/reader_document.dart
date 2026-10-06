// G11.2 — o que a tela precisa de um livro aberto, igual para EPUB e PDF (desenho G11 §2): a página atual e a
// vizinha prontas para pintar, virar, os números do rodapé, seguir um link, voltar a um lugar e gravar a
// posição. A tela não sabe se o livro é EPUB ou PDF. G12: autor, salto por página (barra de posição — D-119),
// rascunho do marcador (D-49), cor do texto (Tema — D-121) e a marca da busca (D-120).
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show Listenable;

import '../domain/locator.dart';
import '../domain/reader_numbers.dart';
import '../layout/display_page.dart';

export '../layout/display_page.dart';

/// "pág. 159 de 256" e "62%" (D-19/D-89): a página de referência do 1º caractere visível e o total; a % é a
/// posição global ÷ o total (Anexo 03 §6).
final class ReaderNumbersView {
  const ReaderNumbersView({
    required this.refPage,
    required this.refTotal,
    required this.progression,
  });

  final int refPage;
  final int refTotal;
  final double progression;

  String get pageLabel => 'pág. $refPage de $refTotal';

  String get percentLabel => percentOf(progression);

  @override
  bool operator ==(Object other) =>
      other is ReaderNumbersView &&
      other.refPage == refPage &&
      other.refTotal == refTotal &&
      other.progression == progression;

  @override
  int get hashCode => Object.hash(refPage, refTotal, progression);

  @override
  String toString() => '$pageLabel · $percentLabel';
}

/// Um lugar do livro: no EPUB, o item do spine e o caractere; no PDF, spine 0 e a página (a partir de 0).
typedef ReaderMark = ({int spine, int offset});

/// Páginas de referência que a página mostrada cobre (tempo: "páginas lidas", D-95).
typedef RefRange = ({int fromRef, int toRef});

/// O marcador da página mostrada antes de gravar: onde ela começa, a página de referência, o capítulo e o
/// começo do texto (D-49).
typedef BookmarkDraft = ({
  Locator locator,
  int refPage,
  int chapterIndex,
  String excerpt,
});

/// Um trecho achado pela busca: [unit] = item do spine (EPUB) ou página (PDF); [from]…[to] no texto dele.
typedef FoundRange = ({int unit, int from, int to});

/// Um resultado da busca no livro pronto para a lista e para o salto (D-120): onde saltar, o que marcar na página,
/// a página de referência e o trecho com a palavra em [matchStart, matchEnd).
typedef SearchHit = ({
  ReaderMark at,
  FoundRange found,
  int refPage,
  String excerpt,
  int matchStart,
  int matchEnd,
});

/// Os resultados seguidos de um capítulo (EPUB) ou de uma página (PDF).
typedef SearchGroup = ({String title, List<SearchHit> hits});

/// D-49: o começo da página para o marcador — até 90 caracteres, cortado em palavra, com "…" quando cortado.
String bookmarkExcerpt(String pageText) {
  final t = pageText.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.length <= 90) return t;
  final cut = t.lastIndexOf(' ', 90);
  return '${t.substring(0, cut > 40 ? cut : 90).trimRight()}…';
}

abstract interface class ReaderDocument {
  /// Título do livro (rótulo da página para o leitor de tela; ilha de cima — G12).
  String get title;

  /// Autor do livro (ilha de cima).
  String get author;

  /// Caracteres do livro: a régua do tempo restante (D-97). PDF: páginas × 1.500 (D-122).
  int get totalChars;

  /// O começo da página de referência [refPage] (limitada a 1…total): a barra de posição (D-119).
  ReaderMark markOfRefPage(int refPage);

  /// Os resultados de [query] por capítulo (EPUB) ou por página (PDF), à medida que saem, até 501 (a tela mostra
  /// 500 e o aviso); cancelar a assinatura para a busca (D-120).
  Stream<SearchGroup> search(String query);

  /// A página mostrada é a última do livro: o tempo restante some (D-124). Não dá para usar a última página de
  /// referência: quando ela é curta, nenhuma página da tela começa nela.
  bool get atEnd;

  /// O marcador da página mostrada (fita da ilha de cima).
  BookmarkDraft bookmarkHere();

  /// Troca a cor do texto sem mudar as quebras (Tema — D-121). PDF: a página não muda de cor (D-43).
  Future<void> recolor(ui.Color ink);

  /// A ocorrência da busca marcada na página (D-120), até a próxima virada ou salto.
  FoundRange? get found;

  void showFound(FoundRange f);

  /// A página mostrada.
  DisplayPage get current;

  /// Avisa quando a página mostrada muda (virar, abrir outro lugar, repaginar, a página do cache que vira a do
  /// layout completo).
  Listenable get changes;

  ReaderNumbersView get numbers;

  /// Onde a pessoa está (a volta de um link guarda isto).
  ReaderMark get mark;

  RefRange get shownRange;

  /// A página vizinha sem virar; `null` = começo/fim do livro. Vizinha que não abre (arquivo danificado) = erro,
  /// não fim do livro: a tela vira e a sessão mostra o aviso.
  Future<DisplayPage?> peek(PageDirection d);

  /// Vira; `false` = começo/fim do livro.
  Future<bool> turn(PageDirection d);

  /// Vai ao destino do link; `false` = o destino não está no livro.
  Future<bool> follow(LinkHit link);

  /// Abre na página que contém [m].
  Future<void> goTo(ReaderMark m);

  /// Abre na página de referência [refPage] (barra de posição — D-119): a 1ª página da tela que começa nela, para
  /// o rodapé mostrar o número escolhido (a que contém o começo dela quase sempre começa ainda na anterior).
  Future<void> goToRefPage(int refPage);

  /// Grava a posição pendente agora (segundo plano, sair).
  Future<void> flush();

  /// Enquanto houver [mark], a posição gravada é ela e não a página mostrada — a volta de um link (D-115): sair
  /// do livro com a pílula valendo guarda a página de onde se saiu. `null` solta e grava a página mostrada.
  Future<void> pin(ReaderMark? mark);

  void dispose();
}

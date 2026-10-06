// G11.2 — o que a tela precisa de um livro aberto, igual para EPUB e PDF (desenho G11 §2): a página atual e a
// vizinha prontas para pintar, virar, os números do rodapé, seguir um link, voltar a um lugar e gravar a
// posição. A tela não sabe se o livro é EPUB ou PDF.
import 'package:flutter/foundation.dart' show Listenable;

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

abstract interface class ReaderDocument {
  /// Título do livro (rótulo da página para o leitor de tela).
  String get title;

  /// A página mostrada.
  DisplayPage get current;

  /// Avisa quando a página mostrada muda (virar, abrir outro lugar, repaginar, a página do cache que vira a do
  /// layout completo).
  Listenable get changes;

  ReaderNumbersView get numbers;

  /// Onde a pessoa está (a volta de um link guarda isto).
  ReaderMark get mark;

  RefRange get shownRange;

  /// A página vizinha sem virar; `null` = começo/fim do livro.
  Future<DisplayPage?> peek(PageDirection d);

  /// Vira; `false` = começo/fim do livro.
  Future<bool> turn(PageDirection d);

  /// Vai ao destino do link; `false` = o destino não está no livro.
  Future<bool> follow(LinkHit link);

  /// Abre na página que contém [m].
  Future<void> goTo(ReaderMark m);

  /// Grava a posição pendente agora (segundo plano, sair).
  Future<void> flush();

  void dispose();
}

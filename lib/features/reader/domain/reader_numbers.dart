// G10.3 — os números do leitor (Anexo 03 §6, D-19/D-89): "pág. X de Y" = página de referência do 1º caractere
// visível / total; "%" = posição global ÷ total de caracteres (5 casas guardadas, mostrado inteiro); capítulo
// atual = a entrada do sumário que contém a posição; sumário com a página de início de cada entrada.
import 'dart:math' as math;

import '../content/book_index.dart';

/// Os números de uma posição (capítulo [spine], caractere [offset] do texto canônico dele).
final class ReaderNumbers {
  const ReaderNumbers({
    required this.refPage,
    required this.refTotal,
    required this.progression,
    required this.chapterIndex,
  });

  /// Página de referência (≥ 1) e o total.
  final int refPage;
  final int refTotal;

  /// 0…1 com 5 casas (`numeric(6,5)` no servidor).
  final double progression;

  /// Entrada do sumário (0 = a primeira) — 0 quando o livro não tem sumário.
  final int chapterIndex;

  /// "62%".
  String get percentLabel => percentOf(progression);
}

/// 0,62113 → "62%" (arredondado para inteiro — Anexo 03 §6).
String percentOf(double progression) => '${(progression * 100).round()}%';

/// Posição global (itens lineares) de ([spine], [offset]); item fora da ordem de leitura → o começo do
/// próximo item linear (ou o fim do livro).
int globalPositionOf(BookIndex index, int spine, int offset) {
  final g = index.globalOffset(spine, offset);
  if (g != null) return g;
  var at = 0;
  for (var i = 0; i < index.spine.length; i++) {
    if (i > spine && index.spine[i].linear) return at;
    if (index.spine[i].linear) at += index.spine[i].chars;
  }
  return at;
}

ReaderNumbers numbersAt(BookIndex index, int spine, int offset) {
  final total = index.totalChars;
  final g = math.min(
    math.max(0, globalPositionOf(index, spine, offset)),
    math.max(0, total),
  );
  final raw = total == 0 ? 0.0 : g / total;
  final progression = double.parse(raw.clamp(0.0, 1.0).toStringAsFixed(5));
  return ReaderNumbers(
    refPage: math.max(1, index.refPages.pageOf(g)),
    refTotal: index.refPagesTotal,
    progression: progression,
    chapterIndex: chapterIndexAt(index, g),
  );
}

/// Entrada do sumário que contém a posição global [global]: a última que começa nela ou antes.
int chapterIndexAt(BookIndex index, int global) {
  var c = 0;
  for (var i = 0; i < index.toc.length; i++) {
    final t = index.toc[i];
    if (t.spine == null) continue;
    final g = index.globalOffset(t.spine!, t.offset ?? 0);
    if (g != null && g <= global) c = i;
  }
  return c;
}

/// Página de início de cada entrada do sumário (tela 27); `null` para entrada sem lugar no texto linear.
List<int?> tocStartPages(BookIndex index) => [
  for (final t in index.toc)
    switch (t.spine) {
      final s? when index.globalOffset(s, t.offset ?? 0) != null =>
        index.refPages.pageOf(index.globalOffset(s, t.offset ?? 0)!),
      _ => null,
    },
];

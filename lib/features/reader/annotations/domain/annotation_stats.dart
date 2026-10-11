// Contagens sempre derivadas, nunca armazenadas (Anexo 02 §4.2).
import 'package:flutter/foundation.dart' show immutable, listEquals;

import '../../domain/locator.dart';
import 'annotation.dart';

/// Filtros da tela 25 ("Tudo 12 · Grifos 6 · Notas 2 · À mão 1 · Desenhos 3") e contador da tela 20.
@immutable
final class AnnotationKindCounts {
  const AnnotationKindCounts({
    required this.highlights,
    required this.notes,
    required this.handwriting,
    required this.drawings,
  });

  final int highlights;
  final int notes;
  final int handwriting;
  final int drawings;

  int get all => highlights + notes + handwriting + drawings;
}

/// Um símbolo das marcas do capítulo no sumário (tela 27).
@immutable
final class MarkSymbol {
  const MarkSymbol(this.kind, this.color);

  final AnnotationKind kind;

  /// Cor do grifo ou da tinta; nula para nota (quadradinho amarelo) e nota à mão (caneta coral),
  /// que têm desenho fixo.
  final String? color;

  @override
  bool operator ==(Object other) =>
      other is MarkSymbol && other.kind == kind && other.color == color;

  @override
  int get hashCode => Object.hash(kind, color);

  @override
  String toString() => 'MarkSymbol(${kind.code}, $color)';
}

@immutable
final class ChapterMarks {
  const ChapterMarks({required this.count, required this.symbols});

  final int count;

  /// No máximo 3, na ordem grifo → nota → desenho → nota à mão.
  final List<MarkSymbol> symbols;

  @override
  bool operator ==(Object other) =>
      other is ChapterMarks &&
      other.count == count &&
      listEquals(other.symbols, symbols);

  @override
  int get hashCode => Object.hash(count, Object.hashAll(symbols));
}

abstract final class AnnotationStats {
  static const _kindOrder = [
    AnnotationKind.highlight,
    AnnotationKind.note,
    AnnotationKind.drawing,
    AnnotationKind.handwriting,
  ];

  /// Itens não apagados do livro, por tipo.
  static AnnotationKindCounts countByKind(
    Iterable<Annotation> annotations, {
    required String userBookId,
  }) {
    final n = {for (final k in AnnotationKind.values) k: 0};
    for (final a in annotations) {
      if (a.userBookId != userBookId || a.meta.isDeleted) continue;
      n[a.kind] = n[a.kind]! + 1;
    }
    return AnnotationKindCounts(
      highlights: n[AnnotationKind.highlight]!,
      notes: n[AnnotationKind.note]!,
      handwriting: n[AnnotationKind.handwriting]!,
      drawings: n[AnnotationKind.drawing]!,
    );
  }

  /// Grifos por cor em **todos** os livros (rótulos da tela 23b — D-40).
  static Map<String, int> highlightsByColor(Iterable<Annotation> annotations) {
    final porCor = <String, int>{};
    for (final a in annotations) {
      if (a.kind != AnnotationKind.highlight || a.meta.isDeleted) continue;
      porCor[a.color!] = (porCor[a.color!] ?? 0) + 1;
    }
    return porCor;
  }

  /// Marcas de um capítulo (anotações de um livro): total e até 3 símbolos, um por (tipo, cor)
  /// — nota e nota à mão contam só pelo tipo —, cada tipo na ordem em que aparece no livro.
  static ChapterMarks chapterMarks(
    Iterable<Annotation> bookAnnotations, {
    required int chapterIndex,
  }) {
    final doCapitulo = [
      for (final a in bookAnnotations)
        if (a.chapterIndex == chapterIndex && !a.meta.isDeleted) a,
    ]..sort(_bookOrder);
    final symbols = <MarkSymbol>[];
    for (final kind in _kindOrder) {
      for (final a in doCapitulo) {
        if (a.kind != kind) continue;
        final s = MarkSymbol(
          kind,
          kind == AnnotationKind.highlight || kind == AnnotationKind.drawing
              ? a.color
              : null,
        );
        if (!symbols.contains(s)) symbols.add(s);
      }
    }
    return ChapterMarks(
      count: doCapitulo.length,
      symbols: List.unmodifiable(symbols.take(3)),
    );
  }

  static int _bookOrder(Annotation a, Annotation b) {
    final porPagina = a.refPage.compareTo(b.refPage);
    if (porPagina != 0) return porPagina;
    final porInicio = _start(a).compareTo(_start(b));
    if (porInicio != 0) return porInicio;
    return a.meta.createdAt.compareTo(b.meta.createdAt);
  }

  static int _start(Annotation a) => switch (a.anchor) {
    EpubAnchor(:final start) => start,
    RawAnchor() => 0,
  };
}

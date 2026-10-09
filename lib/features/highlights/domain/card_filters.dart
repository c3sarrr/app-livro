// G19.1 — a cor de cada item (R2), a fileira COR (D-196), os filtros sobre cartões (D-197) e as contagens dos chips
// (R1). Dart puro.
import 'package:flutter/foundation.dart' show immutable, setEquals;

import '../../reader/annotations/domain/annotation.dart';
import '../../reader/annotations/domain/annotation_stats.dart';
import 'highlight_card.dart';

/// Os chips de tipo (radiogroup "Tipo").
enum TypeFilter { all, highlights, notes, handwriting, drawings }

/// O `kind` de cada chip (Anexo 02 §4.2); Tudo = nenhum.
AnnotationKind? kindOfFilter(TypeFilter t) => switch (t) {
  TypeFilter.all => null,
  TypeFilter.highlights => AnnotationKind.highlight,
  TypeFilter.notes => AnnotationKind.note,
  TypeFilter.handwriting => AnnotationKind.handwriting,
  TypeFilter.drawings => AnnotationKind.drawing,
};

@immutable
final class HighlightFilters {
  const HighlightFilters({
    this.type = TypeFilter.all,
    this.colors = const {},
    this.clubOnly = false,
    this.query = '',
  });

  final TypeFilter type;

  /// As cores marcadas, `#RRGGBB` maiúsculo; nenhuma = sem filtro de cor.
  final Set<String> colors;
  final bool clubOnly;
  final String query;

  bool get isDefault =>
      type == TypeFilter.all &&
      colors.isEmpty &&
      !clubOnly &&
      query.trim().isEmpty;

  HighlightFilters copyWith({
    TypeFilter? type,
    Set<String>? colors,
    bool? clubOnly,
    String? query,
  }) => HighlightFilters(
    type: type ?? this.type,
    colors: colors ?? this.colors,
    clubOnly: clubOnly ?? this.clubOnly,
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) =>
      other is HighlightFilters &&
      other.type == type &&
      setEquals(other.colors, colors) &&
      other.clubOnly == clubOnly &&
      other.query == query;

  @override
  int get hashCode =>
      Object.hash(type, Object.hashAllUnordered(colors), clubOnly, query);
}

/// R2: a cor do item (`#RRGGBB` maiúsculo, como o banco guarda) — a própria; a nota, a do grifo pai; a nota à mão,
/// nenhuma.
String? itemColor(Annotation a, Map<String, Annotation> byId) =>
    switch (a.kind) {
      AnnotationKind.note => byId[a.parentId]?.color,
      AnnotationKind.handwriting => null,
      _ => a.color,
    };

/// O item passa no tipo, nas cores, no clube e na busca ([hits] = os ids achados; `null` = sem busca).
bool itemPasses(
  Annotation a,
  HighlightFilters f,
  Map<String, Annotation> byId,
  Set<String>? hits,
) {
  final k = kindOfFilter(f.type);
  if (k != null && a.kind != k) return false;
  if (f.colors.isNotEmpty && !f.colors.contains(itemColor(a, byId))) {
    return false;
  }
  if (f.clubOnly && a.sharedClubPostId == null) return false;
  if (hits != null && !hits.contains(a.id)) return false;
  return true;
}

/// D-197: os cartões em que algum item passa (o cartão aparece inteiro).
List<HighlightCard> filterCards(
  List<HighlightCard> cards,
  HighlightFilters f, {
  Set<String>? hits,
}) {
  final byId = {
    for (final c in cards)
      for (final a in c.items) a.id: a,
  };
  return [
    for (final c in cards)
      if (c.items.any((a) => itemPasses(a, f, byId, hits))) c,
  ];
}

/// Uma caixa da fileira COR: a cor, a chave (`hl.filters.colors.<key>`) e o rótulo do leitor de tela.
typedef ColorChoice = ({String hex, String key, String label});

/// As 4 do marca-texto (L25b), na ordem do arquivo.
const List<ColorChoice> markerChoices = [
  (hex: '#FED170', key: 'yellow', label: 'Amarelo'),
  (hex: '#FFC1C6', key: 'pink', label: 'Rosa'),
  (hex: '#ABCF82', key: 'green', label: 'Verde'),
  (hex: '#B6ACE4', key: 'lavender', label: 'Lavanda'),
];

/// As favoritas da caneta (tela 23) como tinta ("Tinta coral" é o rótulo do arquivo).
const Map<String, String> _inkLabels = {
  '#FF552E': 'Tinta coral',
  '#552CB7': 'Tinta roxa',
  '#058CD7': 'Tinta azul',
  '#00995E': 'Tinta verde',
  '#F2A815': 'Tinta dourada',
  '#1A1714': 'Tinta preta',
};

/// D-196: as 4 do marca-texto e as outras cores do livro, na ordem do primeiro uso (criação).
List<ColorChoice> colorRow(Iterable<Annotation> items) {
  final byId = {for (final a in items) a.id: a};
  final byCreation = [...items]
    ..sort((a, b) => a.meta.createdAt.compareTo(b.meta.createdAt));
  final extra = <String>[];
  for (final a in byCreation) {
    final c = itemColor(a, byId);
    if (c == null ||
        markerChoices.any((m) => m.hex == c) ||
        extra.contains(c)) {
      continue;
    }
    extra.add(c);
  }
  return [
    ...markerChoices,
    for (final c in extra)
      (
        hex: c,
        key: c == '#FF552E' ? 'coral' : 'c${c.substring(1).toLowerCase()}',
        label: _inkLabels[c] ?? 'Outra cor',
      ),
  ];
}

/// R1: os totais do livro por tipo (os números dos chips), sem os filtros.
AnnotationKindCounts kindCounts(List<Annotation> items) =>
    AnnotationStats.countByKind(
      items,
      userBookId: items.firstOrNull?.userBookId ?? '',
    );

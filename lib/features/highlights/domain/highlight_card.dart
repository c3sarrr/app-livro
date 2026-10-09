// G19.1 — os cartões da tela 25: um por `group_id` (D-30, Anexo 02 §4.3), na ordem do 1º item (a do livro), e o
// rótulo de cada um (R4): a pílula principal com a bolinha, as pílulas NOTA e À MÃO e o rótulo do leitor de tela.
// Dart puro.
import 'package:flutter/foundation.dart' show immutable, listEquals;

import '../../../core/design_system/color/color_names.dart';
import '../../reader/annotations/domain/annotation.dart';

/// O que dá nome ao cartão: um grifo, desenhos ou só a nota à mão.
enum CardKind { highlight, drawing, handwriting }

@immutable
final class HighlightCard {
  HighlightCard(this.groupId, List<Annotation> items)
    : assert(items.isNotEmpty, 'cartão sem item'),
      items = List.unmodifiable(items);

  final String groupId;

  /// Na ordem do livro.
  final List<Annotation> items;

  /// A página do 1º item.
  int get page => items.first.refPage;

  /// A criação mais antiga do grupo (a data do cartão).
  DateTime get createdAt => items
      .map((a) => a.meta.createdAt)
      .reduce((a, b) => a.isBefore(b) ? a : b);

  List<Annotation> _of(AnnotationKind k) => [
    for (final a in items)
      if (a.kind == k) a,
  ];

  Annotation? get highlight => _of(AnnotationKind.highlight).firstOrNull;
  List<Annotation> get notes => _of(AnnotationKind.note);
  List<Annotation> get drawings => _of(AnnotationKind.drawing);
  List<Annotation> get handwriting => _of(AnnotationKind.handwriting);

  /// O post do clube de algum item do cartão (o chip "Leitoras de Capitu · 3 respostas").
  String? get clubPostId =>
      items.map((a) => a.sharedClubPostId).nonNulls.firstOrNull;

  CardKind get kind => highlight != null
      ? CardKind.highlight
      : drawings.isNotEmpty
      ? CardKind.drawing
      : CardKind.handwriting;

  /// A pílula principal: GRIFO, DESENHO, "N DESENHOS" ou À MÃO.
  String get label => switch (kind) {
    CardKind.highlight => 'GRIFO',
    CardKind.drawing =>
      drawings.length == 1 ? 'DESENHO' : '${drawings.length} DESENHOS',
    CardKind.handwriting => 'À MÃO',
  };

  /// A cor da bolinha da pílula principal; `null` = sem bolinha (À MÃO).
  String? get dot => switch (kind) {
    CardKind.highlight => highlight!.color,
    CardKind.drawing => drawings.first.color,
    CardKind.handwriting => null,
  };

  /// A pílula amarela NOTA.
  bool get hasNotePill => notes.isNotEmpty;

  /// A pílula À MÃO ao lado da principal.
  bool get hasHandPill =>
      kind != CardKind.handwriting && handwriting.isNotEmpty;

  /// O grifo veio da tinta (o marca-texto — a mancha da D-161).
  bool get freehand => highlight?.source == AnnotationSource.ink;

  @override
  bool operator ==(Object other) =>
      other is HighlightCard &&
      other.groupId == groupId &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(groupId, Object.hashAll(items));
}

/// Os cartões de [inBookOrder] (vivos, na ordem do `forBook`), na ordem do 1º item de cada grupo.
List<HighlightCard> buildCards(Iterable<Annotation> inBookOrder) {
  final groups = <String, List<Annotation>>{};
  for (final a in inBookOrder) {
    (groups[a.groupId] ??= []).add(a);
  }
  return [for (final e in groups.entries) HighlightCard(e.key, e.value)];
}

const List<String> _numbers = [
  'Dois',
  'Três',
  'Quatro',
  'Cinco',
  'Seis',
  'Sete',
  'Oito',
  'Nove',
  'Dez',
];

/// "Desenho", "Dois desenhos"…"Dez desenhos", "11 desenhos".
String drawingsWord(int n) => n == 1
    ? 'Desenho'
    : n <= 10
    ? '${_numbers[n - 2]} desenhos'
    : '$n desenhos';

/// R4: o rótulo do cartão para o leitor de tela ("Grifo rosa com nota, página 6").
String cardSemanticsLabel(HighlightCard c) {
  final base = switch (c.kind) {
    CardKind.highlight when c.freehand => 'Grifo à mão livre',
    CardKind.highlight =>
      'Grifo ${markerColorName(c.highlight!.color!) ?? 'de outra cor'}',
    CardKind.drawing => drawingsWord(c.drawings.length),
    CardKind.handwriting => 'Nota à mão',
  };
  final extras = [if (c.hasNotePill) 'nota', if (c.hasHandPill) 'nota à mão'];
  final joined = extras.isEmpty
      ? base
      : c.kind == CardKind.highlight
      ? '$base com ${extras.join(' e ')}'
      : '$base e ${extras.join(' e ')}';
  final club = c.clubPostId == null ? '' : ', compartilhado no clube';
  return '$joined$club, página ${c.page}';
}

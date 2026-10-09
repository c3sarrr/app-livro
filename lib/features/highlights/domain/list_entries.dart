// G19.1 — as entradas da lista da tela 25, na ordem do livro: o separador de cada página (o da posição atual vira
// "você parou aqui" — R6; sozinho, no lugar da página, quando ela não tem cartão), os cartões e, no fim, os grifos sem
// lugar (D-199), depois do separador cinza. Os números (`hl.list.sep<n>`, `hl.list.card<n>`) contam o que aparece.
// Dart puro.
import 'package:flutter/foundation.dart' show immutable;

import 'highlight_card.dart';

sealed class ListEntry {
  const ListEntry();
}

/// O separador "pág. N" (ou "pág. N · você parou aqui", com [here]).
@immutable
final class PageMark extends ListEntry {
  const PageMark(this.page, this.n, {this.here = false});

  final int page;

  /// 1, 2, 3…
  final int n;
  final bool here;

  @override
  bool operator ==(Object other) =>
      other is PageMark &&
      other.page == page &&
      other.n == n &&
      other.here == here;

  @override
  int get hashCode => Object.hash(page, n, here);
}

@immutable
final class CardItem extends ListEntry {
  const CardItem(this.card, this.n, {this.orphan = false});

  final HighlightCard card;

  /// 1, 2, 3…
  final int n;

  /// Sem lugar no texto (D-199).
  final bool orphan;

  @override
  bool operator ==(Object other) =>
      other is CardItem &&
      other.card == card &&
      other.n == n &&
      other.orphan == orphan;

  @override
  int get hashCode => Object.hash(card, n, orphan);
}

/// O separador cinza "sem lugar no texto".
final class OrphanMark extends ListEntry {
  const OrphanMark();

  @override
  bool operator ==(Object other) => other is OrphanMark;

  @override
  int get hashCode => 0;
}

List<ListEntry> listEntries(
  List<HighlightCard> visible, {
  int? herePage,
  Set<String> orphanGroups = const {},
}) {
  final placed = [
    for (final c in visible)
      if (!orphanGroups.contains(c.groupId)) c,
  ];
  final orphans = [
    for (final c in visible)
      if (orphanGroups.contains(c.groupId)) c,
  ];
  final out = <ListEntry>[];
  var sep = 0;
  var card = 0;
  int? last;
  var hereDone = herePage == null || visible.isEmpty;
  for (final c in placed) {
    if (!hereDone && herePage! < c.page) {
      out.add(PageMark(herePage, ++sep, here: true));
      hereDone = true;
    }
    if (c.page != last) {
      final here = c.page == herePage;
      if (here) hereDone = true;
      out.add(PageMark(c.page, ++sep, here: here));
      last = c.page;
    }
    out.add(CardItem(c, ++card));
  }
  if (!hereDone) out.add(PageMark(herePage!, ++sep, here: true));
  if (orphans.isNotEmpty) {
    out.add(const OrphanMark());
    for (final c in orphans) {
      out.add(CardItem(c, ++card, orphan: true));
    }
  }
  return out;
}

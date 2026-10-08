// G17.4 — os grifos da página na sessão do modo anotação (D-173): os de seleção e os à mão, com o lugar de agora, a
// cor, o estilo, a altura, o grupo e a data de criação. Cada trecho do Marca-texto passa pela mesma `planHighlight`
// da tela 21 (D-32) contra os do mesmo item: unidos ficam com o jeito do mais antigo; os pedaços cortados mantêm cor,
// estilo, altura, grupo e origem; os que somem deixam o destino das notas. A Borracha tira só os à mão (D-168). Valor
// imutável: o desfazer guarda a mesa de antes e a de depois. Dart puro.
import 'package:flutter/foundation.dart'
    show immutable, listEquals, mapEquals, setEquals;

import '../domain/annotation.dart' show FillHeight, HighlightStyle;
import '../domain/highlight_overlap.dart';
import 'marker_snap.dart' show MarkedRun;

@immutable
final class DeskHighlight {
  const DeskHighlight({
    required this.id,
    required this.unit,
    required this.start,
    required this.end,
    required this.color,
    required this.style,
    required this.height,
    required this.ink,
    required this.groupId,
    required this.createdAt,
  });

  final String id;
  final int unit;
  final int start;
  final int end;

  /// `#RRGGBB`.
  final String color;
  final HighlightStyle style;

  /// Só no fundo.
  final FillHeight? height;

  /// Feito à mão (`source = ink`): a mancha; senão, de seleção.
  final bool ink;
  final String groupId;
  final DateTime createdAt;

  DeskHighlight copyWith({
    String? id,
    int? start,
    int? end,
    DateTime? createdAt,
  }) => DeskHighlight(
    id: id ?? this.id,
    unit: unit,
    start: start ?? this.start,
    end: end ?? this.end,
    color: color,
    style: style,
    height: height,
    ink: ink,
    groupId: groupId,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is DeskHighlight &&
      other.id == id &&
      other.unit == unit &&
      other.start == start &&
      other.end == end &&
      other.color == color &&
      other.style == style &&
      other.height == height &&
      other.ink == ink &&
      other.groupId == groupId &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    unit,
    start,
    end,
    color,
    style,
    height,
    ink,
    groupId,
    createdAt,
  );

  @override
  String toString() =>
      'DeskHighlight($id, $unit, $start…$end, $color, ${style.name}, ink: $ink)';
}

@immutable
final class HighlightDesk {
  const HighlightDesk(
    this.items, {
    this.removed = const {},
    this.erased = const {},
  });

  static const HighlightDesk empty = HighlightDesk([]);

  /// Os grifos vivos.
  final List<DeskHighlight> items;

  /// Os que a D-32 tirou, com o grifo para onde vão as notas de cada um.
  final Map<String, String> removed;

  /// Os à mão que a Borracha apagou (as notas vão junto — D-168).
  final Set<String> erased;

  DeskHighlight? byId(String id) {
    for (final h in items) {
      if (h.id == id) return h;
    }
    return null;
  }

  /// O trecho [r] grifado com [color], [style] e [height] pela D-32. [id] e [groupId] = os do grifo novo (se ele não
  /// se juntar a um mais antigo); [newId] dá os ids dos pedaços cortados.
  HighlightDesk mark(
    MarkedRun r, {
    required String color,
    required HighlightStyle style,
    required FillHeight? height,
    required String id,
    required String groupId,
    required DateTime at,
    required String Function() newId,
  }) {
    final same = [
      for (final h in items)
        if (h.unit == r.unit) h,
    ];
    final plan = planHighlight(
      [
        for (final h in same)
          (
            id: h.id,
            start: h.start,
            end: h.end,
            color: h.color,
            style: h.style,
            createdAt: h.createdAt,
          ),
      ],
      (start: r.from, end: r.to, color: color, style: style),
    );
    final byId = {for (final h in same) h.id: h};
    final keep = plan.keepId == null ? null : byId[plan.keepId];
    final resized = {for (final x in plan.resized) x.id: x};
    final gone = plan.removed.toSet();
    final next = <DeskHighlight>[];
    for (final h in items) {
      if (h.unit != r.unit) {
        next.add(h);
        continue;
      }
      if (gone.contains(h.id)) continue;
      if (h.id == keep?.id) {
        next.add(h.copyWith(start: plan.start, end: plan.end));
        continue;
      }
      final x = resized[h.id];
      next.add(x == null ? h : h.copyWith(start: x.start, end: x.end));
    }
    if (keep == null) {
      next.add(
        DeskHighlight(
          id: id,
          unit: r.unit,
          start: plan.start,
          end: plan.end,
          color: color,
          style: style,
          height: style == HighlightStyle.fill ? height : null,
          ink: true,
          groupId: groupId,
          createdAt: at,
        ),
      );
    }
    for (final a in plan.added) {
      next.add(
        byId[a.from]!.copyWith(
          id: newId(),
          start: a.start,
          end: a.end,
          createdAt: at,
        ),
      );
    }
    final target = keep?.id ?? id;
    return HighlightDesk(
      List.unmodifiable(next),
      removed: Map.unmodifiable({
        ...removed,
        for (final g in plan.removed) g: plan.notesTo[g] ?? target,
      }),
      erased: erased,
    );
  }

  /// A Borracha: tira os à mão de [ids] (os de seleção ficam — D-168).
  HighlightDesk erase(Iterable<String> ids) {
    final want = ids.toSet();
    final out = {
      for (final h in items)
        if (h.ink && want.contains(h.id)) h.id,
    };
    if (out.isEmpty) return this;
    return HighlightDesk(
      List.unmodifiable([
        for (final h in items)
          if (!out.contains(h.id)) h,
      ]),
      removed: removed,
      erased: Set.unmodifiable({...erased, ...out}),
    );
  }

  /// Para onde vão as notas de [id] (seguindo os tirados em cadeia); o próprio, se ele ficou.
  String targetOf(String id) {
    var t = id;
    final seen = <String>{};
    while (removed.containsKey(t) && seen.add(t)) {
      t = removed[t]!;
    }
    return t;
  }

  /// Quantos grifos vivos de cada cor (D-40, a parte da página).
  Map<String, int> counts() {
    final out = <String, int>{};
    for (final h in items) {
      out[h.color] = (out[h.color] ?? 0) + 1;
    }
    return out;
  }

  @override
  bool operator ==(Object other) =>
      other is HighlightDesk &&
      listEquals(other.items, items) &&
      mapEquals(other.removed, removed) &&
      setEquals(other.erased, erased);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(items),
    Object.hashAllUnordered(
      removed.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAllUnordered(erased),
  );
}

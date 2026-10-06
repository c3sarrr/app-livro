// G13.2 — grifos que se cruzam (D-32, D-136), numa função pura. Mesma cor e mesmo estilo: os que cruzam ou
// encostam no pedido viram um só (fica o mais antigo; as notas dos outros vão para ele). Cor ou estilo diferente:
// o pedido entra inteiro e cada antigo perde o trecho coberto, sobrando em até 2 pedaços (o da esquerda mantém a
// identidade, o grupo e as notas; sobrando só o da direita, ele mantém; sumindo todo, as notas vão para quem fica).
import 'annotation.dart' show HighlightStyle;

/// Um grifo vivo do mesmo item do spine, onde ele está agora.
typedef HighlightSpan = ({
  String id,
  int start,
  int end,
  String color,
  HighlightStyle style,
  DateTime createdAt,
});

/// O grifo pedido (seleção → cor, Sublinhar, Nota).
typedef HighlightRequest = ({
  int start,
  int end,
  String color,
  HighlightStyle style,
});

/// O que gravar. [start]…[end] = o grifo pedido já unido; [keepId] = o antigo que vira ele (senão é novo);
/// [resized] = antigos que encolhem; [added] = pedaços da direita (grifos novos com a cor, o estilo e o grupo de
/// `from`); [removed] = os que somem; [notesTo] = para quem vão as notas de cada um que some (`null` = o pedido).
final class OverlapPlan {
  const OverlapPlan({
    required this.start,
    required this.end,
    this.keepId,
    this.resized = const [],
    this.added = const [],
    this.removed = const [],
    this.notesTo = const {},
  });

  final int start;
  final int end;
  final String? keepId;
  final List<({String id, int start, int end})> resized;
  final List<({String from, int start, int end})> added;
  final List<String> removed;
  final Map<String, String?> notesTo;
}

/// O plano para gravar [next] sobre os grifos [existing] do mesmo item (D-32).
OverlapPlan planHighlight(List<HighlightSpan> existing, HighlightRequest next) {
  bool same(HighlightSpan h) => h.color == next.color && h.style == next.style;
  var start = next.start;
  var end = next.end;
  final merged = <HighlightSpan>[];
  // a união cresce até parar: o pedido pode encostar num que encosta noutro da mesma cor
  for (var grew = true; grew;) {
    grew = false;
    for (final h in existing) {
      if (!same(h) || merged.contains(h)) continue;
      if (h.start <= end && h.end >= start) {
        merged.add(h);
        if (h.start < start) start = h.start;
        if (h.end > end) end = h.end;
        grew = true;
      }
    }
  }
  merged.sort((a, b) {
    final c = a.createdAt.compareTo(b.createdAt);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  final keep = merged.isEmpty ? null : merged.first.id;
  final removed = <String>[for (final h in merged.skip(1)) h.id];
  final notesTo = <String, String?>{for (final id in removed) id: keep};
  final resized = <({String id, int start, int end})>[];
  final added = <({String from, int start, int end})>[];
  for (final h in existing) {
    if (merged.contains(h)) continue;
    if (h.end <= start || h.start >= end) continue; // encostar não corta
    final left = h.start < start ? (start: h.start, end: start) : null;
    final right = h.end > end ? (start: end, end: h.end) : null;
    if (left == null && right == null) {
      removed.add(h.id);
      notesTo[h.id] = keep;
      continue;
    }
    final kept = left ?? right!;
    resized.add((id: h.id, start: kept.start, end: kept.end));
    if (left != null && right != null) {
      added.add((from: h.id, start: right.start, end: right.end));
    }
  }
  return OverlapPlan(
    start: start,
    end: end,
    keepId: keep,
    resized: resized,
    added: added,
    removed: removed,
    notesTo: notesTo,
  );
}

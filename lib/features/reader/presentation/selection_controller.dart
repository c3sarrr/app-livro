// G13.3 — o trecho selecionado (tela 21). Começa na pressão longa (a palavra), o fim cresce arrastando sem soltar e
// as alças movem as bordas: por palavra; por letra depois de 300 ms parado, com a lupa (D-45). Fica dentro da página
// (D-47) e com pelo menos 1 letra. Na barra de um grifo existente, guarda o id dele (D-132) e não tem fundo nem
// alças, só a barra (D-137).
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Offset;

import '../layout/display_page.dart';

/// Qual alça: a do começo ou a do fim.
enum SelectionHandle { start, end }

@immutable
final class ReaderSelection {
  const ReaderSelection({
    required this.range,
    this.highlightId,
    this.anchor,
    this.dragging,
    this.byChar = false,
    this.finger,
  });

  final ReaderRange range;

  /// O grifo existente cuja barra está aberta (D-132); `null` = seleção nova.
  final String? highlightId;

  /// A palavra da pressão longa (arrastar sem soltar cresce a partir dela).
  final ReaderRange? anchor;

  /// A alça que está sendo arrastada.
  final SelectionHandle? dragging;

  /// A lupa abriu: a alça anda por letra até soltar (D-45).
  final bool byChar;

  /// Onde está o dedo que arrasta a alça (a lupa).
  final Offset? finger;
}

final class SelectionController extends ChangeNotifier
    implements ValueListenable<ReaderRange?> {
  ReaderSelection? _s;

  ReaderSelection? get selection => _s;
  bool get active => _s != null;

  @override
  ReaderRange? get value => _s?.range;

  /// O fundo da seleção (o pintor e a lupa): no grifo existente, nenhum — só a barra (D-137).
  late final ValueListenable<ReaderRange?> fill = _Fill(this);

  void _set(ReaderSelection? s) {
    _s = s;
    notifyListeners();
  }

  /// A pressão longa escolheu [word].
  void selectWord(ReaderRange word) =>
      _set(ReaderSelection(range: word, anchor: word));

  /// O toque num grifo existente abre a barra dele (D-132).
  void showHighlight(String id, ReaderRange range) =>
      _set(ReaderSelection(range: range, highlightId: id));

  /// Arrastar sem soltar depois da pressão longa.
  void setRange(ReaderRange r) {
    final s = _s;
    if (s == null || s.range == r) return;
    _set(
      ReaderSelection(
        range: r,
        highlightId: s.highlightId,
        anchor: s.anchor,
        dragging: s.dragging,
        byChar: s.byChar,
        finger: s.finger,
      ),
    );
  }

  /// O dedo pegou a alça [h].
  void beginDrag(SelectionHandle h, Offset finger) {
    final s = _s;
    if (s == null) return;
    _set(
      ReaderSelection(
        range: s.range,
        highlightId: s.highlightId,
        dragging: h,
        finger: finger,
      ),
    );
  }

  /// 300 ms parado com a alça: a lupa abre e a alça anda por letra (D-45).
  void enterCharMode() {
    final s = _s;
    if (s == null || s.dragging == null || s.byChar) return;
    _set(
      ReaderSelection(
        range: s.range,
        highlightId: s.highlightId,
        dragging: s.dragging,
        byChar: true,
        finger: s.finger,
      ),
    );
  }

  /// A alça arrastada foi para [p].
  void dragTo(DisplayPage page, Offset p) {
    final s = _s;
    final h = s?.dragging;
    if (s == null || h == null) return;
    _set(
      ReaderSelection(
        range: moveEdge(page, s.range, h, p, byChar: s.byChar),
        highlightId: s.highlightId,
        dragging: h,
        byChar: s.byChar,
        finger: p,
      ),
    );
  }

  /// Soltou a alça.
  void endDrag() {
    final s = _s;
    if (s == null || s.dragging == null) return;
    _set(ReaderSelection(range: s.range, highlightId: s.highlightId));
  }

  void clear() {
    if (_s == null) return;
    _set(null);
  }
}

final class _Fill implements ValueListenable<ReaderRange?> {
  _Fill(this._c);
  final SelectionController _c;

  @override
  ReaderRange? get value => _c._s?.highlightId == null ? _c.value : null;

  @override
  void addListener(VoidCallback listener) => _c.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _c.removeListener(listener);
}

/// A seleção quando a alça [h] vai para [p] (D-45, D-47): por palavra, a borda vai ao fim (alça final) ou ao
/// começo (inicial) da palavra sob o dedo; por letra, ao ponto entre as letras. Sempre dentro da página e com pelo
/// menos 1 letra.
ReaderRange moveEdge(
  DisplayPage page,
  ReaderRange r,
  SelectionHandle h,
  Offset p, {
  required bool byChar,
}) {
  final s = page.spotAt(p);
  final shown = page.shown;
  if (s == null || shown == null || s.unit != r.unit) return r;
  var at = s.offset;
  if (!byChar) {
    final w =
        page.wordAround(s) ??
        (s.offset > shown.from
            ? page.wordAround((unit: s.unit, offset: s.offset - 1))
            : null);
    if (w != null) at = h == SelectionHandle.end ? w.to : w.from;
  }
  at = at.clamp(shown.from, shown.to);
  return h == SelectionHandle.end
      ? (unit: r.unit, from: r.from, to: math.max(at, r.from + 1))
      : (unit: r.unit, from: math.min(at, r.to - 1), to: r.to);
}

/// Arrastar sem soltar depois da pressão longa (D-136): o fim vai ao fim da palavra sob [p]; o início fica no da
/// palavra [anchor] (para trás dela, fica só ela).
ReaderRange extendFrom(DisplayPage page, ReaderRange anchor, Offset p) {
  final end = moveEdge(page, anchor, SelectionHandle.end, p, byChar: false);
  return (
    unit: anchor.unit,
    from: anchor.from,
    to: math.max(anchor.to, end.to),
  );
}

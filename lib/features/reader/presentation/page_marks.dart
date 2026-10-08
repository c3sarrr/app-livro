// G13.1 — o que a página pinta além do texto do livro (Anexo 03 §9.2, prancha 21): por trás das letras, o fundo
// dos grifos, a seleção e a marca da busca; por cima, o sublinhado. Onde dois fundos se cruzam vale o de prioridade
// maior (seleção > busca > grifo): o outro é recortado naquela linha. Com letras claras (o Noite), todo fundo usa a
// técnica da D-127 (D-133). Nada de camada. G17: o fundo na altura de cada grifo (D-172) e o ondulado (R25).
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../annotations/domain/annotation.dart' show FillHeight, HighlightStyle;
import '../annotations/domain/highlight_band.dart';
import '../layout/display_page.dart';
import 'wavy_underline.dart';

/// Um grifo pronto para pintar.
@immutable
final class PaintedHighlight {
  const PaintedHighlight({
    required this.id,
    required this.range,
    required this.color,
    required this.style,
    this.height = FillHeight.medium,
  });

  final String id;
  final ReaderRange range;
  final ui.Color color;
  final HighlightStyle style;

  /// A altura do fundo (D-172); no sublinhado e no ondulado, não conta.
  final FillHeight height;

  @override
  bool operator ==(Object other) =>
      other is PaintedHighlight &&
      other.id == id &&
      other.range == range &&
      other.color == color &&
      other.style == style &&
      other.height == height;

  @override
  int get hashCode => Object.hash(id, range, color, style, height);
}

/// Quem sabe os grifos de um trecho mostrado (o `ReaderAnnotations`; nos testes, uma lista).
abstract interface class HighlightSource implements Listenable {
  List<PaintedHighlight> highlightsIn(ReaderRange shown);
}

/// Grifo de fundo (prancha 21): a faixa vai de 12 % a 92 % da área do texto (a Média; as outras alturas pela
/// `fillBand` — D-172), com raio 3, na cor a 85 %.
const double highlightAlpha = 0.85;
const double highlightRadius = 3;

/// Seleção (L21a nº 9): a `brand` a 62 %, raio 2, na área do texto.
const double selectionAlpha = 0.62;
const double selectionRadius = 2;

/// Sublinhado (tela 23b, medido na prancha): 4 px, a partir de 3 px abaixo da linha de base.
const double underlineOffset = 3;
const double underlineThickness = 4;

/// Marca da busca (G12): a caixa das letras 1 px maior, raio 3.
const double foundInflate = 1;
const double foundRadius = 3;

/// Um fundo numa linha: o retângulo arredondado, o corte vertical opcional (a faixa do grifo), a cor, a
/// prioridade (0 = grifo, 1 = busca, 2 = seleção) e a linha (o topo das letras dela).
typedef MarkBand = ({
  double left,
  double right,
  double top,
  double bottom,
  double radius,
  double? clipTop,
  double? clipBottom,
  ui.Color color,
  int priority,
  double line,
});

/// Os fundos da página: grifos de fundo, marca da busca e seleção, já recortados por prioridade. Com letras
/// claras ([night]) as cores ficam opacas (a técnica da D-127 precisa da cor viva — D-133).
List<MarkBand> backgroundBands(
  DisplayPage page, {
  List<PaintedHighlight> highlights = const [],
  ReaderRange? found,
  ui.Color? foundColor,
  ReaderRange? selection,
  ui.Color? selectionColor,
  bool night = false,
}) {
  ui.Color tone(ui.Color c, double a) => c.withValues(alpha: night ? 1 : a);
  final out = <MarkBand>[];
  for (final h in highlights) {
    if (h.style != HighlightStyle.fill) continue;
    final (top, bottom) = fillBand(h.height);
    for (final b in page.boxesOf(h.range.unit, h.range.from, h.range.to)) {
      final area = b.textBottom - b.textTop;
      out.add((
        left: b.rect.left,
        right: b.rect.right,
        top: b.textTop,
        bottom: b.textBottom,
        radius: highlightRadius,
        clipTop: b.textTop + top * area,
        clipBottom: b.textTop + bottom * area,
        color: tone(h.color, highlightAlpha),
        priority: 0,
        line: b.rect.top,
      ));
    }
  }
  if (found != null && foundColor != null) {
    for (final b in page.boxesOf(found.unit, found.from, found.to)) {
      final r = b.rect.inflate(foundInflate);
      out.add((
        left: r.left,
        right: r.right,
        top: r.top,
        bottom: r.bottom,
        radius: foundRadius,
        clipTop: null,
        clipBottom: null,
        color: foundColor,
        priority: 1,
        line: b.rect.top,
      ));
    }
  }
  if (selection != null && selectionColor != null) {
    for (final b in page.boxesOf(
      selection.unit,
      selection.from,
      selection.to,
    )) {
      out.add((
        left: b.rect.left,
        right: b.rect.right,
        top: b.textTop,
        bottom: b.textBottom,
        radius: selectionRadius,
        clipTop: null,
        clipBottom: null,
        color: tone(selectionColor, selectionAlpha),
        priority: 2,
        line: b.rect.top,
      ));
    }
  }
  return cutBands(out);
}

/// Recorta cada fundo pelos de prioridade maior na mesma linha (a ordem dos que sobram é a de entrada).
List<MarkBand> cutBands(List<MarkBand> bands) {
  final out = <MarkBand>[];
  for (final b in bands) {
    var pieces = [(b.left, b.right)];
    for (final o in bands) {
      if (o.priority <= b.priority || (o.line - b.line).abs() > 0.5) continue;
      pieces = [
        for (final (l, r) in pieces) ...cutInterval(l, r, o.left, o.right),
      ];
    }
    for (final (l, r) in pieces) {
      if (r - l > 0.01) {
        out.add((
          left: l,
          right: r,
          top: b.top,
          bottom: b.bottom,
          radius: b.radius,
          clipTop: b.clipTop,
          clipBottom: b.clipBottom,
          color: b.color,
          priority: b.priority,
          line: b.line,
        ));
      }
    }
  }
  return out;
}

/// [l]…[r] sem [a]…[z].
List<(double, double)> cutInterval(double l, double r, double a, double z) {
  if (z <= l || a >= r) return [(l, r)];
  return [if (a > l) (l, a), if (z < r) (z, r)];
}

/// Pinta um fundo em [color] com [mode] (a faixa do grifo é um corte do retângulo arredondado).
void paintBand(
  ui.Canvas canvas,
  MarkBand b,
  ui.Color color, [
  ui.BlendMode mode = ui.BlendMode.srcOver,
]) {
  final paint = ui.Paint()
    ..color = color
    ..blendMode = mode;
  final shape = ui.RRect.fromLTRBR(
    b.left,
    b.top,
    b.right,
    b.bottom,
    ui.Radius.circular(b.radius),
  );
  final top = b.clipTop;
  final bottom = b.clipBottom;
  if (top == null || bottom == null) {
    canvas.drawRRect(shape, paint);
    return;
  }
  canvas
    ..save()
    ..clipRect(ui.Rect.fromLTRB(b.left, top, b.right, bottom))
    ..drawRRect(shape, paint)
    ..restore();
}

/// Os sublinhados e os ondulados (R25) dos grifos, na cor viva, por cima do texto.
void paintUnderlines(
  ui.Canvas canvas,
  DisplayPage page,
  List<PaintedHighlight> highlights,
) {
  for (final h in highlights) {
    if (h.style == HighlightStyle.fill) continue;
    final boxes = page.boxesOf(h.range.unit, h.range.from, h.range.to);
    if (h.style == HighlightStyle.wavy) {
      for (final b in boxes) {
        paintWavyUnderline(
          canvas,
          b.rect.left,
          b.rect.right,
          b.baseline,
          h.color,
        );
      }
      continue;
    }
    final paint = ui.Paint()..color = h.color.withValues(alpha: 1);
    for (final b in boxes) {
      canvas.drawRect(
        ui.Rect.fromLTRB(
          b.rect.left,
          b.baseline + underlineOffset,
          b.rect.right,
          b.baseline + underlineOffset + underlineThickness,
        ),
        paint,
      );
    }
  }
}

/// D-127/D-133: o maior de letra e cor em cada canal.
ui.Color channelMax(ui.Color a, ui.Color b) => ui.Color.from(
  alpha: 1,
  red: math.max(a.r, b.r),
  green: math.max(a.g, b.g),
  blue: math.max(a.b, b.b),
);

/// D-127/D-133: a diferença canal a canal.
ui.Color channelMinus(ui.Color a, ui.Color b) =>
    ui.Color.from(alpha: 1, red: a.r - b.r, green: a.g - b.g, blue: a.b - b.b);

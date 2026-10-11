// G18 — a geometria das peças do Espaço (pranchas 24 e 24b), em números do arquivo, sem pintar nada: o abridor na
// área tracejada (L24.1–L24.2), a caixa da nota à mão (L24b.1–L24b.4) e a faixa recolhida (D-184). A pintura, os
// botões e os testes usam as mesmas contas.
import 'dart:ui';

import 'space_metrics.dart';

export 'space_metrics.dart' show noteBorder;

/// O abridor: a área, a costura (4 para dentro, 1 acima, 2,5 de altura), as bolinhas de 10 nas pontas, o rastro
/// (24 de largura, do topo da área até 18 acima da base), o dedo (42, centrado no x dele, na borda de baixo) e o
/// lugar do chip (a 14 da esquerda, 28 de altura, no meio da área — a largura é a do texto).
typedef OpenerParts = ({
  Rect area,
  Rect seam,
  Rect dotLeft,
  Rect dotRight,
  Rect trail,
  Rect finger,
  Rect chip,
});

OpenerParts openerLayout(Rect area, double fingerX) => (
  area: area,
  seam: Rect.fromLTWH(area.left + 4, area.top - 1, area.width - 8, 2.5),
  dotLeft: Rect.fromLTWH(area.left, area.top - 4.5, 10, 10),
  dotRight: Rect.fromLTWH(area.right - 10, area.top - 4.5, 10, 10),
  trail: Rect.fromLTWH(fingerX - 12, area.top + 2, 24, area.height - 18),
  finger: Rect.fromCircle(center: Offset(fingerX, area.bottom), radius: 21),
  chip: Rect.fromLTWH(area.left + 14, area.center.dy - 14, 0, 28),
);

/// A caixa da nota à mão de [lines] linhas [box] (a caixa com a borda, sem as margens). Por dentro da borda: a
/// etiqueta (a 14 da esquerda, 13 acima; 24 de altura — a largura é a do texto), as pautas (a 12 dos lados, 1,5), os
/// botões de 40 (a 12 da direita, 20 acima, 6 entre eles), o pé da dica (a 14 da esquerda, 8 acima da borda de
/// baixo), a alça (52 × 22, centrada, 12 abaixo da borda) e as duas barras dela (20 × 1,6, 3 entre elas). A tinta
/// fica no [inkFrame] (a caixa por dentro da borda).
typedef HandNoteParts = ({
  Rect box,
  Offset tag,
  List<Rect> rules,
  Rect collapse,
  Rect delete,
  Offset hintBottomLeft,
  Rect handle,
  Rect bar1,
  Rect bar2,
});

HandNoteParts handNoteLayout(Rect box, int lines) {
  final inner = inkFrame(box);
  final delete = Rect.fromLTWH(inner.right - 12 - 40, inner.top - 20, 40, 40);
  final handle = Rect.fromLTWH(
    inner.center.dx - 26,
    inner.bottom + 12 - 22,
    52,
    22,
  );
  final barsTop = handle.center.dy - (1.6 + 3 + 1.6) / 2;
  return (
    box: box,
    tag: Offset(inner.left + 14, inner.top - 13),
    rules: [
      for (final y in noteRulesY(lines))
        Rect.fromLTWH(inner.left + 12, inner.top + y, inner.width - 24, 1.5),
    ],
    collapse: delete.translate(-6 - 40, 0),
    delete: delete,
    hintBottomLeft: Offset(inner.left + 14, inner.bottom - 8),
    handle: handle,
    bar1: Rect.fromLTWH(handle.center.dx - 10, barsTop, 20, 1.6),
    bar2: Rect.fromLTWH(handle.center.dx - 10, barsTop + 1.6 + 3, 20, 1.6),
  );
}

/// Onde a tinta da nota vive: a caixa [box] por dentro da borda (a unidade da nota mede a partir daqui —
/// `note_ink.dart`).
Rect inkFrame(Rect box) => box.deflate(noteBorder);

/// A faixa recolhida (D-184) na caixa [strip] (a altura de uma linha do texto): a etiqueta no meio da altura, a 14
/// da esquerda; o botão de abrir (32) a 6 da direita, no meio.
typedef StripParts = ({Rect strip, Offset tag, Rect open});

StripParts stripLayout(Rect strip) => (
  strip: strip,
  tag: Offset(strip.left + noteBorder + 14, strip.center.dy - 12),
  open: Rect.fromLTWH(
    strip.right - noteBorder - 6 - 32,
    strip.center.dy - 16,
    32,
    32,
  ),
);

/// A altura da etiqueta "✎ Nota à mão".
const double noteTagHeight = 24;

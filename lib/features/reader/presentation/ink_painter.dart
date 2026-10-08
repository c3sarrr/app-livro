// G16.5 — a pintura da tinta (§5):
// - o traço da Caneta vira o contorno do freehand com a ponta e a largura gravadas nele (D-159), preenchido na cor e
//   no alpha com que foi feito (D-59); a Reta, uma cápsula da largura do traço entre o primeiro e o último ponto; um
//   ponto só (ou a Reta sem comprimento), um círculo;
// - os desenhos de uma página vão num `ui.Picture` guardado pela página (cada layout tem as páginas dele) e pela
//   revisão da tinta, até 4 páginas — as usadas há mais tempo são descartadas;
// - a mancha do grifo feito à mão (D-161): o caminho do arquivo, numa caixa de 100×20, esticado em cada linha do
//   trecho — 5 px para os lados, de 3 px abaixo do topo da letra até 1 px acima da base —, a 90 % e multiplicada por
//   cima do texto. Com letras claras (o Noite), a técnica da D-133: por trás vai D − cor e, por cima, D em diferença.
//   G17 (R25): na altura do grifo (Baixa do meio da letra, Alta da letra toda) e só no fundo; o sublinhado e o
//   ondulado à mão pintam como os da tela 21 (`paintUnderlines`);
// - G17 (R26): no Noite, a tinta translúcida do marca-texto pela D-133 (por trás D − cor, por cima D em diferença) e a
//   tinta com contraste < 1,5 : 1 contra o papel do Noite na cor das letras (D-174); o cache separa o Creme, o Noite e
//   a passada de trás.
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../core/design_system/color/hsv.dart' show contrastRatio;
import '../../../core/design_system/tokens/app_colors.dart';
import '../annotations/domain/annotation.dart' show FillHeight, HighlightStyle;
import '../annotations/ink/freehand.dart';
import '../annotations/ink/ink_stroke.dart';
import '../annotations/ink/ink_units.dart';
import '../layout/display_page.dart';
import 'page_marks.dart';

/// O caminho preenchido do traço [s], nas coordenadas dos pontos dele.
ui.Path inkPath(InkStroke s) {
  final pts = s.points;
  if (pts.isEmpty) return ui.Path();
  final size = dpOfCentiMm(s.widthCentiMm);
  final r = size / 2;
  final a = pts.first;
  final b = pts.last;
  if (pts.length == 1) return _circle(a.x, a.y, r);
  if (InkTool.fromCode(s.tool) == InkTool.line) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return _circle(a.x, a.y, r);
    final c = dx / len;
    final sn = dy / len;
    // a cápsula deitada em (0, 0)…(len, 0), girada e levada ao primeiro ponto
    return (ui.Path()..addRRect(
          ui.RRect.fromLTRBR(-r, -r, len + r, r, ui.Radius.circular(r)),
        ))
        .transform(
          Float64List.fromList([
            c, sn, 0, 0, //
            -sn, c, 0, 0,
            0, 0, 1, 0,
            a.x, a.y, 0, 1,
          ]),
        );
  }
  final outline = freehandOutline([
    for (final p in pts) (p.x, p.y, p.pressure),
  ], tipOptions(tipOfCode(s.tip), size: size, last: true));
  return _smoothPolygon(outline);
}

ui.Path _circle(double x, double y, double r) =>
    ui.Path()..addOval(ui.Rect.fromCircle(center: ui.Offset(x, y), radius: r));

/// O contorno fechado com curvas pelos pontos médios (o `getSvgPathFromStroke` do perfect-freehand).
ui.Path _smoothPolygon(List<Vec> pts) {
  final path = ui.Path();
  if (pts.isEmpty) return path;
  path.moveTo(pts.first.$1, pts.first.$2);
  for (var i = 0; i < pts.length; i++) {
    final p = pts[i];
    final q = pts[(i + 1) % pts.length];
    path.quadraticBezierTo(p.$1, p.$2, (p.$1 + q.$1) / 2, (p.$2 + q.$2) / 2);
  }
  return path..close();
}

/// D-174: abaixo deste contraste contra o papel do Noite, a tinta sai na cor das letras.
const double nightInkMinContrast = 1.5;

/// A cor com que a tinta [argb] é pintada: no Noite ([lightText] = a cor das letras), a que some no papel do Noite
/// (contraste < 1,5 : 1 contra `#1F1B17`) sai na cor das letras, com o alpha dela (D-174); senão, a dela.
int inkArgbOn(int argb, ui.Color? lightText) {
  final light = lightText;
  if (light == null ||
      contrastRatio(argb | 0xFF000000, AppColors.paperNight.toARGB32()) >=
          nightInkMinContrast) {
    return argb;
  }
  return (argb & 0xFF000000) | (light.toARGB32() & 0x00FFFFFF);
}

bool _isMarker(InkStroke s) => InkTool.fromCode(s.tool) == InkTool.marker;

/// Pinta [strokes] na ordem, cada um na cor e no alpha com que foi feito (D-59). O Marca-texto (R22): a linha dos
/// pontos na largura dele, com as pontas redondas, multiplicada (como a mancha da D-161); com letras claras
/// ([lightText], o Noite), a parte de cima da D-133 (D em diferença). A cor passa pela D-174.
void paintInk(
  ui.Canvas canvas,
  List<InkStroke> strokes, {
  ui.Color? lightText,
}) {
  for (final s in strokes) {
    final argb = inkArgbOn(s.argb, lightText);
    if (_isMarker(s)) {
      final light = lightText;
      _paintMarker(
        canvas,
        s,
        light == null
            ? (ui.Color(argb), ui.BlendMode.multiply)
            : (
                channelMax(light, ui.Color(argb | 0xFF000000)),
                ui.BlendMode.difference,
              ),
      );
      continue;
    }
    canvas.drawPath(
      inkPath(s),
      ui.Paint()
        ..color = ui.Color(argb)
        ..isAntiAlias = true,
    );
  }
}

/// Com letras claras ([lightText], o Noite — D-133): a parte do Marca-texto que vai por trás das letras (D − cor). A
/// caneta e a Reta vão só por cima.
void paintInkBehind(
  ui.Canvas canvas,
  List<InkStroke> strokes, {
  required ui.Color lightText,
}) {
  for (final s in strokes) {
    if (!_isMarker(s)) continue;
    final c = ui.Color(inkArgbOn(s.argb, lightText) | 0xFF000000);
    _paintMarker(canvas, s, (
      channelMinus(channelMax(lightText, c), c),
      ui.BlendMode.srcOver,
    ));
  }
}

/// A linha dos pontos de [s].
ui.Path markerLine(InkStroke s) {
  final path = ui.Path();
  final pts = s.points;
  if (pts.isEmpty) return path;
  path.moveTo(pts.first.x, pts.first.y);
  if (pts.length == 1) {
    // um toque: um ponto na largura do traço
    path.lineTo(pts.first.x, pts.first.y);
  }
  for (final p in pts.skip(1)) {
    path.lineTo(p.x, p.y);
  }
  return path;
}

void _paintMarker(
  ui.Canvas canvas,
  InkStroke s,
  (ui.Color, ui.BlendMode) look,
) => canvas.drawPath(
  markerLine(s),
  ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = dpOfCentiMm(s.widthCentiMm)
    ..strokeCap = ui.StrokeCap.round
    ..strokeJoin = ui.StrokeJoin.round
    ..color = look.$1
    ..blendMode = look.$2
    ..isAntiAlias = true,
);

/// Os desenhos de cada página gravados num `ui.Picture`, pela página e pela revisão da tinta (e, no Noite, pela cor
/// das letras e pela passada: a de trás e a de cima — R26).
final class InkPictureCache {
  InkPictureCache({this.capacity = 4});

  /// Quantas `Picture` ficam guardadas (a página atual, as vizinhas e a que acabou de sair).
  final int capacity;

  /// Da usada há mais tempo para a mais recente.
  final List<
    ({
      Object page,
      ui.Color? light,
      bool behind,
      int revision,
      ui.Picture picture,
    })
  >
  _entries = [];

  /// A `Picture` dos traços de [page] na [revision], com as letras [lightText] (o Noite) e só a passada de trás
  /// ([behind], o Marca-texto pela D-133); `strokes` só é chamado quando ela ainda não existe. Sem traços (ou, por trás,
  /// sem Marca-texto), `null`.
  ui.Picture? pictureOf(
    Object page,
    int revision,
    List<InkStroke> Function() strokes, {
    ui.Color? lightText,
    bool behind = false,
  }) {
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      if (!identical(e.page, page) ||
          e.light != lightText ||
          e.behind != behind) {
        continue;
      }
      _entries.removeAt(i);
      if (e.revision == revision) {
        _entries.add(e);
        return e.picture;
      }
      e.picture.dispose();
      break;
    }
    final light = lightText;
    if (behind && light == null) return null;
    final list = [
      for (final s in strokes())
        if (!behind || _isMarker(s)) s,
    ];
    if (list.isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    if (behind) {
      paintInkBehind(canvas, list, lightText: light!);
    } else {
      paintInk(canvas, list, lightText: light);
    }
    final picture = recorder.endRecording();
    _entries.add((
      page: page,
      light: light,
      behind: behind,
      revision: revision,
      picture: picture,
    ));
    while (_entries.length > capacity) {
      _entries.removeAt(0).picture.dispose();
    }
    return picture;
  }

  void dispose() {
    for (final e in _entries) {
      e.picture.dispose();
    }
    _entries.clear();
  }
}

/// D-161: 5 px para os lados da linha.
const double handHighlightSide = 5;

/// D-161: de 3 px abaixo do topo da letra…
const double handHighlightTop = 3;

/// …até 1 px acima da base.
const double handHighlightBottom = 1;

/// D-161: a mancha vai a 90 %.
const double handHighlightAlpha = 0.9;

/// A caixa da mancha em cada linha dos grifos de fundo feitos à mão [highlights], com a cor de cada um, na altura
/// deles (R25): Média de 3 px abaixo do topo da letra até 1 px acima da base; Baixa do meio da letra até 1 px acima da
/// base; Alta da letra toda.
List<({ui.Rect box, ui.Color color})> handHighlightBoxes(
  DisplayPage page,
  List<PaintedHighlight> highlights,
) => [
  for (final h in highlights)
    if (h.style == HighlightStyle.fill)
      for (final b in page.boxesOf(h.range.unit, h.range.from, h.range.to))
        (
          box: ui.Rect.fromLTRB(
            b.rect.left - handHighlightSide,
            switch (h.height) {
              FillHeight.low => (b.textTop + b.textBottom) / 2,
              FillHeight.high => b.textTop,
              FillHeight.medium => b.textTop + handHighlightTop,
            },
            b.rect.right + handHighlightSide,
            h.height == FillHeight.high
                ? b.textBottom
                : b.textBottom - handHighlightBottom,
          ),
          color: h.color,
        ),
];

/// O caminho da mancha do arquivo (`M2 4C20 1.5 45 3.5 70 2.5S94 2 98.5 3.5L99 17C82 18.5 60 16.5 38 18S8 18.5
/// 1.5 17.5Z`, numa caixa de 100×20; os `S` com o primeiro controle refletido), esticado em [box].
ui.Path handHighlightPath(ui.Rect box) {
  final sx = box.width / 100;
  final sy = box.height / 20;
  double x(double v) => box.left + v * sx;
  double y(double v) => box.top + v * sy;
  return ui.Path()
    ..moveTo(x(2), y(4))
    ..cubicTo(x(20), y(1.5), x(45), y(3.5), x(70), y(2.5))
    ..cubicTo(x(95), y(1.5), x(94), y(2), x(98.5), y(3.5))
    ..lineTo(x(99), y(17))
    ..cubicTo(x(82), y(18.5), x(60), y(16.5), x(38), y(18))
    ..cubicTo(x(16), y(19.5), x(8), y(18.5), x(1.5), y(17.5))
    ..close();
}

/// Com letras claras ([lightText], o Noite — D-133): a parte da mancha que vai por trás das letras (D − cor). Com
/// letras escuras, nada (a mancha vai toda por cima, multiplicada).
void paintHandHighlightsBehind(
  ui.Canvas canvas,
  DisplayPage page,
  List<PaintedHighlight> highlights, {
  ui.Color? lightText,
}) {
  final light = lightText;
  if (light == null) return;
  for (final (:box, :color) in handHighlightBoxes(page, highlights)) {
    canvas.drawPath(
      handHighlightPath(box),
      ui.Paint()
        ..color = channelMinus(channelMax(light, color), color)
        ..isAntiAlias = true,
    );
  }
}

/// A mancha por cima do texto: multiplicada a 90 %; com letras claras ([lightText]), D em diferença (D-133).
void paintHandHighlights(
  ui.Canvas canvas,
  DisplayPage page,
  List<PaintedHighlight> highlights, {
  ui.Color? lightText,
}) {
  final light = lightText;
  for (final (:box, :color) in handHighlightBoxes(page, highlights)) {
    final paint = ui.Paint()..isAntiAlias = true;
    if (light == null) {
      paint
        ..color = color.withValues(alpha: handHighlightAlpha)
        ..blendMode = ui.BlendMode.multiply;
    } else {
      paint
        ..color = channelMax(light, color)
        ..blendMode = ui.BlendMode.difference;
    }
    canvas.drawPath(handHighlightPath(box), paint);
  }
}

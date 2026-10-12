// T01 — o traço tracejado de um elemento de um SVG do arquivo (`stroke-dasharray`) como o Chromium pinta: o padrão
// começa no início do elemento e segue pelos segmentos dele (no `<ellipse>`, a ponta direita, no sentido horário). O
// flutter_svg tracejava as curvas com outra fase: a elipse do Laço da prateleira começava no topo e a dica "Gruda nas
// palavras" da 23b perdia o último traço. O SVG é lido com o traço desse elemento escondido (a troca de cores da
// `AppSvg`) e o [SvgDashPainter] o pinta por cima, nas coordenadas do `viewBox` levadas à caixa como o `SvgPicture`
// faz (`BoxFit.contain`, no centro). T13.11 (D-285): o elemento pode ser indicado pelo `id` (o traço escondido é só o
// dele) e outros elementos podem vir depois, desde que nenhum cruze o tracejado. D-286: o comprimento das curvas é
// medido na escala em que o traço é pintado, como o Chromium mede.
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/rendering.dart';

/// [source] em traços de [on] com vãos de [off], ao longo de cada contorno: o padrão começa no início do contorno e
/// segue pelos segmentos dele. [scale] (T13.11, D-286): a escala em que o traço vai ser pintado. O Skia mede uma curva
/// pelos segmentos retos com que a aproxima, mais finos quanto maior a escala, e o Chromium mede na escala da pintura;
/// medida no `viewBox`, a curva sai mais curta (a elipse do Laço: 80,22 contra 80,67 a 8×) e os traços vão adiantando
/// ao longo do contorno. O caminho é levado à escala, tracejado e trazido de volta.
Path dashedPath(Path source, double on, double off, {double scale = 1}) {
  if (scale != 1) {
    return dashedPath(
      source.transform(_escala(scale)),
      on * scale,
      off * scale,
    ).transform(_escala(1 / scale));
  }
  final out = Path();
  for (final m in source.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      final end = (d + on).clamp(0, m.length).toDouble();
      out.addPath(m.extractPath(d, end), Offset.zero);
      d = end + off;
    }
  }
  return out;
}

Float64List _escala(double s) =>
    Float64List.fromList([s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);

/// O traço tracejado do elemento [element] de um desenho: o tamanho do `viewBox`, o caminho do elemento nele, o
/// padrão [on]/[off], a espessura, a cor do arquivo e a ponta.
@immutable
final class SvgDash {
  SvgDash({
    required this.element,
    required this.viewBox,
    required this.path,
    required this.on,
    required this.off,
    required this.width,
    required this.color,
    this.cap = StrokeCap.butt,
    this.id,
  });

  /// O nome do elemento no SVG (o traço dele é escondido na leitura do arquivo).
  final String element;

  /// O `id` do elemento tracejado no arquivo, quando o desenho tem outros elementos de mesmo nome com traço (T13.11,
  /// D-285: os `<rect>` dos livros do scanner). Com ele, só o traço desse elemento sai escondido.
  final String? id;

  /// A largura e a altura do `viewBox` (que começa em 0, 0).
  final Size viewBox;
  final Path path;
  final double on;
  final double off;
  final double width;
  final Color color;
  final StrokeCap cap;

  /// O traço tracejado medido na escala de pintura [scale] (o encaixe × a densidade do aparelho — D-286), guardado
  /// por escala (as últimas 8).
  Path dashedAt(double scale) {
    final pronto = _porEscala[scale];
    if (pronto != null) return pronto;
    if (_porEscala.length >= 8) _porEscala.remove(_porEscala.keys.first);
    return _porEscala[scale] = dashedPath(path, on, off, scale: scale);
  }

  final Map<double, Path> _porEscala = {};
}

/// Pinta o traço de [dash] por cima do desenho; [color] troca a cor do arquivo (a troca de cores da `AppSvg`) e
/// [opacity] esmaece com ele. [devicePixelRatio]: a densidade do aparelho, que entra na escala em que o traço é medido
/// (D-286).
class SvgDashPainter extends CustomPainter {
  const SvgDashPainter(
    this.dash, {
    this.color,
    this.opacity = 1,
    this.devicePixelRatio = 1,
  });

  final SvgDash dash;
  final Color? color;
  final double opacity;
  final double devicePixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final c = color ?? dash.color;
    final v = dash.viewBox;
    final k = math.min(size.width / v.width, size.height / v.height);
    canvas
      ..save()
      ..translate(
        (size.width - v.width * k) / 2,
        (size.height - v.height * k) / 2,
      )
      ..scale(k);
    canvas.drawPath(
      dash.dashedAt(k * devicePixelRatio),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = dash.width
        ..strokeCap = dash.cap
        ..color = c.withValues(alpha: c.a * opacity),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(SvgDashPainter old) =>
      !identical(old.dash, dash) ||
      old.color != color ||
      old.opacity != opacity ||
      old.devicePixelRatio != devicePixelRatio;
}

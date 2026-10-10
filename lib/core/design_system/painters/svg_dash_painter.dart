// T01 — o traço tracejado de um elemento de um SVG do arquivo (`stroke-dasharray`) como o Chromium pinta: o padrão
// começa no início do elemento e segue pelos segmentos dele (no `<ellipse>`, a ponta direita, no sentido horário). O
// flutter_svg tracejava as curvas com outra fase: a elipse do Laço da prateleira começava no topo e a dica "Gruda nas
// palavras" da 23b perdia o último traço. O SVG é lido com o traço desse elemento escondido (a troca de cores da
// `AppSvg`) e o [SvgDashPainter] o pinta por cima, nas coordenadas do `viewBox` levadas à caixa como o `SvgPicture`
// faz (`BoxFit.contain`, no centro).
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/rendering.dart';

/// [source] em traços de [on] com vãos de [off], ao longo de cada contorno: o padrão começa no início do contorno e
/// segue pelos segmentos dele.
Path dashedPath(Path source, double on, double off) {
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
  });

  /// O nome do elemento no SVG (o traço dele é escondido na leitura do arquivo).
  final String element;

  /// A largura e a altura do `viewBox` (que começa em 0, 0).
  final Size viewBox;
  final Path path;
  final double on;
  final double off;
  final double width;
  final Color color;
  final StrokeCap cap;

  late final Path dashed = dashedPath(path, on, off);
}

/// Pinta o traço de [dash] por cima do desenho; [color] troca a cor do arquivo (a troca de cores da `AppSvg`) e
/// [opacity] esmaece com ele.
class SvgDashPainter extends CustomPainter {
  const SvgDashPainter(this.dash, {this.color, this.opacity = 1});

  final SvgDash dash;
  final Color? color;
  final double opacity;

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
      dash.dashed,
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
      old.opacity != opacity;
}

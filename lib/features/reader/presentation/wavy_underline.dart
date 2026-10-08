// G17 (R25) — o grifo ondulado: a onda do Chromium medida na amostra da prancha 23b
// (`mk.markerPanel.styles.wavy.sample.word`, `text-decoration: underline 2.5px wavy`, `text-underline-offset: 2px`,
// fotografada a 10× com `tools/medicao`): por coluna, o meio da faixa amarela dá a linha do meio da onda 4,5 px abaixo
// da base, o período de 10,3 px (picos para baixo em 2,5; 12,8; 23,1… e vales em 7,5; 17,8… a partir da borda da
// caixa) e a amplitude de 2,2 px; o traço tem 2,5 px. A onda começa na borda esquerda da caixa, no meio, descendo, e
// acaba na direita (pontas retas). Vale para o grifo de seleção e o feito à mão, por cima do texto, na cor viva.
import 'dart:math' as math;
import 'dart:ui' as ui;

/// A espessura do traço.
const double wavyThickness = 2.5;

/// O comprimento de uma onda.
const double wavyPeriod = 10.3;

/// Do meio ao pico.
const double wavyAmplitude = 2.2;

/// A linha do meio da onda, abaixo da base.
const double wavyBelowBaseline = 4.5;

/// O passo dos pontos do caminho.
const double _step = 0.5;

/// A altura da linha do meio da onda em [x], na caixa que começa em [left], sobre a base [baseline].
double wavyY(double x, {required double left, required double baseline}) =>
    baseline +
    wavyBelowBaseline +
    wavyAmplitude * math.sin(2 * math.pi * (x - left) / wavyPeriod);

/// A linha do meio da onda de [left] a [right] sobre a base [baseline].
ui.Path wavyUnderlinePath(double left, double right, double baseline) {
  final path = ui.Path();
  if (right <= left) return path;
  double y(double x) => wavyY(x, left: left, baseline: baseline);
  path.moveTo(left, y(left));
  for (var x = left + _step; x < right; x += _step) {
    path.lineTo(x, y(x));
  }
  return path..lineTo(right, y(right));
}

/// Pinta a onda de [left] a [right] sobre a base [baseline] em [color] (opaca).
void paintWavyUnderline(
  ui.Canvas canvas,
  double left,
  double right,
  double baseline,
  ui.Color color,
) => canvas.drawPath(
  wavyUnderlinePath(left, right, baseline),
  ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = wavyThickness
    ..strokeCap = ui.StrokeCap.butt
    ..strokeJoin = ui.StrokeJoin.round
    ..color = color.withValues(alpha: 1)
    ..isAntiAlias = true,
);

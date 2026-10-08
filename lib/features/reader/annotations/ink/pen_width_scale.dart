// G17.3 (D-50, R11) — a escala do slider de espessura da tela 23: de 0,3 a 4,0 mm (o `aria-valuemin/max` do arquivo)
// com `v = 0,3 + 3,7 · t^1,24`, que põe 1,2 mm em 32 % como a prancha (linear daria 24 %). O valor anda de 0,1 em
// 0,1 (o `numeric(3,1)` do `pen_presets`). Dart puro.
import 'dart:math' as math;

const double penWidthMin = 0.3;
const double penWidthMax = 4.0;
const double _span = penWidthMax - penWidthMin;
const double _exponent = 1.24;

/// A espessura (mm, 1 casa) do ponto [t] (0 = começo, 1 = fim) do slider.
double widthOfSlider(double t) {
  final v = penWidthMin + _span * math.pow(t.clamp(0.0, 1.0), _exponent);
  return (v * 10).round() / 10;
}

/// O ponto do slider (0–1) da espessura [mm].
double sliderOfWidth(double mm) {
  final u = ((mm - penWidthMin) / _span).clamp(0.0, 1.0);
  return math.pow(u, 1 / _exponent).toDouble();
}

/// "1,2 mm" (sempre 1 casa, com vírgula).
String widthLabel(double mm) =>
    '${mm.toStringAsFixed(1).replaceAll('.', ',')} mm';

/// "1,2 milímetro" / "2,0 milímetros" (o `aria-valuetext` do arquivo; plural a partir de 2).
String widthSpoken(double mm) =>
    '${mm.toStringAsFixed(1).replaceAll('.', ',')} '
    '${mm >= 2 ? 'milímetros' : 'milímetro'}';

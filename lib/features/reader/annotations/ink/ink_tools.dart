// G16.3 — as ferramentas puras do modo anotação (§3), sem widget:
// - Reta: gruda em múltiplos de 15° quando a diferença é menor que 4° (o comprimento fica); com menos de 4 px não
//   cria nada.
// - Borracha: apaga o traço inteiro que o caminho do dedo tocar a até meia espessura + 8 px de algum segmento (cruzar
//   também conta); o traço de 1 ponto é o ponto, a Reta é o segmento dela. O grifo, pela área pintada.
// - Laço: o par-ímpar decide o que está dentro; seleciona o traço com ≥ 50 % dos pontos dentro.
// - Batente (D-165, como o da D-107): a página só sobe até a última linha passar da borda de mesa; além disso anda
//   1/3 do dedo.
import 'dart:math' as math;

import 'ink_geometry.dart';
import 'ink_stroke.dart';
import 'ink_units.dart';

/// Os ângulos em que a Reta gruda (graus) e a diferença máxima para grudar.
const double lineSnapStepDegrees = 15;
const double lineSnapWithinDegrees = 4;

/// A Reta mais curta que cria alguma coisa (px).
const double lineMinLength = 4;

/// O alcance da Borracha além da meia espessura do traço (px).
const double eraserSlack = 8;

/// Além do batente, a página anda 1/[rubberBandDivisor] do excesso.
const double rubberBandDivisor = 3;

/// O fim da Reta de [start] a [end], grudado no múltiplo de 15° mais perto quando a diferença é menor que 4°.
InkOffset snapLineEnd(InkOffset start, InkOffset end) {
  final dx = end.x - start.x;
  final dy = end.y - start.y;
  final length = math.sqrt(dx * dx + dy * dy);
  if (length == 0) return end;
  final degrees = math.atan2(dy, dx) * 180 / math.pi;
  final snapped = (degrees / lineSnapStepDegrees).round() * lineSnapStepDegrees;
  if ((degrees - snapped).abs() >= lineSnapWithinDegrees) return end;
  final rad = snapped * math.pi / 180;
  return (
    x: start.x + length * math.cos(rad),
    y: start.y + length * math.sin(rad),
  );
}

/// A Reta de [start] a [end] é curta demais para existir.
bool lineTooShort(InkOffset start, InkOffset end) =>
    _dist(start, end) < lineMinLength;

double _dist(InkOffset a, InkOffset b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return math.sqrt(dx * dx + dy * dy);
}

double _cross(InkOffset o, InkOffset a, InkOffset b) =>
    (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);

/// A distância de [p] ao segmento [a]–[b].
double _pointSegment(InkOffset p, InkOffset a, InkOffset b) {
  final dx = b.x - a.x;
  final dy = b.y - a.y;
  final len2 = dx * dx + dy * dy;
  if (len2 == 0) return _dist(p, a);
  final t = (((p.x - a.x) * dx + (p.y - a.y) * dy) / len2).clamp(0.0, 1.0);
  return _dist(p, (x: a.x + t * dx, y: a.y + t * dy));
}

/// Os segmentos [a1]–[a2] e [b1]–[b2] se cruzam (as pontas dos dois de lados opostos do outro).
bool _crosses(InkOffset a1, InkOffset a2, InkOffset b1, InkOffset b2) {
  final d1 = _cross(b1, b2, a1);
  final d2 = _cross(b1, b2, a2);
  final d3 = _cross(a1, a2, b1);
  final d4 = _cross(a1, a2, b2);
  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}

/// A menor distância entre os segmentos [a1]–[a2] e [b1]–[b2]; 0 quando eles se cruzam.
double segmentDistance(InkOffset a1, InkOffset a2, InkOffset b1, InkOffset b2) {
  if (_crosses(a1, a2, b1, b2)) return 0;
  return [
    _pointSegment(a1, b1, b2),
    _pointSegment(a2, b1, b2),
    _pointSegment(b1, a1, a2),
    _pointSegment(b2, a1, a2),
  ].reduce(math.min);
}

/// Até onde a Borracha alcança o traço [s]: meia espessura (D-159) + 8 px.
double eraserReach(InkStroke s) =>
    dpOfCentiMm(s.widthCentiMm) / 2 + eraserSlack;

/// O trecho [e1]–[e2] do caminho da Borracha toca o traço [s].
bool eraserTouchesStroke(InkOffset e1, InkOffset e2, InkStroke s) {
  final pts = s.points;
  if (pts.isEmpty) return false;
  final reach = eraserReach(s);
  if (pts.length == 1) {
    return _pointSegment((x: pts[0].x, y: pts[0].y), e1, e2) <= reach;
  }
  for (var i = 1; i < pts.length; i++) {
    final a = (x: pts[i - 1].x, y: pts[i - 1].y);
    final b = (x: pts[i].x, y: pts[i].y);
    if (segmentDistance(a, b, e1, e2) <= reach) return true;
  }
  return false;
}

bool _inside(InkOffset p, InkRect r) =>
    p.x >= r.left && p.x <= r.right && p.y >= r.top && p.y <= r.bottom;

/// O trecho [e1]–[e2] do caminho da Borracha passa pela área pintada [r] de um grifo.
bool eraserTouchesRect(InkOffset e1, InkOffset e2, InkRect r) {
  if (_inside(e1, r) || _inside(e2, r)) return true;
  final corners = [
    (x: r.left, y: r.top),
    (x: r.right, y: r.top),
    (x: r.right, y: r.bottom),
    (x: r.left, y: r.bottom),
  ];
  for (var i = 0; i < 4; i++) {
    if (segmentDistance(e1, e2, corners[i], corners[(i + 1) % 4]) == 0) {
      return true;
    }
  }
  return false;
}

/// [p] está dentro do [polygon] (par-ímpar).
bool insidePolygon(InkOffset p, List<InkOffset> polygon) {
  if (polygon.length < 3) return false;
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final a = polygon[i];
    final b = polygon[j];
    if ((a.y > p.y) != (b.y > p.y) &&
        p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x) {
      inside = !inside;
    }
  }
  return inside;
}

/// O Laço de contorno [polygon] seleciona o traço [s]: ≥ 50 % dos pontos dentro.
bool lassoSelects(InkStroke s, List<InkOffset> polygon) {
  if (s.points.isEmpty) return false;
  var inside = 0;
  for (final p in s.points) {
    if (insidePolygon((x: p.x, y: p.y), polygon)) inside++;
  }
  return inside * 2 >= s.points.length;
}

/// Quanto a página pode subir (D-165): até a base da última linha ([lastLineBottom]) passar do topo da borda de mesa
/// ([deskTop]).
double panLimit({required double lastLineBottom, required double deskTop}) =>
    math.max(0, lastLineBottom - deskTop);

/// O deslocamento da página para o arrasto [raw] (negativo = a página sobe), com o batente em 0 e em −[limit]: além
/// deles, a página anda 1/3 do excesso.
double rubberBand(double raw, double limit) {
  if (raw > 0) return raw / rubberBandDivisor;
  if (raw < -limit) return -limit + (raw + limit) / rubberBandDivisor;
  return raw;
}

// G16.1 — suavização do traço no estilo perfect-freehand (Anexo 03 §9.3). Dart puro.
//
// Porte fiel de perfect-freehand 1.2.3 (getStrokePoints + getStrokeOutlinePoints + simulatePressure), feito no
// spike S4 da G02 e conferido contra o pacote npm 1.2.3 nos 30 casos de `test/fixtures/tinta/pf_referencia.json`
// (tolerância 1e-9).
//
// MIT License — Copyright (c) 2021 Stephen Ruiz Ltd — https://github.com/steveruizok/perfect-freehand
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
// to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above
// copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.
//
// Pontas (§1): esferográfica (afinamento 0,1), tinteiro (0,6, afunila no fim), pincel (0,85, suavização 0,5), todas
// com estabilização 0,2 em vez do padrão 0,5 — o 0,5 achata ondas curtas (cerca de −35 % de amplitude numa onda de
// 12 px amostrada a 2 px). A pressão vem do ponto: a da caneta do aparelho, ou a simulada pela velocidade NA CAPTURA
// ([simulatedPressure]); o desenho salvo nunca simula de novo e sai igual ao traço ao vivo.
import 'dart:math' as math;

import '../domain/pen_presets.dart';

typedef Vec = (double, double);

class FreehandOptions {
  const FreehandOptions({
    this.size = 16,
    this.thinning = 0.5,
    this.smoothing = 0.5,
    this.streamline = 0.5,
    this.simulatePressure = true,
    this.taperStart = 0,
    this.taperEnd = 0,
    this.capStart = true,
    this.capEnd = true,
    this.last = false,
  });

  /// Diâmetro base (dp).
  final double size;

  /// Efeito da pressão no diâmetro (0 = constante).
  final double thinning;

  /// Distância mínima entre pontos do contorno (fração do tamanho).
  final double smoothing;

  /// Quanto o ponto segue o anterior (0 = cru, 1 = muito suave).
  final double streamline;
  final bool simulatePressure;

  /// Distância de afunilamento no início/fim (0 = sem; `double.infinity` = o traço todo).
  final double taperStart;
  final double taperEnd;
  final bool capStart;
  final bool capEnd;

  /// O traço terminou (usa o ponto real no fim).
  final bool last;
}

/// Estabilização das três pontas (§1).
const double tipStreamline = 0.2;

/// As opções da ponta [tip] com o diâmetro [size] (Anexo 03 §9.3; estabilização 0,2 — §1).
FreehandOptions tipOptions(
  PenTip tip, {
  required double size,
  bool last = false,
}) => switch (tip) {
  PenTip.ballpoint => FreehandOptions(
    size: size,
    thinning: 0.1,
    streamline: tipStreamline,
    simulatePressure: false,
    last: last,
  ),
  PenTip.fountain => FreehandOptions(
    size: size,
    thinning: 0.6,
    streamline: tipStreamline,
    simulatePressure: false,
    taperEnd: double.infinity,
    last: last,
  ),
  PenTip.brush => FreehandOptions(
    size: size,
    thinning: 0.85,
    smoothing: 0.5,
    streamline: tipStreamline,
    simulatePressure: false,
    last: last,
  ),
};

class FreehandPoint {
  FreehandPoint(
    this.point,
    this.pressure,
    this.vector,
    this.distance,
    this.runningLength,
  );
  final Vec point;
  final double pressure;
  Vec vector;
  final double distance;
  final double runningLength;
}

// Constantes do perfect-freehand.
const _rateOfPressureChange = 0.275;
const _fixedPi = math.pi + 0.0001;
const _startCapSegments = 13;
const _endCapSegments = 29;
const _cornerCapSegments = 13;
const _endNoiseThreshold = 3.0;
const _minStreamlineT = 0.15;
const _streamlineTRange = 0.85;
const _minRadius = 0.01;
const _defaultFirstPressure = 0.25;
const _defaultPressure = 0.5;

/// A pressão do 1º ponto quando ela não vem da caneta (a do perfect-freehand).
const double firstPressure = _defaultFirstPressure;

Vec _add(Vec a, Vec b) => (a.$1 + b.$1, a.$2 + b.$2);
Vec _sub(Vec a, Vec b) => (a.$1 - b.$1, a.$2 - b.$2);
Vec _mul(Vec a, double n) => (a.$1 * n, a.$2 * n);
Vec _per(Vec a) => (a.$2, -a.$1);
Vec _neg(Vec a) => (-a.$1, -a.$2);
double _dpr(Vec a, Vec b) => a.$1 * b.$1 + a.$2 * b.$2;
double _len(Vec a) => math.sqrt(a.$1 * a.$1 + a.$2 * a.$2);
Vec _uni(Vec a) {
  final l = _len(a);
  return (a.$1 / l, a.$2 / l);
}

double _dist(Vec a, Vec b) => _len(_sub(a, b));
double _dist2(Vec a, Vec b) {
  final d = _sub(a, b);
  return d.$1 * d.$1 + d.$2 * d.$2;
}

Vec _lrp(Vec a, Vec b, double t) => _add(a, _mul(_sub(b, a), t));
Vec _prj(Vec a, Vec b, double c) => _add(a, _mul(b, c));
Vec _rot(Vec a, Vec c, double r) {
  final s = math.sin(r);
  final co = math.cos(r);
  final px = a.$1 - c.$1;
  final py = a.$2 - c.$2;
  return (px * co - py * s + c.$1, px * s + py * co + c.$2);
}

/// A pressão simulada pela velocidade (a fórmula do perfect-freehand): [previous] = a do ponto anterior,
/// [distance] = o quanto o dedo andou desde ele, [size] = o diâmetro do traço.
double simulatedPressure(double previous, double distance, double size) {
  final sp = math.min(1.0, distance / size);
  final rp = math.min(1.0, 1 - sp);
  return math.min(
    1.0,
    previous + (rp - previous) * (sp * _rateOfPressureChange),
  );
}

double _radius(double size, double thinning, double pressure) =>
    size * (0.5 - thinning * (0.5 - pressure));

/// getStrokePoints. [input] = (x, y, pressão ou null).
List<FreehandPoint> strokePoints(
  List<(double, double, double?)> input,
  FreehandOptions o,
) {
  if (input.isEmpty) return [];
  final t = _minStreamlineT + (1 - o.streamline) * _streamlineTRange;
  var pts = [...input];
  if (pts.length == 2) {
    final last = pts[1];
    pts = [pts[0]];
    for (var i = 1; i < 5; i++) {
      // como no JS: o lrp só devolve (x, y) — a pressão dos pontos inseridos fica "sem valor"
      final p = _lrp((pts[0].$1, pts[0].$2), (last.$1, last.$2), i / 4);
      pts.add((p.$1, p.$2, null));
    }
  }
  if (pts.length == 1) {
    pts = [...pts, (pts[0].$1 + 1, pts[0].$2 + 1, pts[0].$3)];
  }
  bool valid(double? p) => p != null && p >= 0;
  final out = <FreehandPoint>[
    FreehandPoint(
      (pts[0].$1, pts[0].$2),
      valid(pts[0].$3) ? pts[0].$3! : _defaultFirstPressure,
      (1, 1),
      0,
      0,
    ),
  ];
  var hasReachedMinimumLength = false;
  var runningLength = 0.0;
  var prev = out[0];
  final max = pts.length - 1;
  for (var i = 1; i < pts.length; i++) {
    final Vec point = o.last && i == max
        ? (pts[i].$1, pts[i].$2)
        : _lrp(prev.point, (pts[i].$1, pts[i].$2), t);
    if (point.$1 == prev.point.$1 && point.$2 == prev.point.$2) continue;
    final distance = _dist(point, prev.point);
    runningLength += distance;
    if (i < max && !hasReachedMinimumLength) {
      if (runningLength < o.size) continue;
      hasReachedMinimumLength = true;
    }
    prev = FreehandPoint(
      point,
      valid(pts[i].$3) ? pts[i].$3! : _defaultPressure,
      _uni(_sub(prev.point, point)),
      distance,
      runningLength,
    );
    out.add(prev);
  }
  out[0].vector = out.length > 1 ? out[1].vector : (0, 0);
  return out;
}

/// getStrokeOutlinePoints: o polígono do contorno.
List<Vec> strokeOutline(List<FreehandPoint> points, FreehandOptions o) {
  final size = o.size;
  if (points.isEmpty || size <= 0) return [];
  final totalLength = points.last.runningLength;
  final taperStart = o.taperStart == double.infinity
      ? math.max(size, totalLength)
      : o.taperStart;
  final taperEnd = o.taperEnd == double.infinity
      ? math.max(size, totalLength)
      : o.taperEnd;
  final minDistance = math.pow(size * o.smoothing, 2);
  final leftPts = <Vec>[];
  final rightPts = <Vec>[];

  var prevPressure = points.take(10).fold<double>(points[0].pressure, (acc, c) {
    var p = c.pressure;
    if (o.simulatePressure) p = simulatedPressure(acc, c.distance, size);
    return (acc + p) / 2;
  });
  var radius = _radius(size, o.thinning, points.last.pressure);
  double? firstRadius;
  var prevVector = points[0].vector;
  var prevLeftPoint = points[0].point;
  var prevRightPoint = prevLeftPoint;
  var tempLeftPoint = prevLeftPoint;
  var tempRightPoint = prevRightPoint;
  var isPrevPointSharpCorner = false;

  for (var i = 0; i < points.length; i++) {
    var pressure = points[i].pressure;
    final point = points[i].point;
    final vector = points[i].vector;
    final distance = points[i].distance;
    final runningLength = points[i].runningLength;
    final isLast = i == points.length - 1;
    if (!isLast && totalLength - runningLength < _endNoiseThreshold) continue;

    if (o.thinning != 0) {
      if (o.simulatePressure) {
        pressure = simulatedPressure(prevPressure, distance, size);
      }
      radius = _radius(size, o.thinning, pressure);
    } else {
      radius = size / 2;
    }
    firstRadius ??= radius;

    final taperStartStrength = runningLength < taperStart
        ? _easeStart(runningLength / taperStart)
        : 1.0;
    final taperEndStrength = totalLength - runningLength < taperEnd
        ? _easeEnd((totalLength - runningLength) / taperEnd)
        : 1.0;
    radius = math.max(
      _minRadius,
      radius * math.min(taperStartStrength, taperEndStrength),
    );

    final nextVector = (!isLast ? points[i + 1] : points[i]).vector;
    final nextDpr = !isLast ? _dpr(vector, nextVector) : 1.0;
    final prevDpr = _dpr(vector, prevVector);
    final isPointSharpCorner = prevDpr < 0 && !isPrevPointSharpCorner;
    final isNextPointSharpCorner = nextDpr < 0;

    if (isPointSharpCorner || isNextPointSharpCorner) {
      final offset = _mul(_per(prevVector), radius);
      const step = 1 / _cornerCapSegments;
      for (var t = 0.0; t <= 1; t += step) {
        tempLeftPoint = _rot(_sub(point, offset), point, _fixedPi * t);
        leftPts.add(tempLeftPoint);
        tempRightPoint = _rot(_add(point, offset), point, _fixedPi * -t);
        rightPts.add(tempRightPoint);
      }
      prevLeftPoint = tempLeftPoint;
      prevRightPoint = tempRightPoint;
      if (isNextPointSharpCorner) isPrevPointSharpCorner = true;
      continue;
    }
    isPrevPointSharpCorner = false;

    if (isLast) {
      final offset = _mul(_per(vector), radius);
      leftPts.add(_sub(point, offset));
      rightPts.add(_add(point, offset));
      continue;
    }

    final offset = _mul(_per(_lrp(nextVector, vector, nextDpr)), radius);
    tempLeftPoint = _sub(point, offset);
    if (i <= 1 || _dist2(prevLeftPoint, tempLeftPoint) > minDistance) {
      leftPts.add(tempLeftPoint);
      prevLeftPoint = tempLeftPoint;
    }
    tempRightPoint = _add(point, offset);
    if (i <= 1 || _dist2(prevRightPoint, tempRightPoint) > minDistance) {
      rightPts.add(tempRightPoint);
      prevRightPoint = tempRightPoint;
    }
    prevPressure = pressure;
    prevVector = vector;
  }

  final firstPoint = (points[0].point.$1, points[0].point.$2);
  final Vec lastPoint = points.length > 1
      ? (points.last.point.$1, points.last.point.$2)
      : _add(points[0].point, (1, 1));
  final startCap = <Vec>[];
  final endCap = <Vec>[];

  if (points.length == 1) {
    if (!(taperStart != 0 || taperEnd != 0) || o.last) {
      return _dot(firstPoint, firstRadius ?? radius);
    }
  } else {
    if (taperStart != 0 || (taperEnd != 0 && points.length == 1)) {
      // início afunilado
    } else if (o.capStart) {
      const step = 1 / _startCapSegments;
      for (var t = step; t <= 1; t += step) {
        startCap.add(_rot(rightPts[0], firstPoint, _fixedPi * t));
      }
    } else {
      final cornersVector = _sub(leftPts[0], rightPts[0]);
      final offsetA = _mul(cornersVector, 0.5);
      final offsetB = _mul(cornersVector, 0.51);
      startCap.addAll([
        _sub(firstPoint, offsetA),
        _sub(firstPoint, offsetB),
        _add(firstPoint, offsetB),
        _add(firstPoint, offsetA),
      ]);
    }
    final direction = _per(_neg(points.last.vector));
    if (taperEnd != 0 || (taperStart != 0 && points.length == 1)) {
      endCap.add(lastPoint);
    } else if (o.capEnd) {
      final start = _prj(lastPoint, direction, radius);
      const step = 1 / _endCapSegments;
      for (var t = step; t < 1; t += step) {
        endCap.add(_rot(start, lastPoint, _fixedPi * 3 * t));
      }
    } else {
      endCap.addAll([
        _add(lastPoint, _mul(direction, radius)),
        _add(lastPoint, _mul(direction, radius * 0.99)),
        _sub(lastPoint, _mul(direction, radius * 0.99)),
        _sub(lastPoint, _mul(direction, radius)),
      ]);
    }
  }
  return [...leftPts, ...endCap, ...rightPts.reversed, ...startCap];
}

double _easeStart(double t) => t * (2 - t);
double _easeEnd(double t) {
  final u = t - 1;
  return u * u * u + 1;
}

List<Vec> _dot(Vec center, double radius) {
  final offset = _add(center, (1, 1));
  final start = _prj(center, _uni(_per(_sub(center, offset))), -radius);
  final pts = <Vec>[];
  const step = 1 / _startCapSegments;
  for (var t = step; t <= 1; t += step) {
    pts.add(_rot(start, center, _fixedPi * 2 * t));
  }
  return pts;
}

/// getStroke: o contorno do traço [input] = (x, y, pressão ou null).
List<Vec> freehandOutline(
  List<(double, double, double?)> input,
  FreehandOptions o,
) => strokeOutline(strokePoints(input, o), o);

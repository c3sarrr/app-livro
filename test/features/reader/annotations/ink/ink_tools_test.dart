// G16.3 — as ferramentas puras (§3): a Reta gruda em múltiplos de 15° abaixo de 4° e não nasce com menos de 4 px; a
// Borracha toca o traço a até meia espessura + 8 px de algum segmento (cruzando também) e o grifo pela área pintada;
// o Laço seleciona com ≥ 50 % dos pontos dentro (par-ímpar, polígono côncavo); o batente da página (D-165).
import 'dart:math' as math;

import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_tools.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:flutter_test/flutter_test.dart';

InkOffset _polar(double length, double degrees) => (
  x: 100 + length * math.cos(degrees * math.pi / 180),
  y: 200 + length * math.sin(degrees * math.pi / 180),
);

double _lengthOf(InkOffset end) =>
    math.sqrt(math.pow(end.x - 100, 2) + math.pow(end.y - 200, 2));

InkStroke _stroke(
  List<(double, double)> points, {
  int width = 120,
  int? tool,
}) => InkStroke(
  tool: tool ?? InkTool.pen.code,
  tip: 0,
  argb: 0xFFFF552E,
  widthCentiMm: width,
  points: [for (final (x, y) in points) InkPoint(x, y, 0.5, 0)],
);

void main() {
  const start = (x: 100.0, y: 200.0);

  group('Reta', () {
    test('gruda no múltiplo de 15° mais perto abaixo de 4°, com o mesmo comprimento', () {
      for (final (degrees, expected) in [
        (3.9, 0.0),
        (-3.9, 0.0),
        (89.0, 90.0),
        (-44.0, -45.0),
        (18.5, 15.0),
        (176.5, 180.0),
      ]) {
        final end = snapLineEnd(start, _polar(80, degrees));
        final want = _polar(80, expected);
        expect(end.x, closeTo(want.x, 1e-9), reason: '$degrees°');
        expect(end.y, closeTo(want.y, 1e-9), reason: '$degrees°');
        expect(_lengthOf(end), closeTo(80, 1e-9), reason: '$degrees°');
      }
    });

    test('a 4° ou mais não gruda', () {
      for (final degrees in [4.1, -4.1, 19.1, 52.5]) {
        final end = _polar(80, degrees);
        expect(snapLineEnd(start, end), end, reason: '$degrees°');
      }
      expect(snapLineEnd(start, start), start, reason: 'sem comprimento');
    });

    test('com menos de 4 px não cria', () {
      expect(lineTooShort(start, _polar(3.9, 30)), isTrue);
      expect(lineTooShort(start, (x: 104, y: 200)), isFalse);
      expect(lineTooShort(start, start), isTrue);
    });
  });

  group('Borracha', () {
    test('distância entre segmentos: 0 quando cruzam', () {
      expect(
        segmentDistance(
          (x: 0, y: 0),
          (x: 10, y: 10),
          (x: 0, y: 10),
          (x: 10, y: 0),
        ),
        0,
      );
      expect(
        segmentDistance(
          (x: 0, y: 0),
          (x: 10, y: 0),
          (x: 5, y: 3),
          (x: 5, y: 9),
        ),
        3,
      );
      expect(
        segmentDistance(
          (x: 0, y: 0),
          (x: 10, y: 0),
          (x: 13, y: 4),
          (x: 20, y: 4),
        ),
        5,
        reason: 'ponta com ponta',
      );
      expect(
        segmentDistance((x: 0, y: 0), (x: 0, y: 0), (x: 3, y: 4), (x: 3, y: 4)),
        5,
        reason: 'dois pontos',
      );
    });

    test('toca o traço a até meia espessura + 8 px de algum segmento', () {
      final s = _stroke([(0, 100), (50, 100), (100, 100)]);
      final reach = dpOfCentiMm(120) / 2 + 8;
      expect(eraserReach(s), closeTo(9.1, 1e-12));
      expect(
        eraserTouchesStroke(
          (x: 40, y: 100 + reach - 0.001),
          (x: 60, y: 100 + reach - 0.001),
          s,
        ),
        isTrue,
      );
      expect(
        eraserTouchesStroke(
          (x: 40, y: 100 + 8.2 + 1.1),
          (x: 60, y: 100 + 8.2 + 1.1),
          s,
        ),
        isFalse,
      );
      // a espessura conta: a Grossa de 4 mm (7,2 mm efetivos) alcança mais
      final thick = _stroke([(0, 100), (100, 100)], width: 720);
      expect(
        eraserTouchesStroke((x: 40, y: 100 + 14), (x: 60, y: 100 + 14), thick),
        isTrue,
      );
    });

    test('cruzando o traço longe dos pontos, toca', () {
      final s = _stroke([(0, 0), (100, 0)]);
      expect(eraserTouchesStroke((x: 50, y: -50), (x: 50, y: 50), s), isTrue);
    });

    test('a Reta é o segmento dela; o traço de 1 ponto é o ponto', () {
      final line = _stroke([(0, 0), (200, 0)], tool: InkTool.line.code);
      expect(eraserTouchesStroke((x: 150, y: 5), (x: 151, y: 5), line), isTrue);
      final dot = _stroke([(30, 30)]);
      expect(eraserTouchesStroke((x: 30, y: 39), (x: 30, y: 39), dot), isTrue);
      expect(
        eraserTouchesStroke((x: 30, y: 39.2), (x: 30, y: 45), dot),
        isFalse,
      );
      expect(
        eraserTouchesStroke((x: 0, y: 0), (x: 1, y: 1), _stroke(const [])),
        isFalse,
      );
    });

    test('o grifo: o caminho do dedo passa pela área pintada', () {
      const box = InkRect(28, 230, 176, 260);
      // atravessando
      expect(
        eraserTouchesRect((x: 100, y: 200), (x: 100, y: 300), box),
        isTrue,
      );
      // dentro
      expect(eraserTouchesRect((x: 50, y: 240), (x: 60, y: 245), box), isTrue);
      // passando de raspão pelo canto (entra pela borda direita em y = 231)
      expect(
        eraserTouchesRect((x: 165, y: 220), (x: 185, y: 240), box),
        isTrue,
      );
      // e por fora do canto, sem tocar (em x = 176, y = 226)
      expect(
        eraserTouchesRect((x: 170, y: 220), (x: 190, y: 240), box),
        isFalse,
      );
      // ao lado, sem tocar
      expect(
        eraserTouchesRect((x: 180, y: 200), (x: 180, y: 300), box),
        isFalse,
      );
      expect(
        eraserTouchesRect((x: 10, y: 225), (x: 200, y: 229), box),
        isFalse,
      );
    });
  });

  group('Laço', () {
    // um "C": o vão do meio fica fora
    const c = [
      (x: 0.0, y: 0.0),
      (x: 100.0, y: 0.0),
      (x: 100.0, y: 30.0),
      (x: 30.0, y: 30.0),
      (x: 30.0, y: 70.0),
      (x: 100.0, y: 70.0),
      (x: 100.0, y: 100.0),
      (x: 0.0, y: 100.0),
    ];

    test('dentro pelo par-ímpar, com o polígono côncavo', () {
      expect(insidePolygon((x: 10, y: 50), c), isTrue);
      expect(insidePolygon((x: 60, y: 15), c), isTrue);
      expect(insidePolygon((x: 60, y: 50), c), isFalse, reason: 'o vão do C');
      expect(insidePolygon((x: 150, y: 50), c), isFalse);
      expect(
        insidePolygon(
          (x: 10, y: 50),
          const [(x: 0.0, y: 0.0), (x: 10.0, y: 0.0)],
        ),
        isFalse,
      );
    });

    test('seleciona com ≥ 50 % dos pontos dentro', () {
      List<(double, double)> points(int inside, int total) => [
        for (var i = 0; i < total; i++)
          i < inside ? (10.0, 50.0) : (60.0, 50.0),
      ];
      expect(lassoSelects(_stroke(points(50, 100)), c), isTrue);
      expect(lassoSelects(_stroke(points(49, 100)), c), isFalse);
      expect(lassoSelects(_stroke(points(1, 2)), c), isTrue);
      expect(lassoSelects(_stroke(const []), c), isFalse);
    });
  });

  group('Batente (D-165)', () {
    test('o limite: a última linha passa da borda de mesa', () {
      expect(panLimit(lastLineBottom: 890, deskTop: 594), 296);
      expect(panLimit(lastLineBottom: 500, deskTop: 594), 0);
    });

    test('dentro do limite igual; fora, 1/3 do excesso, dos dois lados', () {
      expect(rubberBand(-100, 296), -100);
      expect(rubberBand(0, 296), 0);
      expect(rubberBand(-296, 296), -296);
      expect(rubberBand(30, 296), 10);
      expect(rubberBand(-326, 296), -306);
      expect(rubberBand(-30, 0), -10, reason: 'sem folga');
    });
  });
}

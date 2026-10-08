// G16.1 — codec BNK1 (Anexo 03 §9.6): o formato congelado do S4, ida e volta, erros tipados, base64, a unidade pelo
// tipo da camada e o teto de 256 KiB.
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:flutter_test/flutter_test.dart';

/// O traço do vetor congelado do S4.
const _frozen = InkStroke(
  tool: 0,
  tip: 1,
  argb: 0xFFE4572E,
  widthCentiMm: 120,
  points: [
    InkPoint(1.5, -0.25, 0.5, 0),
    InkPoint(1.62, -0.2, 0.6, 8),
    InkPoint(1.75, -0.1, 0.7, 16),
  ],
);

InkStroke _random(math.Random r) {
  final n = r.nextInt(300);
  var t = 0;
  var x = (r.nextDouble() - 0.5) * 200;
  var y = (r.nextDouble() - 0.5) * 200;
  return InkStroke(
    tool: r.nextInt(6),
    tip: r.nextInt(3),
    argb: r.nextInt(1 << 32),
    widthCentiMm: r.nextInt(0x10000),
    points: [
      for (var i = 0; i < n; i++)
        InkPoint(
          x += (r.nextDouble() - 0.5) * (i % 50 == 0 ? 400 : 4),
          y += (r.nextDouble() - 0.5) * (i % 50 == 0 ? 400 : 4),
          r.nextDouble(),
          t += r.nextInt(i % 70 == 0 ? 5000 : 20),
        ),
    ],
  );
}

/// Os maiores desvios de [back] contra [original]: (posição, pressão); o resto tem de ser igual.
(double, double) _deviation(List<InkStroke> original, List<InkStroke> back) {
  expect(back, hasLength(original.length));
  var position = 0.0;
  var pressure = 0.0;
  for (var k = 0; k < original.length; k++) {
    final a = original[k];
    final b = back[k];
    expect(
      (b.tool, b.tip, b.argb, b.widthCentiMm),
      (a.tool, a.tip, a.argb, a.widthCentiMm),
    );
    expect(b.points, hasLength(a.points.length));
    for (var i = 0; i < a.points.length; i++) {
      final p = a.points[i];
      final q = b.points[i];
      position = math.max(position, (p.x - q.x).abs());
      position = math.max(position, (p.y - q.y).abs());
      pressure = math.max(pressure, (p.pressure - q.pressure).abs());
      expect(q.tMs, p.tMs);
    }
  }
  return (position, pressure);
}

InkStroke _withPoint(InkPoint p) => InkStroke(
  tool: 1,
  tip: 0,
  argb: 0xFFFF552E,
  widthCentiMm: 120,
  points: [p],
);

void main() {
  test('formato congelado da versão 1 (o mesmo vetor do S4)', () {
    // Qualquer mudança nestes bytes quebra camadas já gravadas: exige versão 2 e migração.
    final hex = encodeBnk1([
      _frozen,
    ], Bnk1Unit.em).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    expect(
      hex,
      '424e4b310101' // "BNK1", versão 1, 1 traço
      '0001e4572eff780003' // ferramenta 0, ponta 1, RGB, alpha, 1,20 mm, 3 pontos
      'ac02318000' // Δx +150 · Δy −25 · pressão 128 · Δt 0
      '180a9908' // Δx +12 · Δy +5 · 153 · 8 ms
      '1a14b308', // Δx +13 · Δy +10 · 179 (0,7 × 255 = 178,5 arredonda para cima) · 8 ms
    );
  });

  test('ida e volta: 1.000 traços aleatórios nas duas unidades', () {
    final r = math.Random(20261003);
    for (final u in Bnk1Unit.values) {
      var position = 0.0;
      var pressure = 0.0;
      for (var batch = 0; batch < 50; batch++) {
        final strokes = List.generate(10, (_) => _random(r));
        final bytes = encodeBnk1(strokes, u);
        final back = decodeBnk1(bytes, u);
        final (dp, dpr) = _deviation(strokes, back);
        position = math.max(position, dp);
        pressure = math.max(pressure, dpr);
        // idempotente: recodificar o que voltou dá os mesmos bytes
        expect(encodeBnk1(back, u), bytes);
      }
      expect(position, lessThanOrEqualTo(0.5 / u.scale + 1e-12));
      expect(pressure, lessThanOrEqualTo(0.5 / 255 + 1e-12));
    }
  });

  test('camada vazia e traço sem pontos', () {
    final empty = encodeBnk1(const [], Bnk1Unit.em);
    expect(empty, [0x42, 0x4E, 0x4B, 0x31, 1, 0]);
    expect(decodeBnk1(empty, Bnk1Unit.em), isEmpty);
    const t = InkStroke(
      tool: 1,
      tip: 2,
      argb: 0x80FFD23F,
      widthCentiMm: 65535,
      points: [],
    );
    final back = decodeBnk1(encodeBnk1([t], Bnk1Unit.box), Bnk1Unit.box);
    expect(back, [t]);
  });

  test(
    'erros tipados: assinatura, versão, cada prefixo truncado, lixo no fim',
    () {
      final ok = encodeBnk1([_frozen, _frozen.copyWith(tool: 2)], Bnk1Unit.em);
      expect(
        () => decodeBnk1(
          Uint8List.fromList([0x42, 0x4E, 0x4B, 0x32, 1, 0]),
          Bnk1Unit.em,
        ),
        throwsA(isA<InvalidSignature>()),
      );
      final v2 = Uint8List.fromList(ok)..[4] = 2;
      expect(
        () => decodeBnk1(v2, Bnk1Unit.em),
        throwsA(isA<UnknownVersion>().having((e) => e.version, 'version', 2)),
      );
      for (var n = 0; n < ok.length; n++) {
        expect(
          () => decodeBnk1(Uint8List.sublistView(ok, 0, n), Bnk1Unit.em),
          throwsA(n < 4 ? isA<InvalidSignature>() : isA<TruncatedData>()),
          reason: 'prefixo de $n bytes',
        );
      }
      expect(
        () => decodeBnk1(Uint8List.fromList([...ok, 0, 0]), Bnk1Unit.em),
        throwsA(isA<TrailingBytes>().having((e) => e.count, 'count', 2)),
      );
      expect(
        () => decodeBnk1(Uint8List.fromList([...ok, 0]), Bnk1Unit.em),
        throwsA(isA<Bnk1Failure>()),
      );
    },
  );

  test(
    'fora da faixa: tempo voltando, largura, códigos e números não finitos',
    () {
      expect(
        () => encodeBnk1(const [
          InkStroke(
            tool: 1,
            tip: 0,
            argb: 0,
            widthCentiMm: 10,
            points: [InkPoint(0, 0, 0, 10), InkPoint(0, 0, 0, 5)],
          ),
        ], Bnk1Unit.em),
        throwsA(isA<ValueOutOfRange>()),
      );
      for (final bad in [
        _frozen.copyWith(widthCentiMm: -1),
        _frozen.copyWith(widthCentiMm: 0x10000),
        _frozen.copyWith(tool: 256),
        _frozen.copyWith(tip: -1),
        _withPoint(const InkPoint(double.nan, 0, 0.5, 0)),
        _withPoint(const InkPoint(0, double.infinity, 0.5, 0)),
        _withPoint(const InkPoint(1e300, 0, 0.5, 0)),
        _withPoint(const InkPoint(0, 0, double.nan, 0)),
        _withPoint(const InkPoint(0, 0, 0.5, -1)),
      ]) {
        expect(
          () => encodeBnk1([bad], Bnk1Unit.em),
          throwsA(isA<ValueOutOfRange>()),
          reason: '$bad',
        );
      }
      // a pressão fora de 0–1 só é presa na faixa (a caneta do aparelho passa de 1 às vezes)
      final clamped = decodeBnk1(
        encodeBnk1([_withPoint(const InkPoint(0, 0, 1.4, 0))], Bnk1Unit.em),
        Bnk1Unit.em,
      );
      expect(clamped.single.points.single.pressure, 1);
    },
  );

  test('base64: ida e volta; vazio = nenhum traço; inválido = assinatura', () {
    final b64 = encodeStrokesB64([_frozen], Bnk1Unit.em);
    expect(b64, base64Encode(encodeBnk1([_frozen], Bnk1Unit.em)));
    final (position, pressure) = _deviation([
      _frozen,
    ], decodeStrokesB64(b64, Bnk1Unit.em));
    expect(position, lessThanOrEqualTo(0.005 + 1e-12));
    expect(pressure, lessThanOrEqualTo(0.5 / 255 + 1e-12));
    // as camadas antigas do mundo têm `strokesB64` vazio
    expect(decodeStrokesB64('', Bnk1Unit.em), isEmpty);
    expect(
      () => decodeStrokesB64('não é base64!', Bnk1Unit.em),
      throwsA(isA<InvalidSignature>()),
    );
    expect(
      () => decodeStrokesB64(base64Encode([1, 2, 3, 4, 5, 6]), Bnk1Unit.em),
      throwsA(isA<InvalidSignature>()),
    );
  });

  test('a unidade vem do tipo da camada', () {
    expect(unitOf(InkLayerKind.overText), Bnk1Unit.em);
    expect(unitOf(InkLayerKind.space), Bnk1Unit.box);
    expect((Bnk1Unit.em.scale, Bnk1Unit.box.scale), (100, 10000));
  });

  test('teto de 256 KiB: o desenho que passaria disso não cabe', () {
    InkStroke zeros(int n) => InkStroke(
      tool: 1,
      tip: 0,
      argb: 0xFFFF552E,
      widthCentiMm: 120,
      points: List.filled(n, const InkPoint(0, 0, 0, 0)),
    );
    // 6 do cabeçalho + 11 do traço (nº de pontos em 3 bytes) + 4 por ponto
    expect(encodeBnk1([zeros(65531)], Bnk1Unit.em).length, 262141);
    expect(fitsBnk1([zeros(65531)], Bnk1Unit.em), isTrue);
    expect(encodeBnk1([zeros(65532)], Bnk1Unit.em).length, 262145);
    expect(fitsBnk1([zeros(65532)], Bnk1Unit.em), isFalse);
    expect(fitsBnk1(const [], Bnk1Unit.em), isTrue);
    // o teto do binário é o mesmo do base64 da camada (o CHECK do banco)
    expect(bnk1MaxBytes, 256 * 1024);
    expect(
      base64Encode(Uint8List(bnk1MaxBytes)).length,
      InkLayer.maxStrokesB64,
    );
  });
}

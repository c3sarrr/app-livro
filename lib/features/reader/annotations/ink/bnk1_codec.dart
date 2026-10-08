// G16.1 — codec BNK1 dos traços de tinta (Anexo 03 §9.6): o porte do spike S4 da G02, com o formato da versão 1
// congelado pelo mesmo vetor de bytes. Dart puro (sem dart:ui).
//
//   cabeçalho: "BNK1" | versão u8 | nº de traços varint
//   traço:     ferramenta u8 | ponta u8 | cor RGB 3 bytes | alpha u8 | largura (centésimos de mm) u16 LE
//              nº de pontos varint
//              pontos: x, y quantizados (1/escala da unidade da camada) em delta zigzag varint,
//                      pressão u8 (0–255), Δt ms varint (o 1º ponto guarda o Δt desde o início do traço)
//
// A unidade vem do tipo da camada (D-29, D-162): `over_text` → em da linha da âncora (1/100 em); `space` → caixa do
// espaço normalizada (1/10000 da caixa). Quantização: |x − x'| ≤ 0,5/escala; pressão ±0,5/255; tempo em ms inteiros.
// Arredondamento "meio para longe do zero" (`double.round()` do Dart = `Math.round` do JS para positivos); outra
// implementação (servidor, exportação) precisa usar o mesmo — o teste do formato congelado pega.
//
// O teto de 256 KiB por camada (o CHECK do banco: 349.528 em base64) é aplicado antes de gravar: um desenho que
// passaria disso fecha e o próximo traço começa outro ([fitsBnk1]).
import 'dart:convert';
import 'dart:typed_data';

import '../domain/ink_layer.dart';
import 'ink_stroke.dart';

const int bnk1Version = 1;

/// O teto de uma camada em bytes (256 KiB; o base64 dele é o `InkLayer.maxStrokesB64`).
const int bnk1MaxBytes = 256 * 1024;

/// Coordenada quantizada máxima (folga larga: uma página tem poucas dezenas de em).
const int _maxQuantized = 1 << 40;

/// A unidade das coordenadas gravadas.
enum Bnk1Unit {
  /// `over_text`: 1/100 do em da linha da âncora.
  em(100),

  /// `space`: x em 1/10000 da largura da caixa do espaço; y em 1/10000 de linha da nota (42 px), a partir do topo
  /// da caixa (Anexo 03 §9.5, G18 — `note_ink.dart`).
  box(10000);

  const Bnk1Unit(this.scale);

  final int scale;
}

/// A unidade da camada do tipo [kind].
Bnk1Unit unitOf(InkLayerKind kind) => switch (kind) {
  InkLayerKind.overText => Bnk1Unit.em,
  InkLayerKind.space => Bnk1Unit.box,
};

sealed class Bnk1Failure implements Exception {
  const Bnk1Failure(this.message);

  final String message;

  @override
  String toString() => 'Bnk1Failure: $message';
}

final class InvalidSignature extends Bnk1Failure {
  const InvalidSignature() : super('não começa com "BNK1"');
}

final class UnknownVersion extends Bnk1Failure {
  const UnknownVersion(this.version) : super('versão $version desconhecida');

  final int version;
}

final class TruncatedData extends Bnk1Failure {
  const TruncatedData() : super('os dados terminam no meio de um campo');
}

final class TrailingBytes extends Bnk1Failure {
  const TrailingBytes(this.count)
    : super('$count bytes sobrando depois do último traço');

  final int count;
}

final class ValueOutOfRange extends Bnk1Failure {
  const ValueOutOfRange(super.message);
}

final class _Writer {
  final _b = BytesBuilder();

  void u8(int v) => _b.addByte(v & 0xFF);

  void u16(int v) {
    _b
      ..addByte(v & 0xFF)
      ..addByte((v >> 8) & 0xFF);
  }

  void varint(int v) {
    assert(v >= 0);
    while (v >= 0x80) {
      _b.addByte((v & 0x7F) | 0x80);
      v >>= 7;
    }
    _b.addByte(v);
  }

  void zigzag(int v) => varint(v >= 0 ? v << 1 : ((-v) << 1) - 1);

  void bytes(List<int> b) => _b.add(b);

  Uint8List done() => _b.takeBytes();
}

final class _Reader {
  _Reader(this._d);

  final Uint8List _d;
  int _i = 0;

  int get remaining => _d.length - _i;

  int u8() {
    if (_i >= _d.length) throw const TruncatedData();
    return _d[_i++];
  }

  int u16() => u8() | (u8() << 8);

  int varint() {
    var r = 0;
    var s = 0;
    while (true) {
      final b = u8();
      r |= (b & 0x7F) << s;
      if (b < 0x80) return r;
      s += 7;
      if (s > 63) throw const ValueOutOfRange('varint longo demais');
    }
  }

  int zigzag() {
    final v = varint();
    return (v & 1) == 0 ? v >> 1 : -((v + 1) >> 1);
  }
}

int _quantize(double v, Bnk1Unit u) {
  final q = v * u.scale;
  if (!q.isFinite || q.abs() > _maxQuantized) {
    throw ValueOutOfRange('coordenada $v');
  }
  return q.round();
}

int _quantizePressure(double p) {
  if (p.isNaN) throw ValueOutOfRange('pressão $p');
  return (p.clamp(0.0, 1.0) * 255).round();
}

int _byte(int v, String what) {
  if (v < 0 || v > 0xFF) throw ValueOutOfRange('$what $v');
  return v;
}

/// Os traços [strokes] em BNK1, nas coordenadas da unidade [unit].
Uint8List encodeBnk1(List<InkStroke> strokes, Bnk1Unit unit) {
  final w = _Writer()
    ..bytes(const [0x42, 0x4E, 0x4B, 0x31]) // "BNK1"
    ..u8(bnk1Version)
    ..varint(strokes.length);
  for (final s in strokes) {
    if (s.widthCentiMm < 0 || s.widthCentiMm > 0xFFFF) {
      throw ValueOutOfRange('largura ${s.widthCentiMm}');
    }
    w
      ..u8(_byte(s.tool, 'ferramenta'))
      ..u8(_byte(s.tip, 'ponta'))
      ..u8(s.argb >> 16)
      ..u8(s.argb >> 8)
      ..u8(s.argb)
      ..u8(s.argb >> 24)
      ..u16(s.widthCentiMm)
      ..varint(s.points.length);
    var px = 0;
    var py = 0;
    var pt = 0;
    for (final p in s.points) {
      final qx = _quantize(p.x, unit);
      final qy = _quantize(p.y, unit);
      final dt = p.tMs - pt;
      if (dt < 0) throw ValueOutOfRange('o tempo voltou: ${p.tMs} < $pt');
      w
        ..zigzag(qx - px)
        ..zigzag(qy - py)
        ..u8(_quantizePressure(p.pressure))
        ..varint(dt);
      px = qx;
      py = qy;
      pt = p.tMs;
    }
  }
  return w.done();
}

/// Os traços de [data] (BNK1), nas coordenadas da unidade [unit].
List<InkStroke> decodeBnk1(Uint8List data, Bnk1Unit unit) {
  final r = _Reader(data);
  if (data.length < 4 ||
      r.u8() != 0x42 ||
      r.u8() != 0x4E ||
      r.u8() != 0x4B ||
      r.u8() != 0x31) {
    throw const InvalidSignature();
  }
  final version = r.u8();
  if (version != bnk1Version) throw UnknownVersion(version);
  final n = r.varint();
  final strokes = <InkStroke>[];
  for (var k = 0; k < n; k++) {
    final tool = r.u8();
    final tip = r.u8();
    final red = r.u8();
    final green = r.u8();
    final blue = r.u8();
    final alpha = r.u8();
    final width = r.u16();
    final count = r.varint();
    final points = <InkPoint>[];
    var x = 0;
    var y = 0;
    var t = 0;
    for (var i = 0; i < count; i++) {
      x += r.zigzag();
      y += r.zigzag();
      final pressure = r.u8();
      t += r.varint();
      points.add(InkPoint(x / unit.scale, y / unit.scale, pressure / 255, t));
    }
    strokes.add(
      InkStroke(
        tool: tool,
        tip: tip,
        argb: (alpha << 24) | (red << 16) | (green << 8) | blue,
        widthCentiMm: width,
        points: points,
      ),
    );
  }
  if (r.remaining != 0) throw TrailingBytes(r.remaining);
  return strokes;
}

/// O `strokes_b64` da camada.
String encodeStrokesB64(List<InkStroke> strokes, Bnk1Unit unit) =>
    base64Encode(encodeBnk1(strokes, unit));

/// Os traços do `strokes_b64` da camada; vazio = nenhum traço (as camadas antigas do mundo).
List<InkStroke> decodeStrokesB64(String b64, Bnk1Unit unit) {
  if (b64.isEmpty) return <InkStroke>[];
  final Uint8List bytes;
  try {
    bytes = base64Decode(b64);
  } on FormatException {
    throw const InvalidSignature();
  }
  return decodeBnk1(bytes, unit);
}

/// Os traços [strokes] cabem numa camada (≤ 256 KiB em BNK1).
bool fitsBnk1(List<InkStroke> strokes, Bnk1Unit unit) =>
    encodeBnk1(strokes, unit).length <= bnk1MaxBytes;

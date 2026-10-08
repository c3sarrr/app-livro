// G16.1 — o traço da tinta (Anexo 03 §9.6): os pontos (posição, pressão 0–1 e o tempo desde o início do traço), a
// ferramenta, a ponta, a cor ARGB e a largura efetiva em centésimos de mm (D-159). A ferramenta e a ponta ficam como
// os códigos do BNK1 (`int`): uma camada vinda de outra versão do app, com um código que esta não conhece, volta
// para o banco sem perder nada.
import 'package:flutter/foundation.dart' show immutable, listEquals;

import '../domain/pen_presets.dart';

/// Ferramenta gravada no traço (BNK1): 1 Caneta, 2 Reta, 3 Marca-texto (G17).
enum InkTool {
  pen(1),
  line(2),

  /// O Marca-texto fora das palavras: a tinta translúcida (R22, G17).
  marker(3);

  const InkTool(this.code);

  final int code;

  static InkTool? fromCode(int code) {
    for (final t in values) {
      if (t.code == code) return t;
    }
    return null;
  }
}

/// A ponta no BNK1: 0 esferográfica, 1 tinteiro, 2 pincel (as do `PenTip`).
int tipCode(PenTip t) => t.index;

/// A ponta do código [code]; desconhecida = esferográfica.
PenTip tipOfCode(int code) => code >= 0 && code < PenTip.values.length
    ? PenTip.values[code]
    : PenTip.ballpoint;

/// "#RRGGBB" de uma cor ARGB (o alpha fica de fora).
String colorHex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// A cor opaca de "#RRGGBB".
int argbOfHex(String hex) =>
    0xFF000000 | int.parse(hex.substring(1), radix: 16);

/// Um ponto do traço.
@immutable
final class InkPoint {
  const InkPoint(this.x, this.y, this.pressure, this.tMs);

  final double x;
  final double y;

  /// 0–1: a da caneta do aparelho, ou a simulada pela velocidade na captura (o dedo).
  final double pressure;

  /// Milissegundos desde o início do traço.
  final int tMs;

  @override
  bool operator ==(Object other) =>
      other is InkPoint &&
      other.x == x &&
      other.y == y &&
      other.pressure == pressure &&
      other.tMs == tMs;

  @override
  int get hashCode => Object.hash(x, y, pressure, tMs);

  @override
  String toString() => 'InkPoint($x, $y, $pressure, $tMs)';
}

/// Um traço: ferramenta e ponta (códigos do BNK1), cor ARGB, largura efetiva (centésimos de mm) e os pontos.
@immutable
final class InkStroke {
  const InkStroke({
    required this.tool,
    required this.tip,
    required this.argb,
    required this.widthCentiMm,
    required this.points,
  });

  final int tool;
  final int tip;
  final int argb;
  final int widthCentiMm;
  final List<InkPoint> points;

  InkStroke copyWith({
    int? tool,
    int? tip,
    int? argb,
    int? widthCentiMm,
    List<InkPoint>? points,
  }) => InkStroke(
    tool: tool ?? this.tool,
    tip: tip ?? this.tip,
    argb: argb ?? this.argb,
    widthCentiMm: widthCentiMm ?? this.widthCentiMm,
    points: points ?? this.points,
  );

  /// O mesmo traço deslocado de ([dx], [dy]).
  InkStroke translated(double dx, double dy) => copyWith(
    points: [
      for (final p in points) InkPoint(p.x + dx, p.y + dy, p.pressure, p.tMs),
    ],
  );

  @override
  bool operator ==(Object other) =>
      other is InkStroke &&
      other.tool == tool &&
      other.tip == tip &&
      other.argb == argb &&
      other.widthCentiMm == widthCentiMm &&
      listEquals(other.points, points);

  @override
  int get hashCode =>
      Object.hash(tool, tip, argb, widthCentiMm, Object.hashAll(points));
}

// G02 · S4 — traços sintéticos realistas (Dart puro, determinísticos pela semente).
// Unidades de entrada em dp; amostragem na taxa do sensor (60/120/240 Hz).
import 'dart:math' as math;

import 'bnk1.dart';

enum FormaTraco { manuscrito, sublinhado, circulo }

class AmostraDp {
  const AmostraDp(this.x, this.y, this.pressao, this.tMs);
  final double x;
  final double y;
  final double pressao;
  final int tMs;
}

/// Um traço: manuscrito (laçadas de ~4 Hz andando para a direita a ~60 dp/s), sublinhado
/// (reta rápida ~350 dp/s com tremor) ou círculo em volta de uma palavra (~1 s).
List<AmostraDp> tracoSintetico(math.Random rnd, FormaTraco forma, double hz) {
  final dt = 1000 / hz;
  final pts = <AmostraDp>[];
  final x0 = 28 + rnd.nextDouble() * 200;
  final y0 = 120 + rnd.nextDouble() * 500;
  final pBase = 0.35 + rnd.nextDouble() * 0.3;
  switch (forma) {
    case FormaTraco.manuscrito:
      final dur = 0.4 + rnd.nextDouble() * 0.8;
      final f = 3.5 + rnd.nextDouble();
      final v = 50 + rnd.nextDouble() * 30;
      final a = 6 + rnd.nextDouble() * 4;
      for (var t = 0.0; t <= dur; t += dt / 1000) {
        pts.add(
          AmostraDp(
            x0 + v * t + a * math.sin(2 * math.pi * f * t),
            y0 + a * 1.4 * math.cos(2 * math.pi * f * t + 0.6),
            (pBase + 0.15 * math.sin(2 * math.pi * 1.3 * t)).clamp(0, 1),
            (t * 1000).round(),
          ),
        );
      }
    case FormaTraco.sublinhado:
      final dur = 0.25 + rnd.nextDouble() * 0.4;
      final v = 300 + rnd.nextDouble() * 100;
      for (var t = 0.0; t <= dur; t += dt / 1000) {
        pts.add(
          AmostraDp(
            x0 + v * t,
            y0 +
                0.6 * math.sin(2 * math.pi * 9 * t) +
                (rnd.nextDouble() - 0.5) * 0.3,
            pBase,
            (t * 1000).round(),
          ),
        );
      }
    case FormaTraco.circulo:
      final dur = 0.8 + rnd.nextDouble() * 0.5;
      final rx = 30 + rnd.nextDouble() * 40;
      final ry = 14 + rnd.nextDouble() * 6;
      for (var t = 0.0; t <= dur; t += dt / 1000) {
        final ang = 2 * math.pi * 1.08 * t / dur;
        pts.add(
          AmostraDp(
            x0 + rx * math.cos(ang),
            y0 + ry * math.sin(ang),
            pBase,
            (t * 1000).round(),
          ),
        );
      }
  }
  return pts;
}

/// Converte para a unidade da camada `over_text` (em da palavra-âncora, D-29).
Traco tracoEmEm(
  List<AmostraDp> a, {
  double tamanhoFonte = 20.5,
  int argb = 0xFFE4572E,
  int larguraCentesimosMm = 120,
  int ferramenta = 0,
  int ponta = 0,
}) => Traco(
  ferramenta: ferramenta,
  ponta: ponta,
  argb: argb,
  larguraCentesimosMm: larguraCentesimosMm,
  pontos: [
    for (final p in a)
      PontoTinta(p.x / tamanhoFonte, p.y / tamanhoFonte, p.pressao, p.tMs),
  ],
);

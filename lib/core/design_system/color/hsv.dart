// G17.1 — a cor da roda da tela 23 (R13): tom de 0 a 360 (0° no topo, no sentido horário — o `conic-gradient` do
// arquivo), intensidade de 0 a 1 (do centro à borda) e brilho de 0 a 1 (o V do HSV). Com brilho 0 a cor é preta, mas
// o tom e a intensidade ficam guardados (a roda não perde o lugar). `normalizeHex` aceita só 6 dígitos (R14);
// `contrastRatio` é o da WCAG 2.1 (a tinta quase preta no Noite — D-174).
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;

@immutable
final class Hsv {
  const Hsv(this.h, this.s, this.v);

  /// O tom, em graus (0 = vermelho, no topo da roda).
  final double h;

  /// A intensidade (0 = branco, no centro da roda; 1 = a borda).
  final double s;

  /// O brilho (0 = preto).
  final double v;

  factory Hsv.fromArgb(int argb) {
    final r = (argb >> 16 & 0xFF) / 255;
    final g = (argb >> 8 & 0xFF) / 255;
    final b = (argb & 0xFF) / 255;
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final d = max - min;
    final double h;
    if (d == 0) {
      h = 0;
    } else if (max == r) {
      h = 60 * (((g - b) / d) % 6);
    } else if (max == g) {
      h = 60 * ((b - r) / d + 2);
    } else {
      h = 60 * ((r - g) / d + 4);
    }
    return Hsv(h, max == 0 ? 0 : d / max, max);
  }

  /// A cor de `#RRGGBB`.
  factory Hsv.fromHex(String hex) =>
      Hsv.fromArgb(0xFF000000 | int.parse(hex.substring(1), radix: 16));

  Hsv withH(double h) => Hsv(h, s, v);
  Hsv withS(double s) => Hsv(h, s, v);
  Hsv withV(double v) => Hsv(h, s, v);

  /// A cor opaca (ARGB).
  int toArgb() {
    final c = v * s;
    final hh = (h % 360) / 60;
    final x = c * (1 - ((hh % 2) - 1).abs());
    final (r, g, b) = switch (hh.floor()) {
      0 => (c, x, 0.0),
      1 => (x, c, 0.0),
      2 => (0.0, c, x),
      3 => (0.0, x, c),
      4 => (x, 0.0, c),
      _ => (c, 0.0, x),
    };
    final m = v - c;
    int ch(double u) => ((u + m) * 255).round().clamp(0, 255);
    return 0xFF000000 | ch(r) << 16 | ch(g) << 8 | ch(b);
  }

  /// `#RRGGBB` em maiúsculas.
  String toHex() =>
      '#${(toArgb() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  bool operator ==(Object other) =>
      other is Hsv && other.h == h && other.s == s && other.v == v;

  @override
  int get hashCode => Object.hash(h, s, v);

  @override
  String toString() => 'Hsv($h, $s, $v)';
}

final RegExp _sixHex = RegExp(r'^[0-9a-fA-F]{6}$');

/// `#RRGGBB` em maiúsculas; `null` se não forem 6 dígitos hexadecimais (com ou sem "#").
String? normalizeHex(String text) {
  final t = text.startsWith('#') ? text.substring(1) : text;
  if (!_sixHex.hasMatch(t)) return null;
  return '#${t.toUpperCase()}';
}

/// A luminância relativa da WCAG 2.1 (0 = preto, 1 = branco).
double relativeLuminance(int argb) {
  double lin(int c) {
    final u = c / 255;
    return u <= 0.04045
        ? u / 12.92
        : math.pow((u + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * lin(argb >> 16 & 0xFF) +
      0.7152 * lin(argb >> 8 & 0xFF) +
      0.0722 * lin(argb & 0xFF);
}

/// O contraste da WCAG 2.1 entre [a] e [b] (de 1 a 21).
double contrastRatio(int a, int b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

// G13 — uma página de mentira de uma linha só, com a geometria do leitor: a letra i ocupa x = x0 + 10·i … + 10; a
// linha vai de [topo] a [topo] + 35,26, com a linha de base em [topo] + 29,6 e a área do texto de [topo] + 2,41 a
// [topo] + 32,85 (Literata 20,5 com a entrelinha 1,72). Pinta cada letra (não espaço) como um retângulo de tinta.
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:flutter/painting.dart';

final class PaginaDeTexto implements DisplayPage {
  PaginaDeTexto(this.texto, {this.x0 = 0, this.topo = 0, this.unit = 0});

  final String texto;
  final double x0;
  final double topo;
  final int unit;

  static const double letra = 10;
  static const double alturaDaLinha = 35.26;
  static const Color tinta = Color(0xFF2A2520);
  static final RegExp _palavra = RegExp(r'\w+|[^\w\s]');

  @override
  bool get alive => true;

  @override
  bool get opaque => false;

  @override
  String get spokenText => texto;

  @override
  LinkHit? linkAt(Offset p) => null;

  @override
  void paint(ui.Canvas canvas) {
    final p = Paint()..color = tinta;
    for (var i = 0; i < texto.length; i++) {
      if (texto[i] == ' ') continue;
      canvas.drawRect(Rect.fromLTWH(x0 + letra * i + 2, topo + 8, 6, 20), p);
    }
  }

  @override
  List<Rect> rectsOf(int unit, int from, int to) => [
    for (final b in boxesOf(unit, from, to)) b.rect,
  ];

  @override
  ReaderRange? get shown => (unit: unit, from: 0, to: texto.length);

  @override
  ReaderSpot? spotAt(Offset p) => (
    unit: unit,
    offset: ((p.dx - x0) / letra).round().clamp(0, texto.length),
  );

  @override
  ReaderRange? wordAround(ReaderSpot s) {
    if (s.unit != unit) return null;
    for (final m in _palavra.allMatches(texto)) {
      if (m.start <= s.offset && s.offset < m.end) {
        return (unit: unit, from: m.start, to: m.end);
      }
    }
    return null;
  }

  @override
  ReaderRange? wordAt(Offset p) {
    final s = spotAt(p);
    if (s == null) return null;
    for (final o in [s.offset, s.offset - 1]) {
      final w = wordAround((unit: unit, offset: o));
      if (w == null || !RegExp(r'\w').hasMatch(texto.substring(w.from, w.to))) {
        continue;
      }
      if (boxesOf(unit, w.from, w.to).any((b) => b.rect.contains(p))) return w;
    }
    return null;
  }

  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) =>
      unit == this.unit && from < to
      ? [
          (
            rect: Rect.fromLTRB(
              x0 + letra * from,
              topo,
              x0 + letra * to,
              topo + alturaDaLinha,
            ),
            baseline: topo + 29.6,
            textTop: topo + 2.41,
            textBottom: topo + 32.85,
            em: 20.5,
          ),
        ]
      : const [];

  @override
  String textOf(int unit, int from, int to) => unit == this.unit
      ? texto.substring(from.clamp(0, texto.length), to.clamp(0, texto.length))
      : '';
}

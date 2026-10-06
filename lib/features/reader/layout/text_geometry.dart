// G13.1 — a área do texto de uma linha como no Chromium: o fundo de um `span` (grifo, seleção) cobre o ascent +
// descent da fonte, centrado na linha (30,44 px na Literata 20,5 com a entrelinha de 35,26 — L21a). Medida uma vez
// por tamanho, com a mesma Literata variável do livro.
import 'dart:ui' as ui;

import 'reader_typography.dart';

final Map<double, double> _areas = {};

/// ascent + descent da Literata do livro no tamanho [em] (sem a entrelinha).
double readerTextArea(double em) => _areas[em] ??= _measure(em);

double _measure(double em) {
  final b =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(textDirection: ui.TextDirection.ltr),
        )
        ..pushStyle(
          ui.TextStyle(
            fontFamily: readerFontFamily,
            fontFamilyFallback: readerFontFallback,
            fontSize: em,
            fontVariations: [
              ui.FontVariation('opsz', em),
              const ui.FontVariation('wght', readerTextWeight),
            ],
          ),
        )
        ..addText('x');
  final p = b.build()..layout(const ui.ParagraphConstraints(width: 1e6));
  final m = p.computeLineMetrics().first;
  p.dispose();
  return m.ascent + m.descent;
}

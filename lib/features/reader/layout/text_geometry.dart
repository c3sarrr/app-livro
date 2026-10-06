// G13.1 — a área do texto de uma linha como no Chromium: o fundo de um `span` (grifo, seleção) cobre o ascent +
// descent da fonte, centrado na linha (30,44 px na Literata 20,5 com a entrelinha de 35,26 — L21a). G14: medida uma
// vez por (fonte, tamanho), com a mesma família do livro (D-18).
import 'dart:ui' as ui;

import '../domain/reader_settings.dart';
import 'reader_typography.dart';

final Map<(ReaderFontFamily, double), double> _areas = {};

/// ascent + descent da fonte [font] do livro no tamanho [em] (sem a entrelinha).
double readerTextArea(
  double em, [
  ReaderFontFamily font = ReaderFontFamily.literata,
]) => _areas[(font, em)] ??= _measure(font, em);

double _measure(ReaderFontFamily font, double em) {
  final b =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(textDirection: ui.TextDirection.ltr),
        )
        ..pushStyle(
          ui.TextStyle(
            fontFamily: readerFamilyOf(font),
            fontFamilyFallback: readerFontFallback,
            fontSize: em,
            fontWeight: ui.FontWeight.w400,
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

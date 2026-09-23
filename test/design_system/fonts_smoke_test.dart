import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

/// Um caso da tabela da Subfase 0.6 (valores medidos no HTML original).
typedef _FontCase = ({
  String text,
  String family,
  double size,
  ui.FontWeight weight,
  ui.FontStyle style,
  double letterSpacing,
  double height,
  double width,
  double paragraphHeight,
});

const _kWidthTolerance = 0.10;

/// Tolerância da altura EXATA da linha (ascent + descent), igual à da tabela.
///
/// Decisão do usuário (opção A, 23/09/2026): o SkParagraph arredonda a altura de
/// cada linha para pixel inteiro (`skia/modules/skparagraph/src/Run.h:483-485`,
/// Skia 8df24be6 do Flutter 3.47.2) e nenhuma API do `dart:ui` desliga isso, então
/// `paragraph.height` nunca vale 19,2. A altura da caixa de linha do CSS
/// (fontSize × line-height) é lida sem arredondar em `ascent + descent` de
/// `computeLineMetrics()`; `paragraph.height` é conferido contra `round(esperado)`
/// para documentar o comportamento do motor (se um SDK futuro parar de
/// arredondar, este teste acusa).
const _kHeightTolerance = 0.01;

const List<_FontCase> _kCases = [
  (
    text: 'Continuar lendo',
    family: 'Figtree',
    size: 16,
    weight: ui.FontWeight.w700,
    style: ui.FontStyle.normal,
    letterSpacing: 0,
    height: 1.2,
    width: 117.89,
    paragraphHeight: 19.20,
  ),
  (
    text: 'Boa noite,',
    family: 'Figtree',
    size: 13,
    weight: ui.FontWeight.w500,
    style: ui.FontStyle.normal,
    letterSpacing: 0,
    height: 1.2,
    width: 58.43,
    paragraphHeight: 15.60,
  ),
  (
    text: 'ENCONTRO',
    family: 'Figtree',
    size: 10,
    weight: ui.FontWeight.w700,
    style: ui.FontStyle.normal,
    letterSpacing: 1.0,
    height: 1.2,
    width: 64.63,
    paragraphHeight: 12.00,
  ),
  (
    text: 'Continue',
    family: 'Bricolage42',
    size: 42,
    weight: ui.FontWeight.w800,
    style: ui.FontStyle.normal,
    letterSpacing: -1.4,
    height: 0.98,
    width: 170.69,
    paragraphHeight: 41.16,
  ),
  (
    text: '18',
    family: 'Bricolage34',
    size: 34,
    weight: ui.FontWeight.w800,
    style: ui.FontStyle.normal,
    letterSpacing: -1.0,
    height: 1.0,
    width: 31.86,
    paragraphHeight: 34.00,
  ),
  (
    text: 'Também lendo',
    family: 'Bricolage18',
    size: 18,
    weight: ui.FontWeight.w800,
    style: ui.FontStyle.normal,
    letterSpacing: -0.3,
    height: 1.2,
    width: 126.54,
    paragraphHeight: 21.60,
  ),
  (
    text: 'sua história.',
    family: 'InstrumentSerif',
    size: 50,
    weight: ui.FontWeight.w400,
    style: ui.FontStyle.italic,
    letterSpacing: -0.6,
    height: 0.98,
    width: 219.65,
    paragraphHeight: 49.00,
  ),
  (
    text: 'Capitu',
    family: 'InstrumentSerif',
    size: 36,
    weight: ui.FontWeight.w400,
    style: ui.FontStyle.italic,
    letterSpacing: -0.4,
    height: 0.95,
    width: 86.41,
    paragraphHeight: 34.20,
  ),
];

/// Layout de um `ui.Paragraph` puro (sem Text/TextPainter), largura infinita,
/// `TextLeadingDistribution.even`.
ui.Paragraph _layout(_FontCase c) {
  const behavior = ui.TextHeightBehavior(
    leadingDistribution: ui.TextLeadingDistribution.even,
  );
  final builder =
      ui.ParagraphBuilder(ui.ParagraphStyle(textHeightBehavior: behavior))
        ..pushStyle(
          ui.TextStyle(
            fontFamily: c.family,
            fontSize: c.size,
            fontWeight: c.weight,
            fontStyle: c.style,
            letterSpacing: c.letterSpacing,
            height: c.height,
            leadingDistribution: ui.TextLeadingDistribution.even,
          ),
        )
        ..addText(c.text);
  return builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
}

String _styleLabel(_FontCase c) =>
    '${c.family} ${c.size.toStringAsFixed(0)} w${c.weight.value}'
    '${c.style == ui.FontStyle.italic ? ' itálico' : ''}'
    ' ls ${c.letterSpacing} h ${c.height}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  for (final c in _kCases) {
    test('fonte: "${c.text}" — ${_styleLabel(c)}', () {
      final paragraph = _layout(c);
      final width = paragraph.maxIntrinsicWidth;
      final lines = paragraph.computeLineMetrics();
      final exactHeight = lines.fold<double>(
        0,
        (sum, line) => sum + line.ascent + line.descent,
      );
      final engineHeight = paragraph.height;
      final roundedExpected = c.paragraphHeight.roundToDouble();
      debugPrint(
        '[fonts_smoke] "${c.text}" (${_styleLabel(c)}): '
        'largura ${width.toStringAsFixed(3)} (esperado ${c.width.toStringAsFixed(2)} '
        '±$_kWidthTolerance, Δ ${(width - c.width).toStringAsFixed(3)}) | '
        'altura ascent+descent ${exactHeight.toStringAsFixed(3)} (esperado '
        '${c.paragraphHeight.toStringAsFixed(2)} ±$_kHeightTolerance, '
        'Δ ${(exactHeight - c.paragraphHeight).toStringAsFixed(3)}) | '
        'paragraph.height ${engineHeight.toStringAsFixed(3)} '
        '(round(esperado) = ${roundedExpected.toStringAsFixed(0)})',
      );
      expect(width, closeTo(c.width, _kWidthTolerance), reason: 'largura');
      expect(lines, hasLength(1), reason: 'o texto deve caber em 1 linha');
      expect(
        exactHeight,
        closeTo(c.paragraphHeight, _kHeightTolerance),
        reason: 'altura exata da linha (ascent + descent)',
      );
      expect(
        engineHeight,
        roundedExpected,
        reason: 'paragraph.height = altura arredondada pelo SkParagraph',
      );
    });
  }
}

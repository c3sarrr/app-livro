import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// Os 5 rótulos, na ordem da tabela "Linhas de texto" da F11.
const _textIds = [
  'nav.home.label',
  'nav.library.label',
  'nav.scanner.label',
  'nav.clubs.label',
  'nav.profile.label',
];

/// Linhas da tabela da F11 (relativas à seção `nav`): texto, baseline, início, fim e largura.
const _tableLines = <String, (String, double, double, double, double)>{
  'nav.home.label': ('Início', 51.35, 28.01, 55.59, 27.58),
  'nav.library.label': ('Biblioteca', 51.35, 85.5, 135.3, 49.8),
  'nav.scanner.label': ('Scanner', 55.75, 158.35, 199.65, 41.3),
  'nav.clubs.label': ('Clubes', 51.35, 230.37, 264.83, 34.46),
  'nav.profile.label': ('Perfil', 51.35, 303.18, 329.22, 26.04),
};

/// Origem da seção `nav` (16; 2290) no canvas.
const _origin = Offset(16, 2290);

/// Larguras de texto: as fontes estáticas foram validadas contra o navegador com desvio ≤ 0,05 px (§6.1).
const _eps = 0.05;

List<RenderAppText> _rendersOf(WidgetTester tester, String id) => [
  for (final e
      in find
          .descendant(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .evaluate())
    e.renderObject! as RenderAppText,
];

/// F11 — camada 4 (texto): strings, quebras e linhas dos 5 rótulos.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F11 texto: 5 rótulos, uma linha cada, strings e quebras exatas; baselines e extensões como no arquivo (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final id in _textIds) {
        expectTextLines(tester, id);
        reportTextLines(tester, id);
        final renders = _rendersOf(tester, id);
        expect(renders, hasLength(1), reason: id);
        expect(renders.single.debugLines(), hasLength(1), reason: id);
      }
    },
  );

  testWidgets(
    'linhas da tabela da F11 (relativas à seção): texto, baseline, início, fim e largura ≤ 0,05 px; as Keys do arquivo coincidem com a tabela',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      var worst = ('', 0.0);
      for (final id in _textIds) {
        final (text, baseline, left, right, width) = _tableLines[id]!;
        // O arquivo (kRefLayout) traz as mesmas linhas, em coordenadas do canvas.
        final ref = kRefLayout[id]!.lines.single;
        expect(ref.text, text, reason: id);
        expect(
          ref.baseline - _origin.dy,
          moreOrLessEquals(baseline, epsilon: 0.01),
        );
        expect(ref.left - _origin.dx, moreOrLessEquals(left, epsilon: 0.01));
        expect(ref.right - _origin.dx, moreOrLessEquals(right, epsilon: 0.01));
        final line = _rendersOf(tester, id).single.debugLines().single;
        expect(line.text, text, reason: id);
        for (final (what, got, want) in [
          ('baseline', line.baseline - _origin.dy, baseline),
          ('início', line.left - _origin.dx, left),
          ('fim', line.right - _origin.dx, right),
          ('largura', line.right - line.left, width),
        ]) {
          final d = (got - want).abs();
          if (d > worst.$2) worst = ('$id.$what', d);
          expect(
            got,
            moreOrLessEquals(want, epsilon: _eps),
            reason: '$id $what',
          );
        }
      }
      debugPrint(
        '[tabela F11 texto] 5 linhas; maior desvio ${worst.$1} = ${worst.$2.toStringAsFixed(4)}',
      );
    },
  );

  testWidgets(
    'os textos vêm literalmente do arquivo (acentos preservados) e nenhum rótulo é truncado',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final texts = {
        for (final id in _textIds)
          id: tester
              .widget<AppText>(
                find.descendant(
                  of: find.byKey(ValueKey<String>(id)),
                  matching: find.byType(AppText),
                  matchRoot: true,
                ),
              )
              .span
              .toPlainText(),
      };
      expect(texts, {
        'nav.home.label': 'Início',
        'nav.library.label': 'Biblioteca',
        'nav.scanner.label': 'Scanner',
        'nav.clubs.label': 'Clubes',
        'nav.profile.label': 'Perfil',
      });
      for (final id in _textIds) {
        expect(_rendersOf(tester, id).single.debugDidExceedMaxLines, isFalse);
      }
    },
  );
}

import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/home/presentation/covers/mrs_dalloway_cover.dart';
import 'package:app_leitura/features/home/presentation/covers/pride_prejudice_cover.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// Todos os textos da seção, na ordem da tabela "Linhas de texto" da F06.
const _textIds = [
  'alsoReading.title',
  'alsoReading.count',
  'alsoReading.card1.cover.title',
  'alsoReading.card1.ring.label',
  'alsoReading.card1.title',
  'alsoReading.card1.author',
  'alsoReading.card2.cover.title',
  'alsoReading.card2.ring.label',
  'alsoReading.card2.title',
  'alsoReading.card2.author',
];

/// Títulos e autores dos cards: `nowrap` + `ellipsis` no arquivo.
const _ellipsisIds = [
  'alsoReading.card1.title',
  'alsoReading.card1.author',
  'alsoReading.card2.title',
  'alsoReading.card2.author',
];

AppText _textWidget(WidgetTester tester, String id) => tester.widget<AppText>(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  ),
);

String _textOf(WidgetTester tester, String id) =>
    (_textWidget(tester, id).span as TextSpan).text!;

RenderAppText _renderOf(WidgetTester tester, String id) =>
    tester.renderObject<RenderAppText>(
      find.descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(AppText),
        matchRoot: true,
      ),
    );

/// Largura natural (uma linha) de [text] no parágrafo do SkParagraph.
double _naturalWidth(TextStyle style, String text) {
  final builder =
      ui.ParagraphBuilder(
          style.getParagraphStyle(
            textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        )
        ..pushStyle(style.getTextStyle())
        ..addText(text);
  final p = builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
  final w = p.maxIntrinsicWidth;
  p.dispose();
  return w;
}

/// F06 — camada 4 (texto) da seção `alsoReading`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F06 texto: quebras, baselines e extensões dos 10 textos da seção (capas: só quebras; card2.title: reticências)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final id in _textIds) {
        expectTextLines(tester, id);
        reportTextLines(tester, id);
      }
    },
  );

  testWidgets(
    'strings exatas do arquivo, derivadas dos dados (contador, percentuais, títulos e autores)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(_textOf(tester, 'alsoReading.title'), 'Também lendo');
      expect(_textOf(tester, 'alsoReading.count'), '2');
      // Capas: o <br> do arquivo.
      expect(
        _textOf(tester, 'alsoReading.card1.cover.title'),
        'Mrs.\nDalloway',
      );
      expect(
        _textOf(tester, 'alsoReading.card2.cover.title'),
        'Orgulho e\nPreconceito',
      );
      expect(_textOf(tester, 'alsoReading.card1.ring.label'), '34%');
      expect(_textOf(tester, 'alsoReading.card2.ring.label'), '81%');
      expect(_textOf(tester, 'alsoReading.card1.title'), 'Mrs. Dalloway');
      expect(_textOf(tester, 'alsoReading.card1.author'), 'Virginia Woolf');
      // O texto é o título inteiro; o "…" é só da pintura (e a semântica lê o título completo).
      expect(
        _textOf(tester, 'alsoReading.card2.title'),
        'Orgulho e Preconceito',
      );
      expect(_textOf(tester, 'alsoReading.card2.author'), 'Jane Austen');
      for (final id in _textIds) {
        final covers = id.contains('.cover.');
        final render = _renderOf(tester, id);
        expect(render.debugLines(), hasLength(covers ? 2 : 1), reason: id);
        // Nenhum "\n" fora das capas (o arquivo só quebra no <br> das artes).
        expect(_textOf(tester, id).contains('\n'), covers, reason: id);
        final text = _textWidget(tester, id);
        if (_ellipsisIds.contains(id)) {
          expect((text.maxLines, text.ellipsis), (1, true), reason: id);
        } else {
          // Sem limite de linhas nem reticências no arquivo.
          expect((text.maxLines, text.ellipsis), (null, false), reason: id);
          expect(render.debugDidExceedMaxLines, isFalse, reason: id);
        }
      }
    },
  );

  testWidgets(
    '6.6 reticências: "Orgulho e Preconceito" em 138 → exatamente "Orgulho e Precon…" (a próxima letra estouraria 138 por 0,70)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final render = _renderOf(tester, 'alsoReading.card2.title');
      expect(render.debugDidExceedMaxLines, isTrue);
      final line = render.debugLines().single;
      final ref = kRefLayout['alsoReading.card2.title']!.lines.single;
      expect(ref.text, 'Orgulho e Precon…');
      // Caracteres que sobram antes do "…" e a extensão da linha pintada (com o "…").
      expect(line.text, 'Orgulho e Precon');
      expect(line.left, moreOrLessEquals(ref.left, epsilon: 0.5));
      expect(line.right, moreOrLessEquals(ref.right, epsilon: 0.5));
      expect(line.baseline, moreOrLessEquals(ref.baseline, epsilon: 0.5));
      final painted = line.right - line.left;
      final cut = _naturalWidth(AppTextStyles.title15, 'Orgulho e Precon…');
      final next = _naturalWidth(AppTextStyles.title15, 'Orgulho e Preconc…');
      debugPrint(
        '[reticências] linha ${line.left.toStringAsFixed(3)}–${line.right.toStringAsFixed(3)} '
        '(${painted.toStringAsFixed(3)}; arquivo ${(ref.right - ref.left).toStringAsFixed(2)}) | '
        '"Orgulho e Precon…" = ${cut.toStringAsFixed(3)} | "Orgulho e Preconc…" = ${next.toStringAsFixed(3)} '
        '(estoura 138 por ${(next - 138).toStringAsFixed(3)})',
      );
      // A linha pintada é exatamente "Orgulho e Precon…" …
      expect(painted, moreOrLessEquals(cut, epsilon: 0.01));
      expect(painted, moreOrLessEquals(130.52, epsilon: 0.05));
      // … e com mais uma letra não caberia nos 138.
      expect(next, greaterThan(138));
      expect(next - 138, moreOrLessEquals(0.70, epsilon: 0.05));
      // Os outros três textos dos cards cabem inteiros.
      for (final id in _ellipsisIds.where(
        (i) => i != 'alsoReading.card2.title',
      )) {
        expect(
          _renderOf(tester, id).debugDidExceedMaxLines,
          isFalse,
          reason: id,
        );
      }
    },
  );

  testWidgets(
    '6.3/6.4 artes das capas SEM rotação nos slots de layout: baselines, inícios e fins das 4 linhas do arquivo (±0,5)',
    (tester) async {
      // O navegador mede o layout ignorando o transform; aqui cada arte é montada sem o giro, no retângulo
      // de layout da capa, e as linhas são comparadas com a tabela da F06.
      setCanvasView(tester);
      final slot1 = kRefLayout['alsoReading.card1.cover']!.rect;
      final slot2 = kRefLayout['alsoReading.card2.cover']!.rect;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned(
                left: slot1.left,
                top: slot1.top,
                child: const MrsDallowayCover(),
              ),
              Positioned(
                left: slot2.left,
                top: slot2.top,
                child: const PridePrejudiceCover(),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final id in [
        'alsoReading.card1.cover.title',
        'alsoReading.card2.cover.title',
      ]) {
        final got = _renderOf(tester, id).debugLines();
        final ref = kRefLayout[id]!.lines;
        expect(got.map((l) => l.text), ref.map((l) => l.text), reason: id);
        for (var i = 0; i < got.length; i++) {
          debugPrint(
            '[capa sem giro] $id L${i + 1} "${got[i].text}": baseline ${got[i].baseline.toStringAsFixed(3)} '
            '(arquivo ${ref[i].baseline}) | início ${got[i].left.toStringAsFixed(3)} (arquivo ${ref[i].left}) | '
            'fim ${got[i].right.toStringAsFixed(3)} (arquivo ${ref[i].right})',
          );
          expect(
            got[i].baseline,
            moreOrLessEquals(ref[i].baseline, epsilon: 0.5),
            reason: '$id L${i + 1} baseline',
          );
          expect(
            got[i].left,
            moreOrLessEquals(ref[i].left, epsilon: 0.5),
            reason: '$id L${i + 1} início',
          );
          expect(
            got[i].right,
            moreOrLessEquals(ref[i].right, epsilon: 0.5),
            reason: '$id L${i + 1} fim',
          );
        }
      }
    },
  );
}

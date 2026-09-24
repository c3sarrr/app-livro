import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/home/presentation/covers/dom_casmurro_cover.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// Todos os textos da seção, na ordem da tabela "Linhas de texto" da F05.
const _textIds = [
  'hero.cover.title',
  'hero.cover.author',
  'hero.chapterPill',
  'hero.title',
  'hero.author',
  'hero.percent',
  'hero.timeLeft',
  'hero.cta.label',
  'hero.notesButton.badge',
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

/// Largura natural (uma linha) de [text] no parágrafo do SkParagraph, com o letter-spacing final.
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

/// F05 — camada 4 (texto) da seção `hero`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F05 texto: quebras, baselines e extensões dos 9 textos da seção (capa: só quebras)',
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
    'strings exatas do arquivo, derivadas dos dados (capítulo, percentual, tempo, contagem)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // Capa: o <br> do arquivo e a quebra forçada do autor (F05, leitura de designer §8).
      expect(_textOf(tester, 'hero.cover.title'), 'Dom\nCasmurro');
      expect(_textOf(tester, 'hero.cover.author'), 'MACHADO DE\nASSIS');
      expect(_textOf(tester, 'hero.chapterPill'), 'Cap. 92 de 148');
      expect(_textOf(tester, 'hero.title'), 'Dom Casmurro');
      expect(_textOf(tester, 'hero.author'), 'Machado de Assis');
      expect(_textOf(tester, 'hero.percent'), '62%');
      expect(_textOf(tester, 'hero.timeLeft'), '~2h 10min');
      expect(_textOf(tester, 'hero.cta.label'), 'Continuar lendo');
      expect(_textOf(tester, 'hero.notesButton.badge'), '14');
      // Textos de uma linha: sem limite de linhas nem reticências no arquivo.
      for (final id in _textIds.skip(2)) {
        final render = _renderOf(tester, id);
        expect(render.debugLines(), hasLength(1), reason: id);
        expect(render.debugDidExceedMaxLines, isFalse, reason: id);
        expect(_textWidget(tester, id).maxLines, isNull, reason: id);
        expect(_textWidget(tester, id).ellipsis, isFalse, reason: id);
      }
      // Nenhum "\n" fora da capa (o arquivo só quebra no <br> e na arte).
      for (final id in _textIds.skip(2)) {
        expect(_textOf(tester, id).contains('\n'), isFalse, reason: id);
      }
    },
  );

  testWidgets(
    '5.2 quebra forçada do autor da capa: "MACHADO DE ASSIS" mede 78,33 (com o espaçamento final) em 78,00 disponíveis',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final width = _naturalWidth(
        AppTextStyles.coverAuthorPaper,
        'MACHADO DE ASSIS',
      );
      final available = tester
          .getSize(find.byKey(const ValueKey('hero.cover.textBlock')))
          .width;
      debugPrint(
        '[capa] "MACHADO DE ASSIS" = ${width.toStringAsFixed(3)} px em ${available.toStringAsFixed(3)} disponíveis',
      );
      // Fio de navalha (0,33 px): no arquivo quebra; aqui a quebra é explícita e o texto semântico
      // continua sem ela.
      expect(available, 78);
      expect(width, moreOrLessEquals(78.33, epsilon: 0.05));
      expect(width, greaterThan(available));
      final author = _textWidget(tester, 'hero.cover.author');
      expect(author.semanticsLabel, 'MACHADO DE ASSIS');
      expect(
        _renderOf(tester, 'hero.cover.author').debugLines().map((l) => l.text),
        ['MACHADO DE', 'ASSIS'],
      );
      expect(
        _renderOf(tester, 'hero.cover.title').debugLines().map((l) => l.text),
        ['Dom', 'Casmurro'],
      );
    },
  );

  testWidgets(
    '5.2 arte da capa SEM rotação no slot de layout (43,5; 271,66): baselines, inícios e fins das 4 linhas do arquivo (±0,5)',
    (tester) async {
      // O navegador mede o layout ignorando o transform; aqui a mesma arte é montada sem o giro, no
      // retângulo de layout de `hero.cover`, e as linhas são comparadas com a tabela da F05.
      setCanvasView(tester);
      final slot = kRefLayout['hero.cover']!.rect;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned(
                left: slot.left,
                top: slot.top,
                child: const DomCasmurroCover(),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final id in ['hero.cover.title', 'hero.cover.author']) {
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

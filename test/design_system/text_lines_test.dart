import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/text_lines.dart';

/// Helper `expectTextLines` (F01 1.4) contra linhas medidas no HTML: AppText posicionado à mão no
/// retângulo de referência (as seções de verdade entram nas fases F03–F10).
Widget _at(String id, Widget child, {bool fixedWidth = true}) {
  final r = kRefLayout[id]!.rect;
  return Positioned(
    left: r.left,
    top: r.top,
    width: fixedWidth ? r.width : null,
    child: KeyedSubtree(key: ValueKey<String>(id), child: child),
  );
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'linha única, várias linhas (3) e reticências conferem com o arquivo',
    (tester) async {
      setCanvasView(tester);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              _at(
                'header.greeting',
                AppText('Boa noite,', style: AppTextStyles.body13Muted),
                fixedWidth: false,
              ),
              _at(
                'forYou.item1.cover.title',
                AppText(
                  'Memórias Póstumas de Brás Cubas',
                  style: AppTextStyles.coverTitle19,
                ),
              ),
              _at(
                'alsoReading.card2.title',
                AppText(
                  'Orgulho e Preconceito',
                  style: AppTextStyles.title15,
                  maxLines: 1,
                  ellipsis: true,
                ),
              ),
            ],
          ),
        ),
      );
      expectTextLines(tester, 'header.greeting');
      expectTextLines(tester, 'forYou.item1.cover.title');
      expectTextLines(tester, 'alsoReading.card2.title');
      final lines = tester
          .renderObject<RenderAppText>(find.byType(AppText).at(1))
          .debugLines();
      final ref = kRefLayout['forYou.item1.cover.title']!.lines;
      for (var i = 0; i < 3; i++) {
        debugPrint(
          '[linhas] L${i + 1} "${lines[i].text}": baseline ${lines[i].baseline.toStringAsFixed(3)} '
          '(arquivo ${ref[i].baseline}) | fim ${lines[i].right.toStringAsFixed(3)} (arquivo ${ref[i].right})',
        );
        // Mais apertado que o gate (±0,5): a baseline de cada linha é a exata do CSS.
        expect(
          lines[i].baseline,
          moreOrLessEquals(ref[i].baseline, epsilon: 0.02),
        );
      }
    },
  );

  testWidgets('o helper acusa quebra diferente do arquivo', (tester) async {
    setCanvasView(tester);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // Largura errada (200 px): a capa quebraria em 2 linhas, não nas 3 do arquivo.
            Positioned(
              left: 37.5,
              top: 1333.66,
              width: 200,
              child: KeyedSubtree(
                key: const ValueKey<String>('forYou.item1.cover.title'),
                child: AppText(
                  'Memórias Póstumas de Brás Cubas',
                  style: AppTextStyles.coverTitle19,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    expect(
      () => expectTextLines(tester, 'forYou.item1.cover.title'),
      throwsA(isA<TestFailure>()),
    );
  });
}

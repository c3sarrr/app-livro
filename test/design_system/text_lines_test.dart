import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/load_fonts.dart';
import '../support/text_lines.dart';

/// Helper `expectTextLines` (F01 1.4) contra linhas medidas no HTML: AppText posicionado à mão no retângulo de
/// referência (as seções de verdade estão nas fases). Desde a T03 a prancha 01 (`kRef01`).
Widget _at(String id, Widget child, {bool fixedWidth = true}) {
  final r = ref01(id).rect;
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
    'linha única, várias linhas (capa e subtítulo da revisão) e reticências conferem com o arquivo',
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
                // o `<br>` da capa ("Esaú<br>e Jacó")
                AppText('Esaú\ne Jacó', style: AppTextStyles.coverTitle22Ink),
              ),
              _at(
                'review.subtitle',
                AppText(
                  'De Dom Casmurro, Quincas Borba e Iracema.',
                  style: AppTextStyles.reviewSubtitle,
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
      expectTextLines(tester, 'review.subtitle');
      expectTextLines(tester, 'alsoReading.card2.title');
      for (final (i, id) in [
        (1, 'forYou.item1.cover.title'),
        (2, 'review.subtitle'),
      ]) {
        final lines = tester
            .renderObject<RenderAppText>(find.byType(AppText).at(i))
            .debugLines();
        final ref = ref01(id).lines;
        expect(lines, hasLength(2), reason: id);
        for (var l = 0; l < 2; l++) {
          debugPrint(
            '[linhas] $id L${l + 1} "${lines[l].text}": baseline ${lines[l].baseline.toStringAsFixed(3)} '
            '(arquivo ${ref[l].baseline}) | fim ${lines[l].right.toStringAsFixed(3)} (arquivo ${ref[l].right})',
          );
          // Mais apertado que o gate (±0,5): a baseline de cada linha é a exata do CSS.
          expect(
            lines[l].baseline,
            moreOrLessEquals(ref[l].baseline, epsilon: 0.02),
            reason: '$id L${l + 1}',
          );
        }
      }
    },
  );

  testWidgets('o helper acusa quebra diferente do arquivo', (tester) async {
    setCanvasView(tester);
    final r = ref01('review.subtitle').rect;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // Largura errada (300 px): o subtítulo caberia numa linha, não nas 2 do arquivo.
            Positioned(
              left: r.left,
              top: r.top,
              width: 300,
              child: KeyedSubtree(
                key: const ValueKey<String>('review.subtitle'),
                child: AppText(
                  'De Dom Casmurro, Quincas Borba e Iracema.',
                  style: AppTextStyles.reviewSubtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    expect(
      () => expectTextLines(tester, 'review.subtitle'),
      throwsA(isA<TestFailure>()),
    );
  });
}

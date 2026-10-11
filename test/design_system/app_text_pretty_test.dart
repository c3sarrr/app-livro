import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

/// `text-wrap: pretty` (G00): a frase da meta do arquivo, nas larguras 181 (390) e 151 (360).
void main() {
  setUpAll(loadAppFonts);

  const key = ValueKey('frase');

  Widget frase(double width, AppTextWrap wrap) => Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: AppText.rich(
          TextSpan(
            text: 'Faltam ',
            style: AppTextStyles.goalSentence,
            children: [
              TextSpan(text: '12 min', style: AppTextStyles.goalSentenceStrong),
              const TextSpan(text: ' para fechar a meta de hoje.'),
            ],
          ),
          key: key,
          textWrap: wrap,
        ),
      ),
    ),
  );

  List<String> linhas(WidgetTester tester) => tester
      .renderObject<RenderAppText>(find.byKey(key))
      .debugLines()
      .map((l) => l.text)
      .toList();

  testWidgets('151 px: o guloso deixa a viúva "hoje."', (tester) async {
    await tester.pumpWidget(frase(151, AppTextWrap.wrap));
    expect(linhas(tester), ['Faltam 12 min para', 'fechar a meta de', 'hoje.']);
  });

  testWidgets('151 px: pretty reequilibra como o Chromium (referência w360)', (
    tester,
  ) async {
    await tester.pumpWidget(frase(151, AppTextWrap.pretty));
    expect(linhas(tester), ['Faltam 12 min', 'para fechar a meta', 'de hoje.']);
    // mesma altura (o pretty não muda o número de linhas)
    expect(
      tester.getSize(find.byKey(key)).height,
      moreOrLessEquals(3 * 19.5, epsilon: 1e-3),
    );
  });

  testWidgets('181 px: sem viúva, pretty = guloso (referência 390)', (
    tester,
  ) async {
    await tester.pumpWidget(frase(181, AppTextWrap.pretty));
    expect(linhas(tester), ['Faltam 12 min para fechar', 'a meta de hoje.']);
  });

  testWidgets('semântica sem as quebras inseridas', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(frase(151, AppTextWrap.pretty));
    expect(
      tester.getSemantics(find.byKey(key)),
      matchesSemantics(
        label: 'Faltam 12 min para fechar a meta de hoje.',
        textDirection: TextDirection.ltr,
      ),
    );
    handle.dispose();
  });
}

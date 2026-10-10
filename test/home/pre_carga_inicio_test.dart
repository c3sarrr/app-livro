// T03 · pendência 3 — o `main()` pré-carrega só o que a Início da prancha 01 desenha: os 6 ícones novos e a capa do
// Dom Casmurro (`AppIconsInicio.inicio01`, `AppIllustrationsInicio.inicio01`). Os da 01b (o cronômetro rodando) e
// da revisão entram com as telas deles (T04, T05). Este teste mantém a lista honesta: ela é exatamente o conjunto de
// peças da Início nova que a tela monta com a fixture `t01` (todas as seções presentes), nem mais nem menos.
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fase_inicio.dart';
import '../support/load_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'as listas da 01 são exatamente as peças da Início nova que a tela desenha (6 ícones e a capa)',
    (tester) async {
      await abrirInicio01(tester);
      final novos = {...AppIconsInicio.all, ...AppIllustrationsInicio.all};
      final naTela = {
        for (final w in tester.widgetList<AppSvg>(find.byType(AppSvg)))
          if (novos.contains(w.asset)) w.asset,
      };
      expect(AppIconsInicio.inicio01, hasLength(6));
      expect(AppIllustrationsInicio.inicio01, [
        AppIllustrationsInicio.coverDomCasmurro,
      ]);
      expect(naTela, {
        ...AppIconsInicio.inicio01,
        ...AppIllustrationsInicio.inicio01,
      });
      // sem repetição e só peças do pacote
      expect(AppIconsInicio.inicio01.toSet(), hasLength(6));
      expect(AppIconsInicio.all, containsAll(AppIconsInicio.inicio01));
      expect(
        AppIllustrationsInicio.all,
        containsAll(AppIllustrationsInicio.inicio01),
      );
    },
  );
}

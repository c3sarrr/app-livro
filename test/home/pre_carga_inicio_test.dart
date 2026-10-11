// T03 · pendência 3 — o `main()` pré-carrega só o que a Início da prancha 01 desenha: os 6 ícones novos e a capa do
// Dom Casmurro (`AppIconsInicio.inicio01`, `AppIllustrationsInicio.inicio01`). T04: e o que a 01b soma (o cronômetro,
// rodando e pausado — `inicio01b`); os da revisão entram com as telas dela (T05). Este teste mantém as listas
// honestas: cada uma é exatamente o conjunto de peças da Início nova que a tela monta, nem mais nem menos.
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../fixtures/paper_timer_fakes.dart';
import '../fixtures/telas/inicio01b.dart';
import '../reference/inicio2/referencias_inicio2.dart';
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

  testWidgets('T04: as listas da 01b são o que a 01b soma à 01 — o "pausar" do cartão em sessão, o pausar e o play tinta da '
      'mini-barra (rodando e pausada) e a capa com asas', (tester) async {
    final novos = {...AppIconsInicio.all, ...AppIllustrationsInicio.all};
    final naTela = <String>{};
    for (final sessao in [
      TelaInicio01b.sessao,
      TelaInicio01b.sessao.pause(TelaInicio01b.agora),
    ]) {
      // outra árvore antes: o mesmo ProviderScope guardaria a sessão da abertura anterior
      await tester.pumpWidget(const SizedBox.shrink());
      await abrirInicio01(
        tester,
        prancha: kRef01b,
        safeTop: 47,
        safeBottom: 34,
        repositorio: const HomeMockRepository01b(),
        cronometro: overridesDaSessao(
          store: MemoryPaperTimerStore({donoDaSessao: sessao}),
          livros: estanteDePapel01(),
        ),
      );
      naTela.addAll({
        for (final w in tester.widgetList<AppSvg>(find.byType(AppSvg)))
          if (novos.contains(w.asset)) w.asset,
      });
    }
    final da01 = {
      ...AppIconsInicio.inicio01,
      ...AppIllustrationsInicio.inicio01,
    };
    expect(naTela.difference(da01), {
      ...AppIconsInicio.inicio01b,
      ...AppIllustrationsInicio.inicio01b,
    });
    expect(AppIconsInicio.inicio01b, [
      AppIconsInicio.pause,
      AppIconsInicio.pauseInk,
      AppIconsInicio.playInk,
    ]);
    expect(AppIllustrationsInicio.inicio01b, [
      AppIllustrationsInicio.coverBrasCubasWings,
    ]);
    // nada em comum com as da 01, e só peças do pacote
    expect(AppIconsInicio.inicio01b.toSet().intersection(da01), isEmpty);
    expect(AppIconsInicio.all, containsAll(AppIconsInicio.inicio01b));
  });
}

// T03.15 — L60: a prancha 60 ("Início — grifos de hoje") é a Início da 01 num aparelho 390 × 844 (áreas seguras
// 47/34) rolada de 930 (D-241): o conteúdo sobe, o degradê e a barra ficam presos. Aqui o app (a fixture `t01`) rolado
// de 930 confere contra `kRef60`: os 281 ids, todas as linhas e as camadas presas; a rolagem até o fim substitui o
// 13.2 da F13 da v1 (1511,16 → 1768,12). O golden da viewport (`golden_viewport_test.dart`) é esta mesma tela, e o
// gate visual roda fora do teste contra `docs/design/medicao/inicio2/png/060_inicio_grifos_de_hoje_390x844@3x.png`.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reference/inicio2/referencias_inicio2.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';
import '../../support/pump_app.dart';

/// A translação do `<main>` na prancha 60 (`matrix(1, 0, 0, 1, 0, −930)`).
const _rolagem = 930.0;

/// O aparelho da 60 (390 × 844, áreas seguras 47/34), rolado de [rolagem].
Future<void> _abrir60(WidgetTester tester, {double rolagem = _rolagem}) async {
  await abrirInicio01(tester, prancha: kRef60, safeTop: 47, safeBottom: 34);
  homeScrollPosition(tester).jumpTo(rolagem);
  await tester.pumpAndSettle();
}

Rect _r(WidgetTester tester, String id) => tester.getRect(ini(id));

void main() {
  setUpAll(loadAppFonts);

  testWidgets('L60 rolada 930: os 287 ids de kRef60 (281 com widget + 6 inline) — o layout volta à prancha com +930, menos o '
      'degradê e a barra, presos — e a caixa visual na tela', (tester) async {
    await _abrir60(tester);
    expect(homeScrollPosition(tester).pixels, _rolagem);
    expect(kRef60.canvas, const Size(390, 844));
    expect(kRef60.elements, hasLength(287));
    expect(idsDasSecoes(kRef60, kRef60.sections.keys), hasLength(281));
    expect(
      geometria01(
        tester,
        kRef60.sections.keys,
        prancha: kRef60,
        rolagem: _rolagem,
      ),
      isEmpty,
    );
  });

  testWidgets(
    'L60 rolada 930: as linhas de texto de todos os ids (quebras, reticências, baselines e extensões)',
    (tester) async {
      await _abrir60(tester);
      expect(kRef60.ellipsized, {'i60.alsoReading.card2.title'});
      expect(
        texto01(
          tester,
          kRef60.sections.keys,
          prancha: kRef60,
          rolagem: _rolagem,
        ),
        isEmpty,
      );
    },
  );

  testWidgets(
    'L60 o degradê e a barra ficam presos: os mesmos retângulos da prancha rolada 0, 930 e no fim',
    (tester) async {
      await _abrir60(tester, rolagem: 0);
      final position = homeScrollPosition(tester);
      for (final y in [0.0, _rolagem, position.maxScrollExtent]) {
        position.jumpTo(y);
        await tester.pumpAndSettle();
        for (final id in [
          'i60.bottomFade',
          'i60.nav',
          'i60.nav.home',
          'i60.nav.scanner',
          'i60.nav.scanner.fab',
          'i60.nav.profile',
        ]) {
          final esperado = kRef60.elements[id]!.rect;
          final medido = _r(tester, id);
          for (final (o, g, x) in [
            ('x', medido.left, esperado.left),
            ('y', medido.top, esperado.top),
            ('w', medido.width, esperado.width),
            ('h', medido.height, esperado.height),
          ]) {
            expect(g, closeTo(x, 0.5), reason: '$id.$o rolada $y');
          }
        }
      }
    },
  );

  testWidgets('rolagem até o fim: 2612,12 − 844 = 1768,12; a lista termina em y 704, 19,5 px acima do FAB (723,5) e 40 acima da '
      'barra (744)', (tester) async {
    await _abrir60(tester, rolagem: 0);
    final position = homeScrollPosition(tester);
    expect(position.viewportDimension, 844);
    // a prancha arredonda as alturas a 2 casas: o Também lendo mede 205,80 no app e 205,81 na prancha (−0,010)
    expect(position.maxScrollExtent, closeTo(2612.12 - 844, 0.011));
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(position.pixels, position.maxScrollExtent);
    final list = tester.getRect(find.byKey(const ValueKey('recent.list')));
    final fab = tester.getRect(find.byKey(const ValueKey('nav.scanner.fab')));
    final nav = tester.getRect(find.byKey(const ValueKey('nav')));
    expect(list.bottom, moreOrLessEquals(704, epsilon: 1e-3));
    expect(fab.top, 723.5);
    expect(nav.top, 744);
    debugPrint(
      '[L60 fim] maxScrollExtent ${position.maxScrollExtent.toStringAsFixed(3)} (prancha 1768,12) | '
      'recent.list.bottom ${list.bottom.toStringAsFixed(3)} | fab.top ${fab.top} | nav.top ${nav.top}',
    );
  });

  testWidgets(
    'L60 captura @3x (1170 × 2532): a tela rolada de 930 para o gate visual fora do teste',
    (tester) async {
      await _abrir60(tester);
      final image = await capturar01(tester, 't03_L60');
      expect((image.width, image.height), (1170, 2532));
    },
  );
}

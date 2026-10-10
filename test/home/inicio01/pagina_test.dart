// T03.15 — a página inteira da prancha 01 no app (a troca, D-240): os 287 ids de `kRef01` de uma vez (281 com widget
// próprio; os 6 inline conferidos pelas linhas do pai), todas as linhas de texto, o ritmo vertical (9 seções, 8 gaps,
// padding 140) e as larguras 360/430 medidas no mesmo HTML. As fases L01a1…L01a9 conferiram cada seção; aqui a tela
// montada pelo app real é conferida contra a prancha (substitui o 13.1 e o 13.3 da F13 da v1).
import 'package:app_leitura/core/design_system/tokens/app_spacing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reference/inicio2/referencias_inicio2.dart';
import '../../reference/inicio2_larguras/referencias_inicio2_larguras.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';
import '../../support/pump_app.dart';

/// As 9 seções do conteúdo, na ordem da prancha (as camadas fixas — degradê e barra — ficam fora do ritmo).
const _conteudo = [
  'header',
  'headline',
  'hero',
  'alsoReading',
  'today',
  'review',
  'forYou',
  'club',
  'recent',
];

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'página 390: os 287 ids da prancha 01 (281 com widget + 6 inline) dentro da tolerância, na composição real',
    (tester) async {
      await abrirInicio01(tester);
      expect(kRef01.elements, hasLength(287));
      final ids = idsDasSecoes(kRef01, kRef01.sections.keys);
      expect(ids, hasLength(281));
      expect(
        kRef01.elements.values.where((e) => e.kind == LeitorRefKind.inline),
        hasLength(6),
      );
      expect(geometria01(tester, kRef01.sections.keys), isEmpty);

      // Os 10 maiores desvios (para o relatório): o maior |Δ| entre x, y, w e h de cada id.
      final linhas = <(String, String, double)>[];
      for (final id in ids) {
        final g = retanguloDeLayout(tester, id);
        final r = kRef01.elements[id]!.rect;
        final d = {
          'x': g.left - r.left,
          'y': g.top - r.top,
          'w': g.width - r.width,
          'h': g.height - r.height,
        }.entries.reduce((a, b) => a.value.abs() >= b.value.abs() ? a : b);
        linhas.add((id, d.key, d.value));
      }
      linhas.sort((a, b) => b.$3.abs().compareTo(a.$3.abs()));
      debugPrint('[T03 página 390] 281/281 ids; 10 maiores desvios:');
      for (final (id, o, d) in linhas.take(10)) {
        debugPrint('[T03 página 390]   $id Δ$o = ${d.toStringAsFixed(3)}');
      }
    },
  );

  testWidgets(
    'página 390: as linhas de texto de todos os ids (quebras, reticências, baselines e extensões)',
    (tester) async {
      await abrirInicio01(tester);
      final comLinhas = kRef01.elements.values.where((e) => e.lines.isNotEmpty);
      expect(comLinhas, hasLength(99));
      expect(kRef01.ellipsized, {'i01.alsoReading.card2.title'});
      expect(texto01(tester, kRef01.sections.keys), isEmpty);
    },
  );

  testWidgets('ritmo vertical: inset 62, as 9 seções com os 8 gaps (24, 24, 32, 36, 40, 40, 40, 40) e padding 140 → o conteúdo '
      'termina em 2612,12 e o canvas de 2650 não rola', (tester) async {
    await abrirInicio01(tester);
    expect(AppSpacing.sectionGaps, [24, 24, 32, 36, 40, 40, 40, 40]);
    Rect sec(String s) => retanguloDeLayout(tester, 'i01.$s');
    expect(sec('header').top, AppSpacing.topInsetMin);
    for (var i = 1; i < _conteudo.length; i++) {
      final gap = sec(_conteudo[i]).top - sec(_conteudo[i - 1]).bottom;
      expect(
        gap,
        closeTo(AppSpacing.sectionGaps[i - 1], 1e-3),
        reason: _conteudo[i],
      );
      final r = kRef01.sections['i01.${_conteudo[i]}']!;
      final p = kRef01.sections['i01.${_conteudo[i - 1]}']!;
      expect(r.top - p.bottom, closeTo(gap, 1e-3), reason: _conteudo[i]);
    }
    // a prancha arredonda as alturas a 2 casas: o Também lendo mede 205,80 no app e 205,81 na prancha (o maior
    // desvio da página, −0,010 — teste acima), e o fim herda essa diferença
    final fim = sec('recent').bottom + AppSpacing.bottomPadding;
    expect(fim, closeTo(2612.12, 0.011));
    expect(homeScrollPosition(tester).maxScrollExtent, 0);
  });

  for (final tela in ['01w360', '01w430']) {
    testWidgets(
      'página ${tela.substring(3)}: os 281 ids e todas as linhas contra a prancha medida nessa largura (a mesma '
      'árvore, sem código por largura)',
      (tester) async {
        final ref = kRefInicio2Larguras[tela]!;
        await abrirInicio01(tester, prancha: ref);
        expect(idsDasSecoes(ref, ref.sections.keys), hasLength(281));
        expect(geometria01(tester, ref.sections.keys, prancha: ref), isEmpty);
        expect(texto01(tester, ref.sections.keys, prancha: ref), isEmpty);
      },
    );
  }
}

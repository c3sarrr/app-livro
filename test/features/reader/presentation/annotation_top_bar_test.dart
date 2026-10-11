// G16.6 — o topo do modo anotação (L22b): a pílula "Modo anotação" (círculo amarelo de 38 com o lápis de 19, título em
// Bricolage 15,5/800 e o subtítulo da ferramenta) e o "Concluir" verde (✓ 19 + Figtree 15/800), nos lugares e com as
// linhas da prancha; no Noite, a pílula com as cores das ilhas do Noite e o Concluir e o círculo com a borda e a
// sombra do Noite (D-167 17); a semântica (os ícones fora; "Concluir" é botão) e o toque.
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/annotation_top_bar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_22_modo_anotacao.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pecas_l22.dart';
import '../../../support/precache_svgs.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<List<String>> montar(
    WidgetTester tester, {
    ReaderPaper papel = ReaderPaper.creme,
  }) async {
    final toques = <String>[];
    await precacheSvgs(tester, [AppIconsLeitor.pencil, AppIconsLeitor.check]);
    await montarPecasL22(tester, [
      Positioned(
        left: 14,
        right: 14,
        top: 50,
        child: AnnotationTopBar(
          subtitle: '2 dedos movem a página',
          onDone: () => toques.add('concluir'),
        ),
      ),
    ], papel: papel);
    return toques;
  }

  NeoBox caixa(WidgetTester tester, String id) => tester.widget<NeoBox>(
    find
        .descendant(
          of: chaveL22(id),
          matching: find.byType(NeoBox),
          matchRoot: true,
        )
        .first,
  );

  testWidgets('L22b — geometria: os 8 ids da pílula e do Concluir', (
    tester,
  ) async {
    await montar(tester);
    final ids = [
      ...kRef22.idsOfSection('ann.modePill'),
      ...kRef22.idsOfSection('ann.done'),
    ];
    expect(ids, hasLength(8));
    conferirGeometriaL22(tester, ids);
  });

  testWidgets(
    'L22b — texto: título, subtítulo e "Concluir" nas baselines da prancha',
    (tester) async {
      await montar(tester);
      for (final id in const [
        'ann.modePill.title',
        'ann.modePill.subtitle',
        'ann.done',
      ]) {
        conferirLinhasL22(tester, id);
      }
    },
  );

  testWidgets(
    'L22b — estilo: #FFFAF1 e #ABCF82 com borda 1,5, raio 26 e sombra dura 3/3; o círculo #FED170',
    (tester) async {
      await montar(tester);
      final pilula = caixa(tester, 'ann.modePill');
      expect(pilula.color, AppColors.surface);
      expect(pilula.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(pilula.radius, BorderRadius.circular(26));
      expect(
        (pilula.shadow, pilula.shadowColor),
        (AppShadows.hard3, AppColors.ink),
      );
      final circulo = caixa(tester, 'ann.modePill.iconCircle');
      expect(circulo.color, AppColors.sun);
      expect(
        circulo.border,
        const BorderSide(width: 1.5, color: AppColors.ink),
      );
      final pronto = caixa(tester, 'ann.done');
      expect(pronto.color, AppColors.leaf);
      expect(pronto.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(pronto.radius, BorderRadius.circular(26));
      expect(
        (pronto.shadow, pronto.shadowColor),
        (AppShadows.hard3, AppColors.ink),
      );
      expect(
        tester.widget<AppSvg>(chaveL22('ann.modePill.icon')).asset,
        AppIconsLeitor.pencil,
      );
      expect(
        tester.widget<AppSvg>(chaveL22('ann.done.icon')).asset,
        AppIconsLeitor.check,
      );
    },
  );

  testWidgets(
    'Noite (D-167 17): a pílula #2A2520 com borda e letras #EDE3D1 e sombra #0B0A08; o Concluir e o círculo amarelo ficam',
    (tester) async {
      await montar(tester, papel: ReaderPaper.noite);
      final pilula = caixa(tester, 'ann.modePill');
      expect(pilula.color, AppColors.islandNight);
      expect(pilula.border?.color, AppColors.inkNight);
      expect(pilula.shadowColor, AppColors.shadowNight);
      final circulo = caixa(tester, 'ann.modePill.iconCircle');
      expect(
        (circulo.color, circulo.border?.color),
        (AppColors.sun, AppColors.inkNight),
      );
      final pronto = caixa(tester, 'ann.done');
      expect(
        (pronto.color, pronto.border?.color, pronto.shadowColor),
        (AppColors.leaf, AppColors.inkNight, AppColors.shadowNight),
      );
      // a geometria não muda com o papel
      conferirGeometriaL22(tester, kRef22.idsOfSection('ann.modePill'));
    },
  );

  testWidgets(
    'semântica: os textos da pílula; "Concluir" é botão; os ícones ficam fora; o toque chama o Concluir',
    (tester) async {
      final toques = await montar(tester);
      final h = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Modo anotação'), findsOneWidget);
      expect(find.bySemanticsLabel('2 dedos movem a página'), findsOneWidget);
      expect(
        tester.getSemantics(chaveL22('ann.done')),
        isSemantics(label: 'Concluir', isButton: true, hasTapAction: true),
      );
      await tester.tap(chaveL22('ann.done'));
      expect(toques, ['concluir']);
      h.dispose();
    },
  );
}

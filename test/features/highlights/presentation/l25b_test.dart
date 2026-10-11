// G19.4 — a fase L25b (filtros de tipo, cor e clube) pela rota real, no mundo de referência: geometria dos 22 ids,
// texto (as linhas do chip "Desenhos" existem, recortadas pela faixa), estilo, semântica (radio, checkbox, switch) e
// o que cada filtro faz na lista (D-197), sem mudar as contagens (R1); a marcada com o anel (D-201); o clube ligado
// rosa com a sombra (D-202); a fileira de cores que rola quando não cabe.
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/highlights/domain/card_filters.dart';
import 'package:app_leitura/features/highlights/presentation/highlight_filters.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_25_grifos_notas.dart';
import '../../../support/dados_t25.dart';
import '../../../support/fase_l25.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela25());
  tearDown(() async => livro.close());

  const secoes = ['hl.types', 'hl.filters'];
  const linha = BorderSide(width: 1.5, color: AppColors.ink);

  testWidgets('L25b — geometria: os 22 ids das seções', (tester) async {
    await abrirTela25(tester, livro);
    expect([for (final s in secoes) ...kRef25.idsOfSection(s)], hasLength(22));
    final falhas = geometria25(tester, kRef25, secoes);
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  });

  testWidgets('L25b — texto: chips, contadores, COR e Só do clube', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final falhas = texto25Secoes(tester, kRef25, secoes);
    expect(falhas, isEmpty, reason: falhas.join('\n'));
    // o 5º chip passa da borda (recortado pela faixa)
    expect(tester.getRect(hl('hl.types.drawings')).right, greaterThan(390));
  });

  testWidgets(
    'L25b — estilo: o ativo na brand com sombra, os outros no papel',
    (tester) async {
      await abrirTela25(tester, livro);
      const brand = AppColors.lavender; // a brand do mundo (a do arquivo)
      final ativo = tester.widget<NeoBox>(hl('hl.types.all'));
      expect(
        (ativo.color, ativo.border, ativo.shadow, ativo.radius, ativo.height),
        (brand, linha, const Offset(2, 2), BorderRadius.circular(999), 40.0),
      );
      for (final t in ['highlights', 'notes', 'handwritten', 'drawings']) {
        final c = tester.widget<NeoBox>(hl('hl.types.$t'));
        expect((c.color, c.shadow), (AppColors.surface, null), reason: t);
        expect(
          appText25(tester, 'hl.types.$t.count', '').span.style!.color,
          AppColors.inkSoft,
        );
      }
      expect(
        appText25(tester, 'hl.types.all.count', '12').span.style!.color,
        AppColors.ink,
      );
      final cores = tester.widget<NeoBox>(hl('hl.filters.colors'));
      expect(
        (cores.color, cores.border, cores.radius),
        (AppColors.surface, linha, BorderRadius.circular(999)),
      );
      for (final (k, cor) in [
        ('yellow', AppColors.sun),
        ('pink', AppColors.blush),
        ('green', AppColors.leaf),
        ('lavender', AppColors.lavender),
        ('coral', AppColors.flame),
      ]) {
        final b = tester.widget<NeoBox>(hl('hl.filters.colors.$k'));
        expect((b.color, b.border, b.width), (cor, linha, 28.0), reason: k);
      }
      final clube = tester.widget<NeoBox>(hl('hl.filters.clubOnly'));
      expect(
        (clube.color, clube.shadow, clube.border),
        (AppColors.surface, null, linha),
      );
      expect(
        tester.widget<NeoBox>(hl('hl.filters.clubOnly.circle')).color,
        AppColors.blush,
      );
      // a máscara: o papel de 0 % até 85 % da faixa, depois até 100 % na borda (sem ShaderMask — F12 12.4)
      final fade = tester.widget<DecoratedBox>(hl('hl.types.fade'));
      final g = (fade.decoration as BoxDecoration).gradient! as LinearGradient;
      expect(g.colors, [
        AppColors.paperTransparent,
        AppColors.paperTransparent,
        AppColors.paper,
      ]);
      expect(g.stops, [0.0, 0.85, 1.0]);
      expect(
        tester.getRect(hl('hl.types.fade')),
        tester.getRect(hl('hl.types')),
      );
    },
  );

  testWidgets(
    'L25b — semântica: Tipo (radio), Filtrar por cor (checkbox), Só do clube (switch)',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela25(tester, livro);
      final tipo = no25(tester, (d) => d.label == 'Tipo')!;
      expect(tipo.role, SemanticsRole.radioGroup);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Tudo, 12')),
        isSemantics(
          label: 'Tudo, 12',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Desenhos, 3')),
        isSemantics(
          label: 'Desenhos, 3',
          hasCheckedState: true,
          isChecked: false,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      expect(no25(tester, (d) => d.label == 'Filtrar por cor'), isNotNull);
      for (final c in markerChoices) {
        final d = no25(tester, (d) => d.label == c.label)!.getSemanticsData();
        expect(
          (
            d.flagsCollection.isInMutuallyExclusiveGroup,
            d.hasAction(SemanticsAction.tap),
          ),
          (false, true),
          reason: c.label,
        );
      }
      expect(find.bySemanticsLabel('Tinta coral'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Só do clube')),
        isSemantics(
          label: 'Só do clube',
          isButton: true,
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
        ),
      );
      h.dispose();
    },
  );

  testWidgets(
    'L25b — tipo: "Notas" marca e deixa os 2 cartões com nota; as contagens não mudam (R1)',
    (tester) async {
      await abrirTela25(tester, livro);
      await tester.tap(hl('hl.types.notes'));
      await tester.pump();
      expect(cartoes25(tester).map((c) => c.card.notes.length), [1, 1]);
      expect(
        [
          for (final t in [
            'all',
            'highlights',
            'notes',
            'handwritten',
            'drawings',
          ])
            appText25(tester, 'hl.types.$t.count', '').span.toPlainText(),
        ],
        ['12', '6', '2', '1', '3'],
      );
      final notas = tester.widget<NeoBox>(hl('hl.types.notes'));
      expect(notas.shadow, const Offset(2, 2));
      expect(tester.widget<NeoBox>(hl('hl.types.all')).shadow, isNull);
    },
  );

  testWidgets(
    'L25b — cor: Rosa marca com o anel (D-201) e deixa o cartão rosa; de novo, volta tudo',
    (tester) async {
      await abrirTela25(tester, livro);
      await tester.tap(hl('hl.filters.colors.pink'));
      await tester.pump();
      expect(hl('hl.filters.colors.pink.marked'), findsOneWidget);
      final anel = tester.getRect(hl('hl.filters.colors.pink.marked'));
      final caixa = tester.getRect(hl('hl.filters.colors.pink'));
      expect(anel, caixa.inflate(3));
      expect(cartoes25(tester), hasLength(1));
      expect(cartoes25(tester).single.card.page, 6);
      await tester.tap(hl('hl.filters.colors.pink'));
      await tester.pump();
      expect(hl('hl.filters.colors.pink.marked'), findsNothing);
      expect(cartoes25(tester), hasLength(8));
    },
  );

  testWidgets(
    'L25b — clube: ligado, a pílula rosa com sombra (D-202) e só o cartão da pág. 152',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela25(tester, livro);
      await tester.tap(hl('hl.filters.clubOnly'));
      await tester.pump();
      final p = tester.widget<NeoBox>(hl('hl.filters.clubOnly'));
      expect((p.color, p.shadow), (AppColors.blush, const Offset(2, 2)));
      expect(cartoes25(tester).map((c) => c.card.page), [152]);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Só do clube')),
        isSemantics(
          label: 'Só do clube',
          isButton: true,
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
      h.dispose();
    },
  );

  testWidgets(
    'L25b — com 7 cores, a fileira rola junto com o COR e "Só do clube" cabe',
    (tester) async {
      final sete = [
        ...markerChoices,
        (hex: '#FF552E', key: 'coral', label: 'Tinta coral'),
        (hex: '#552CB7', key: 'c552CB7', label: 'Tinta roxa'),
        (hex: '#058CD7', key: 'c058CD7', label: 'Tinta azul'),
      ];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 358,
              child: HighlightColorFilters(
                colors: sete,
                marked: const {},
                clubOnly: false,
                onColor: (_) {},
                onClubOnly: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(hl('hl.filters.colors.scroll'), findsOneWidget);
      final clube = tester.getSize(hl('hl.filters.clubOnly'));
      expect(
        clube.width,
        closeTo(HighlightColorFilters.naturalClubWidth(), 0.01),
      );
      final cores = tester.getSize(hl('hl.filters.colors'));
      expect(cores.width + 8 + clube.width, closeTo(358, 0.01));
      // a última cor fica fora; rolando, aparece
      final caixa = tester.getRect(hl('hl.filters.colors'));
      expect(
        tester.getRect(hl('hl.filters.colors.c058CD7')).right,
        greaterThan(caixa.right),
      );
      await tester.drag(hl('hl.filters.colors.scroll'), const Offset(-200, 0));
      await tester.pump();
      expect(
        tester.getRect(hl('hl.filters.colors.c058CD7')).right,
        lessThan(caixa.right),
      );
    },
  );

  test(
    'a largura natural da pílula das 5 cores é a do arquivo (215,9)',
    () async {
      await loadAppFonts();
      expect(HighlightColorFilters.naturalColorsWidth(5), closeTo(215.9, 1));
    },
  );

  testWidgets(
    '§9: com o leitor de tela, o resultado de um filtro e da busca é anunciado ("N cartões")',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await abrirTela25(tester, livro);
      tester.takeAnnouncements();
      await tester.tap(hl('hl.types.notes'));
      await tester.pump();
      expect(tester.takeAnnouncements().map((a) => a.message), ['2 cartões']);
      await tester.tap(hl('hl.types.all'));
      await tester.pump();
      tester.takeAnnouncements();
      await tester.enterText(hl('hl.search.field'), 'ressaca');
      await tester.pump();
      // enquanto a busca espera, nada é anunciado (nem o número de antes)
      expect(tester.takeAnnouncements(), isEmpty);
      await tester.pump(const Duration(milliseconds: 220));
      await banco25(tester);
      expect(tester.takeAnnouncements().map((a) => a.message), ['1 cartão']);
    },
  );
}

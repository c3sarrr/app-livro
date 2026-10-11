// G19.8 — a fase L25d (o fim da lista) e os vazios pela rota real, no mundo de referência: geometria e texto do cartão
// do fim (a linha do botão existe e fica fora da prancha), estilo, os vazios da D-198 (livro sem anotações; filtros
// sem resultado com "Limpar filtros"), os grifos sem lugar da D-199 e as saídas da R13 (pelo leitor, `pop` com o
// resultado; pela Início, o leitor no lugar da tela).
import 'package:app_leitura/core/design_system/painters/dashed_stadium_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/highlights/application/highlights_exit.dart';
import 'package:app_leitura/features/highlights/presentation/highlights_end.dart';
import 'package:app_leitura/features/highlights/presentation/highlights_screen.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../reference/leitor/reference_layout_25_grifos_notas.dart';
import '../../../support/dados_t25.dart';
import '../../../support/fase_l25.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

String _visto(WidgetTester tester, String id) =>
    tester.widget<AppText>(hl(id)).span.toPlainText();

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela25());
  tearDown(() async => livro.close());

  testWidgets('L25d — geometria: o cartão do fim e o botão (fora da prancha)', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final falhas = geometria25(tester, kRef25, ['hl.end']);
    expect(falhas, isEmpty, reason: falhas.join('\n'));
    // a prancha (2170) corta o botão: ele existe abaixo dela
    expect(tester.getRect(hl('hl.end.cta')).top, greaterThan(2170));
  });

  testWidgets('L25d — texto: a frase com a quebra forçada e o botão', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final falhas = texto25Secoes(tester, kRef25, ['hl.end']);
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  });

  testWidgets('L25d — estilo: tracejado 1,5 de raio 22 e o botão preto de 52', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final borda =
        tester.widget<CustomPaint>(hl('hl.end')).painter!
            as DashedStadiumPainter;
    expect(
      (borda.radius, borda.thickness, borda.color),
      (22.0, 1.5, AppColors.ink),
    );
    final cta = tester.widget<NeoBox>(hl('hl.end.cta'));
    expect(
      (cta.color, cta.height, cta.radius, cta.border),
      (AppColors.ink, 52.0, BorderRadius.circular(999), null),
    );
    final rotulo = tester.widget<AppText>(hl('hl.end.cta.label')).span.style!;
    expect(
      (rotulo.fontSize, rotulo.fontWeight, rotulo.color),
      (15.5, FontWeight.w800, AppColors.paper),
    );
    final frase = tester.widget<AppText>(hl('hl.end.text'));
    expect(
      (
        frase.textAlign,
        frase.span.style!.fontSize,
        frase.span.style!.fontStyle,
        frase.span.style!.height,
      ),
      (TextAlign.center, 22.0, FontStyle.italic, 1.15),
    );
  });

  testWidgets(
    'L25d — D-198: livro sem anotações — sem busca e sem filtros, "Nenhum grifo ainda."',
    (tester) async {
      final vazio = await livroDaTela25(comAnotacoes: false);
      addTearDown(vazio.close);
      await abrirTela25(tester, vazio);
      expect(hl('hl.search'), findsNothing);
      expect(hl('hl.types'), findsNothing);
      expect(hl('hl.filters'), findsNothing);
      expect(hl('hl.title'), findsOneWidget);
      expect(_visto(tester, 'hl.end.text'), emptyBookText);
      expect(_visto(tester, 'hl.end.cta.label'), 'Continuar lendo · pág. 159');
      // o cartão vem logo depois do título (margem 26)
      expect(
        tester.getTopLeft(hl('hl.end')).dy,
        closeTo(tester.getBottomLeft(hl('hl.subtitle')).dy + endGap, 0.01),
      );
    },
  );

  testWidgets(
    'L25d — D-198: Desenhos + Rosa não dá nada; "Limpar filtros" volta ao padrão',
    (tester) async {
      await abrirTela25(tester, livro);
      // o chip "Desenhos" passa da borda: a faixa rola um pouco
      await tester.drag(hl('hl.types'), const Offset(-120, 0));
      await tester.pumpAndSettle();
      await tester.tap(hl('hl.types.drawings'));
      await tester.pump();
      await tester.tap(hl('hl.filters.colors.pink'));
      await tester.pump();
      expect(cartoes25(tester), isEmpty);
      expect(_visto(tester, 'hl.empty.text'), noResultsText);
      // o fim continua embaixo
      expect(
        tester.getTopLeft(hl('hl.end')).dy,
        greaterThan(tester.getBottomLeft(hl('hl.empty')).dy),
      );
      await tester.tap(hl('hl.empty.clear'));
      await tester.pump();
      expect(cartoes25(tester), hasLength(8));
      expect(hl('hl.empty'), findsNothing);
      // a faixa volta ao começo (fora da tela, o chip "Tudo" fica fora do que se acha)
      await tester.drag(hl('hl.types'), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(tester.widget<NeoBox>(hl('hl.types.all')).shadow, isNotNull);
      expect(hl('hl.filters.colors.pink.marked'), findsNothing);
    },
  );

  testWidgets(
    'L25d — D-199: o cartão sem lugar vai para o fim, depois do separador cinza, com a página na data',
    (tester) async {
      final p121 = mundoReferencia.anotacoes
          .firstWhere((a) => a.refPage == 121)
          .groupId;
      await abrirTela25(
        tester,
        livro,
        deps: depsDaTela25(livro, texto: TrechosDaTela25(semLugar: {p121})),
      );
      final cartoes = cartoes25(tester);
      expect(cartoes.map((c) => c.card.page), [
        3,
        6,
        41,
        152,
        159,
        159,
        159,
        121,
      ]);
      expect(_visto(tester, 'hl.list.card8.head.date'), 'pág. 121 · 15 set');
      expect(hl('hl.list.sepOrphan'), findsOneWidget);
      expect(
        tester.getTopLeft(hl('hl.list.sepOrphan')).dy,
        greaterThan(tester.getBottomLeft(hl('hl.list.card7')).dy),
      );
      // o separador da 121 some
      final paginas = [
        for (var n = 1; n <= 5; n++)
          appText25(tester, 'hl.list.sep$n.label', 'pág.').span.toPlainText(),
      ];
      expect(paginas, [
        'pág. 3',
        'pág. 6',
        'pág. 41',
        'pág. 152',
        'pág. 159 · você parou aqui',
      ]);
    },
  );

  test('"Continuar lendo" sem posição não diz a página', () {
    expect(continueText(null), 'Continuar lendo');
    expect(continueText(159), 'Continuar lendo · pág. 159');
  });

  group('R13 — as saídas', () {
    testWidgets(
      'pelo leitor: tocar num cartão publica o 1º item dele no canal (R5)',
      (tester) async {
        await abrirTela25(tester, livro, deLeitor: true);
        final primeiro = cartoes25(tester).first.card.items.first;
        await tester.tap(hl('hl.list.card1.body.quote'));
        await tester.pumpAndSettle();
        expect(find.byType(HighlightsScreen), findsNothing);
        expect(saidasDaTela25, [HighlightsOpenAt(primeiro.id, page: 3)]);
        expect(
          await saidaDaTela25,
          isNull,
          reason: 'a saída não vai mais no resultado do push',
        );
      },
    );

    testWidgets(
      'pelo leitor: "Continuar lendo" publica o continuar no canal (R5)',
      (tester) async {
        await abrirTela25(tester, livro, deLeitor: true);
        await tester.ensureVisible(hl('hl.end.cta'));
        await tester.pumpAndSettle();
        await tester.tap(hl('hl.end.cta'));
        await tester.pumpAndSettle();
        expect(saidasDaTela25, [const HighlightsContinue()]);
      },
    );

    testWidgets(
      'pela Início: tocar num cartão troca a tela pelo leitor com ?ir=',
      (tester) async {
        await abrirTela25(tester, livro);
        final primeiro = cartoes25(tester).first.card.items.first;
        await tester.tap(hl('hl.list.card1.body.quote'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(HighlightsScreen), findsNothing);
        expect(find.byType(ReaderScreen), findsOneWidget);
        expect(
          routerOf25(tester),
          '/leitor/${livro.userBookId}?ir=${Uri.encodeQueryComponent(primeiro.id)}',
        );
      },
    );

    testWidgets('pela Início: "Continuar lendo" troca a tela pelo leitor', (
      tester,
    ) async {
      await abrirTela25(tester, livro);
      await tester.ensureVisible(hl('hl.end.cta'));
      await tester.pumpAndSettle();
      await tester.tap(hl('hl.end.cta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(HighlightsScreen), findsNothing);
      expect(routerOf25(tester), '/leitor/${livro.userBookId}');
    });
  });
}

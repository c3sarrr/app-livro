// G19.3 — a fase L25a (topo, título e busca) pela rota real, no mundo de referência: geometria dos 11 ids, texto com
// as baselines, estilo, semântica, a busca (o × da D-203, a ação "Buscar", a espera da R7), o topo abaixo da área
// segura (R14) e o Voltar (D-195).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/highlights/presentation/highlight_card.dart';
import 'package:app_leitura/features/highlights/presentation/highlights_screen.dart';
import 'package:flutter/material.dart' show TextField;
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

  const secoes = [
    'hl.topBar',
    'hl.sparkle',
    'hl.title',
    'hl.subtitle',
    'hl.search',
  ];
  const linha = BorderSide(width: 1.5, color: AppColors.ink);

  testWidgets('L25a — a tela abre pela rota real com os 8 cartões e o fim', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    expect(find.byType(HighlightsScreen), findsOneWidget);
    expect(cartoes25(tester), hasLength(8));
    expect(
      tester.widget<AppText>(hl('hl.end.cta.label')).span.toPlainText(),
      'Continuar lendo · pág. 159',
    );
  });

  testWidgets('L25a — geometria: os 11 ids das seções', (tester) async {
    await abrirTela25(tester, livro);
    final ids = [for (final s in secoes) ...kRef25.idsOfSection(s)];
    expect(ids, hasLength(11));
    final falhas = geometria25(tester, kRef25, secoes);
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  });

  testWidgets(
    'L25a — texto: título misto, subtítulo e Exportar, com as baselines',
    (tester) async {
      await abrirTela25(tester, livro);
      final falhas = texto25Secoes(tester, kRef25, secoes);
      expect(falhas, isEmpty, reason: falhas.join('\n'));
    },
  );

  testWidgets(
    'T01 — a busca: o texto (e a dica) 2 px para dentro do campo, o padding-inline do <input> do Chromium '
    '(a prancha não o zera: a dica sai em 66,7, não em 64,7)',
    (tester) async {
      await abrirTela25(tester, livro);
      final input = tester.getRect(hl('hl.search.input'));
      final campo = tester.getRect(hl('hl.search.field'));
      expect(input.left, moreOrLessEquals(63.5, epsilon: 0.5));
      expect(campo.left - input.left, moreOrLessEquals(2, epsilon: 1e-6));
      expect(input.right - campo.right, moreOrLessEquals(2, epsilon: 1e-6));
    },
  );

  testWidgets('L25a — estilo: voltar, exportar, título, subtítulo e busca', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final voltar = tester.widget<NeoBox>(hl('hl.topBar.back'));
    expect(
      (voltar.color, voltar.border, voltar.shadow, voltar.radius),
      (AppColors.surface, linha, const Offset(2, 2), BorderRadius.circular(24)),
    );
    final exportar = tester.widget<NeoBox>(hl('hl.topBar.export'));
    expect(
      (exportar.color, exportar.border, exportar.shadow, exportar.radius),
      (
        AppColors.surface,
        linha,
        const Offset(2, 2),
        BorderRadius.circular(999),
      ),
    );
    final busca = tester.widget<NeoBox>(hl('hl.search'));
    expect(
      (busca.color, busca.border, busca.shadow, busca.radius),
      (AppColors.surface, linha, null, BorderRadius.circular(999)),
    );
    final titulo = tester.widget<AppText>(hl('hl.title')).span as TextSpan;
    final grifos = titulo.children![0] as TextSpan;
    final notas = titulo.children![1] as TextSpan;
    expect(
      (
        grifos.style!.fontSize,
        grifos.style!.height,
        grifos.style!.letterSpacing,
        grifos.style!.fontFamily,
      ),
      (34.0, 0.98, -1.0, 'Bricolage34'),
    );
    expect(
      (
        notas.style!.fontSize,
        notas.style!.fontStyle,
        notas.style!.letterSpacing,
      ),
      (42.0, FontStyle.italic, -0.4),
    );
    final sub = tester.widget<AppText>(hl('hl.subtitle')).span as TextSpan;
    expect(
      (sub.style!.fontSize, sub.style!.fontWeight, sub.style!.color),
      (14.0, FontWeight.w600, AppColors.inkMuted),
    );
    final nome = sub.children!.first as TextSpan;
    expect(
      (nome.text, nome.style!.fontWeight, nome.style!.color),
      ('Dom Casmurro', FontWeight.w800, AppColors.ink),
    );
    final campo = tester.widget<TextField>(hl('hl.search.field'));
    expect(
      (
        campo.decoration!.hintText,
        campo.decoration!.hintStyle!.color,
        campo.style!.fontSize,
        campo.style!.fontWeight,
        campo.textInputAction,
      ),
      (
        'Buscar nos grifos e notas',
        AppColors.placeholder,
        15.0,
        FontWeight.w600,
        TextInputAction.search,
      ),
    );
    expect(tester.getSize(hl('hl.sparkle')), const Size(22, 22));
  });

  testWidgets(
    'L25a — semântica: Voltar ao livro, Exportar e o campo da busca',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela25(tester, livro);
      expect(find.bySemanticsLabel('Voltar ao livro'), findsOneWidget);
      final voltar = no25(tester, (d) => d.label == 'Voltar ao livro')!;
      expect(voltar.getSemanticsData().flagsCollection.isButton, isTrue);
      final exportar = no25(
        tester,
        (d) => d.label == 'Exportar grifos e notas',
      )!;
      expect(exportar.getSemanticsData().flagsCollection.isButton, isTrue);
      final campo = no25(
        tester,
        (d) =>
            d.flagsCollection.isTextField &&
            '${d.label}${d.hint}'.contains('Buscar nos grifos e notas'),
      );
      expect(campo, isNotNull);
      // a estrela e os ícones ficam fora
      expect(no25(tester, (d) => d.label.contains('estrela')), isNull);
      h.dispose();
    },
  );

  testWidgets(
    'L25a — busca: "ressaca" deixa só o cartão 7; o × limpa e some (D-203)',
    (tester) async {
      await abrirTela25(tester, livro);
      expect(hl('hl.search.clear'), findsNothing);
      await tester.enterText(hl('hl.search.field'), 'ressaca');
      await tester.pump();
      expect(hl('hl.search.clear'), findsOneWidget);
      expect(tester.getSize(hl('hl.search.clear')), const Size(28, 28));
      final x = tester.widget<NeoBox>(hl('hl.search.clear'));
      expect((x.border, x.radius), (linha, BorderRadius.circular(14)));
      // R7: antes da espera, a lista não muda
      await tester.pump(const Duration(milliseconds: 100));
      expect(cartoes25(tester), hasLength(8));
      await tester.pump(const Duration(milliseconds: 120));
      await banco25(tester);
      expect(cartoes25(tester).map((c) => c.id).toList(), ['hl.list.card1']);
      expect(
        cartoes25(tester).single.card.drawings,
        isNotEmpty,
        reason: 'o cartão de "Olhos de ressaca?"',
      );
      await tester.tap(hl('hl.search.clear'));
      await tester.pump();
      await banco25(tester);
      expect(hl('hl.search.clear'), findsNothing);
      expect(
        tester.widget<TextField>(hl('hl.search.field')).controller!.text,
        isEmpty,
      );
      expect(cartoes25(tester), hasLength(8));
    },
  );

  testWidgets('L25a — a ação "Buscar" do teclado fecha o teclado', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    await tester.tap(hl('hl.search'));
    await tester.pump();
    final campo = tester.widget<TextField>(hl('hl.search.field'));
    expect(campo.focusNode!.hasFocus, isTrue);
    await tester.enterText(hl('hl.search.field'), 'Capitu');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(campo.focusNode!.hasFocus, isFalse);
  });

  testWidgets(
    'L25a — R14: com a área segura de 60 em cima, o topo começa em 67',
    (tester) async {
      await abrirTela25(tester, livro, safeTop: 60);
      expect(tester.getTopLeft(hl('hl.topBar')), const Offset(16, 67));
      expect(tester.getTopLeft(hl('hl.title')).dy, closeTo(135, 0.01));
    },
  );

  testWidgets('L25a — Voltar ao livro fecha a tela sem resultado (D-195)', (
    tester,
  ) async {
    await abrirTela25(tester, livro, deLeitor: true);
    await tester.tap(hl('hl.topBar.back'));
    await tester.pumpAndSettle();
    expect(find.byType(HighlightsScreen), findsNothing);
    expect(await saidaDaTela25, isNull);
    expect(saidasDaTela25, isEmpty, reason: 'o Voltar não publica saída');
  });

  test('a caixa da letra da Literata 16,5 é a do arquivo (24,5)', () async {
    await loadAppFonts();
    expect(quoteContentHeight(), closeTo(24.5, 0.05));
  });
}

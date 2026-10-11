// G19.5/G19.6 — a fase L25c (a lista na ordem do livro) pela rota real, no mundo de referência: geometria dos ids da
// lista (as miniaturas de tinta pela tinta — desvio da R10), texto com as baselines, estilo (separadores, cartão,
// pílulas, post-it, fita, chip, miniatura da nota à mão), semântica (o cartão é um nó que abre o livro; "Mais
// opções", o chip e a nota à mão à parte) e o chip do clube (R8: sem fonte, sem chip; "1 resposta").
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/highlights/application/highlights_club_source.dart';
import 'package:app_leitura/features/highlights/presentation/highlight_card.dart';
import 'package:app_leitura/features/highlights/presentation/page_separator.dart';
import 'package:app_leitura/features/placeholder/presentation/placeholder_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../reference/leitor/reference_layout_25_grifos_notas.dart';
import '../../../support/dados_t25.dart';
import '../../../support/fase_l25.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

/// O clube do mundo com 1 resposta só.
final class _UmaResposta implements HighlightsClubSource {
  const _UmaResposta();

  @override
  Future<ClubChip?> clubOf(String id) async {
    final c = await const ClubeDaTela25().clubOf(id);
    return c == null ? null : (clubId: c.clubId, name: c.name, replies: 1);
  }
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela25());
  tearDown(() async => livro.close());

  const linha = BorderSide(width: 1.5, color: AppColors.ink);

  testWidgets('L25c — geometria: os ids da lista (a tinta pela tinta — R10)', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final falhas = geometria25(tester, kRef25, ['hl.list']);
    expect(falhas, isEmpty, reason: falhas.join('\n'));
  });

  testWidgets(
    'L25c — texto: separadores, cabeçalhos, citações, notas e chip, com as baselines',
    (tester) async {
      await abrirTela25(tester, livro);
      final falhas = texto25Secoes(tester, kRef25, ['hl.list']);
      expect(falhas, isEmpty, reason: falhas.join('\n'));
    },
  );

  testWidgets('L25c — estilo: separadores, cartão, pílulas e citação', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final pag = tester.widget<NeoBox>(hl('hl.list.sep1.label'));
    expect(
      (pag.color, pag.border, pag.shadow, pag.height),
      (AppColors.surface, linha, null, 28.0),
    );
    expect(
      appText25(tester, 'hl.list.sep1.label', 'pág.').span.style!.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    final aqui = tester.widget<NeoBox>(hl('hl.list.sep6.label'));
    expect(
      (aqui.color, aqui.border, aqui.shadow, aqui.height),
      (AppColors.flame, linha, const Offset(2, 2), 30.0),
    );
    final tracejado = tester.widget<CustomPaint>(
      find.descendant(
        of: hl('hl.list.sep1.rule'),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(tracejado.painter, isNotNull);
    final cartao = tester.widget<NeoBox>(hl('hl.list.card1'));
    expect(
      (
        cartao.color,
        cartao.border,
        cartao.shadow,
        cartao.radius,
        cartao.padding,
      ),
      (
        AppColors.surface,
        linha,
        const Offset(3, 3),
        BorderRadius.circular(20),
        const EdgeInsets.fromLTRB(16, 12, 8, 16),
      ),
    );
    final grifo = tester.widget<NeoBox>(hl('hl.list.card2.head.highlight'));
    expect((grifo.color, grifo.border), (AppColors.paper, linha));
    expect(
      tester.widget<NeoBox>(hl('hl.list.card2.head.highlight.dot')).color,
      AppColors.blush,
    );
    expect(
      tester.widget<NeoBox>(hl('hl.list.card2.head.highlight.dot')).border,
      const BorderSide(width: 1.2, color: AppColors.ink),
    );
    expect(
      tester.widget<NeoBox>(hl('hl.list.card2.head.note')).color,
      AppColors.sun,
    );
    expect(
      tester.widget<NeoBox>(hl('hl.list.card7.head.drawing.dot')).color,
      AppColors.flame,
    );
    final data = tester.widget<AppText>(hl('hl.list.card1.head.date'));
    expect(
      (data.span.toPlainText(), data.span.style!.color),
      ('2 set', AppColors.inkSoft),
    );
    final quote =
        tester.widget<AppText>(hl('hl.list.card1.body.quote')).span as TextSpan;
    expect(
      (
        quote.style!.fontFamily,
        quote.style!.fontSize,
        quote.style!.height,
        quote.style!.color,
      ),
      ('Literata16_5', 16.5, 1.6, AppColors.bookText),
    );
    expect((quote.children!.first as TextSpan).style!.color, AppColors.inkSoft);
    expect((quote.children!.last as TextSpan).style, isNull);
  });

  testWidgets('L25c — estilo: post-it, fita, chip do clube e a nota à mão', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final giro = tester.widget<Transform>(hl('hl.list.card2.body.note'));
    expect(giro.transform.storage.sublist(0, 2), [
      moreOrLessEquals(0.99994517, epsilon: 1e-6),
      moreOrLessEquals(-0.01047178, epsilon: 1e-6),
    ]);
    final nota = tester.widget<NeoBox>(hl('hl.list.card2.body.note.box'));
    expect(
      (nota.color, nota.border, nota.shadow, nota.radius),
      (AppColors.sun, linha, const Offset(2, 2), BorderRadius.circular(12)),
    );
    final fita = tester.widget<NeoBox>(hl('hl.list.card2.body.note.tape.box'));
    expect(
      (fita.color, fita.border),
      (
        AppColors.surface.withValues(alpha: 0.85),
        const BorderSide(width: 1.2, color: AppColors.ink),
      ),
    );
    final rotulo = appText25(tester, 'hl.list.card2.body.note.label', 'NOTA');
    expect(rotulo.span.style!.color, AppColors.noteLabel);
    final chip = tester.widget<NeoBox>(hl('hl.list.card5.body.club.chip'));
    expect(
      (chip.color, chip.border, chip.height),
      (AppColors.blush, linha, 32.0),
    );
    expect(
      appText25(
        tester,
        'hl.list.card5.body.club.chip.replies',
        '·',
      ).span.style!.color,
      AppColors.clubKicker,
    );
    final tag = tester.widget<NeoBox>(hl('hl.list.card7.body.handNote.tag'));
    expect((tag.color, tag.border, tag.height), (AppColors.sun, linha, 21.0));
    final pauta = tester.widget<ColoredBox>(
      find.descendant(
        of: hl('hl.list.card7.body.handNote.rule1'),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(pauta.color, AppColors.noteRule);
  });

  testWidgets(
    'L25c — semântica: o cartão abre o livro; "Mais opções", o chip e a nota à mão à parte',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela25(tester, livro);
      expect(
        no25(tester, (d) => d.label == 'Grifos e notas na ordem do livro'),
        isNotNull,
      );
      for (final rotulo in [
        'Grifo amarelo, página 3',
        'Grifo rosa com nota, página 6',
        'Grifo verde, página 41',
        'Grifo amarelo, página 121',
        'Grifo lavanda com nota, compartilhado no clube, página 152',
        'Grifo à mão livre, página 159',
        'Desenho e nota à mão, página 159',
        'Dois desenhos, página 159',
      ]) {
        final no = no25(tester, (d) => d.label.startsWith('$rotulo, '));
        expect(no, isNotNull, reason: rotulo);
        expect(
          no,
          isSemantics(hasTapAction: true, onTapHint: 'Abrir no livro'),
          reason: rotulo,
        );
      }
      final um = no25(
        tester,
        (d) => d.label.startsWith('Grifo amarelo, página 3'),
      )!.getSemanticsData();
      expect(
        um.label,
        'Grifo amarelo, página 3, 2 set\n'
        '…encontrei no trem da Central um rapaz aqui do bairro, que eu conheço de vista e de chapéu.',
      );
      final dois = no25(
        tester,
        (d) => d.label.startsWith('Grifo rosa'),
      )!.getSemanticsData();
      expect(dois.label, endsWith('\nNota: É o livro todo nessa frase.'));
      expect(find.bySemanticsLabel('Mais opções'), findsNWidgets(8));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Nota à mão, hoje')),
        isSemantics(label: 'Nota à mão, hoje', isImage: true),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Leitoras de Capitu · 3 respostas'),
        ),
        isSemantics(
          label: 'Leitoras de Capitu · 3 respostas',
          isLink: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('página 159, você parou aqui'),
        ),
        isSemantics(label: 'página 159, você parou aqui', isHeader: true),
      );
      h.dispose();
    },
  );

  testWidgets('L25c — o chip do clube vai à discussão do clube', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    await tester.ensureVisible(hl('hl.list.card5.body.club.chip'));
    await tester.pumpAndSettle();
    await tester.tap(hl('hl.list.card5.body.club.chip'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is PlaceholderScreen && w.title == 'Discussão',
      ),
      findsOneWidget,
    );
    expect(routerOf25(tester), '/clube/${mundoReferencia.clube.id}/discussao');
  });

  testWidgets(
    'L25c — R8: sem o clube na fonte, sem chip (o rótulo continua "compartilhado no clube")',
    (tester) async {
      final h = tester.ensureSemantics();
      await abrirTela25(
        tester,
        livro,
        deps: depsDaTela25(livro, clube: const NoHighlightsClub()),
      );
      expect(hl('hl.list.card5.body.club'), findsNothing);
      expect(
        no25(
          tester,
          (d) => d.label.startsWith(
            'Grifo lavanda com nota, compartilhado no clube, página 152',
          ),
        ),
        isNotNull,
      );
      h.dispose();
    },
  );

  testWidgets('L25c — "1 resposta" no singular', (tester) async {
    await abrirTela25(
      tester,
      livro,
      deps: depsDaTela25(livro, clube: const _UmaResposta()),
    );
    expect(
      appText25(
        tester,
        'hl.list.card5.body.club.chip.replies',
        '·',
      ).span.toPlainText(),
      '· 1 resposta',
    );
  });

  testWidgets(
    'L25c — R10: rolar a lista não redesenha as miniaturas (o cache)',
    (tester) async {
      await abrirTela25(tester, livro, tela: const Size(390, 844));
      await tester.dragUntilVisible(
        hl('hl.list.card8'),
        hl('hl.scroll'),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      final cache = cache25(tester);
      final antes = cache.renders;
      expect(antes, greaterThan(0));
      for (var i = 0; i < 4; i++) {
        await tester.drag(hl('hl.scroll'), const Offset(0, 120));
        await tester.pump();
        await tester.drag(hl('hl.scroll'), const Offset(0, -120));
        await tester.pump();
      }
      expect(cache.renders, antes);
    },
  );

  testWidgets('L25c — o separador cinza dos sem lugar (D-199)', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 358,
            child: PageSeparator.orphan(id: 'hl.list.sepOrphan'),
          ),
        ),
      ),
    );
    final t = appText25(tester, 'hl.list.sepOrphan.label', 'sem lugar');
    expect(t.span.style!.color, AppColors.inkSoft);
    expect(tester.getSize(hl('hl.list.sepOrphan')).height, 28);
  });

  test('a cor do fundo do grifo a cada cor do arquivo', () {
    expect(
      [
        for (final c in ['#FED170', '#FFC1C6', '#ABCF82', '#B6ACE4', '#FF552E'])
          markAlpha(c),
      ],
      [0.9, 0.95, 0.85, 0.75, 0.9],
    );
    expect(repliesText(1), '· 1 resposta');
    expect(repliesText(3), '· 3 respostas');
  });
}

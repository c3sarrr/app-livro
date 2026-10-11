// G19.7 — "Mais opções" (D-192, D-193, R11) pela rota real, no mundo de referência: o que a folha mostra em cada
// cartão, a nota (a NoteSheet do leitor, pela regra da D-131/D-138), a cor (todos os grifos do cartão; a marcada não
// faz nada), o clube (aviso da D-118), Apagar com Desfazer (o cartão e as camadas voltam; com o leitor de tela, a
// pílula fica — D-139) e Fechar/véu/Voltar do sistema sem mudar nada.
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/highlights/application/highlights_share.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:flutter/material.dart' show TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/dados_t25.dart';
import '../../../support/fase_l25.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

String _visto(WidgetTester tester, String id) =>
    tester.widget<AppText>(hl(id)).span.toPlainText();

Future<void> _mais(WidgetTester tester, int n) async {
  await tester.ensureVisible(hl('hl.list.card$n.head.more'));
  await tester.pumpAndSettle();
  await tester.tap(hl('hl.list.card$n.head.more'));
  await tester.pump();
}

Future<List<Annotation>> _doLivro(
  WidgetTester tester,
  LivroNaEstante l,
) async =>
    (await tester.runAsync(() => AnnotationsDao(l.db).forBook(l.userBookId)))!;

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela25());
  tearDown(() async => livro.close());

  testWidgets(
    'cartão 2: "pág. 6 · GRIFO + NOTA", o trecho, Editar nota, as 4 cores (a rosa marcada)…',
    (tester) async {
      await abrirTela25(tester, livro);
      await _mais(tester, 2);
      expect(hl('hl.more'), findsOneWidget);
      expect(_visto(tester, 'hl.more.title'), 'pág. 6 · GRIFO + NOTA');
      expect(
        _visto(tester, 'hl.more.excerpt'),
        startsWith('O meu fim evidente'),
      );
      expect(tester.widget<AppText>(hl('hl.more.excerpt')).maxLines, 1);
      expect(
        appText25(tester, 'hl.more.note', '').span.toPlainText(),
        'Editar nota',
      );
      for (final k in ['yellow', 'pink', 'green', 'lavender']) {
        expect(hl('hl.more.colors.$k'), findsOneWidget, reason: k);
      }
      expect(hl('hl.more.colors.pink.marked'), findsOneWidget);
      expect(hl('hl.more.colors.yellow.marked'), findsNothing);
      for (final b in ['share', 'delete', 'close']) {
        expect(hl('hl.more.$b'), findsOneWidget, reason: b);
      }
      final folha = tester.widget<NeoBox>(hl('hl.more'));
      expect(
        (folha.border!.width, folha.radius, folha.shadow),
        (1.5, BorderRadius.circular(28), const Offset(3, 3)),
      );
      final r = tester.getRect(hl('hl.more'));
      expect((r.left, r.right), (14.0, 376.0));
    },
  );

  testWidgets(
    'cartão 8 (só desenhos): Apagar e Fechar — sem texto, sem Compartilhar (G21 §5)',
    (tester) async {
      await abrirTela25(tester, livro);
      await _mais(tester, 8);
      expect(_visto(tester, 'hl.more.title'), 'pág. 159 · 2 DESENHOS');
      expect(hl('hl.more.note'), findsNothing);
      expect(hl('hl.more.colors'), findsNothing);
      expect(hl('hl.more.share'), findsNothing);
      for (final b in ['delete', 'close']) {
        expect(hl('hl.more.$b'), findsOneWidget, reason: b);
      }
    },
  );

  testWidgets('cartão 1 (sem nota): "Escrever nota"', (tester) async {
    await abrirTela25(tester, livro);
    await _mais(tester, 1);
    expect(
      appText25(tester, 'hl.more.note', '').span.toPlainText(),
      'Escrever nota',
    );
  });

  testWidgets(
    'Editar nota: a folha da nota com o texto; Salvar grava e o post-it muda',
    (tester) async {
      await abrirTela25(tester, livro);
      await _mais(tester, 2);
      await tester.tap(hl('hl.more.note'));
      await tester.pump();
      expect(hl('hl.more'), findsNothing);
      final campo = find.byKey(const ValueKey('leitor.nota.campo'));
      expect(campo, findsOneWidget);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(of: campo, matching: find.byType(EditableText)),
            )
            .controller
            .text,
        'É o livro todo nessa frase.',
      );
      await tester.enterText(campo, 'O livro inteiro numa frase.');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('leitor.nota.salvar')));
      await tester.pump();
      await banco25(tester);
      expect(campo, findsNothing);
      expect(
        _visto(tester, 'hl.list.card2.body.note.text'),
        'O livro inteiro numa frase.',
      );
      final notas = [
        for (final a in await _doLivro(tester, livro))
          if (a.kind == AnnotationKind.note && a.refPage == 6) a.noteText,
      ];
      expect(notas, ['O livro inteiro numa frase.']);
    },
  );

  testWidgets(
    'Trocar cor: a amarela troca no banco e no cartão; a marcada não faz nada',
    (tester) async {
      await abrirTela25(tester, livro);
      await _mais(tester, 2);
      await tester.tap(hl('hl.more.colors.pink'));
      await tester.pump();
      expect(hl('hl.more'), findsOneWidget);
      await tester.tap(hl('hl.more.colors.yellow'));
      await tester.pump();
      await banco25(tester);
      expect(hl('hl.more'), findsNothing);
      expect(
        tester.widget<NeoBox>(hl('hl.list.card2.head.highlight.dot')).color,
        AppColors.sun,
      );
      final grifo = (await _doLivro(tester, livro)).firstWhere(
        (a) => a.kind == AnnotationKind.highlight && a.refPage == 6,
      );
      expect(grifo.color, '#FED170');
    },
  );

  testWidgets(
    'Compartilhar no clube sem conta (G21 §5): a folha fecha e "Entre na sua conta para compartilhar." fica 2 s',
    (tester) async {
      await abrirTela25(tester, livro);
      final n =
          cartoes25(tester).indexWhere(
            (v) =>
                shareableHighlight(v.card) != null && v.card.clubPostId == null,
          ) +
          1;
      await _mais(tester, n);
      await tester.tap(hl('hl.more.share'));
      await tester.pump();
      expect(hl('hl.more'), findsNothing);
      expect(
        appText25(tester, 'leitor.aviso', '').span.toPlainText(),
        'Entre na sua conta para compartilhar.',
      );
      await tester.pump(const Duration(seconds: 2));
      expect(hl('leitor.aviso'), findsNothing);
    },
  );

  testWidgets(
    'o cartão já compartilhado: "Já está em Leitoras de Capitu", apagado (G21 §5, caso 6)',
    (tester) async {
      await abrirTela25(tester, livro);
      final n =
          cartoes25(tester).indexWhere((v) => v.card.clubPostId != null) + 1;
      expect(n, greaterThan(0));
      await _mais(tester, n);
      expect(
        appText25(tester, 'hl.more.share', '').span.toPlainText(),
        'Já está em Leitoras de Capitu',
      );
      await tester.tap(hl('hl.more.share'));
      await tester.pump();
      expect(
        hl('hl.more'),
        findsOneWidget,
        reason: 'apagado: o toque não faz nada',
      );
    },
  );

  testWidgets(
    'Apagar o cartão 7: some, "Cartão apagado · Desfazer" e o Desfazer traz o cartão e a tinta',
    (tester) async {
      await abrirTela25(tester, livro);
      await _mais(tester, 7);
      await tester.tap(hl('hl.more.delete'));
      await tester.pump();
      await banco25(tester);
      expect(hl('hl.more'), findsNothing);
      expect(cartoes25(tester), hasLength(7));
      expect(
        cartoes25(tester).any((c) => c.card.handwriting.isNotEmpty),
        isFalse,
      );
      expect(
        appText25(tester, 'leitor.desfazer', '').span.toPlainText(),
        'Cartão apagado',
      );
      await tester.tap(find.byKey(const ValueKey('leitor.desfazer.botao')));
      await tester.pump();
      await banco25(tester);
      expect(hl('leitor.desfazer'), findsNothing);
      expect(cartoes25(tester), hasLength(8));
      expect(hl('hl.list.card7.body.handNote'), findsOneWidget);
      final view = cartoes25(tester)[6];
      expect(
        view.layers.containsKey(view.card.drawings.single.inkLayerId),
        isTrue,
      );
    },
  );

  testWidgets(
    'o Desfazer some depois de 4 s; com o leitor de tela, fica até a próxima ação (D-139)',
    (tester) async {
      await abrirTela25(tester, livro);
      await _mais(tester, 1);
      await tester.tap(hl('hl.more.delete'));
      await tester.pump();
      await banco25(tester);
      expect(hl('leitor.desfazer'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      expect(hl('leitor.desfazer'), findsNothing);

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      await _mais(tester, 1);
      await tester.tap(hl('hl.more.delete'));
      await tester.pump();
      await banco25(tester);
      await tester.pump(const Duration(seconds: 10));
      expect(hl('leitor.desfazer'), findsOneWidget);
      // a próxima ação tira
      await tester.tap(hl('hl.types.notes'));
      await tester.pump();
      expect(hl('leitor.desfazer'), findsNothing);
    },
  );

  testWidgets('Fechar, o véu e o Voltar do sistema fecham sem mudar nada', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    final antes = (await _doLivro(tester, livro)).length;
    await _mais(tester, 2);
    await tester.tap(hl('hl.more.close'));
    await tester.pump();
    expect(hl('hl.more'), findsNothing);
    await _mais(tester, 2);
    await tester.tapAt(const Offset(195, 60));
    await tester.pump();
    expect(hl('hl.more'), findsNothing);
    await _mais(tester, 2);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(hl('hl.more'), findsNothing);
    expect(cartoes25(tester), hasLength(8));
    expect((await _doLivro(tester, livro)).length, antes);
  });

  testWidgets('abrir a folha fecha o teclado da busca (a folha fica à vista)', (
    tester,
  ) async {
    await abrirTela25(tester, livro);
    await tester.tap(hl('hl.search'));
    await tester.pump();
    final campo = tester.widget<TextField>(hl('hl.search.field'));
    expect(campo.focusNode!.hasFocus, isTrue);
    await _mais(tester, 2);
    expect(hl('hl.more'), findsOneWidget);
    expect(campo.focusNode!.hasFocus, isFalse);
  });
}

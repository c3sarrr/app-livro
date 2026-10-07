// G15.3 — a folha do sumário (telas 27/27b) sozinha: o lugar (10 das bordas, topo 112, base 10), o véu, abrir e
// fechar em 150 ms; fechar pelo ×, pelo véu e puxando pela alça (como a D-141); as abas (sempre abre em Capítulos;
// os ids viram `bm.*` na aba Marcadas); sem dados ainda, só a moldura; a semântica; o Noite nas cores das ilhas.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/toc_chapters.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import 'toc_support.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'aberta: folha a 10 das bordas, topo 112, base 10; o véu na tela toda',
    (tester) async {
      await montarSumario(tester);
      expect(
        tester.getRect(chave('toc.sheet')),
        perto(const Rect.fromLTWH(10, 112, 370, 722)),
      );
      expect(
        tester.getRect(chave('toc.fade')),
        const Rect.fromLTWH(0, 0, 390, 844),
      );
      final veu = tester.widget<ColoredBox>(
        find.descendant(
          of: chave('toc.fade'),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(veu.color, AppColors.ink.withValues(alpha: 0.28));
      expect(
        tester.getRect(chave('toc.sheet.grabber')),
        perto(const Rect.fromLTWH(175, 123.5, 40, 5)),
      );
      expect(
        tester.getRect(chave('toc.sheet.tabs')),
        perto(const Rect.fromLTWH(25.5, 193.1, 339, 46)),
      );
    },
  );

  testWidgets('abre e fecha em 150 ms, subindo e descendo', (tester) async {
    final m = MesaDoSumario();
    await montarSumario(tester, open: false);
    expect(chave('toc.sheet'), findsNothing);
    await tester.pumpWidget(folhaDoSumario(m, open: true, view: vista()));
    await tester.pump(const Duration(milliseconds: 75));
    expect(tester.getRect(chave('toc.sheet')).top, greaterThan(112));
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      tester.getRect(chave('toc.sheet')).top,
      moreOrLessEquals(112, epsilon: 0.01),
    );
    await tester.pumpWidget(folhaDoSumario(m, open: false, view: vista()));
    await tester.pump(const Duration(milliseconds: 160));
    expect(chave('toc.sheet'), findsNothing);
  });

  testWidgets(
    'fecha pelo ×, pelo véu e puxando a alça; empurrão para cima não fecha',
    (tester) async {
      final m = await montarSumario(tester);
      await tester.tap(chave('toc.sheet.close'));
      await tester.tapAt(const Offset(195, 60));
      expect(m.fechou, 2);
      await tester.drag(chave('toc.sheet.grabber'), const Offset(0, 70));
      await tester.pump();
      expect(m.fechou, 3);
      await tester.fling(
        chave('toc.sheet.grabber'),
        const Offset(0, -80),
        1500,
      );
      await tester.pump();
      expect(m.fechou, 3);
      // o puxão curto devolve a folha ao lugar
      await tester.drag(chave('toc.sheet.grabber'), const Offset(0, 30));
      await tester.pumpAndSettle();
      expect(m.fechou, 3);
      expect(
        tester.getRect(chave('toc.sheet')).top,
        moreOrLessEquals(112, epsilon: 0.01),
      );
    },
  );

  testWidgets(
    'abas: abre em Capítulos; Marcadas troca os ids para bm.*; reabrir volta a Capítulos',
    (tester) async {
      final m = await montarSumario(tester, view: vista(cartoes: [cartao(1)]));
      expect(chave('toc.sheet.chapters'), findsOneWidget);
      expect(find.text('Capítulos'), findsNothing, reason: 'AppText, não Text');
      await tester.tap(chave('toc.sheet.tabs.bookmarks'));
      await tester.pump();
      expect(chave('bm.sheet'), findsOneWidget);
      expect(chave('toc.sheet'), findsNothing);
      expect(chave('bm.sheet.bookmarks'), findsOneWidget);
      expect(chave('bm.fade'), findsOneWidget);
      await tester.pumpWidget(
        folhaDoSumario(m, open: false, view: vista(cartoes: [cartao(1)])),
      );
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pumpWidget(
        folhaDoSumario(m, open: true, view: vista(cartoes: [cartao(1)])),
      );
      await tester.pump(const Duration(milliseconds: 160));
      expect(chave('toc.sheet.chapters'), findsOneWidget);
    },
  );

  testWidgets(
    'trocar de aba e voltar: a lista fica onde estava; reabrir volta ao capítulo atual',
    (tester) async {
      final m = await montarSumario(tester, view: vista(n: 40, atual: 20));
      ScrollPosition rolagem() => tester
          .state<ScrollableState>(
            find.descendant(
              of: chave('toc.sheet.chapters'),
              matching: find.byType(Scrollable),
            ),
          )
          .position;
      final posta = rolagem().pixels;
      expect(posta, greaterThan(0));
      await tester.dragFrom(
        tester.getCenter(chave('toc.sheet.chapters')),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();
      final rolada = rolagem().pixels;
      expect(rolada, lessThan(posta - 100));
      await tester.tap(chave('toc.sheet.tabs.bookmarks'));
      await tester.pump();
      await tester.tap(chave('bm.sheet.tabs.chapters'));
      await tester.pump();
      await tester.pump();
      expect(rolagem().pixels, moreOrLessEquals(rolada, epsilon: 0.01));
      await tester.pumpWidget(
        folhaDoSumario(m, open: false, view: vista(n: 40, atual: 20)),
      );
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pumpWidget(
        folhaDoSumario(m, open: true, view: vista(n: 40, atual: 20)),
      );
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump();
      expect(rolagem().pixels, moreOrLessEquals(posta, epsilon: 0.01));
    },
  );

  testWidgets(
    'subir e puxar pela alça só movem a folha: a lista de capítulos não é refeita a cada quadro',
    (tester) async {
      final m = MesaDoSumario();
      await montarSumario(tester, open: false);
      await tester.pumpWidget(folhaDoSumario(m, open: true, view: vista()));
      await tester.pump(const Duration(milliseconds: 40));
      final subindo = tester.widget<TocChapters>(find.byType(TocChapters));
      await tester.pump(const Duration(milliseconds: 40));
      expect(
        tester.widget<TocChapters>(find.byType(TocChapters)),
        same(subindo),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final g = await tester.startGesture(
        tester.getCenter(chave('toc.sheet.grabber')),
      );
      await g.moveBy(const Offset(0, 30));
      await tester.pump();
      final topo = tester.getRect(chave('toc.sheet')).top;
      final puxando = tester.widget<TocChapters>(find.byType(TocChapters));
      await g.moveBy(const Offset(0, 20));
      await tester.pump();
      expect(tester.getRect(chave('toc.sheet')).top, greaterThan(topo));
      expect(
        tester.widget<TocChapters>(find.byType(TocChapters)),
        same(puxando),
      );
      await g.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'títulos e abas: "Sumário", o subtítulo, "Capítulos 148" e "Marcadas 3"',
    (tester) async {
      await montarSumario(
        tester,
        view: vista(
          cartoes: [cartao(1), cartao(2), cartao(3), cartao(4, marcada: false)],
        ),
      );
      String texto(String id) =>
          tester.widget<AppText>(chave(id)).span.toPlainText();
      expect(texto('toc.sheet.title'), 'Sumário');
      expect(texto('toc.sheet.subtitle'), 'Dom Casmurro · 148 capítulos');
      expect(
        tester
            .widget<AppText>(
              find.descendant(
                of: chave('toc.sheet.tabs.chapters'),
                matching: find.byType(AppText),
              ),
            )
            .span
            .toPlainText(),
        'Capítulos 148',
      );
      expect(texto('toc.sheet.tabs.bookmarks.count'), '3');
    },
  );

  testWidgets('sem dados ainda: a moldura e as abas, sem lista', (
    tester,
  ) async {
    await montarSumario(tester, semVista: true);
    expect(chave('toc.sheet.title'), findsOneWidget);
    expect(chave('toc.sheet.tabs'), findsOneWidget);
    expect(chave('toc.sheet.chapters'), findsNothing);
  });

  testWidgets(
    'semântica: diálogo "Sumário", o título cabeçalho, as abas com a selecionada',
    (tester) async {
      final h = tester.ensureSemantics();
      await montarSumario(tester);
      expect(
        tester.getSemantics(chave('toc.sheet')),
        isSemantics(label: 'Sumário', scopesRoute: true, namesRoute: true),
      );
      final abas = tester.getSemantics(chave('toc.sheet.tabs.chapters'));
      expect(abas.role, SemanticsRole.tab);
      expect(abas, isSemantics(isSelected: true, label: 'Capítulos 148'));
      final outra = tester.getSemantics(chave('toc.sheet.tabs.bookmarks'));
      expect(outra.role, SemanticsRole.tab);
      expect(outra, isSemantics(isSelected: false, label: 'Marcadas 0'));
      expect(
        tester.getSemantics(chave('toc.sheet.tabs')).role,
        SemanticsRole.tabBar,
      );
      expect(tester.getSemantics(chave('toc.sheet.close')).label, 'Fechar');
      h.dispose();
    },
  );

  testWidgets('Noite: a folha nas cores das ilhas', (tester) async {
    await montarSumario(tester, papel: ReaderPaper.noite);
    final folha = tester.widget<NeoBox>(chave('toc.sheet'));
    expect(folha.color, AppColors.islandNight);
    expect(folha.border!.color, AppColors.inkNight);
    expect(folha.shadowColor, AppColors.shadowNight);
  });
}

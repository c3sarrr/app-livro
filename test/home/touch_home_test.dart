import 'dart:ui' show SemanticsAction;

import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/highlights/presentation/highlights_screen.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/placeholder/presentation/placeholder_screen.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/gestures.dart' show kPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

StatefulNavigationShell _shell(WidgetTester tester) =>
    tester.widget<MainShell>(find.byType(MainShell, skipOffstage: false)).shell;

Finder _key(String id) => find.byKey(ValueKey<String>(id));

Finder _placeholder(String title) =>
    find.byWidgetPredicate((w) => w is PlaceholderScreen && w.title == title);

/// O destino de cada toque: o placeholder da rota; o "Continuar lendo" abre o leitor de verdade (G11).
Finder _destino(String title) => switch (title) {
  'Leitor' => find.byType(ReaderScreen),
  // G19: a tela 25 de verdade
  'Grifos e notas' => find.byType(HighlightsScreen),
  _ => _placeholder(title),
};

/// Aparelho 390×844 com as áreas seguras do iPhone (47/34): a Início rola de verdade.
Future<void> _device(WidgetTester tester) async {
  setCanvasView(
    tester,
    logical: const Size(390, 844),
    safeTop: 47,
    safeBottom: 34,
  );
  await pumpApp(tester);
}

/// Rola a Início até o centro do elemento chegar a [y] (acima da barra flutuante e fora do fade). Elementos
/// perto do topo (sino, hero) ficam com 40 px de rolagem, no mínimo, para que o teste sempre role de verdade.
Future<void> _scrollTo(WidgetTester tester, String id, {double y = 300}) async {
  final position = homeScrollPosition(tester);
  final center = tester.getCenter(find.byKey(ValueKey<String>(id))).dy;
  position.jumpTo(
    (position.pixels + center - y).clamp(40.0, position.maxScrollExtent),
  );
  await tester.pump();
}

/// Toca no centro do elemento. As colunas de texto não participam do hit test por si (só o `Pressable` que as
/// contém), o que o `tap` avisa como "would not hit test": a prova do toque é a rota/ação que se segue.
Future<void> _tap(WidgetTester tester, Finder finder) =>
    tester.tap(finder, warnIfMissed: false);

/// Voltar do sistema (botão/gesto de voltar): fecha a rota do topo.
Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

/// A discussão do clube da fixture (a rota leva o id do clube do mundo de referência).
final _discussao = '/clube/${mundoReferencia.clube.id}/discussao';

/// (Key, rota esperada, título do placeholder da rota) — a tabela do mapa de toques (F12 12.1), exceto a
/// troca de aba (`recent.libraryLink`, testada à parte) e as abas/Scanner (F11). Desde a T03 com a prancha 01: o
/// 1º cartão de "Também lendo" é o papel sem página (D-253) — só a capa é link (o "play" é sem ação, abaixo).
final _pushRows = <(String, String, String)>[
  ('header.bell', '/notificacoes', 'Notificações'),
  ('hero.cta', '/leitor/dom-casmurro', 'Leitor'),
  ('hero.notesButton', '/livro/dom-casmurro/destaques', 'Grifos e notas'),
  (
    'alsoReading.card1.cover',
    '/livro/memorias-postumas-de-bras-cubas',
    'Livro',
  ),
  ('alsoReading.card2', '/livro/orgulho-e-preconceito', 'Livro'),
  ('forYou.seeAll', '/para-voce', 'Para você'),
  ('forYou.item1', '/livro/esau-e-jaco', 'Livro'),
  ('forYou.item2', '/livro/memorial-de-aires', 'Livro'),
  ('forYou.item3', '/livro/casa-de-pensao', 'Livro'),
  ('club.cta', _discussao, 'Discussão'),
  ('recent.row0.textBlock', '/livro/frankenstein', 'Livro'),
  ('recent.row1.textBlock', '/livro/o-alienista', 'Livro'),
  ('recent.row2.textBlock', '/livro/senhora', 'Livro'),
];

/// F12 12.1 — mapa de toques da Início: destino, volta com a mesma rolagem, alvos e ausência de ripple.
void main() {
  setUpAll(loadAppFonts);

  for (final (id, path, title) in _pushRows) {
    testWidgets(
      '12.1 $id → push $path ($title); voltar devolve a Início na MESMA rolagem',
      (tester) async {
        await _device(tester);
        expect(_router(tester).state.uri.path, AppRoutes.inicio);
        await _scrollTo(tester, id);
        final scrolled = homeScrollPosition(tester).pixels;
        expect(scrolled, greaterThan(0), reason: 'o teste precisa rolar');
        final carousel = find.byKey(const ValueKey('forYou.carousel'));
        final carouselOffset = tester
            .state<ScrollableState>(
              find.descendant(of: carousel, matching: find.byType(Scrollable)),
            )
            .position
            .pixels;

        await _tap(tester, _key(id));
        await tester.pumpAndSettle();
        expect(_router(tester).state.uri.path, path, reason: id);
        expect(_destino(title), findsOneWidget, reason: id);
        // Empilhou no navigator raiz, por cima do shell: a aba ativa não mudou.
        expect(_shell(tester).currentIndex, 0, reason: id);
        expect(find.byKey(const ValueKey('nav')), findsNothing, reason: id);

        await _back(tester);
        expect(_router(tester).state.uri.path, AppRoutes.inicio, reason: id);
        expect(_destino(title), findsNothing, reason: id);
        expect(find.byType(HomeScreen), findsOneWidget, reason: id);
        expect(find.byKey(const ValueKey('nav')), findsOneWidget, reason: id);
        expect(
          homeScrollPosition(tester).pixels,
          scrolled,
          reason: '$id: rolagem da Início depois de voltar',
        );
        // O carrossel horizontal também fica onde estava.
        expect(
          tester
              .state<ScrollableState>(
                find.descendant(
                  of: carousel,
                  matching: find.byType(Scrollable),
                ),
              )
              .position
              .pixels,
          carouselOffset,
          reason: id,
        );
        debugPrint(
          '[toques] $id → $path · rolagem antes/depois: $scrolled → ${homeScrollPosition(tester).pixels}',
        );
      },
    );
  }

  testWidgets(
    '12.1 recent.libraryLink → troca para a aba Biblioteca (go, não push): ramo 1, placeholder da aba; a Início volta na mesma rolagem pela barra',
    (tester) async {
      await _device(tester);
      await _scrollTo(tester, 'recent.libraryLink', y: 500);
      final scrolled = homeScrollPosition(tester).pixels;
      await _tap(tester, _key('recent.libraryLink'));
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.biblioteca);
      expect(_shell(tester).currentIndex, 1);
      expect(_placeholder('Biblioteca'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      // É troca de aba: o shell continua e nenhuma rota foi empilhada por cima dele.
      expect(find.byKey(const ValueKey('nav')), findsOneWidget);
      expect(
        Navigator.of(
          tester.element(find.byKey(const ValueKey('nav'))),
          rootNavigator: true,
        ).canPop(),
        isFalse,
      );

      await _tap(tester, _key('nav.home'));
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.inicio);
      expect(_shell(tester).currentIndex, 0);
      expect(homeScrollPosition(tester).pixels, scrolled);
    },
  );

  // Alvos de toque: o retângulo inteiro da tabela responde (inclusive pontas e o badge/ponto sobrepostos).
  for (final (id, path, size, edges) in [
    ('header.bell', '/notificacoes', const Size(48, 48), true),
    ('hero.cta', '/leitor/dom-casmurro', const Size(243, 54), true),
    (
      'hero.notesButton',
      '/livro/dom-casmurro/destaques',
      const Size(54, 54),
      true,
    ),
    ('forYou.seeAll', '/para-voce', null, false),
    ('club.cta', _discussao, const Size(221, 46), true),
    ('recent.libraryLink', '/biblioteca', null, false),
  ]) {
    testWidgets(
      '12.1 alvo de $id: ${size ?? 'altura 44'} — responde nos 4 lados e no centro; 4 px fora não responde',
      (tester) async {
        await _device(tester);
        await _scrollTo(tester, id, y: 400);
        final rect = tester.getRect(_key(id));
        if (size != null) {
          expect(rect.width, closeTo(size.width, 0.05), reason: id);
          expect(rect.height, closeTo(size.height, 0.05), reason: id);
        } else {
          expect(rect.height, 44, reason: id);
        }
        Future<void> expectTap(Offset p, {required bool opens}) async {
          await tester.tapAt(p);
          await tester.pumpAndSettle();
          final now = _router(tester).state.uri.path;
          if (opens) {
            expect(now, path, reason: '$id @ $p');
            if (path == AppRoutes.biblioteca) {
              await _tap(tester, _key('nav.home'));
              await tester.pumpAndSettle();
            } else {
              await _back(tester);
            }
          } else {
            expect(now, AppRoutes.inicio, reason: '$id @ $p (fora do alvo)');
          }
        }

        for (final p in [
          rect.center,
          Offset(rect.left + 3, rect.center.dy),
          Offset(rect.right - 3, rect.center.dy),
          Offset(rect.center.dx, rect.top + 3),
          Offset(rect.center.dx, rect.bottom - 3),
        ]) {
          await expectTap(p, opens: true);
        }
        if (edges) {
          for (final p in [
            Offset(rect.center.dx, rect.top - 4),
            Offset(rect.center.dx, rect.bottom + 4),
          ]) {
            await expectTap(p, opens: false);
          }
        }
      },
    );
  }

  testWidgets(
    '12.1 o ponto do sino e o badge dos destaques (camadas sobrepostas) NÃO bloqueiam o toque: tocar neles abre o mesmo destino',
    (tester) async {
      await _device(tester);
      await _scrollTo(tester, 'hero.notesButton');
      for (final (overlay, path) in [
        ('hero.notesButton.badge', '/livro/dom-casmurro/destaques'),
        ('hero.notesButton.icon', '/livro/dom-casmurro/destaques'),
        ('hero.cta.label', '/leitor/dom-casmurro'),
        ('hero.cta.icon', '/leitor/dom-casmurro'),
      ]) {
        await tester.tapAt(tester.getCenter(_key(overlay)));
        await tester.pumpAndSettle();
        expect(_router(tester).state.uri.path, path, reason: overlay);
        await _back(tester);
      }
      await _scrollTo(tester, 'header.bell');
      for (final overlay in ['header.bell.dot', 'header.bell.icon']) {
        await tester.tapAt(tester.getCenter(_key(overlay)));
        await tester.pumpAndSettle();
        expect(
          _router(tester).state.uri.path,
          AppRoutes.notificacoes,
          reason: overlay,
        );
        await _back(tester);
      }
      // Outros textos/ícones dentro dos links também são parte do alvo.
      await _scrollTo(tester, 'club.cta');
      for (final overlay in [
        'club.cta.label',
        'club.cta.icon',
        'club.cta.badge',
      ]) {
        await tester.tapAt(tester.getCenter(_key(overlay)));
        await tester.pumpAndSettle();
        expect(_router(tester).state.uri.path, _discussao, reason: overlay);
        await _back(tester);
      }
    },
  );

  testWidgets(
    '12.1 "Mais opções" (recent.rowN.more): existe a ação, mas NÃO abre nada visual — sem rota, sem diálogo, sem folha, sem menu',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _device(tester);
      await _scrollTo(tester, 'recent.row0.more', y: 380);
      for (final (n, label) in [
        (0, 'Mais opções para Frankenstein'),
        (1, 'Mais opções para O Alienista'),
        (2, 'Mais opções para Senhora'),
      ]) {
        final id = 'recent.row$n.more';
        await _scrollTo(tester, id, y: 400);
        final overlayBefore = find.byType(Overlay).evaluate().length;
        final routesBefore = _router(tester)
            .routerDelegate
            .currentConfiguration
            .matches
            .length;
        // O botão tem ação de toque (callback `onMoreOptions` não nulo, vazio).
        final press = tester.widget<Pressable>(
          find.descendant(of: _key(id), matching: find.byType(Pressable)),
        );
        expect(press.onTap, isNotNull, reason: id);
        expect(press.semanticsLabel, label, reason: id);
        final node = tester.getSemantics(_key(id));
        expect(node.label, label);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

        await _tap(tester, _key(id));
        await tester.pumpAndSettle();
        expect(_router(tester).state.uri.path, AppRoutes.inicio, reason: id);
        expect(
          _router(tester).routerDelegate.currentConfiguration.matches.length,
          routesBefore,
          reason: id,
        );
        expect(find.byType(Overlay).evaluate().length, overlayBefore);
        expect(find.byType(PlaceholderScreen), findsNWidgets(0), reason: id);
        expect(find.byType(Dialog), findsNothing);
        expect(find.byType(BottomSheet), findsNothing);
        expect(find.byType(PopupMenuItem<Object?>), findsNothing);
        expect(
          find.byType(ModalBarrier).evaluate().where((e) {
            final w = e.widget as ModalBarrier;
            return w.color != null;
          }),
          isEmpty,
        );
        expect(
          Navigator.of(tester.element(_key(id)), rootNavigator: true).canPop(),
          isFalse,
          reason: id,
        );
      }
      // O callback do app é o no-op documentado (não faz nada com o livro).
      expect(
        () => HomeScreen.onMoreOptions(
          const Book(
            id: 'x',
            title: 'x',
            author: 'x',
            cover: DesignedCover(CoverArt.frankenstein),
          ),
        ),
        returnsNormally,
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'T03 (D-243 b) a lupa, o "play" do papel, "Ler agora" e "Revisar" existem com a ação da prancha, mas NÃO abrem nada — sem rota, sem diálogo, sem folha, sem menu',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _device(tester);
      for (final (id, label, link) in [
        ('header.search', 'Buscar livros', true),
        ('alsoReading.card1.play', 'Iniciar leitura de Brás Cubas', false),
        ('today.readNow', 'Iniciar leitura (cronômetro)', true),
        ('review.cta', 'Revisar', true),
      ]) {
        await _scrollTo(tester, id, y: 400);
        final overlayBefore = find.byType(Overlay).evaluate().length;
        final routesBefore = _router(tester)
            .routerDelegate
            .currentConfiguration
            .matches
            .length;
        // O alvo tem ação de toque (o callback da Início não é nulo — é o no-op documentado).
        final press = tester.widget<Pressable>(
          find
                  .ancestor(of: _key(id), matching: find.byType(Pressable))
                  .evaluate()
                  .isNotEmpty
              ? find
                    .ancestor(of: _key(id), matching: find.byType(Pressable))
                    .first
              : find
                    .descendant(of: _key(id), matching: find.byType(Pressable))
                    .first,
        );
        expect(press.onTap, isNotNull, reason: id);
        expect(press.isLink, link, reason: id);
        final node = tester.getSemantics(_key(id));
        expect(node.label, label, reason: id);
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason: id,
        );

        await _tap(tester, _key(id));
        await tester.pumpAndSettle();
        expect(_router(tester).state.uri.path, AppRoutes.inicio, reason: id);
        expect(
          _router(tester).routerDelegate.currentConfiguration.matches.length,
          routesBefore,
          reason: id,
        );
        expect(find.byType(Overlay).evaluate().length, overlayBefore);
        expect(find.byType(PlaceholderScreen), findsNothing, reason: id);
        expect(find.byType(Dialog), findsNothing, reason: id);
        expect(find.byType(BottomSheet), findsNothing, reason: id);
        expect(find.byType(PopupMenuItem<Object?>), findsNothing, reason: id);
        expect(
          Navigator.of(tester.element(_key(id)), rootNavigator: true).canPop(),
          isFalse,
          reason: id,
        );
      }
      // Os callbacks do app são os no-ops documentados.
      const book = Book(
        id: 'x',
        title: 'x',
        author: 'x',
        cover: DesignedCover(CoverArt.brasCubas),
      );
      expect(HomeScreen.onSearch, returnsNormally);
      expect(() => HomeScreen.onStartReading(book), returnsNormally);
      expect(HomeScreen.onReadNow, returnsNormally);
      expect(HomeScreen.onReview, returnsNormally);
      semantics.dispose();
    },
  );

  testWidgets(
    '12.1 sem ripple/splash/realce do Material em nenhum alvo (D-04): nenhum InkWell/InkResponse na árvore, nem durante o toque; feedback = escala 0,97',
    (tester) async {
      await _device(tester);
      expect(Pressable.feedbackEnabled, isTrue);
      for (final id in [
        'header.bell',
        'hero.cta',
        'hero.notesButton',
        'alsoReading.card1.cover',
        'alsoReading.card1.play',
        'alsoReading.card2',
        'header.search',
        'today.readNow',
        'review.cta',
        'forYou.seeAll',
        'forYou.item1',
        'club.cta',
        'recent.libraryLink',
        'recent.row0.textBlock',
        'recent.row0.more',
      ]) {
        await _scrollTo(tester, id, y: 380);
        double scale() {
          // A Key fica dentro do Pressable (cards, itens, CTAs) ou é o próprio botão que o contém.
          final outer = find.ancestor(
            of: _key(id),
            matching: find.byType(Pressable),
          );
          final pressable = outer.evaluate().isNotEmpty
              ? outer.first
              : find
                    .descendant(of: _key(id), matching: find.byType(Pressable))
                    .first;
          return tester
              .widget<AnimatedScale>(
                find
                    .descendant(
                      of: pressable,
                      matching: find.byType(AnimatedScale),
                    )
                    .first,
              )
              .scale;
        }

        expect(scale(), 1.0, reason: id);
        final g = await tester.startGesture(tester.getCenter(_key(id)));
        // Numa lista rolável o gesto de arrastar disputa a arena: o `onTapDown` só vem após o kPressTimeout.
        await tester.pump(kPressTimeout);
        expect(scale(), 0.97, reason: id);
        expect(find.byType(InkWell), findsNothing, reason: id);
        expect(find.byType(InkResponse), findsNothing, reason: id);
        expect(find.byType(Ink), findsNothing, reason: id);
        // Arrastar para fora cancela: volta ao repouso e nada abre.
        await g.moveBy(
          const Offset(0, -200),
          timeStamp: const Duration(milliseconds: 40),
        );
        await g.up();
        await tester.pumpAndSettle();
        expect(scale(), 1.0, reason: id);
        expect(_router(tester).state.uri.path, AppRoutes.inicio, reason: id);
      }
    },
  );
}

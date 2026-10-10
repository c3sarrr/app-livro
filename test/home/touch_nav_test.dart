import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/placeholder/presentation/placeholder_screen.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

StatefulNavigationShell _shell(WidgetTester tester) =>
    tester.widget<MainShell>(find.byType(MainShell, skipOffstage: false)).shell;

Finder _placeholder(String title) =>
    find.byWidgetPredicate((w) => w is PlaceholderScreen && w.title == title);

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// Aparelho 390×844 com as áreas seguras do iPhone (47/34): barra em y 744, FAB em y 723,5.
void _device(WidgetTester tester) => setCanvasView(
  tester,
  logical: const Size(390, 844),
  safeTop: 47,
  safeBottom: 34,
);

/// O item está ativo quando tem a pílula (único com `DecoratedBox` sob a Key).
bool _isActive(WidgetTester tester, String id) => find
    .descendant(
      of: find.byKey(ValueKey<String>(id)),
      matching: find.byType(DecoratedBox),
    )
    .evaluate()
    .isNotEmpty;

List<String> _activeItems(WidgetTester tester) => [
  for (final id in ['nav.home', 'nav.library', 'nav.clubs', 'nav.profile'])
    if (_isActive(tester, id)) id,
];

/// Sinaliza se o hit test em [p] passa por um render object que pertence a [widget] (ou a um descendente).
bool _hits(WidgetTester tester, Offset p, Finder widget) {
  final targets = tester.hitTestOnBinding(p).path.map((e) => e.target).toSet();
  return widget.evaluate().any((element) {
    var found = false;
    void visit(Element e) {
      if (found) return;
      if (e.renderObject != null && targets.contains(e.renderObject)) {
        found = true;
        return;
      }
      e.visitChildren(visit);
    }

    visit(element);
    return found;
  });
}

/// F11 11.5 — toques e rotas da navegação (go_router): troca de aba, item ativo e `/scanner` por push.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'tocar Biblioteca / Clubes / Perfil / Início troca a aba (ramo, rota, placeholder) e move a pílula ativa; a posição de rolagem da Início é preservada',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      expect(_shell(tester).currentIndex, 0);
      expect(_activeItems(tester), ['nav.home']);

      await tester.drag(homeScrollView(), const Offset(0, -600));
      await tester.pumpAndSettle();
      final scrolled = homeScrollPosition(tester).pixels;
      expect(scrolled, greaterThan(500));

      for (final (id, path, title, index) in [
        ('nav.library', AppRoutes.biblioteca, 'Biblioteca', 1),
        ('nav.clubs', AppRoutes.clubes, 'Clubes', 2),
        ('nav.profile', AppRoutes.perfil, 'Perfil', 3),
      ]) {
        await tester.tap(find.byKey(ValueKey(id)));
        await tester.pumpAndSettle();
        expect(_router(tester).state.uri.path, path, reason: id);
        expect(_shell(tester).currentIndex, index, reason: id);
        expect(_placeholder(title), findsOneWidget, reason: id);
        expect(find.byType(HomeScreen), findsNothing, reason: id);
        expect(_activeItems(tester), [id], reason: id);
        // As camadas fixas continuam sobre a aba.
        expect(_rect(tester, 'nav'), const Rect.fromLTWH(16, 744, 358, 70));
        expect(
          _rect(tester, 'nav.scanner.fab'),
          const Rect.fromLTWH(165, 723.5, 60, 60),
        );
      }

      await tester.tap(find.byKey(const ValueKey('nav.home')));
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.inicio);
      expect(_shell(tester).currentIndex, 0);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(_activeItems(tester), ['nav.home']);
      expect(homeScrollPosition(tester).pixels, scrolled);
      debugPrint(
        '[toques] rolagem da Início antes/depois de passear pelas abas: $scrolled → ${homeScrollPosition(tester).pixels}',
      );
    },
  );

  testWidgets(
    'tocar a aba que já está ativa não muda nada (rota, pílula e rolagem da Início ficam como estavam)',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      await tester.drag(homeScrollView(), const Offset(0, -500));
      await tester.pumpAndSettle();
      final scrolled = homeScrollPosition(tester).pixels;
      await tester.tap(find.byKey(const ValueKey('nav.home')));
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.inicio);
      expect(_shell(tester).currentIndex, 0);
      expect(_activeItems(tester), ['nav.home']);
      expect(homeScrollPosition(tester).pixels, scrolled);

      // O mesmo numa aba que não é a Início.
      await tester.tap(find.byKey(const ValueKey('nav.clubs')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav.clubs')));
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.clubes);
      expect(_activeItems(tester), ['nav.clubs']);
      expect(_placeholder('Clubes'), findsOneWidget);
    },
  );

  for (final (label, offset) in [
    (
      'acima da barra (parte do círculo que sai dela, centro)',
      const Offset(0, -17.5),
    ),
    ('acima da barra, junto ao topo do círculo', const Offset(0, -28)),
    (
      'acima da barra, à esquerda do eixo (dentro do círculo)',
      const Offset(-20, -12),
    ),
    (
      'acima da barra, à direita do eixo (dentro do círculo)',
      const Offset(20, -12),
    ),
    ('no centro do círculo (sobre a borda superior da barra)', Offset.zero),
    (
      'na parte baixa do círculo (sobre a barra, onde fica o ícone)',
      const Offset(0, 22),
    ),
    ('na sombra do círculo (4 px abaixo dele)', const Offset(0, 31.5)),
  ]) {
    testWidgets(
      '11.4 FAB tocável em toda a área: $label abre /scanner por push, uma única vez, sem trocar a aba',
      (tester) async {
        _device(tester);
        await pumpApp(tester);
        final center = _rect(tester, 'nav.scanner.fab').center;
        // O ponto da sombra não é "do círculo": só garante que cai no item "Scanner" (mesma ação).
        await tester.tapAt(center + offset);
        await tester.pumpAndSettle();
        final scanner = find.byType(ScannerScreen);
        expect(scanner, findsOneWidget, reason: label);
        expect(_router(tester).state.uri.path, AppRoutes.scanner);
        expect(_shell(tester).currentIndex, 0);
        expect(find.byKey(const ValueKey('nav')), findsNothing);
        // Uma única rota: um pop devolve o shell com a Início ativa.
        _router(tester).pop();
        await tester.pumpAndSettle();
        expect(scanner, findsNothing, reason: label);
        expect(find.byType(ScannerScreen), findsNothing, reason: label);
        expect(find.byKey(const ValueKey('nav')), findsOneWidget);
        expect(_shell(tester).currentIndex, 0);
        expect(_activeItems(tester), ['nav.home']);
      },
    );
  }

  testWidgets(
    'canvas 390×2650 (prancha 01): tocar o FAB acima da barra (y = 2535, 15 acima do topo dela, como o y 2275 da F11) abre /scanner',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      await tester.tapAt(const Offset(195, 2535));
      await tester.pumpAndSettle();
      expect(find.byType(ScannerScreen), findsOneWidget);
      expect(_router(tester).state.uri.path, AppRoutes.scanner);
    },
  );

  testWidgets(
    'o item "Scanner" (rótulo, e o espaço do item abaixo do FAB) também abre /scanner; com outra aba ativa o scanner abre por cima e, ao voltar, a aba continua a mesma (D-08)',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('nav.clubs')));
      await tester.pumpAndSettle();
      expect(_activeItems(tester), ['nav.clubs']);

      for (final point in [
        _rect(tester, 'nav.scanner.label').center,
        _rect(tester, 'nav.scanner').bottomCenter - const Offset(0, 1),
        _rect(tester, 'nav.scanner').bottomLeft + const Offset(2, -2),
      ]) {
        await tester.tapAt(point);
        await tester.pumpAndSettle();
        final scanner = find.byType(ScannerScreen);
        expect(scanner, findsOneWidget, reason: '$point');
        final route =
            ModalRoute.of(tester.element(scanner))! as PageRoute<void>;
        expect(route.fullscreenDialog, isTrue);
        expect(
          route.navigator,
          same(Navigator.of(tester.element(scanner), rootNavigator: true)),
        );
        _router(tester).pop();
        await tester.pumpAndSettle();
        expect(scanner, findsNothing);
        expect(_shell(tester).currentIndex, 2, reason: '$point');
        expect(_activeItems(tester), ['nav.clubs'], reason: '$point');
        expect(_placeholder('Clubes'), findsOneWidget);
      }

      // O FAB também, com Clubes ativa.
      await tester.tapAt(_rect(tester, 'nav.scanner.fab').center);
      await tester.pumpAndSettle();
      expect(find.byType(ScannerScreen), findsOneWidget);
      _router(tester).pop();
      await tester.pumpAndSettle();
      expect(_shell(tester).currentIndex, 2);
    },
  );

  testWidgets(
    'o fade não intercepta toques (os toques passam para o conteúdo); a barra, o vão entre os itens e o espaço dentro da borda NÃO deixam o toque chegar ao conteúdo',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      // Fade (694…744) fora da barra e do FAB: o toque chega ao conteúdo da Início.
      for (final p in const [
        Offset(100, 700),
        Offset(30, 740),
        Offset(360, 720),
      ]) {
        expect(
          _hits(tester, p, find.byKey(const ValueKey('bottomFade'))),
          isFalse,
          reason: '$p',
        );
        expect(_hits(tester, p, find.byType(HomeScreen)), isTrue, reason: '$p');
      }
      // Barra: vão entre os itens, margem interna (padding 8), borda e área abaixo do último rótulo — a barra pega.
      final nav = _rect(tester, 'nav');
      for (final p in [
        Offset(
          nav.left + 9.5 + 64.6 + 2,
          nav.center.dy,
        ), // vão entre Início e Biblioteca
        Offset(nav.left + 4, nav.center.dy), // padding esquerdo
        Offset(nav.right - 4, nav.center.dy), // padding direito
        Offset(nav.center.dx - 80, nav.top + 4), // padding superior
        Offset(nav.center.dx - 80, nav.bottom - 4), // padding inferior
      ]) {
        expect(
          _hits(tester, p, find.byKey(const ValueKey('nav'))),
          isTrue,
          reason: '$p',
        );
        expect(
          _hits(tester, p, find.byType(HomeScreen)),
          isFalse,
          reason: '$p',
        );
      }
      // Sem callbacks de itens soltos: tocar nesses pontos não faz nada.
      await tester.tapAt(Offset(nav.left + 4, nav.center.dy));
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.inicio);
      expect(_shell(tester).currentIndex, 0);
    },
  );

  testWidgets(
    'D-04: pressionar um item ou o FAB aplica o feedback de escala 0,97 e soltar volta ao repouso; o repouso é idêntico',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      double scaleOf(String id) => tester
          .widget<AnimatedScale>(
            find
                .descendant(
                  of: find.byKey(ValueKey(id)),
                  matching: find.byType(AnimatedScale),
                )
                .first,
          )
          .scale;
      // Pressionar → 0,97; arrastar para fora e soltar cancela o toque: volta a 1,0 e não aciona nada.
      for (final id in [
        'nav.home',
        'nav.library',
        'nav.scanner',
        'nav.clubs',
        'nav.profile',
        'nav.scanner.fab',
      ]) {
        expect(scaleOf(id), 1.0, reason: id);
        // O centro do item "Scanner" fica sob o FAB (que pinta por cima): o toque no item é no rótulo.
        final point = id == 'nav.scanner'
            ? _rect(tester, 'nav.scanner.label').center
            : _rect(tester, id).center;
        final g = await tester.startGesture(point);
        await tester.pump();
        expect(scaleOf(id), 0.97, reason: id);
        await g.moveBy(
          const Offset(0, -300),
          timeStamp: const Duration(milliseconds: 40),
        );
        await g.up();
        await tester.pumpAndSettle();
        expect(scaleOf(id), 1.0, reason: id);
        expect(_router(tester).state.uri.path, AppRoutes.inicio, reason: id);
        expect(_shell(tester).currentIndex, 0, reason: id);
      }
      // Soltar dentro do item = toque: a ação executa e o item volta ao repouso (1,0).
      final g = await tester.startGesture(_rect(tester, 'nav.library').center);
      await tester.pump();
      expect(scaleOf('nav.library'), 0.97);
      await g.up();
      await tester.pumpAndSettle();
      expect(scaleOf('nav.library'), 1.0);
      expect(_shell(tester).currentIndex, 1);
      expect(_router(tester).state.uri.path, AppRoutes.biblioteca);
    },
  );
}

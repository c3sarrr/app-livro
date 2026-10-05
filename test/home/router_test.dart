import 'dart:async';

import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/core/design_system/gallery/design_system_gallery.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/account/presentation/account_block.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/placeholder/presentation/placeholder_screen.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/foundation.dart';
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

/// Aparelho 390×844 com as áreas seguras do iPhone (47/34).
void _device(WidgetTester tester) => setCanvasView(
  tester,
  logical: const Size(390, 844),
  safeTop: 47,
  safeBottom: 34,
);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '2.8 abas: /biblioteca, /clubes, /perfil abrem os placeholders; voltar a /inicio preserva a rolagem (IndexedStack)',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      expect(_router(tester).state.uri.path, AppRoutes.inicio);
      expect(_shell(tester).currentIndex, 0);

      await tester.drag(homeScrollView(), const Offset(0, -600));
      await tester.pumpAndSettle();
      final scrolled = homeScrollPosition(tester).pixels;
      expect(scrolled, greaterThan(500));
      debugPrint('[rotas] rolagem da Início antes de trocar de aba: $scrolled');

      for (final (path, title, index) in [
        (AppRoutes.biblioteca, 'Biblioteca', 1),
        (AppRoutes.clubes, 'Clubes', 2),
        (AppRoutes.perfil, 'Perfil', 3),
      ]) {
        _router(tester).go(path);
        await tester.pumpAndSettle();
        expect(_router(tester).state.uri.path, path);
        expect(_shell(tester).currentIndex, index);
        expect(_placeholder(title), findsOneWidget, reason: title);
        // A Início sai de cena, mas continua montada (mesmo estado).
        expect(find.byType(HomeScreen), findsNothing);
        expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
        // As camadas fixas do shell ficam sobre qualquer aba.
        expect(find.byKey(const ValueKey('nav')), findsOneWidget);
        expect(find.byKey(const ValueKey('bottomFade')), findsOneWidget);
      }

      // Troca por índice (o que a barra da F11 fará) também funciona.
      _shell(tester).goBranch(1);
      await tester.pumpAndSettle();
      expect(_router(tester).state.uri.path, AppRoutes.biblioteca);
      expect(_placeholder('Biblioteca'), findsOneWidget);

      _router(tester).go(AppRoutes.inicio);
      await tester.pumpAndSettle();
      expect(_shell(tester).currentIndex, 0);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(homeScrollPosition(tester).pixels, scrolled);
      debugPrint(
        '[rotas] rolagem da Início ao voltar: ${homeScrollPosition(tester).pixels}',
      );
    },
  );

  testWidgets(
    '2.6 /scanner: full screen no navigator raiz (fullscreenDialog), por push, sem trocar a aba ativa (D-08)',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      _router(tester).go(AppRoutes.clubes);
      await tester.pumpAndSettle();

      unawaited(_router(tester).push<void>(AppRoutes.scanner));
      await tester.pumpAndSettle();
      final scanner = find.byType(ScannerScreen);
      expect(scanner, findsOneWidget);
      final route = ModalRoute.of(tester.element(scanner))! as PageRoute<void>;
      expect(route.fullscreenDialog, isTrue);
      expect(route.settings.name, AppRoutes.scanner);
      expect(
        route.navigator,
        same(Navigator.of(tester.element(scanner), rootNavigator: true)),
      );
      // Cobre o shell inteiro (a barra fica fora da tela) e a aba ativa não muda.
      expect(find.byKey(const ValueKey('nav')), findsNothing);
      expect(_shell(tester).currentIndex, 2);

      _router(tester).pop();
      await tester.pumpAndSettle();
      expect(scanner, findsNothing);
      expect(_placeholder('Clubes'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav')), findsOneWidget);
      expect(_shell(tester).currentIndex, 2);
    },
  );

  testWidgets(
    '2.6 destinos placeholder (usados na F12): cada um abre por push no navigator raiz',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      for (final (location, title, params) in [
        (AppRoutes.notificacoes, 'Notificações', <String, String>{}),
        (
          AppRoutes.leitor('dom-casmurro'),
          'Leitor',
          {'bookId': 'dom-casmurro'},
        ),
        (AppRoutes.livro('dom-casmurro'), 'Livro', {'bookId': 'dom-casmurro'}),
        (
          AppRoutes.destaques('dom-casmurro'),
          'Destaques e notas',
          {'bookId': 'dom-casmurro'},
        ),
        (AppRoutes.paraVoce, 'Para você', <String, String>{}),
        (
          AppRoutes.discussao('leitoras-de-capitu'),
          'Discussão',
          {'clubId': 'leitoras-de-capitu'},
        ),
      ]) {
        unawaited(_router(tester).push<void>(location));
        await tester.pumpAndSettle();
        final page = _placeholder(title);
        expect(page, findsOneWidget, reason: location);
        final route = ModalRoute.of(tester.element(page))! as PageRoute<void>;
        expect(route.fullscreenDialog, isFalse, reason: location);
        expect(
          route.navigator,
          same(Navigator.of(tester.element(page), rootNavigator: true)),
          reason: location,
        );
        expect(route.settings.arguments, params, reason: location);
        expect(_router(tester).state.uri.path, location);
        _router(tester).pop();
        await tester.pumpAndSettle();
        expect(page, findsNothing, reason: location);
        expect(find.byType(HomeScreen), findsOneWidget);
      }
      expect(AppRoutes.leitor('x'), '/leitor/x');
      expect(AppRoutes.livro('x'), '/livro/x');
      expect(AppRoutes.destaques('x'), '/livro/x/destaques');
      expect(AppRoutes.discussao('y'), '/clube/y/discussao');
    },
  );

  testWidgets(
    '2.6 /_ds existe só em debug e abre a galeria do design system (F01)',
    (tester) async {
      expect(kDebugMode, isTrue);
      _device(tester);
      await pumpApp(tester);
      unawaited(_router(tester).push<void>(AppRoutes.designSystem));
      await tester.pumpAndSettle();
      expect(find.byType(DesignSystemGallery), findsOneWidget);
    },
  );

  testWidgets(
    'PlaceholderScreen (D-07): fundo papel + SafeArea + título centralizado em Bricolage 24 — nada além disso',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      final semantics = tester.ensureSemantics();
      // Clubes: desde a G05 o Perfil ganhou o bloco da conta abaixo do título (D-69 — teste abaixo).
      _router(tester).go(AppRoutes.clubes);
      await tester.pumpAndSettle();
      final page = _placeholder('Clubes');
      final box = tester.widget<ColoredBox>(
        find.descendant(of: page, matching: find.byType(ColoredBox)).first,
      );
      expect(box.color, AppColors.paper);
      expect(
        tester.getRect(
          find.descendant(of: page, matching: find.byType(ColoredBox)).first,
        ),
        const Rect.fromLTWH(0, 0, 390, 844),
      );
      expect(
        find.descendant(of: page, matching: find.byType(SafeArea)),
        findsOneWidget,
      );
      final texts = find.descendant(of: page, matching: find.byType(AppText));
      expect(texts, findsOneWidget);
      final span = tester.widget<AppText>(texts).span as TextSpan;
      expect(span.text, 'Clubes');
      expect(span.style, same(AppTextStyles.sectionTitleL));
      // Centro da área segura: x = 195; y = 47 + (844 − 47 − 34) / 2 = 428,5.
      final center = tester.getCenter(texts);
      expect(center.dx, moreOrLessEquals(195, epsilon: 1e-6));
      expect(center.dy, moreOrLessEquals(428.5, epsilon: 1e-6));
      expect(
        tester.getSemantics(texts),
        matchesSemantics(label: 'Clubes', isHeader: true),
      );
      semantics.dispose();
    },
  );

  testWidgets(
    'Perfil (D-69): o título continua no centro e o bloco da conta fica abaixo dele, acima da barra',
    (tester) async {
      _device(tester);
      await pumpApp(tester);
      _router(tester).go(AppRoutes.perfil);
      await tester.pumpAndSettle();
      final page = _placeholder('Perfil');
      expect(tester.widget<PlaceholderScreen>(page).below, isA<AccountBlock>());
      final title = find.descendant(
        of: page,
        matching: find.byWidgetPredicate(
          (w) => w is AppText && w.span.toPlainText() == 'Perfil',
        ),
      );
      final center = tester.getCenter(title);
      expect(center.dx, moreOrLessEquals(195, epsilon: 1e-6));
      expect(center.dy, moreOrLessEquals(428.5, epsilon: 1e-6));
      final block = tester.getRect(find.byType(AccountBlock));
      // Começa 32 abaixo do meio da área segura; termina antes da barra (744) com folga.
      expect(block.top, moreOrLessEquals(47 + 763 / 2 + 32, epsilon: 1e-6));
      expect(block.left, 20); // AppSpacing.gutter
      expect(block.right, 390 - 20);
      expect(block.top, greaterThan(tester.getRect(title).bottom));
      final viewport = tester.getRect(
        find.ancestor(
          of: find.byType(AccountBlock),
          matching: find.byType(SingleChildScrollView),
        ),
      );
      expect(viewport.bottom, moreOrLessEquals(844 - 34 - 116, epsilon: 1e-6));
      expect(viewport.bottom, lessThan(744));
    },
  );
}

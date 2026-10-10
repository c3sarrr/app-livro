import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/shell/presentation/bottom_fade.dart';
import 'package:app_leitura/features/shell/presentation/floating_nav_bar.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:app_leitura/features/shell/presentation/scanner_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../reference/inicio2/referencias_inicio2.dart';
import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

// F02 2.7/2.8 — o shell e o ritmo da Início no canvas e no aparelho (D-02, D-13). Desde a troca da T03 (D-240) a
// Início é a da prancha 01: 9 seções + as camadas fixas, conteúdo até 2612,12 no canvas de 390 × 2650.

/// Os 11 blocos da prancha 01 (9 seções + camadas fixas), na ordem do HTML.
const _blocks = [
  'header',
  'headline',
  'hero',
  'alsoReading',
  'today',
  'review',
  'forYou',
  'club',
  'recent',
  'bottomFade',
  'nav',
];

/// 2.8-correção (aprovada na F04): alturas vindas de texto trazem ruído float32 das métricas de fonte
/// do SkParagraph (título: 90,16000175 em vez de 90,16). A referência tem 2 casas decimais.
const _float32Noise = 1e-3;

/// A prancha arredonda as alturas a 2 casas: o Também lendo mede 205,80 no app e 205,81 na prancha, e tudo o que fica
/// abaixo dele herda os −0,01 (`test/home/inicio01/pagina_test.dart`).
const _arredondamento = 0.011;

/// Fim do conteúdo da prancha 01: recém-chegados (2138,12 + 334) + padding 140.
const _fim = 2612.12;

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

void main() {
  setUpAll(loadAppFonts);

  group('2.8 geometria no canvas 390×2650 (DPR 3)', () {
    testWidgets('os 11 blocos da prancha 01 dentro da tolerância (±0,5)', (
      tester,
    ) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final b in _blocks) {
        final got = _rect(tester, b), ref = kRef01.sections['i01.$b']!;
        for (final (o, g, r) in [
          ('x', got.left, ref.left),
          ('y', got.top, ref.top),
          ('w', got.width, ref.width),
          ('h', got.height, ref.height),
        ]) {
          expect(g, moreOrLessEquals(r, epsilon: 0.5), reason: '$b.$o');
        }
      }
    });

    testWidgets(
      'conteúdo: padding 62/140 em volta da coluna das seções → 2612,12',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        expect(_rect(tester, 'header').top, 62);
        // Altura total do conteúdo = padding do SingleChildScrollView + coluna.
        final content = tester.getSize(
          find
              .descendant(of: homeScrollView(), matching: find.byType(Padding))
              .first,
        );
        expect(
          content.height,
          moreOrLessEquals(_fim, epsilon: _arredondamento),
        );
        expect(
          content.height - _rect(tester, 'recent').bottom,
          moreOrLessEquals(140, epsilon: 1e-9),
        );
      },
    );

    testWidgets(
      'gutters 20; "Para você" com o contêiner de largura total (carrossel 0→390)',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        for (final id in _blocks.take(9)) {
          final r = _rect(tester, id);
          expect((r.left, r.width), (20.0, 350.0), reason: id);
        }
        // A Key marca 20→370 dentro de um Stack que ocupa a largura toda.
        final stack = find
            .ancestor(
              of: find.byKey(const ValueKey('forYou')),
              matching: find.byType(Stack),
            )
            .first;
        final r = tester.getRect(stack);
        expect(r.left, 0);
        expect(r.width, 390);
        expect(r.top, moreOrLessEquals(1464.52, epsilon: _arredondamento));
        expect(r.height, moreOrLessEquals(327, epsilon: _float32Noise));
      },
    );
  });

  group('2.7 MainShell', () {
    testWidgets(
      'camadas na ordem do HTML: conteúdo da aba → fade inferior → navegação → FAB do Scanner',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        final stack = tester.widget<Stack>(
          find
              .descendant(
                of: find.byType(MainShell),
                matching: find.byType(Stack),
              )
              .first,
        );
        expect(stack.children, hasLength(4));
        final [content, fade, nav, fab] = stack.children.cast<Positioned>();
        expect(content.child, isA<StatefulNavigationShell>());
        expect(
          (content.left, content.top, content.right, content.bottom),
          (0.0, 0.0, 0.0, 0.0),
        );
        expect(
          (fade.left, fade.right, fade.bottom, fade.height),
          (0.0, 0.0, 0.0, 150.0),
        );
        final ignore = fade.child as IgnorePointer;
        expect(ignore.ignoring, isTrue);
        expect(ignore.child, isA<BottomFade>());
        expect(ignore.child!.key, const ValueKey('bottomFade'));
        expect(
          (nav.left, nav.right, nav.bottom, nav.height),
          (16.0, 16.0, 30.0, 70.0),
        );
        expect(nav.child, isA<FloatingNavBar>());
        expect(nav.child.key, const ValueKey('nav'));
        // F11: o FAB é irmão da barra, DEPOIS dela (pinta por cima e o toque vale no círculo inteiro).
        expect(
          (fab.left, fab.bottom, fab.width, fab.height),
          (165.0, 60.5, 60.0, 60.0),
        );
        expect(fab.child, isA<ScannerFab>());
        expect(fab.child.key, const ValueKey('nav.scanner.fab'));
        // O fade não intercepta toques (pointer-events: none): 10 px abaixo do topo dele, acima do FAB.
        expect(
          tester
              .hitTestOnBinding(const Offset(195, 2510))
              .path
              .any(
                (e) =>
                    e.target ==
                    tester.renderObject(
                      find.byKey(const ValueKey('bottomFade')),
                    ),
              ),
          isFalse,
        );
        // O MainShell não usa Scaffold: o único Scaffold do app é o da Início.
        expect(find.byType(Scaffold, skipOffstage: false), findsOneWidget);
        expect(
          find.ancestor(
            of: find.byType(Scaffold),
            matching: find.byType(HomeScreen),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'status bar transparente com ícones escuros; Android edge-to-edge (D-13)',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find
              .descendant(
                of: find.byType(MainShell),
                matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
              )
              .first,
        );
        final s = region.value;
        expect(s.statusBarColor?.toARGB32(), 0x00000000);
        expect(s.statusBarIconBrightness, Brightness.dark);
        expect(s.statusBarBrightness, Brightness.light);
        expect(s.systemNavigationBarColor?.toARGB32(), 0x00000000);
        expect(s.systemNavigationBarIconBrightness, Brightness.dark);
        expect(s.systemNavigationBarContrastEnforced, isFalse);
        expect(region.value, MainShell.overlayStyle);
        expect(
          tester.getRect(find.byType(MainShell)),
          const Rect.fromLTWH(0, 0, 390, 2650),
        );
      },
    );

    for (final (bottom, expected) in [
      (0.0, 30.0),
      (34.0, 30.0),
      (48.0, 44.0),
    ]) {
      testWidgets(
        'navBottom = max(30, viewPadding.bottom − 4): bottom $bottom → $expected (D-02)',
        (tester) async {
          setCanvasView(
            tester,
            logical: const Size(390, 844),
            safeBottom: bottom,
          );
          await pumpApp(tester);
          expect(
            _rect(tester, 'nav'),
            Rect.fromLTWH(16, 844 - expected - 70, 358, 70),
          );
        },
      );
    }
  });

  group('2.7 HomeScreen', () {
    testWidgets(
      'Scaffold(backgroundColor: paper) sem appBar/drawer/FAB + SingleChildScrollView(primary: true)',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, AppColors.paper);
        expect(scaffold.appBar, isNull);
        expect(scaffold.drawer, isNull);
        expect(scaffold.endDrawer, isNull);
        expect(scaffold.floatingActionButton, isNull);
        expect(scaffold.bottomNavigationBar, isNull);
        expect(scaffold.bottomSheet, isNull);
        final scroll = tester.widget<SingleChildScrollView>(homeScrollView());
        expect(scroll.primary, isTrue);
        expect(scroll.scrollDirection, Axis.vertical);
        expect(scroll.padding, const EdgeInsets.only(top: 62, bottom: 140));
        final column = tester.widget<Column>(
          find
              .descendant(of: homeScrollView(), matching: find.byType(Column))
              .first,
        );
        expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
        // O fundo pintado é só o papel (nenhum placeholder desenha nada).
        expect(
          tester.getRect(find.byType(Scaffold)),
          const Rect.fromLTWH(0, 0, 390, 2650),
        );
      },
    );

    for (final (top, expected) in [(0.0, 62.0), (47.0, 62.0), (59.0, 74.0)]) {
      testWidgets(
        'inset superior = max(62, viewPadding.top + 15): top $top → $expected (D-02)',
        (tester) async {
          setCanvasView(tester, logical: const Size(390, 844), safeTop: top);
          await pumpApp(tester);
          expect(_rect(tester, 'header').top, expected);
          final scroll = tester.widget<SingleChildScrollView>(homeScrollView());
          expect(scroll.padding, EdgeInsets.only(top: expected, bottom: 140));
        },
      );
    }

    // Neste SDK o toque na status bar do iOS chega como a mensagem "handleScrollToTop" do canal
    // SystemChannels.statusBar (não mais como toque em Offset.zero); o Scaffold a trata e anima o
    // PrimaryScrollController — `primary: true` sozinho não faz isso.
    testWidgets(
      'iOS: toque na status bar (handleScrollToTop) rola a Início para o topo (motivo do Scaffold)',
      (tester) async {
        setCanvasView(
          tester,
          logical: const Size(390, 844),
          safeTop: 47,
          safeBottom: 34,
        );
        await pumpApp(tester);
        await tester.drag(homeScrollView(), const Offset(0, -800));
        await tester.pumpAndSettle();
        expect(homeScrollPosition(tester).pixels, greaterThan(700));
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          SystemChannels.statusBar.name,
          SystemChannels.statusBar.codec.encodeMethodCall(
            const MethodCall('handleScrollToTop'),
          ),
          (_) {},
        );
        await tester.pumpAndSettle();
        expect(homeScrollPosition(tester).pixels, 0);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  });

  group('2.8 aparelho 390×844 (safe 47/34)', () {
    testWidgets('header em 62 e nav em 744 = 844 − 30 − 70 (D-02)', (
      tester,
    ) async {
      setCanvasView(
        tester,
        logical: const Size(390, 844),
        safeTop: 47,
        safeBottom: 34,
      );
      await pumpApp(tester);
      expect(_rect(tester, 'header'), const Rect.fromLTWH(20, 62, 350, 48));
      expect(_rect(tester, 'nav'), const Rect.fromLTWH(16, 744, 358, 70));
      expect(
        _rect(tester, 'bottomFade'),
        const Rect.fromLTWH(0, 694, 390, 150),
      );
      debugPrint(
        '[aparelho] header.y = ${_rect(tester, 'header').top} | nav.y = ${_rect(tester, 'nav').top}',
      );
    });

    testWidgets(
      'rolagem até o fim (extensão total 2612,12) com a nav fixa em 744',
      (tester) async {
        setCanvasView(
          tester,
          logical: const Size(390, 844),
          safeTop: 47,
          safeBottom: 34,
        );
        await pumpApp(tester);
        final position = homeScrollPosition(tester);
        expect(position.viewportDimension, 844);
        expect(
          position.maxScrollExtent + position.viewportDimension,
          moreOrLessEquals(_fim, epsilon: _arredondamento),
        );

        // No meio da rolagem a nav não se move.
        await tester.drag(homeScrollView(), const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(position.pixels, greaterThan(600));
        expect(_rect(tester, 'nav').top, 744);

        // Até o fim.
        for (var i = 0; i < 4; i++) {
          await tester.drag(homeScrollView(), const Offset(0, -700));
          await tester.pumpAndSettle();
        }
        expect(position.pixels, position.maxScrollExtent);
        expect(
          position.pixels,
          moreOrLessEquals(_fim - 844, epsilon: _arredondamento),
        );
        // O último bloco termina 140 px acima da borda inferior; a nav continua em 744.
        expect(
          _rect(tester, 'recent').bottom,
          moreOrLessEquals(844 - 140, epsilon: 1e-9),
        );
        expect(_rect(tester, 'nav'), const Rect.fromLTWH(16, 744, 358, 70));
        debugPrint(
          '[rolagem] extensão total ${position.maxScrollExtent + position.viewportDimension} | '
          'fim em ${position.pixels} | recent.bottom ${_rect(tester, 'recent').bottom} | '
          'nav.y ${_rect(tester, 'nav').top}',
        );
      },
    );
  });
}

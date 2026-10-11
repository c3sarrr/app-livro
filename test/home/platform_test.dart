import 'dart:async';

import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// Aparelho 390×844 com as áreas seguras do iPhone (47/34).
void _device(WidgetTester tester) => setCanvasView(
  tester,
  logical: const Size(390, 844),
  safeTop: 47,
  safeBottom: 34,
);

/// Chamadas ao canal de plataforma do sistema (SystemChrome) durante o teste.
List<MethodCall> _mockPlatformChannel() {
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    calls.add(call);
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return calls;
}

/// O Flutter só reenvia o estilo quando ele muda (estado estático do SystemChrome): parte de um estilo DIFERENTE para
/// que o do app seja sempre enviado, e devolve só as chamadas feitas depois dele.
Future<List<Map<Object?, Object?>>> _styleCallsAfterPump(
  WidgetTester tester,
  List<MethodCall> calls,
) async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await tester.idle(); // a chamada ao canal sai num microtask: espera sair antes de marcar o começo
  final start = calls.length;
  await pumpApp(tester);
  return [
    for (final c in calls.skip(start))
      if (c.method == 'SystemChrome.setSystemUIOverlayStyle')
        c.arguments as Map<Object?, Object?>,
  ];
}

/// F12 12.5 — comportamento de sistema: edge-to-edge, status bar, barra de navegação, toque na status bar e
/// física de rolagem de cada plataforma.
void main() {
  setUpAll(loadAppFonts);

  group('12.5 estilo das barras do sistema (D-13)', () {
    testWidgets(
      'o estilo ENVIADO ao sistema: status bar transparente com ícones escuros (Android) / conteúdo escuro (iOS); barra de navegação transparente, ícones escuros, SEM scrim',
      (tester) async {
        final calls = _mockPlatformChannel();
        _device(tester);
        final styles = await _styleCallsAfterPump(tester, calls);
        expect(styles, isNotEmpty);
        final style = styles.last;
        debugPrint(
          '[plataforma] SystemChrome.setSystemUIOverlayStyle → $style',
        );
        expect(style['statusBarColor'], 0, reason: 'status bar transparente');
        expect(style['statusBarIconBrightness'], 'Brightness.dark');
        expect(
          style['statusBarBrightness'],
          'Brightness.light',
        ); // iOS: texto escuro
        expect(
          style['systemNavigationBarColor'],
          0,
          reason: 'barra transparente',
        );
        expect(style['systemNavigationBarIconBrightness'], 'Brightness.dark');
        expect(
          style['systemNavigationBarContrastEnforced'],
          false,
          reason: 'sem scrim translúcido atrás dos botões de navegação',
        );
      },
    );

    testWidgets(
      'o mesmo estilo vale em TODAS as rotas: abas, Scanner (tela cheia), destinos empilhados e a galeria /_ds — nenhuma troca o estilo',
      (tester) async {
        final calls = _mockPlatformChannel();
        _device(tester);
        final first = await _styleCallsAfterPump(tester, calls);
        expect(first, hasLength(1), reason: 'o app envia o estilo uma vez');
        final start = calls.length;
        for (final path in [
          AppRoutes.biblioteca,
          AppRoutes.clubes,
          AppRoutes.perfil,
          AppRoutes.inicio,
        ]) {
          _router(tester).go(path);
          await tester.pumpAndSettle();
        }
        for (final path in [
          AppRoutes.scanner,
          AppRoutes.notificacoes,
          AppRoutes.livro('dom-casmurro'),
          AppRoutes.designSystem,
        ]) {
          unawaited(_router(tester).push<void>(path));
          await tester.pumpAndSettle();
          // A tela cheia não tem Scaffold/AppBar do Material que mude o estilo.
          expect(
            find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
            findsAtLeastNWidgets(1),
            reason: path,
          );
          expect(_router(tester).state.uri.path, path);
          _router(tester).pop();
          await tester.pumpAndSettle();
        }
        // Nenhuma navegação mudou o estilo: não foi enviado nada diferente depois do primeiro.
        final styles = {
          for (final c in calls.skip(start))
            if (c.method == 'SystemChrome.setSystemUIOverlayStyle')
              c.arguments.toString(),
        };
        expect(styles, isEmpty, reason: 'estilos novos: $styles');
      },
    );

    testWidgets(
      'a região anotada está na RAIZ do app (cobre as rotas fora do shell) com o mesmo estilo do shell',
      (tester) async {
        _device(tester);
        await pumpApp(tester);
        final regions = tester
            .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
              find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
            )
            .toList();
        expect(regions, isNotEmpty);
        for (final r in regions) {
          expect(r.value, MainShell.overlayStyle);
        }
        // Uma região envolve o Navigator inteiro (ancestral do shell e das telas cheias); a do shell é descendente.
        expect(
          find.ancestor(
            of: find.byType(MainShell, skipOffstage: false),
            matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MainShell),
            matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('12.5 edge-to-edge', () {
    testWidgets(
      'o conteúdo passa sob as barras do sistema: o fade cobre a faixa de baixo até a borda da tela (sob a barra de gestos) e o topo da Início usa o inset da status bar (D-02)',
      (tester) async {
        _device(tester);
        await pumpApp(tester);
        // O fade termina na borda inferior da TELA (844), não na área segura (810).
        expect(_rect(tester, 'bottomFade').bottom, 844);
        // A barra flutuante fica 30 acima da borda (iPhone com barra de início: 34 − 4 < 30).
        expect(_rect(tester, 'nav').bottom, 844 - 30);
        // O conteúdo começa em y = 62 (≥ status bar 47 + 15), desenhado desde o topo da tela.
        expect(_rect(tester, 'header').top, 62);
        expect(
          tester.getRect(find.byType(MainShell)),
          const Rect.fromLTWH(0, 0, 390, 844),
        );
        expect(
          tester.getRect(find.byType(Scaffold)),
          const Rect.fromLTWH(0, 0, 390, 844),
        );
      },
    );
  });

  group('12.5 toque na status bar do iOS (Scaffold da HomeScreen)', () {
    testWidgets(
      'iOS 390×844: rolar 800 e tocar na status bar (handleScrollToTop) volta a rolagem a 0 — quem trata é o Scaffold; `primary: true` alimenta o PrimaryScrollController',
      (tester) async {
        _device(tester);
        await pumpApp(tester);
        expect(defaultTargetPlatform, TargetPlatform.iOS);
        // A faixa da status bar só existe com altura > 0 (safe top 47) e Scaffold iOS.
        expect(
          MediaQuery.viewPaddingOf(tester.element(find.byType(HomeScreen))).top,
          47,
        );
        expect(
          tester.widget<SingleChildScrollView>(homeScrollView()).primary,
          isTrue,
        );
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
        // Mesmo caminho com a Início de volta de outra aba (a rolagem pertence ao PrimaryScrollController da aba).
        await tester.drag(homeScrollView(), const Offset(0, -500));
        await tester.pumpAndSettle();
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

  group('12.5 física de rolagem de cada plataforma, sem mudar o repouso', () {
    testWidgets(
      'Android: clamping + indicador "stretch"; iOS: bounce (sem indicador). O repouso (offset 0) é o mesmo nas duas',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        final position = homeScrollPosition(tester);
        final android = defaultTargetPlatform == TargetPlatform.android;
        if (android) {
          expect(position.physics, isA<ClampingScrollPhysics>());
          expect(
            find.descendant(
              of: find.byType(HomeScreen),
              matching: find.byType(StretchingOverscrollIndicator),
            ),
            findsWidgets,
          );
        } else {
          expect(position.physics, isA<BouncingScrollPhysics>());
          expect(
            find.descendant(
              of: find.byType(HomeScreen),
              matching: find.byType(StretchingOverscrollIndicator),
            ),
            findsNothing,
          );
        }
        // Repouso: a mesma geometria nas duas plataformas.
        expect(position.pixels, 0);
        expect(_rect(tester, 'header'), const Rect.fromLTWH(20, 62, 350, 48));
        expect(_rect(tester, 'nav'), const Rect.fromLTWH(16, 2550, 358, 70));
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );

    testWidgets(
      'puxar além do topo: iOS estica (pixels < 0 e volta a 0 ao soltar); Android não passa de 0 (o stretch é visual) — e ao soltar tudo volta ao repouso',
      (tester) async {
        _device(tester);
        await pumpApp(tester);
        final position = homeScrollPosition(tester);
        final g = await tester.startGesture(const Offset(195, 300));
        await g.moveBy(const Offset(0, 120));
        await tester.pump();
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          expect(position.pixels, lessThan(0), reason: 'bounce');
        } else {
          expect(position.pixels, 0, reason: 'clamping');
        }
        await g.up();
        await tester.pumpAndSettle();
        expect(position.pixels, 0);
        expect(_rect(tester, 'header').top, 62);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );
  });
}

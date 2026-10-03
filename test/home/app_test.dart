import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:app_leitura/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

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

/// Exatamente uma chamada de cada, nesta ordem (o `Title` do MaterialApp faz outras chamadas ao canal).
void _expectSystemUiCalls(List<MethodCall> calls) {
  const methods = {
    'SystemChrome.setEnabledSystemUIMode',
    'SystemChrome.setPreferredOrientations',
  };
  final chrome = calls.where((c) => methods.contains(c.method)).toList();
  expect(chrome.map((c) => c.method), [
    'SystemChrome.setEnabledSystemUIMode',
    'SystemChrome.setPreferredOrientations',
  ]);
  expect(chrome[0].arguments, 'SystemUiMode.edgeToEdge');
  expect(chrome[1].arguments, ['DeviceOrientation.portraitUp']);
}

void main() {
  setUpAll(loadAppFonts);

  group('2.5 App', () {
    testWidgets(
      'MaterialApp.router sem banner de debug; tema mínimo: M3, fundo papel, NoSplash, sem realce/hover',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        await pumpApp(tester);
        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.debugShowCheckedModeBanner, isFalse);
        expect(materialApp.routerConfig, isA<GoRouter>());
        expect(find.byType(CheckedModeBanner), findsNothing);
        final theme = Theme.of(tester.element(find.byType(HomeScreen)));
        expect(theme.useMaterial3, isTrue);
        expect(theme.scaffoldBackgroundColor, AppColors.paper);
        expect(theme.splashFactory, same(NoSplash.splashFactory));
        expect(theme.highlightColor.toARGB32(), 0x00000000);
        expect(theme.hoverColor.toARGB32(), 0x00000000);
      },
    );

    testWidgets('escala de texto do sistema travada em 1,0 (D-05)', (
      tester,
    ) async {
      setCanvasView(tester, logical: const Size(390, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester);
      // Controle: o sistema pede 2×; o MediaQuery de fora do builder repassa isso…
      final outer = tester
          .widgetList<MediaQuery>(find.byType(MediaQuery))
          .first
          .data
          .textScaler;
      expect(outer.scale(10), 20);
      // …e dentro do app a escala é 1,0 (sem escala), inclusive nas telas.
      for (final type in [MainShell, HomeScreen]) {
        final scaler = MediaQuery.textScalerOf(
          tester.element(find.byType(type)),
        );
        expect(scaler, TextScaler.noScaling);
        expect(scaler.scale(10), 10);
      }
    });

    testWidgets(
      'DefaultTextHeightBehavior "even" e DefaultTextStyle = corpo do arquivo (Figtree 16/400, tinta)',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        await pumpApp(tester);
        final ctx = tester.element(find.byType(MainShell));
        expect(
          DefaultTextHeightBehavior.maybeOf(ctx)?.leadingDistribution,
          TextLeadingDistribution.even,
        );
        final style = DefaultTextStyle.of(ctx).style;
        expect(style.fontFamily, 'Figtree');
        expect(style.fontFamilyFallback, ['FigtreeExt']);
        expect(style.fontSize, 16);
        expect(style.fontWeight, FontWeight.w400);
        expect(style.height, 1.2);
        expect(style.color, AppColors.ink);
        expect(style.leadingDistribution, TextLeadingDistribution.even);
      },
    );

    testWidgets('App.forTests() começa em /inicio', (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await pumpApp(tester);
      final router = GoRouter.of(tester.element(find.byType(MainShell)));
      expect(router.state.uri.path, '/inicio');
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('2.5 main.dart', () {
    test(
      'configureSystemUi(): edge-to-edge (D-13) e somente retrato (D-06)',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final calls = _mockPlatformChannel();
        await app.configureSystemUi();
        _expectSystemUiCalls(calls);
      },
    );

    testWidgets(
      'main(): licença OFL, edge-to-edge + retrato e ProviderScope(App) abrindo na Início',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        final calls = _mockPlatformChannel();
        LicenseRegistry.reset();
        addTearDown(LicenseRegistry.reset);
        // F12 12.4: o main() pré-carrega os SVGs (E/S real) antes do runApp → precisa rodar fora do FakeAsync.
        svg.cache.clear();
        await tester.runAsync(app.main);
        await tester.pumpAndSettle();
        _expectSystemUiCalls(calls);
        // Os 18 SVGs do arquivo já estão no cache do flutter_svg quando a primeira tela aparece.
        for (final asset in AppIcons.all) {
          final loader = SvgAssetLoader(asset);
          var loadedAgain = false;
          await svg.cache.putIfAbsent(loader.cacheKey(null), () {
            loadedAgain = true;
            return loader.loadBytes(null);
          });
          expect(loadedAgain, isFalse, reason: '$asset deveria estar em cache');
        }
        final licenses = await tester.runAsync(
          () => LicenseRegistry.licenses.toList(),
        );
        expect(licenses!.single.packages, app.kFontLicensePackages);
        expect(
          find.ancestor(
            of: find.byType(App),
            matching: find.byType(ProviderScope),
          ),
          findsOneWidget,
        );
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(
          GoRouter.of(tester.element(find.byType(MainShell))).state.uri.path,
          '/inicio',
        );
      },
    );
  });
}

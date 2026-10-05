import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/scanner/presentation/scanner_camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import 'fake_scanner_camera.dart';
import 'precache_svgs.dart';

/// Monta o app real (`ProviderScope` + `App.forTests()`, que começa em `/inicio`) e espera assentar.
/// Chame `setCanvasView` antes (canvas 390×2390 ou aparelho).
Future<void> pumpApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
  ScannerCamera Function()? scannerCamera,
}) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...overridesDoMundo,
        // o scanner abre por cima das abas: nos testes, sem o plugin da câmera
        scannerCameraProvider.overrideWithValue(
          scannerCamera ?? FakeScannerCamera.new,
        ),
        ...overrides,
      ],
      child: const App.forTests(),
    ),
  );
  await tester.pumpAndSettle();
}

/// A rolagem da Início: o `SingleChildScrollView` mais externo da HomeScreen (o primeiro na ordem da árvore).
/// Desde a F08 a tela tem uma segunda rolagem, DENTRO dela: o carrossel horizontal de "Para você"
/// (`forYou.carousel`, D-03). Sem filtrar por direção/`primary`, os asserts sobre eles continuam valendo.
Finder homeScrollView({bool skipOffstage = true}) => find
    .descendant(
      of: find.byType(HomeScreen, skipOffstage: skipOffstage),
      matching: find.byType(SingleChildScrollView, skipOffstage: skipOffstage),
    )
    .first;

/// Posição de rolagem da Início (o `SingleChildScrollView` primário da aba), mesmo com a aba fora da tela: o
/// `Scrollable` mais externo da HomeScreen (o do carrossel, desde a F08, fica dentro dele).
ScrollPosition homeScrollPosition(WidgetTester tester) => tester
    .state<ScrollableState>(
      find
          .descendant(
            of: find.byType(HomeScreen, skipOffstage: false),
            matching: find.byType(Scrollable, skipOffstage: false),
          )
          .first,
    )
    .position;

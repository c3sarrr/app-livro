import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'precache_svgs.dart';

/// Monta o app real (`ProviderScope` + `App.forTests()`, que começa em `/inicio`) e espera assentar.
/// Chame `setCanvasView` antes (canvas 390×2390 ou aparelho).
Future<void> pumpApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const App.forTests()),
  );
  await tester.pumpAndSettle();
}

/// Posição de rolagem da Início (o `SingleChildScrollView` primário da aba), mesmo com a aba fora da tela.
ScrollPosition homeScrollPosition(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byType(HomeScreen, skipOffstage: false),
        matching: find.byType(Scrollable, skipOffstage: false),
      ),
    )
    .position;

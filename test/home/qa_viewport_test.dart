import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// F13 · 13.2 — num aparelho 390 × 844 (safe 47/34), rolando até o fim: rolagem máxima = 2355,16 − 844 =
/// 1511,16; a lista termina em y = 704 na tela, 19,5 px acima do topo do FAB (723,5) e 40 px acima da barra (744).
/// Grava o print do estado final em `build/visual_diff/F13/viewport_fim_da_rolagem@3x.png`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '13.2 rolagem ao fim: 1511,16 · lista em y 704 · 19,5 px do FAB · 40 px da barra',
    (tester) async {
      setCanvasView(
        tester,
        logical: const Size(390, 844),
        safeTop: 47,
        safeBottom: 34,
      );
      await precacheSvgs(tester, AppIcons.all);
      await tester.pumpWidget(
        const ProviderScope(
          child: RepaintBoundary(key: goldenRootKey, child: App.forTests()),
        ),
      );
      await tester.pumpAndSettle();

      final position = homeScrollPosition(tester);
      // Altura do conteúdo: o fim da lista (2215,16) + 140 px de respiro = 2355,16.
      expect(position.viewportDimension, 844);
      expect(
        position.maxScrollExtent,
        moreOrLessEquals(2355.16 - 844, epsilon: 1e-3),
      );
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(position.pixels, position.maxScrollExtent);

      final list = tester.getRect(find.byKey(const ValueKey('recent.list')));
      final fab = tester.getRect(find.byKey(const ValueKey('nav.scanner.fab')));
      final nav = tester.getRect(find.byKey(const ValueKey('nav')));
      expect(list.bottom, moreOrLessEquals(704, epsilon: 1e-3));
      expect(fab.top, 723.5);
      expect(nav.top, 744);
      expect(fab.top - list.bottom, moreOrLessEquals(19.5, epsilon: 1e-3));
      expect(nav.top - list.bottom, moreOrLessEquals(40, epsilon: 1e-3));
      debugPrint(
        '[F13 rolagem] maxScrollExtent ${position.maxScrollExtent.toStringAsFixed(3)} (esperado 1511,16) | '
        'recent.list.bottom ${list.bottom.toStringAsFixed(3)} (esperado 704) | fab.top ${fab.top} | nav.top ${nav.top} | '
        'folga lista→FAB ${(fab.top - list.bottom).toStringAsFixed(3)} (esperado 19,5) | '
        'folga lista→barra ${(nav.top - list.bottom).toStringAsFixed(3)} (esperado 40)',
      );

      // Print do estado final (@3x = 1170×2532).
      final image = await captureAt(tester, find.byKey(goldenRootKey));
      expect((image.width, image.height), (1170, 2532));
      final png = await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      );
      await tester.runAsync(() async {
        final file = File(
          'build/visual_diff/F13/viewport_fim_da_rolagem@3x.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(png!.buffer.asUint8List());
      });
    },
  );
}

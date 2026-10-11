import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/core/design_system/painters/top_border_crescent_painter.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/presentation/debug/design_system_screen.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

ProviderContainer _container(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(MainShell, skipOffstage: false)),
);

Finder _key(String id) => find.byKey(ValueKey<String>(id));

/// Cor de preenchimento do gráfico (barra `i`): o pintor da meia-lua dentro do `…fill`.
Color _barFill(WidgetTester tester, int i) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: _key('today.week.bar$i.fill'),
      matching: find.byType(CustomPaint),
    ),
  );
  return (paint.painter! as TopBorderCrescentPainter).fill;
}

Color _heroColor(WidgetTester tester) =>
    tester.widget<NeoBox>(_key('hero')).color!;

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';

/// F12 12.3 — o tema (D-11): padrão de produção, seletor da galeria `/_ds` (debug) e efeito nas regiões.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '12.3 produção usa o padrão #B6ACE4 em brand e weekColor; as opções do arquivo são 4 e 4',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(
        _container(tester).read(homeThemeProvider).brand,
        AppColors.lavender,
      );
      expect(
        _container(tester).read(homeThemeProvider).weekColor,
        AppColors.lavender,
      );
      expect(_heroColor(tester), const Color(0xFFB6ACE4));
      for (var i = 0; i < 6; i++) {
        expect(
          _barFill(tester, i),
          const Color(0xFFB6ACE4),
          reason: 'barra $i',
        );
      }
      expect(_barFill(tester, 6), AppColors.flame); // hoje: sempre #FF552E
      expect(AppColors.brandOptions, hasLength(4));
      expect(AppColors.weekColorOptions, hasLength(4));
      expect(AppColors.brandOptions.first, const Color(0xFFB6ACE4));
      expect(AppColors.weekColorOptions.first, const Color(0xFFB6ACE4));
    },
  );

  testWidgets(
    '12.3 em kDebugMode a rota /_ds mostra o seletor com as 4 opções de brand e as 4 de weekColor, e a galeria embaixo',
    (tester) async {
      expect(kDebugMode, isTrue);
      setCanvasView(
        tester,
        logical: const Size(390, 844),
        safeTop: 47,
        safeBottom: 34,
      );
      await pumpApp(tester);
      unawaited(_router(tester).push<void>(AppRoutes.designSystem));
      await tester.pumpAndSettle();
      expect(find.byType(DesignSystemScreen), findsOneWidget);
      expect(find.byType(HomeThemeSelector), findsOneWidget);
      for (final name in ['brand', 'weekColor']) {
        for (var i = 0; i < 4; i++) {
          expect(_key('ds.theme.$name.$i'), findsOneWidget, reason: '$name $i');
        }
        expect(find.byKey(ValueKey('ds.theme.$name.4')), findsNothing);
      }
      // Golden do seletor (UI de debug nova), com as opções padrão marcadas.
      await expectLater(
        await captureAt(tester, find.byType(HomeThemeSelector)),
        matchesGoldenFile('../golden/goldens/ds_tema_seletor@3x.png'),
      );
      // O seletor fica fixo no topo; a galeria rola embaixo dele.
      final selector = tester.getRect(find.byType(HomeThemeSelector));
      final gallery = tester.getRect(find.byType(SingleChildScrollView).first);
      expect(selector.top, greaterThanOrEqualTo(47));
      expect(gallery.top, greaterThanOrEqualTo(selector.bottom));
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(HomeThemeSelector)), selector);
    },
  );

  testWidgets(
    '12.3 tocar numa opção troca só aquela prop (brand ≠ weekColor), marca a opção como selecionada e, ao voltar, a Início está com as cores escolhidas (hero, pílula ativa, barras 0–5; a de hoje não muda)',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);
      unawaited(_router(tester).push<void>(AppRoutes.designSystem));
      await tester.pumpAndSettle();

      Tristate selected(String id) =>
          tester.getSemantics(_key(id)).flagsCollection.isSelected;

      for (final (i, brand) in AppColors.brandOptions.indexed) {
        await tester.tap(_key('ds.theme.brand.$i'));
        await tester.pumpAndSettle();
        final theme = _container(tester).read(homeThemeProvider);
        expect(theme.brand, brand, reason: 'brand $i');
        expect(
          theme.weekColor,
          AppColors.lavender,
          reason: 'weekColor intacto',
        );
        for (var j = 0; j < 4; j++) {
          expect(
            selected('ds.theme.brand.$j'),
            j == i ? Tristate.isTrue : Tristate.isFalse,
            reason: 'brand $i → opção $j',
          );
        }
        expect(
          tester.getSemantics(_key('ds.theme.brand.$i')).label,
          contains(_hex(brand)),
        );
      }
      for (final (i, color) in AppColors.weekColorOptions.indexed) {
        await tester.tap(_key('ds.theme.weekColor.$i'));
        await tester.pumpAndSettle();
        final theme = _container(tester).read(homeThemeProvider);
        expect(theme.weekColor, color, reason: 'weekColor $i');
        expect(
          theme.brand,
          AppColors.brandOptions.last,
          reason: 'brand intacto',
        );
        for (var j = 0; j < 4; j++) {
          expect(
            selected('ds.theme.weekColor.$j'),
            j == i ? Tristate.isTrue : Tristate.isFalse,
            reason: 'weekColor $i → opção $j',
          );
        }
      }

      // Volta à Início (a rota /_ds fica por cima do shell): as cores escolhidas valem para a tela.
      _router(tester).pop();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(_heroColor(tester), AppColors.brandOptions.last);
      for (var i = 0; i < 6; i++) {
        expect(_barFill(tester, i), AppColors.weekColorOptions.last);
      }
      expect(_barFill(tester, 6), AppColors.flame);
      semantics.dispose();
    },
  );
}

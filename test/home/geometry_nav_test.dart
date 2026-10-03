import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:app_leitura/features/shell/presentation/bottom_fade.dart';
import 'package:app_leitura/features/shell/presentation/floating_nav_bar.dart';
import 'package:app_leitura/features/shell/presentation/scanner_fab.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

Rect _rect(WidgetTester tester, String id) =>
    tester.getRect(find.byKey(ValueKey<String>(id)));

/// A tabela da F11 usa a origem da seção `nav` (16; 2290); o fade, a da seção `bottomFade` (0; 2240).
Rect _rel(WidgetTester tester, String id, Offset origin) =>
    _rect(tester, id).shift(-origin);

const _navOrigin = Offset(16, 2290);
const _fadeOrigin = Offset(0, 2240);

/// Tabela "Especificação pixel a pixel — navegação" da F11 (x, y, w, h relativos à seção `nav`).
const _navTable = [
  ('nav', 0.0, 0.0, 358.0, 70.0),
  ('nav.home', 9.5, 9.5, 64.6, 51.0),
  ('nav.home.icon', 30.8, 15.9, 22.0, 22.0),
  ('nav.home.label', 28.01, 40.9, 27.59, 13.2),
  ('nav.library', 78.1, 9.5, 64.6, 51.0),
  ('nav.library.icon', 99.4, 15.9, 22.0, 22.0),
  ('nav.library.label', 85.5, 40.9, 49.79, 13.2),
  ('nav.scanner', 146.7, 9.5, 64.6, 51.0),
  ('nav.scanner.fab', 149.0, -20.5, 60.0, 60.0),
  ('nav.scanner.icon', 165.0, -4.5, 28.0, 28.0),
  ('nav.scanner.label', 158.35, 45.3, 41.3, 15.2),
  ('nav.clubs', 215.3, 9.5, 64.6, 51.0),
  ('nav.clubs.icon', 236.6, 15.9, 22.0, 22.0),
  ('nav.clubs.label', 230.37, 40.9, 34.45, 13.2),
  ('nav.profile', 283.9, 9.5, 64.6, 51.0),
  ('nav.profile.icon', 305.2, 15.9, 22.0, 22.0),
  ('nav.profile.label', 303.18, 40.9, 26.05, 13.2),
];

/// Larguras de texto: as fontes estáticas foram validadas contra o navegador com desvio ≤ 0,05 px (§6.1).
const _eps = 0.05;

/// F11 — camada 1 (geometria), construção e posição no aparelho.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F11 geometria: os 18 ids (17 da seção nav + bottomFade) dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = [...idsOfSection('nav'), ...idsOfSection('bottomFade')];
      expect(ids, [for (final row in _navTable) row.$1, 'bottomFade']);
      expect(ids, hasLength(18));
      expectGeometry(tester, ids);
      reportGeometry(tester, ids);
    },
  );

  testWidgets(
    'posições da tabela da F11 relativas à seção (17 linhas da nav + o fade, ≤ 0,05 px)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      var worst = ('', 0.0);
      for (final (id, x, y, w, h) in _navTable) {
        final got = _rel(tester, id, _navOrigin);
        for (final (what, g, e) in [
          ('x', got.left, x),
          ('y', got.top, y),
          ('w', got.width, w),
          ('h', got.height, h),
        ]) {
          final d = (g - e).abs();
          if (d > worst.$2) worst = ('$id.$what', d);
          expect(g, moreOrLessEquals(e, epsilon: _eps), reason: '$id.$what');
        }
      }
      expect(
        _rel(tester, 'bottomFade', _fadeOrigin),
        const Rect.fromLTWH(0, 0, 390, 150),
      );
      debugPrint(
        '[tabela F11] 17 linhas da nav + fade; maior desvio ${worst.$1} = ${worst.$2.toStringAsFixed(4)}',
      );
    },
  );

  testWidgets(
    '11.2 grade: 5 colunas iguais de 64,6 com gap 4 e altura 51 (conteúdo = 358 − 2×(1,5 + 8) = 339 × 51); o FAB sobe 20,5 px acima da borda superior da barra',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final items = [
        'nav.home',
        'nav.library',
        'nav.scanner',
        'nav.clubs',
        'nav.profile',
      ];
      final rects = [for (final id in items) _rect(tester, id)];
      for (final (i, r) in rects.indexed) {
        expect(
          r.width,
          moreOrLessEquals(64.6, epsilon: 1e-9),
          reason: items[i],
        );
        expect(r.height, 51, reason: items[i]);
        expect(r.top, 2299.5, reason: items[i]);
        if (i > 0) {
          expect(
            r.left - rects[i - 1].right,
            moreOrLessEquals(4, epsilon: 1e-9),
            reason: 'gap antes de ${items[i]}',
          );
        }
      }
      expect(rects.first.left, 16 + 1.5 + 8);
      expect(rects.last.right, moreOrLessEquals(374 - 1.5 - 8, epsilon: 1e-9));
      final nav = _rect(tester, 'nav');
      final fab = _rect(tester, 'nav.scanner.fab');
      expect(nav.top - fab.top, 20.5);
      expect(
        fab.center.dx,
        195,
      ); // centro horizontal da tela = centro do item do meio
      expect(rects[2].center.dx, moreOrLessEquals(195, epsilon: 1e-9));
      // O ícone do FAB fica centrado no círculo (60 − 28) / 2 = 16.
      expect(
        _rect(tester, 'nav.scanner.icon').topLeft - fab.topLeft,
        const Offset(16, 16),
      );
    },
  );

  testWidgets(
    'construção: Key nav na barra (NeoBox 358×70 com padding 8), 5 `Expanded` num `Row(spacing 4, stretch)`; ícones 22 / FAB 60 com ícone 28; tipos dos widgets sob as Keys',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(find.byType(FloatingNavBar), findsOneWidget);
      expect(find.byType(ScannerFab), findsOneWidget);
      expect(find.byType(BottomFade), findsOneWidget);
      final neo = tester.widget<NeoBox>(
        find
            .descendant(
              of: find.byKey(const ValueKey('nav')),
              matching: find.byType(NeoBox),
            )
            .first,
      );
      expect(neo.padding, const EdgeInsets.all(8));
      expect(neo.clip, isFalse);
      final row = tester.widget<Row>(
        find
            .descendant(
              of: find.byKey(const ValueKey('nav')),
              matching: find.byType(Row),
            )
            .first,
      );
      expect(row.spacing, 4);
      expect(row.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(row.children, hasLength(5));
      expect(row.children.every((c) => c is Expanded), isTrue);
      // Todo item de navegação é um `Pressable` (a Key fica nele = retângulo do `<a>`).
      for (final id in [
        'nav.home',
        'nav.library',
        'nav.scanner',
        'nav.clubs',
        'nav.profile',
      ]) {
        expect(
          tester.widget(find.byKey(ValueKey(id))),
          isA<Pressable>(),
          reason: id,
        );
      }
      // Ícones 22 (e 28 no FAB), rótulos em AppText.
      for (final id in ['home', 'library', 'clubs', 'profile']) {
        expect(
          tester.widget<AppSvg>(find.byKey(ValueKey('nav.$id.icon'))).size,
          22,
          reason: id,
        );
        expect(
          find.descendant(
            of: find.byKey(ValueKey('nav.$id.label')),
            matching: find.byType(AppText),
            matchRoot: true,
          ),
          findsOneWidget,
        );
      }
      expect(
        tester
            .widget<AppSvg>(find.byKey(const ValueKey('nav.scanner.icon')))
            .size,
        28,
      );
      // O rótulo do Scanner é uma caixa de 41,3 × 15,2 (texto 13,2 + padding-bottom 2) com o AppText dentro.
      final label = tester.widget<Padding>(
        find.byKey(const ValueKey('nav.scanner.label')),
      );
      expect(label.padding, const EdgeInsets.only(bottom: 2));
      // O ícone do Scanner está DENTRO do FAB (e não no item).
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('nav.scanner.fab')),
          matching: find.byKey(const ValueKey('nav.scanner.icon')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('nav.scanner')),
          matching: find.byKey(const ValueKey('nav.scanner.icon')),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    '11.1 fade: 390×150 colado na base do canvas (y 2240); `FloatingNavBar` em y 2290 e FAB em y 2269,5 — mesmas coordenadas da tabela',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(
        _rect(tester, 'bottomFade'),
        const Rect.fromLTWH(0, 2240, 390, 150),
      );
      expect(_rect(tester, 'nav'), const Rect.fromLTWH(16, 2290, 358, 70));
      expect(
        _rect(tester, 'nav.scanner.fab'),
        const Rect.fromLTWH(165, 2269.5, 60, 60),
      );
    },
  );

  group('aparelho 390×844 (safe 47/34)', () {
    void device(WidgetTester tester, {double safeBottom = 34}) => setCanvasView(
      tester,
      logical: const Size(390, 844),
      safeTop: 47,
      safeBottom: safeBottom,
    );

    testWidgets('nav em y 744 e FAB em y 723,5; fade em 694', (tester) async {
      device(tester);
      await pumpApp(tester);
      expect(_rect(tester, 'nav'), const Rect.fromLTWH(16, 744, 358, 70));
      expect(
        _rect(tester, 'nav.scanner.fab'),
        const Rect.fromLTWH(165, 723.5, 60, 60),
      );
      expect(
        _rect(tester, 'bottomFade'),
        const Rect.fromLTWH(0, 694, 390, 150),
      );
      // Os itens e rótulos seguem a barra (aparelho = canvas deslocado em y).
      for (final (id, x, y, w, h) in _navTable) {
        final got = _rel(tester, id, const Offset(16, 744));
        expect(got.left, moreOrLessEquals(x, epsilon: _eps), reason: '$id.x');
        expect(got.top, moreOrLessEquals(y, epsilon: _eps), reason: '$id.y');
        expect(got.width, moreOrLessEquals(w, epsilon: _eps), reason: '$id.w');
        expect(got.height, moreOrLessEquals(h, epsilon: _eps), reason: '$id.h');
      }
      debugPrint(
        '[aparelho] nav.y = ${_rect(tester, 'nav').top} | fab.y = ${_rect(tester, 'nav.scanner.fab').top}',
      );
    });

    testWidgets(
      'após rolar até o fim (e no meio), nav, FAB e fade ficam no mesmo lugar (fixos — D-01)',
      (tester) async {
        device(tester);
        await pumpApp(tester);
        const navRect = Rect.fromLTWH(16, 744, 358, 70);
        const fabRect = Rect.fromLTWH(165, 723.5, 60, 60);
        const fadeRect = Rect.fromLTWH(0, 694, 390, 150);
        await tester.drag(homeScrollView(), const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(homeScrollPosition(tester).pixels, greaterThan(600));
        expect(_rect(tester, 'nav'), navRect);
        expect(_rect(tester, 'nav.scanner.fab'), fabRect);
        for (var i = 0; i < 3; i++) {
          await tester.drag(homeScrollView(), const Offset(0, -700));
          await tester.pumpAndSettle();
        }
        final position = homeScrollPosition(tester);
        expect(position.pixels, position.maxScrollExtent);
        expect(_rect(tester, 'nav'), navRect);
        expect(_rect(tester, 'nav.scanner.fab'), fabRect);
        expect(_rect(tester, 'bottomFade'), fadeRect);
        debugPrint(
          '[rolagem] fim em ${position.pixels} | nav.y ${_rect(tester, 'nav').top} | '
          'fab.y ${_rect(tester, 'nav.scanner.fab').top}',
        );
      },
    );

    testWidgets(
      'D-02: bottom = max(30, viewPadding.bottom − 4) — com safe 48 a barra sobe para 44 e o FAB a acompanha (20,5 acima)',
      (tester) async {
        device(tester, safeBottom: 48);
        await pumpApp(tester);
        expect(_rect(tester, 'nav'), const Rect.fromLTWH(16, 730, 358, 70));
        expect(
          _rect(tester, 'nav.scanner.fab'),
          const Rect.fromLTWH(165, 709.5, 60, 60),
        );
        // O fade continua colado na base.
        expect(
          _rect(tester, 'bottomFade'),
          const Rect.fromLTWH(0, 694, 390, 150),
        );
      },
    );
  });

  for (final w in [360.0, 430.0]) {
    testWidgets(
      'largura $w: barra 16…${w - 16}, FAB centrado em w/2 e itens de (w − 32 − 19 − 16) / 5 (comportamento fluido; validação formal na F13)',
      (tester) async {
        setCanvasView(
          tester,
          logical: Size(w, 844),
          safeTop: 47,
          safeBottom: 34,
        );
        await pumpApp(tester);
        expect(_rect(tester, 'nav'), Rect.fromLTWH(16, 744, w - 32, 70));
        final fab = _rect(tester, 'nav.scanner.fab');
        expect(fab.center.dx, moreOrLessEquals(w / 2, epsilon: 1e-9));
        expect(fab.top, 723.5);
        final item = _rect(tester, 'nav.scanner');
        expect(item.center.dx, moreOrLessEquals(w / 2, epsilon: 1e-9));
        expect(
          item.width,
          moreOrLessEquals((w - 32 - 19 - 16) / 5, epsilon: 1e-9),
        );
        expect(_rect(tester, 'bottomFade'), Rect.fromLTWH(0, 694, w, 150));
      },
    );
  }

  test('constantes: FAB 60, topo = navBottom + 30,5 (= 20,5 acima do topo da barra)', () {
    expect(ScannerFab.size, 60);
    expect(ScannerFab.bottom(30), 60.5);
    expect(ScannerFab.bottom(44), 74.5);
  });
}

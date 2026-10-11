import 'dart:typed_data';

import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// F03 — camada 2 (estilo, sem tolerância) da seção `header`.
BoxDecoration _decorationOf(WidgetTester tester, String id) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byKey(ValueKey<String>(id)),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

TextStyle _styleOf(WidgetTester tester, String id) =>
    (tester
                .widget<AppText>(
                  find.descendant(
                    of: find.byKey(ValueKey<String>(id)),
                    matching: find.byType(AppText),
                    matchRoot: true,
                  ),
                )
                .span
            as TextSpan)
        .style!;

/// Cor ARGB do pixel em (x, y) LÓGICOS de uma captura @3x do canvas.
int _argbAt(Uint8List rgba, int width, double x, double y) {
  final i = ((y * 3).floor() * width + (x * 3).floor()) * 4;
  return (rgba[i + 3] << 24) |
      (rgba[i] << 16) |
      (rgba[i + 1] << 8) |
      rgba[i + 2];
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '3.1 avatar: 44×44, #FED170, borda 1,5 #1A1714, raio 22, sem sombra',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final d = _decorationOf(tester, 'header.avatar');
      expect(d.color!.toARGB32(), 0xFFFED170);
      expect(d.border, Border.all(width: 1.5, color: AppColors.ink));
      expect((d.border! as Border).top.width, 1.5);
      expect((d.border! as Border).top.color.toARGB32(), 0xFF1A1714);
      expect(d.borderRadius, BorderRadius.circular(22));
      expect(d.boxShadow, isNull);
      expect(
        tester.getSize(find.byKey(const ValueKey('header.avatar'))),
        const Size(44, 44),
      );
    },
  );

  testWidgets(
    '3.1 "M" em Bricolage18 800 (opsz 18), 18 px, tinta — centralizado no avatar',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final s = _styleOf(tester, 'header.avatar');
      expect(s, same(AppTextStyles.avatarInitial));
      expect(s.fontFamily, 'Bricolage18');
      expect(s.fontFamilyFallback, ['Bricolage18Ext', 'Bricolage18Vi']);
      expect(s.fontSize, 18);
      expect(s.fontWeight, FontWeight.w800);
      expect(s.height, 1.2);
      expect(s.color!.toARGB32(), 0xFF1A1714);
      final avatar = tester.getRect(
        find.byKey(const ValueKey('header.avatar')),
      );
      final m = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey('header.avatar')),
          matching: find.byType(AppText),
        ),
      );
      expect(m.center.dx, moreOrLessEquals(avatar.center.dx, epsilon: 1e-9));
      expect(m.center.dy, moreOrLessEquals(avatar.center.dy, epsilon: 1e-9));
    },
  );

  testWidgets(
    '3.1 "Boa noite," Figtree 13/500 #5B544B; "Marina" Figtree 16/700 ls −0,1 tinta',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final g = _styleOf(tester, 'header.greeting');
      expect(g, same(AppTextStyles.body13Muted));
      expect(
        (g.fontFamily, g.fontSize, g.fontWeight, g.height, g.letterSpacing),
        ('Figtree', 13.0, FontWeight.w500, 1.2, 0.0),
      );
      expect(g.color!.toARGB32(), 0xFF5B544B);
      final n = _styleOf(tester, 'header.name');
      expect(n, same(AppTextStyles.name16));
      expect(
        (n.fontFamily, n.fontSize, n.fontWeight, n.height, n.letterSpacing),
        ('Figtree', 16.0, FontWeight.w700, 1.2, -0.1),
      );
      expect(n.color!.toARGB32(), 0xFF1A1714);
      for (final s in [g, n]) {
        expect(s.fontFamilyFallback, ['FigtreeExt']);
        expect(s.leadingDistribution, TextLeadingDistribution.even);
      }
    },
  );

  testWidgets(
    '3.2 sino: botão 48×48 #FFFAF1, borda 1,5 #1A1714, círculo; ícone ic_bell.svg 22',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final button = tester.widget<CircleIconButton>(
        find.byKey(const ValueKey('header.bell')),
      );
      expect(button.size, 48);
      final d = _decorationOf(tester, 'header.bell');
      expect(d.color!.toARGB32(), 0xFFFFFAF1);
      expect(d.border, Border.all(width: 1.5, color: AppColors.ink));
      expect(d.borderRadius, BorderRadius.circular(24));
      expect(d.boxShadow, isNull);
      final icon = tester.widget<AppSvg>(
        find.byKey(const ValueKey('header.bell.icon')),
      );
      expect(icon.asset, AppIcons.bell);
      expect(icon.asset, 'assets/icons/ic_bell.svg');
      expect(icon.size, 22);
    },
  );

  testWidgets(
    '3.2 ponto: 12×12 (9 + 2 × 1,5), #FF552E, borda 1,5 #FFFAF1, top 9 / right 11 dentro da borda',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final d = _decorationOf(tester, 'header.bell.dot');
      expect(d.color!.toARGB32(), 0xFFFF552E);
      expect(d.border, Border.all(width: 1.5, color: AppColors.surface));
      expect((d.border! as Border).top.color.toARGB32(), 0xFFFFFAF1);
      expect(d.borderRadius, BorderRadius.circular(6));
      expect(
        tester.getSize(find.byKey(const ValueKey('header.bell.dot'))),
        const Size(12, 12),
      );
      final positioned = tester.widget<Positioned>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('header.bell.dot')),
              matching: find.byType(Positioned),
            )
            .first,
      );
      expect(
        (positioned.top, positioned.right, positioned.left, positioned.bottom),
        (9.0, 11.0, null, null),
      );
      // Relativo à borda externa do botão: (48 − 1,5 − 11 − 12; 1,5 + 9) = (23,5; 10,5).
      final bell = tester.getRect(find.byKey(const ValueKey('header.bell')));
      final dot = tester.getRect(find.byKey(const ValueKey('header.bell.dot')));
      expect(dot.topLeft - bell.topLeft, const Offset(23.5, 10.5));
    },
  );

  testWidgets(
    '3.2 o ponto é pintado POR CIMA do ícone (ordem na Stack e nos pixels)',
    (tester) async {
      setCanvasView(tester);
      await precacheSvgs(tester, AppIcons.all);
      await tester.pumpWidget(
        ProviderScope(
          overrides: overridesDoMundo,
          child: const RepaintBoundary(
            key: goldenRootKey,
            child: App.forTests(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byKey(const ValueKey('header.bell')),
              matching: find.byType(Stack),
            )
            .first,
      );
      expect(stack.clipBehavior, Clip.none);
      expect(stack.children, hasLength(2));
      expect(stack.children[0].key, const ValueKey('header.bell.icon'));
      expect(stack.children[1], isA<Positioned>());
      final image = await captureAt(tester, find.byKey(goldenRootKey));
      final rgba = await rgbaOf(tester, image);
      int at(double x, double y) => _argbAt(rgba, image.width, x, y);
      // Centro do ponto (351,5; 78,5): preenchimento #FF552E.
      expect(at(351.5, 78.5), 0xFFFF552E);
      // (346,83; 76,83): o arco do sino passa por aqui (traço de 1,65 px em (346,92; 76,91)) e o pixel @3x
      // fica inteiro dentro do anel do ponto (4,74–5,17 px do centro; anel de 4,5 a 6) → cor do anel.
      expect(at(346.83, 76.83), 0xFFFFFAF1);
      // Controle: o mesmo ponto do arco espelhado no eixo do sino (x = 346), fora do ponto, é tinta.
      expect(at(2 * 346 - 346.83, 76.83), 0xFF1A1714);
      // Preenchimentos: avatar amarelo acima do "M"; botão claro abaixo do ícone.
      expect(at(42, 68), 0xFFFED170);
      expect(at(346, 104), 0xFFFFFAF1);
    },
  );

  testWidgets(
    '3.3 sem ripple: nenhum InkWell/InkResponse/Material no cabeçalho; toque só escala (D-04)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final header = find.byKey(const ValueKey('header'));
      expect(
        find.descendant(
          of: header,
          matching: find.byWidgetPredicate(
            (w) =>
                w is InkWell || w is InkResponse || w is Material || w is Ink,
          ),
        ),
        findsNothing,
      );
      final scale = find.descendant(
        of: find.byKey(const ValueKey('header.bell')),
        matching: find.byType(AnimatedScale),
      );
      expect(tester.widget<AnimatedScale>(scale).scale, 1.0);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('header.bell'))),
      );
      await tester.pump();
      expect(tester.widget<AnimatedScale>(scale).scale, 0.97);
      expect(
        tester.widget<AnimatedScale>(scale).duration,
        const Duration(milliseconds: 90),
      );
      await gesture.up();
      await tester.pumpAndSettle();
      // F12: soltar dentro do alvo agora navega (o callback está ligado): voltar devolve a Início.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(scale).scale, 1.0);
    },
  );
}

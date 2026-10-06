// G12.1 — o que os controles do leitor pedem dos primitivos: a sombra dura com cor própria (Noite: #0B0A08), o
// estado de alternância (fita "Página marcada", aria-pressed) e o de desabilitado (Fonte no PDF — D-122) na
// semântica, e o ícone que esmaece sem trocar as cores (abrir/fechar sem `Opacity`) e não quadrado (fita 22×24).
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sombra dura com cor própria; o padrão continua a tinta', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            NeoBox(
              key: ValueKey('a'),
              width: 10,
              height: 10,
              shadow: Offset(3, 3),
            ),
            NeoBox(
              key: ValueKey('b'),
              width: 10,
              height: 10,
              shadow: Offset(3, 3),
              shadowColor: Color(0xFF0B0A08),
            ),
          ],
        ),
      ),
    );
    BoxShadow sombra(String k) {
      final c = tester.widget<Container>(
        find.descendant(
          of: find.byKey(ValueKey(k)),
          matching: find.byType(Container),
        ),
      );
      return (c.decoration! as BoxDecoration).boxShadow!.single;
    }

    expect(sombra('a').color, AppColors.ink);
    expect(sombra('b').color, const Color(0xFF0B0A08));
    expect(
      (sombra('b').blurRadius, sombra('b').offset),
      (0.0, const Offset(3, 3)),
    );
  });

  testWidgets(
    'estado de alternância e desabilitado na semântica; desabilitado não chama o toque',
    (tester) async {
      final h = tester.ensureSemantics();
      var toques = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              Pressable(
                key: const ValueKey('fita'),
                semanticsLabel: 'Página marcada',
                toggled: true,
                onTap: () => toques++,
                child: const SizedBox(width: 44, height: 44),
              ),
              Pressable(
                key: const ValueKey('fonte'),
                semanticsLabel: 'Fonte',
                enabled: false,
                onTap: () => toques += 100,
                child: const SizedBox(width: 44, height: 44),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('fita'))),
        isSemantics(
          label: 'Página marcada',
          isButton: true,
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('fonte'))),
        isSemantics(
          label: 'Fonte',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      await tester.tap(find.byKey(const ValueKey('fonte')));
      await tester.tap(find.byKey(const ValueKey('fita')));
      await tester.pumpAndSettle();
      expect(toques, 1);
      h.dispose();
    },
  );

  testWidgets(
    'ícone esmaecido sem trocar as cores (modulate com branco a alfa) e não quadrado',
    (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AppSvg(
              'assets/icons/leitor/ic_ribbon_marked.svg',
              size: 22,
              height: 24,
              opacity: 0.5,
            ),
          ),
        ),
      );
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svg.colorFilter,
        const ColorFilter.mode(
          Color.fromRGBO(255, 255, 255, 0.5),
          BlendMode.modulate,
        ),
      );
      expect(tester.getSize(find.byType(AppSvg)), const Size(22, 24));
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AppSvg(
              'assets/icons/leitor/ic_search.svg',
              size: 21,
              opacity: 1,
            ),
          ),
        ),
      );
      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
        isNull,
      );
    },
  );
}

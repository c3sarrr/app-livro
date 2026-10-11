import 'package:app_leitura/features/home/presentation/sections/header_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';
import '../support/pump_app.dart';

/// Só a seção, com um callback (a tela liga o sino à rota na F12).
Future<void> _pumpHeader(WidgetTester tester, VoidCallback onTap) async {
  await precacheAppIcons(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overridesDoMundo,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 350,
            child: HeaderSection(onNotificationsTap: onTap),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// F03 — 3.3: semântica e toque da seção `header`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '3.3 um único botão "Notificações, 2 novas"; ícone e ponto fora da árvore semântica',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);
      final label = find.bySemanticsLabel('Notificações, 2 novas');
      expect(label, findsOneWidget);
      final node = tester.getSemantics(
        find.byKey(const ValueKey('header.bell')),
      );
      expect(node.label, 'Notificações, 2 novas');
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.childrenCount, 0); // ícone e ponto excluídos
      // O ícone e o ponto não geram nenhum nó próprio.
      for (final id in ['header.bell.icon', 'header.bell.dot']) {
        expect(
          tester.getSemantics(find.byKey(ValueKey<String>(id))),
          same(node),
          reason: '$id deve estar dentro do nó do botão (sem nó próprio)',
        );
      }
      // Os textos visíveis continuam legíveis (como no navegador): "M", "Boa noite," e "Marina".
      for (final text in ['M', 'Boa noite,', 'Marina']) {
        expect(find.bySemanticsLabel(text), findsOneWidget, reason: text);
      }
      semantics.dispose();
    },
  );

  testWidgets(
    '3.3 toque no sino chama o callback (uma vez por toque) e a ação semântica de toque também',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await _pumpHeader(tester, () => taps++);
      await tester.tap(find.byKey(const ValueKey('header.bell')));
      await tester.pumpAndSettle();
      expect(taps, 1);
      final node = tester.getSemantics(
        find.byKey(const ValueKey('header.bell')),
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      // Ação de toque da acessibilidade (checa que o nó declara a ação antes de executá-la).
      tester.semantics.tap(find.semantics.byLabel('Notificações, 2 novas'));
      await tester.pumpAndSettle();
      expect(taps, 2);
      // Toques fora do botão não disparam o callback.
      await tester.tapAt(const Offset(10, 24));
      await tester.pumpAndSettle();
      expect(taps, 2);
      semantics.dispose();
    },
  );
}

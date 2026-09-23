import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

/// F04 — 4.2: semântica da seção `headline` (<h1> de duas linhas = um nó só).
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '4.2 um único nó de cabeçalho (h1) "Continue sua história."; as duas linhas não geram nós próprios',
    (tester) async {
      final semantics = tester.ensureSemantics();
      setCanvasView(tester);
      await pumpApp(tester);
      final node = tester.getSemantics(find.byKey(const ValueKey('headline')));
      expect(node.label, 'Continue sua história.');
      expect(node.flagsCollection.isHeader, isTrue);
      expect(node.getSemanticsData().headingLevel, 1);
      expect(node.childrenCount, 0);
      // Os dois AppText estão dentro do nó do cabeçalho (sem nó próprio).
      final lines = find.descendant(
        of: find.byKey(const ValueKey('headline')),
        matching: find.byType(AppText),
      );
      expect(lines, findsNWidgets(2));
      for (var i = 0; i < 2; i++) {
        expect(tester.getSemantics(lines.at(i)), same(node));
      }
      // Na árvore inteira: exatamente um cabeçalho com esse rótulo e nenhum nó para as linhas.
      expect(
        find.semantics.byPredicate(
          (n) =>
              n.flagsCollection.isHeader && n.label == 'Continue sua história.',
        ),
        findsOne,
      );
      expect(find.semantics.byLabel('Continue sua história.'), findsOne);
      expect(find.semantics.byLabel('Continue'), findsNothing);
      expect(find.semantics.byLabel('sua história.'), findsNothing);
      expect(find.semantics.byLabel(RegExp('Continue|história')), findsOne);
      semantics.dispose();
    },
  );
}

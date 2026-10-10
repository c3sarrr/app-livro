import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/circle_icon_button.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

/// F03 — camada 1 (geometria) da seção `header`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F03 geometria: os 9 ids da seção header dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = idsOfSection('header').toList();
      expect(ids, [
        'header',
        'header.identity',
        'header.avatar',
        'header.greetingColumn',
        'header.greeting',
        'header.name',
        'header.bell',
        'header.bell.icon',
        'header.bell.dot',
      ]);
      expectGeometry(tester, ids);
      reportGeometry(tester, ids);
    },
  );

  testWidgets('3.1 linha de 48 com space-between e centralização vertical', (
    tester,
  ) async {
    setCanvasView(tester);
    await pumpApp(tester);
    final header = find.byKey(const ValueKey('header'));
    final box = tester.widget<SizedBox>(header);
    expect(box.height, 48);
    final row = tester.widget<Row>(
      find.descendant(of: header, matching: find.byType(Row)).first,
    );
    expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    expect(row.crossAxisAlignment, CrossAxisAlignment.center);
    expect(row.children, hasLength(2));
    expect(row.children.first.key, const ValueKey('header.identity'));
    // T03 (prancha 01): à direita, o grupo das ações — a lupa e o sino, gap 8
    final actions = row.children.last as Row;
    expect(actions.key, const ValueKey('header.actions'));
    expect(actions.spacing, 8);
    expect(actions.children, hasLength(2));
    expect(actions.children.first, isA<CircleIconButton>());
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('header.actions')),
        matching: find.byType(CircleIconButton),
      ),
      findsNWidgets(2),
    );
    // Identidade (44) centralizada na linha de 48 → começa em y + 2; sino colado à direita.
    final h = tester.getRect(header);
    final identity = tester.getRect(
      find.byKey(const ValueKey('header.identity')),
    );
    final bell = tester.getRect(find.byKey(const ValueKey('header.bell')));
    expect(identity.top - h.top, 2);
    expect(identity.center.dy, h.center.dy);
    expect(identity.left, h.left);
    expect(bell.right, h.right);
    expect(bell.center.dy, h.center.dy);
  });

  testWidgets(
    '3.1 identidade: gap 12; coluna de saudação IntrinsicWidth + stretch com gap 1',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final identity = tester.widget<Row>(
        find.byKey(const ValueKey('header.identity')),
      );
      expect(identity.mainAxisSize, MainAxisSize.min);
      expect(identity.spacing, 12);
      expect(identity.children.first, isA<NeoBox>());
      expect(identity.children.last, isA<IntrinsicWidth>());
      final column = tester.widget<Column>(
        find.byKey(const ValueKey('header.greetingColumn')),
      );
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.spacing, 1);
      // Os dois textos esticados à largura da coluna (a do texto mais largo, "Boa noite,").
      final col = tester.getRect(
        find.byKey(const ValueKey('header.greetingColumn')),
      );
      final greeting = tester.getRect(
        find.byKey(const ValueKey('header.greeting')),
      );
      final name = tester.getRect(find.byKey(const ValueKey('header.name')));
      expect(greeting.width, col.width);
      expect(name.width, col.width);
      expect(name.top - greeting.bottom, moreOrLessEquals(1, epsilon: 1e-9));
      expect(col.width, moreOrLessEquals(58.43, epsilon: 0.05));
      // O ícone do sino fica centralizado: (13, 13) a partir da borda externa do botão.
      final bell = tester.getRect(find.byKey(const ValueKey('header.bell')));
      final icon = tester.getRect(
        find.byKey(const ValueKey('header.bell.icon')),
      );
      expect(icon.topLeft - bell.topLeft, const Offset(13, 13));
      expect(
        tester
            .widget<AppSvg>(find.byKey(const ValueKey('header.bell.icon')))
            .size,
        22,
      );
      debugPrint(
        '[header] coluna ${col.width} | "Boa noite," ${greeting.width} | "Marina" ${name.width} | '
        'ícone em ${icon.topLeft - bell.topLeft} do botão',
      );
    },
  );
}

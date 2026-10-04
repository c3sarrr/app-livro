// Localizadores das telas da conta (o AppText é um RenderObject próprio: `find.text` não o enxerga).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/account/presentation/account_widgets.dart';
import 'package:flutter/material.dart' show TextField;
import 'package:flutter_test/flutter_test.dart';

Finder texto(String t) => find.byWidgetPredicate(
  (w) => w is AppText && w.span.toPlainText() == t,
  description: 'AppText "$t"',
);

Finder textoComecando(String t) => find.byWidgetPredicate(
  (w) => w is AppText && w.span.toPlainText().startsWith(t),
  description: 'AppText começando com "$t"',
);

Finder botao(String rotulo) => find.byWidgetPredicate(
  (w) => w is AccountButton && w.label == rotulo,
  description: 'botão "$rotulo"',
);

Finder campo(String rotulo) => find.descendant(
  of: find.byWidgetPredicate((w) => w is AccountField && w.label == rotulo),
  matching: find.byType(TextField),
);

/// Rola até o botão e toca.
Future<void> tocar(WidgetTester tester, String rotulo) async {
  final b = botao(rotulo);
  expect(b, findsOneWidget, reason: rotulo);
  await tester.ensureVisible(b);
  await tester.pumpAndSettle();
  await tester.tap(b);
  await tester.pumpAndSettle();
}

Future<void> digitar(WidgetTester tester, String rotulo, String valor) async {
  final c = campo(rotulo);
  await tester.ensureVisible(c);
  await tester.enterText(c, valor);
  await tester.pumpAndSettle();
}

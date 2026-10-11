// Acha um AppText pelo texto (o AppText desenha num RenderObject próprio: `find.text` não o enxerga).
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter_test/flutter_test.dart';

Finder findAppText(String text) => find.byWidgetPredicate(
  (w) =>
      w is AppText && w.span.toPlainText(includeSemanticsLabels: false) == text,
  description: 'AppText "$text"',
);

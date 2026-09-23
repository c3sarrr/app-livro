import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import 'geometry.dart'; // kRotated

void expectTextLines(WidgetTester tester, String id) {
  final ref = kRefLayout[id]!;
  final finder = find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  );
  expect(finder, findsWidgets, reason: '$id: nenhum AppText sob a Key');
  final renders =
      finder.evaluate().map((e) => e.renderObject! as RenderAppText).toList()
        ..sort(
          (a, b) => a
              .localToGlobal(Offset.zero)
              .dy
              .compareTo(b.localToGlobal(Offset.zero).dy),
        );
  final got = [for (final r in renders) ...r.debugLines()];
  if (kEllipsized.contains(id)) {
    expect(
      renders.single.debugDidExceedMaxLines,
      isTrue,
      reason: '$id deve truncar com "…" (${ref.lines.first.text})',
    );
    return;
  }
  expect(
    got.map((l) => l.text).toList(),
    ref.lines.map((l) => l.text).toList(),
    reason: '$id: quebras/strings diferentes',
  );
  // Texto dentro de capa rotacionada: coordenadas globais incluem a rotação → só quebras/strings
  // (posição coberta por expectGeometry/layoutRect e pelo golden).
  if (kRotated.any((c) => id.startsWith('$c.'))) return;
  for (var i = 0; i < got.length; i++) {
    expect(
      got[i].baseline,
      moreOrLessEquals(ref.lines[i].baseline, epsilon: 0.5),
      reason: '$id L${i + 1} baseline',
    );
    expect(
      got[i].left,
      moreOrLessEquals(ref.lines[i].left, epsilon: 0.5),
      reason: '$id L${i + 1} início',
    );
    expect(
      got[i].right,
      moreOrLessEquals(ref.lines[i].right, epsilon: 0.5),
      reason: '$id L${i + 1} fim',
    );
  }
}

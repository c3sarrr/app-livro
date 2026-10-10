import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/inicio2/referencias_inicio2.dart';
import 'fase_inicio.dart';
import 'geometry.dart';

/// Gate de texto dos testes do design system (F01 1.4): as linhas dos `AppText` sob a Key [id] — strings, quebras,
/// baseline, início e fim (±0,5) — contra as da prancha 01 (`kRef01`, desde a T03); com reticências, só o corte.
/// As linhas saem sem os giros (como a prancha mede), também dentro das capas giradas.
void expectTextLines(WidgetTester tester, String id) {
  final ref = ref01(id);
  final finder = find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  );
  expect(finder, findsWidgets, reason: '$id: nenhum AppText sob a Key');
  if (kRef01.ellipsized.contains('i01.$id')) {
    expect(
      (finder.evaluate().single.renderObject! as RenderAppText)
          .debugDidExceedMaxLines,
      isTrue,
      reason: '$id deve truncar com "…" (${ref.lines.first.text})',
    );
    return;
  }
  final got = linhas01(tester, 'i01.$id', ref.lines.first.text);
  expect(
    got.map((l) => l.text).toList(),
    ref.lines.map((l) => l.text).toList(),
    reason: '$id: quebras/strings diferentes',
  );
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

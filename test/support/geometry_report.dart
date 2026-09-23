import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import 'geometry.dart';

/// Para o relatório: retângulo de layout obtido × referência de cada id, os desvios e o maior deles.
void reportGeometry(WidgetTester tester, Iterable<String> ids) {
  var worst = ('', '', 0.0);
  for (final id in ids) {
    final got = layoutRect(tester, id), ref = kRefLayout[id]!.rect;
    final deltas = [
      ('x', got.left - ref.left),
      ('y', got.top - ref.top),
      ('w', got.width - ref.width),
      ('h', got.height - ref.height),
    ];
    for (final (what, d) in deltas) {
      if (d.abs() > worst.$3.abs()) worst = (id, what, d);
    }
    String f(double v) => v.toStringAsFixed(3);
    debugPrint(
      '[geometria] $id: obtido (${f(got.left)}, ${f(got.top)}, ${f(got.width)}, ${f(got.height)}) | '
      'referência (${f(ref.left)}, ${f(ref.top)}, ${f(ref.width)}, ${f(ref.height)}) | '
      'Δ ${deltas.map((e) => '${e.$1} ${e.$2.toStringAsFixed(3)}').join(', ')}',
    );
  }
  debugPrint(
    '[geometria] ${ids.length} ids; maior desvio ${worst.$1}.${worst.$2} = ${worst.$3.toStringAsFixed(3)}',
  );
}

/// Para o relatório: linhas de texto obtidas (baseline, início, fim) × referência do arquivo.
void reportTextLines(WidgetTester tester, String id) {
  final ref = kRefLayout[id]!.lines;
  final renders =
      find
          .descendant(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .evaluate()
          .map((e) => e.renderObject! as RenderAppText)
          .toList()
        ..sort(
          (a, b) => a
              .localToGlobal(Offset.zero)
              .dy
              .compareTo(b.localToGlobal(Offset.zero).dy),
        );
  final got = [for (final r in renders) ...r.debugLines()];
  for (var i = 0; i < got.length; i++) {
    final r = i < ref.length ? ref[i] : null;
    debugPrint(
      '[texto] $id L${i + 1} "${got[i].text}": baseline ${got[i].baseline.toStringAsFixed(3)} '
      '(arquivo ${r?.baseline}) | início ${got[i].left.toStringAsFixed(3)} (arquivo ${r?.left}) | '
      'fim ${got[i].right.toStringAsFixed(3)} (arquivo ${r?.right})',
    );
  }
}

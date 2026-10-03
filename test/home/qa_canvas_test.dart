import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// F13 · 13.1 — gate principal no canvas completo 390 × 2390: os 248 ids de `kRefLayout` de uma vez (as fases
/// 3–11 validaram cada seção; aqui a tela inteira, montada pelo app real, é conferida contra o arquivo) e as
/// linhas de texto de todos os ids que as têm.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('13.1 geometria: 248/248 ids dentro da tolerância', (
    tester,
  ) async {
    setCanvasView(tester);
    await pumpApp(tester);
    expect(kRefLayout.length, 248);
    expectGeometry(tester, kRefLayout.keys);

    // Tabela dos 10 maiores desvios (para o relatório): maior |Δ| entre x, y, w, h de cada id.
    final rows = <(String, String, double, Rect, Rect)>[];
    for (final MapEntry(key: id, value: ref) in kRefLayout.entries) {
      final got = layoutRect(tester, id);
      final deltas = {
        'x': got.left - ref.rect.left,
        'y': got.top - ref.rect.top,
        'w': got.width - ref.rect.width,
        'h': got.height - ref.rect.height,
      };
      final worst = deltas.entries.reduce(
        (a, b) => a.value.abs() >= b.value.abs() ? a : b,
      );
      rows.add((id, worst.key, worst.value, got, ref.rect));
    }
    rows.sort((a, b) => b.$3.abs().compareTo(a.$3.abs()));
    String f(double v) => v.toStringAsFixed(3);
    String r(Rect v) =>
        '(${f(v.left)}, ${f(v.top)}, ${f(v.width)}, ${f(v.height)})';
    debugPrint('[F13 geometria 390] 248/248 ids; 10 maiores desvios:');
    for (var i = 0; i < 10; i++) {
      final (id, what, d, got, ref) = rows[i];
      debugPrint(
        '[F13 geometria 390] ${(i + 1).toString().padLeft(2)}. $id  Δ$what = ${f(d)}  '
        'obtido ${r(got)}  referência ${r(ref)}  '
        'tol ±${what == 'x' || what == 'w' ? (kTextDependentX.contains(id) ? 1.0 : 0.5) : 0.5}',
      );
    }
    final ids390 = rows.map((e) => e.$1).toSet();
    expect(ids390.length, 248);

    // Tabela por seção: ids conferidos, maior desvio e ids com linhas de texto.
    final sections = <String, List<(String, String, double, Rect, Rect)>>{};
    for (final row in rows) {
      sections.putIfAbsent(kRefLayout[row.$1]!.section, () => []).add(row);
    }
    for (final section in kRefSections.keys) {
      final list = sections[section]!;
      final worst = list.first; // `rows` já está ordenado por |Δ| decrescente
      final texts = list
          .where((r) => kRefLayout[r.$1]!.lines.isNotEmpty)
          .length;
      debugPrint(
        '[F13 seção] $section: ${list.length}/${list.length} ids OK · maior desvio '
        '${worst.$1}.Δ${worst.$2} = ${f(worst.$3)} px · $texts ids com linhas de texto',
      );
    }
    expect(sections.keys.toSet(), kRefSections.keys.toSet());
  });

  testWidgets('13.1 texto: linhas, quebras e reticências de todos os ids', (
    tester,
  ) async {
    setCanvasView(tester);
    await pumpApp(tester);
    final withLines = [
      for (final e in kRefLayout.entries)
        if (e.value.lines.isNotEmpty) e.key,
    ];
    final rotated = withLines
        .where((id) => kRotated.any((c) => id.startsWith('$c.')))
        .toList();
    final ellipsized = withLines.where(kEllipsized.contains).toList();
    var linesTotal = 0;
    for (final id in withLines) {
      expectTextLines(tester, id);
      linesTotal += kRefLayout[id]!.lines.length;
    }
    debugPrint(
      '[F13 texto 390] ${withLines.length} ids com linhas conferidos ($linesTotal linhas); '
      '${rotated.length} dentro de capa rotacionada (só quebras); '
      '${ellipsized.length} com reticências: ${ellipsized.join(', ')}',
    );
    expect(withLines.length, 88);
    expect(ellipsized.length, 2);
  });
}

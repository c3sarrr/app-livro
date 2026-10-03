import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout_w360.dart';
import '../reference/reference_layout_w430.dart';
import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

/// F13 · 13.3 — comportamento fluido (validação secundária): a mesma árvore de widgets, sem nenhum código
/// específico de largura, montada com 360 e 430 de largura (DPR 2) tem de reproduzir os 248 retângulos que o
/// Chromium mediu com o mesmo CSS (`kRefLayoutW360` / `kRefLayoutW430`), ±1,0 px em x, y, w e h.
void main() {
  setUpAll(loadAppFonts);

  Rect rectOf(WidgetTester tester, String id) => layoutRect(tester, id);

  List<String> linesOf(WidgetTester tester, String id) {
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
    return [for (final r in renders) ...r.debugLines().map((l) => l.text)];
  }

  void report(WidgetTester tester, int width, Map<String, Rect> ref) {
    final rows = <(String, String, double, Rect, Rect)>[];
    for (final MapEntry(key: id, value: exp) in ref.entries) {
      final got = rectOf(tester, id);
      final deltas = {
        'x': got.left - exp.left,
        'y': got.top - exp.top,
        'w': got.width - exp.width,
        'h': got.height - exp.height,
      };
      final worst = deltas.entries.reduce(
        (a, b) => a.value.abs() >= b.value.abs() ? a : b,
      );
      rows.add((id, worst.key, worst.value, got, exp));
    }
    rows.sort((a, b) => b.$3.abs().compareTo(a.$3.abs()));
    String f(double v) => v.toStringAsFixed(3);
    String r(Rect v) =>
        '(${f(v.left)}, ${f(v.top)}, ${f(v.width)}, ${f(v.height)})';
    debugPrint(
      '[F13 geometria $width] ${rows.length}/248 ids; 10 maiores desvios (tol ±1,0):',
    );
    for (var i = 0; i < 10; i++) {
      final (id, what, d, got, exp) = rows[i];
      debugPrint(
        '[F13 geometria $width] ${(i + 1).toString().padLeft(2)}. $id  Δ$what = ${f(d)}  '
        'obtido ${r(got)}  referência ${r(exp)}',
      );
    }
  }

  testWidgets('13.3 largura 360: 248/248 ids ±1,0 px', (tester) async {
    setCanvasView(tester, logical: const Size(360, 2390), dpr: 2);
    await pumpApp(tester);
    expect(kRefLayoutW360.length, 248);
    expectGeometryAgainst(tester, kRefLayoutW360);
    report(tester, 360, kRefLayoutW360);
  });

  testWidgets('13.3 largura 430: 248/248 ids ±1,0 px', (tester) async {
    setCanvasView(tester, logical: const Size(430, 2390), dpr: 2);
    await pumpApp(tester);
    expect(kRefLayoutW430.length, 248);
    expectGeometryAgainst(tester, kRefLayoutW430);
    report(tester, 430, kRefLayoutW430);
  });

  testWidgets(
    '13.3 casos que só aparecem em 360, reproduzidos pelas regras do CSS (sem código especial)',
    (tester) async {
      setCanvasView(tester, logical: const Size(360, 2390), dpr: 2);
      await pumpApp(tester);

      // 1) Título do hero "Dom Casmurro" quebra em 2 linhas (151 px disponíveis).
      expect(linesOf(tester, 'hero.title'), ['Dom', 'Casmurro']);
      expect(
        rectOf(tester, 'hero.title').height,
        moreOrLessEquals(2 * 25.2, epsilon: 1e-3),
      );
      expect(rectOf(tester, 'hero.title').width, 151);

      // 2) Frase da meta em 3 linhas (em 390 são 2): "Faltam 12 min para fechar / a meta / de hoje."
      final sentence = linesOf(tester, 'today.goalText.sentence');
      debugPrint('[F13 360] frase da meta: $sentence');
      expect(sentence.length, 3);
      expect(
        rectOf(tester, 'today.goalText.sentence').height,
        moreOrLessEquals(3 * 19.5, epsilon: 1e-3),
      );

      // 3) Chips da meta quebram em 2 linhas com gap 6 (flex-wrap).
      final chips = rectOf(tester, 'today.chips');
      final c1 = rectOf(tester, 'today.chip.pages');
      final c2 = rectOf(tester, 'today.chip.highlights');
      expect(c1.left, c2.left);
      expect(c2.top - c1.bottom, moreOrLessEquals(6, epsilon: 1e-3));
      expect(
        chips.height,
        moreOrLessEquals(c1.height + 6 + c2.height, epsilon: 1e-3),
      );

      // 4) Linhas da lista: flex-shrink com 168 px para texto + tag (em 390 sobram 198).
      for (final row in ['row0', 'row1', 'row2']) {
        final block = rectOf(tester, 'recent.$row.textBlock');
        final tag = rectOf(tester, 'recent.$row.tag');
        final more = rectOf(tester, 'recent.$row.more');
        debugPrint(
          '[F13 360] recent.$row: textBlock ${block.width.toStringAsFixed(2)} + tag ${tag.width.toStringAsFixed(2)} '
          '(${(tag.right - block.left).toStringAsFixed(2)} px do início do texto ao fim da tag) · more.left ${more.left}',
        );
        expect(tag.right, lessThanOrEqualTo(more.left));
      }
      final row1Tag = linesOf(tester, 'recent.row1.tag');
      final row1Sub = linesOf(tester, 'recent.row1.subtitle');
      debugPrint('[F13 360] O Alienista: tag $row1Tag · subtítulo $row1Sub');
    },
  );
}

// G16.6 — as peças da tela 22 (pílula e Concluir, prateleira, ilha) montadas sozinhas no canvas de 390×844, nos
// lugares da prancha, com as cores do papel (`ReaderChromeScope`), e conferidas contra o `kRef22`: geometria (±0,5;
// ±1,0 em x/w nos ids que dependem do texto; a caixa visual quando o arquivo tem `transform`) e as linhas de texto.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/leitor/reference_layout_22_modo_anotacao.dart';

Finder chaveL22(String id) => find.byKey(ValueKey<String>(id));

/// Monta [pecas] (já posicionadas, como filhos de um `Stack`) no canvas da 22, com a paleta do [papel].
Future<void> montarPecasL22(
  WidgetTester tester,
  List<Widget> pecas, {
  ReaderPaper papel = ReaderPaper.creme,
  Color brand = AppColors.lavender,
}) async {
  tester.view
    ..devicePixelRatio = 3
    ..physicalSize = const Size(390 * 3, 844 * 3);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844), devicePixelRatio: 3),
        child: ReaderChromeScope(
          palette: ReaderChromePalette.of(papel),
          brand: brand,
          a: 1,
          child: Stack(children: pecas),
        ),
      ),
    ),
  );
}

/// Cada id contra o retângulo da prancha (a caixa visual quando o arquivo tem `transform`).
void conferirGeometriaL22(WidgetTester tester, Iterable<String> ids) {
  final falhas = <String>[];
  for (final id in ids) {
    final e = kRef22.elements[id]!;
    final esperado = e.visual ?? e.rect;
    final f = chaveL22(id);
    if (f.evaluate().isEmpty) {
      falhas.add('$id: sem widget');
      continue;
    }
    final r = tester.getRect(f);
    final tx = kRef22.textDependentX.contains(id) ? 1.0 : 0.5;
    for (final (o, g, x, tol) in [
      ('x', r.left, esperado.left, tx),
      ('y', r.top, esperado.top, 0.5),
      ('w', r.width, esperado.width, tx),
      ('h', r.height, esperado.height, 0.5),
    ]) {
      if ((g - x).abs() > tol + 1e-6) {
        falhas.add('$id.$o: ${g.toStringAsFixed(2)} ≠ ${x.toStringAsFixed(2)}');
      }
    }
  }
  expect(falhas, isEmpty, reason: falhas.join('\n'));
}

/// As linhas do texto de [id] (o `AppText` do id, ou o último dentro dele): texto, baseline (±0,5) e bordas (±1).
void conferirLinhasL22(WidgetTester tester, String id) {
  final e = kRef22.elements[id]!;
  final r = tester.renderObject<RenderAppText>(
    find
        .descendant(
          of: chaveL22(id),
          matching: find.byType(AppText),
          matchRoot: true,
        )
        .last,
  );
  final got = r.debugLines();
  expect(got.map((l) => l.text), e.lines.map((l) => l.text), reason: id);
  for (var i = 0; i < got.length; i++) {
    expect(
      got[i].baseline,
      moreOrLessEquals(e.lines[i].baseline, epsilon: 0.5),
      reason: '$id baseline',
    );
    expect(
      got[i].left,
      moreOrLessEquals(e.lines[i].left, epsilon: 1),
      reason: '$id início',
    );
    expect(
      got[i].right,
      moreOrLessEquals(e.lines[i].right, epsilon: 1),
      reason: '$id fim',
    );
  }
}

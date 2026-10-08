// G17 — as peças das telas 23 e 23b (painéis, seletor de cor) montadas sozinhas no canvas de 390×844, com a paleta
// do papel (`ReaderChromeScope`), e conferidas contra o `kRef23`/`kRef23b`: geometria (±0,5; ±1,0 em x/w nos ids que
// dependem do texto; a caixa visual quando o arquivo tem `transform`) e as linhas de texto. Os ids da prancha (`pen.`,
// `mk.`) viram as chaves do app (`ann.`), como na G16.
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/leitor/ref_tipos.dart';

/// A chave do app para o id da prancha [id] (`pen.x` / `mk.x` → `ann.x`).
String chaveDoApp(LeitorRefPrancha ref, String id) =>
    id.startsWith('${ref.prefix}.')
    ? 'ann.${id.substring(ref.prefix.length + 1)}'
    : id;

Finder chaveL23(String chave) => find.byKey(ValueKey<String>(chave));

/// Monta [pecas] (já posicionadas, filhos de um `Stack`) no canvas de 390×844 @3x, com a paleta do [papel].
Future<void> montarPecasL23(
  WidgetTester tester,
  List<Widget> pecas, {
  ReaderPaper papel = ReaderPaper.creme,
  Color brand = AppColors.lavender,
  EdgeInsets teclado = EdgeInsets.zero,
}) async {
  tester.view
    ..devicePixelRatio = 3
    ..physicalSize = const Size(390 * 3, 844 * 3);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          devicePixelRatio: 3,
          viewInsets: teclado,
        ),
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

/// Cada id da prancha [ref] contra o retângulo medido (a caixa visual quando o arquivo tem `transform`).
void conferirGeometriaL23(
  WidgetTester tester,
  LeitorRefPrancha ref,
  Iterable<String> ids,
) {
  final falhas = <String>[];
  for (final id in ids) {
    final e = ref.elements[id]!;
    final esperado = e.visual ?? e.rect;
    final f = chaveL23(chaveDoApp(ref, id));
    if (f.evaluate().isEmpty) {
      falhas.add('$id: sem widget');
      continue;
    }
    final r = tester.getRect(f.first);
    final tx = ref.textDependentX.contains(id) ? 1.0 : 0.5;
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
void conferirLinhasL23(WidgetTester tester, LeitorRefPrancha ref, String id) {
  final e = ref.elements[id]!;
  final r = tester.renderObject<RenderAppText>(
    find
        .descendant(
          of: chaveL23(chaveDoApp(ref, id)),
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

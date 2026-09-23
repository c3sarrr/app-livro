import 'package:flutter/widgets.dart'; // já exporta rendering.dart (importar os dois gera `unnecessary_import`)
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';

/// Capas com `transform: rotate(...)` no CSS. Convenção obrigatória:
///  - a Key do id (ex.: 'hero.cover') fica no SLOT de layout (widget SEM rotação, mesmo tamanho da capa);
///  - o filho direto do Transform.rotate leva a Key `'<id>#rot'`.
/// O retângulo de referência de qualquer descendente é medido no espaço LOCAL do conteúdo rotacionado
/// (o navegador também mede layout ignorando transforms).
const kRotated = {
  'hero.cover',
  'alsoReading.card1.cover',
  'alsoReading.card2.cover',
};

Rect layoutRect(WidgetTester tester, String id) {
  final finder = find.byKey(ValueKey<String>(id));
  for (final c in kRotated) {
    if (id.startsWith('$c.')) {
      final slot = tester.getRect(find.byKey(ValueKey<String>(c)));
      final rotBox = tester.renderObject<RenderBox>(
        find.byKey(ValueKey<String>('$c#rot')),
      );
      final box = tester.renderObject<RenderBox>(finder);
      final local = box.localToGlobal(Offset.zero, ancestor: rotBox);
      return (slot.topLeft + local) & box.size;
    }
  }
  return tester.getRect(finder);
}

/// Gate de geometria: compara o retângulo de layout de cada Key com a referência medida no HTML.
/// Vertical ±0,5 px sempre; horizontal ±0,5 px (±1,0 px para ids em kTextDependentX).
void expectGeometry(WidgetTester tester, Iterable<String> ids) {
  final failures = <String>[];
  for (final id in ids) {
    final ref = kRefLayout[id];
    if (ref == null) {
      failures.add('$id: id não existe na referência');
      continue;
    }
    final finder = find.byKey(ValueKey<String>(id));
    final count = finder.evaluate().length;
    if (count != 1) {
      failures.add(
        '$id: esperado exatamente 1 widget com esta Key, encontrados $count',
      );
      continue;
    }
    final r = layoutRect(tester, id);
    final tolX = kTextDependentX.contains(id) ? 1.0 : 0.5;
    void check(String what, double got, double exp, double tol) {
      if ((got - exp).abs() > tol + 1e-6) {
        failures.add(
          '$id.$what: obtido ${got.toStringAsFixed(2)} | esperado ${exp.toStringAsFixed(2)} | tol ±$tol',
        );
      }
    }

    check('x', r.left, ref.rect.left, tolX);
    check('w', r.width, ref.rect.width, tolX);
    check('y', r.top, ref.rect.top, 0.5);
    check('h', r.height, ref.rect.height, 0.5);
  }
  expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
}

/// Ids de uma seção (todos os não-inline), para usar nas fases.
Iterable<String> idsOfSection(String section) => kRefLayout.entries
    .where((e) => e.value.section == section)
    .map((e) => e.key);

/// Gate secundário da F13 (larguras 360 e 430): compara com um mapa id → Rect
/// (`kRefLayoutW360` / `kRefLayoutW430`), mesma tolerância em x, y, w e h.
void expectGeometryAgainst(
  WidgetTester tester,
  Map<String, Rect> ref, {
  double tol = 1.0,
}) {
  final failures = <String>[];
  ref.forEach((id, exp) {
    final count = find.byKey(ValueKey<String>(id)).evaluate().length;
    if (count != 1) {
      failures.add(
        '$id: esperado exatamente 1 widget com esta Key, encontrados $count',
      );
      return;
    }
    final r = layoutRect(tester, id);
    for (final (what, got, e) in [
      ('x', r.left, exp.left),
      ('y', r.top, exp.top),
      ('w', r.width, exp.width),
      ('h', r.height, exp.height),
    ]) {
      if ((got - e).abs() > tol + 1e-6) {
        failures.add(
          '$id.$what: obtido ${got.toStringAsFixed(2)} | esperado ${e.toStringAsFixed(2)} | tol ±$tol',
        );
      }
    }
  });
  expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
}

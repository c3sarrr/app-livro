import 'package:flutter/widgets.dart'; // já exporta rendering.dart (importar os dois gera `unnecessary_import`)
import 'package:flutter_test/flutter_test.dart';

import '../reference/inicio2/referencias_inicio2.dart';
import 'fase_inicio.dart';

/// Os gates de geometria dos testes do design system (F01/F02): os primitivos montados à mão no retângulo de um
/// elemento da Início, conferidos contra a prancha. Desde a T03 (D-240) a prancha 01 (`kRef01`; até a T03, a
/// referência da v1): [id] é a Key do app, o id da prancha sem o prefixo `i01.`. As capas giradas seguem a convenção
/// de `fase_inicio.dart` (a Key no slot sem giro e `<id>#rot` no filho do `Transform`; o layout é medido sem os giros).

/// O elemento da prancha 01 da Key [id].
LeitorRefElement ref01(String id) => kRef01.elements['i01.$id']!;

/// O retângulo de layout da Key [id] (sem os giros).
Rect layoutRect(WidgetTester tester, String id) =>
    retanguloDeLayout(tester, 'i01.$id');

/// Gate de geometria: compara o retângulo de layout de cada Key com a referência medida no HTML.
/// Vertical ±0,5 px sempre; horizontal ±0,5 px (±1,0 px para os ids `textDependentX` da prancha).
void expectGeometry(WidgetTester tester, Iterable<String> ids) {
  final failures = <String>[];
  for (final id in ids) {
    final ref = kRef01.elements['i01.$id'];
    if (ref == null) {
      failures.add('$id: id não existe na referência');
      continue;
    }
    final count = find.byKey(ValueKey<String>(id)).evaluate().length;
    if (count != 1) {
      failures.add(
        '$id: esperado exatamente 1 widget com esta Key, encontrados $count',
      );
      continue;
    }
    final r = layoutRect(tester, id);
    final tolX = kRef01.textDependentX.contains('i01.$id') ? 1.0 : 0.5;
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

// G02 · S4 — o cálculo de latência e o app de medição (fumaça; os números reais vêm do aparelho).
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spike_s4_tinta/latencia/medidor.dart';
import 'package:spike_s4_tinta/latencia_app.dart';

void main() {
  test('120 Hz sintético: evento → raster do 1º quadro seguinte', () {
    const periodo = 8333; // µs
    final r = math.Random(5);
    final quadros = [
      for (var k = 0; k < 600; k++)
        QuadroMedido(k * periodo, k * periodo + 5000),
    ];
    final eventos = [for (var k = 0; k < 2000; k++) r.nextInt(599 * periodo)];
    final res = calcularLatencia(eventos, quadros);
    // Latência = espera até o vsync (0…8,3 ms) + 5 ms de build/raster → entre 5 e 13,3 ms.
    expect(res.amostras, 2000);
    expect(res.maxMs, lessThanOrEqualTo(13.34));
    expect(res.p50Ms, closeTo(9.2, 0.6));
    expect(res.passa(16.7), isTrue);
    expect(
      res.passa(8.3),
      isFalse,
    ); // com 5 ms de raster, 120 Hz não fecha no p95
  });

  test('eventos depois do último quadro ficam de fora', () {
    final res = calcularLatencia(
      [10, 20, 999999],
      const [QuadroMedido(15, 30)],
    );
    expect(res.amostras, 1);
    expect(res.semQuadro, 2);
  });

  testWidgets('app de medição: desenhar gera traço e resumo', (tester) async {
    await tester.pumpWidget(const AppLatencia());
    await tester.dragFrom(const Offset(100, 300), const Offset(150, 40));
    await tester.pump();
    expect(find.byKey(const Key('resumo')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('resumo'))).data,
      contains('eventos'),
    );
  });
}

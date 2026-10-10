// T03.5 — o arnês das fases da Início nova (`test/support/fase_inicio.dart`): a Key de cada id, o retângulo de layout
// sem os giros (como o passo A da medição neutraliza os `transform`), a caixa visual dos girados e o gate de geometria
// apontando a falha. Spec `docs/progresso/T03.md` §4.
import 'dart:math' as math;

import 'package:app_leitura/features/home/presentation/sections/headline_section.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reference/inicio2/referencias_inicio2.dart';
import '../../support/fase_inicio.dart';
import '../../support/load_fonts.dart';

/// Uma caixa 100×50 em (10, 20), girada [graus] em torno do centro, com um filho 30×10 em (5, 5) — e, dentro do
/// filho, um segundo giro com o neto 4×4 em (2, 3).
Widget _girados(double graus) => Directionality(
  textDirection: TextDirection.ltr,
  child: Stack(
    children: [
      Positioned(
        left: 10,
        top: 20,
        child: SizedBox(
          key: const ValueKey('caixa'),
          width: 100,
          height: 50,
          child: Transform.rotate(
            angle: graus * math.pi / 180,
            child: Stack(
              children: [
                Positioned(
                  left: 5,
                  top: 5,
                  child: SizedBox(
                    key: const ValueKey('caixa.filho'),
                    width: 30,
                    height: 10,
                    child: Transform.rotate(
                      angle: graus * math.pi / 180,
                      child: const Stack(
                        children: [
                          Positioned(
                            left: 2,
                            top: 3,
                            child: SizedBox(
                              key: ValueKey('caixa.filho.neto'),
                              width: 4,
                              height: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);

void main() {
  setUpAll(loadAppFonts);

  test('Key do app = id da prancha sem o prefixo (01, 01b e 60 usam as mesmas widgets)', () {
    expect(keyDoId('i01.header.search'), 'header.search');
    expect(keyDoId('i01b.miniBar.cover.art'), 'miniBar.cover.art');
    expect(keyDoId('i60.review'), 'review');
    expect(keyDoId('i01.hero'), 'hero');
  });

  testWidgets(
    'retângulo de layout: os giros neutralizados, inclusive aninhados; a caixa visual com eles',
    (tester) async {
      await tester.pumpWidget(_girados(-3));
      expect(
        retanguloDeLayout(tester, 'i01.caixa'),
        const Rect.fromLTWH(10, 20, 100, 50),
      );
      expect(
        retanguloDeLayout(tester, 'i01.caixa.filho'),
        const Rect.fromLTWH(15, 25, 30, 10),
      );
      expect(
        retanguloDeLayout(tester, 'i01.caixa.filho.neto'),
        const Rect.fromLTWH(17, 28, 4, 4),
      );
      // o filho gira −3° com a caixa, em torno do centro dela (60, 45): o centro dele, (30, 30) sem o giro, fica em
      // (60, 45) + R(−3°)·(−30, −15), e a envolvente mede 30·cos + 10·sen por 30·sen + 10·cos
      final c = math.cos(3 * math.pi / 180), s = math.sin(3 * math.pi / 180);
      final visual = caixaVisual(tester, 'i01.caixa.filho');
      final esperado = Rect.fromCenter(
        center:
            const Offset(60, 45) + Offset(-30 * c - 15 * s, 30 * s - 15 * c),
        width: 30 * c + 10 * s,
        height: 30 * s + 10 * c,
      );
      expect(visual.left, closeTo(esperado.left, 1e-9));
      expect(visual.top, closeTo(esperado.top, 1e-9));
      expect(visual.width, closeTo(esperado.width, 1e-9));
      expect(visual.height, closeTo(esperado.height, 1e-9));
      // sem giro, layout = visual
      await tester.pumpWidget(_girados(0));
      expect(
        caixaVisual(tester, 'i01.caixa.filho.neto'),
        retanguloDeLayout(tester, 'i01.caixa.filho.neto'),
      );
    },
  );

  testWidgets(
    'seções no retângulo da prancha: o título da 01 passa no gate de geometria e de texto',
    (tester) async {
      await abrirSecoes01(tester, {'i01.headline': const HeadlineSection()});
      expect(tester.view.physicalSize, const Size(1170, 7950));
      // a altura do texto traz o ruído de float32 (~1e-6) — a mesma margem de 1e-3 da F02
      final r = retanguloDeLayout(tester, 'i01.headline');
      final x = kRef01.sections['i01.headline']!;
      for (final (g, e) in [
        (r.left, x.left),
        (r.top, x.top),
        (r.width, x.width),
        (r.height, x.height),
      ]) {
        expect(g, closeTo(e, 1e-3));
      }
      expect(geometria01(tester, ['i01.headline']), isEmpty);
      expect(texto01(tester, ['i01.headline']), isEmpty);
    },
  );

  testWidgets('o gate aponta o id, a medida e a tolerância que falharam', (
    tester,
  ) async {
    await abrirSecoes01(tester, {'i01.headline': const HeadlineSection()});
    final ref = kRef01.elements['i01.headline']!.rect;
    final falhas = geometria01(
      tester,
      ['i01.headline'],
      medir: {'i01.headline': (_) => ref.translate(0, 0.6)},
    );
    expect(falhas, [
      'i01.headline.y: ${(ref.top + 0.6).toStringAsFixed(2)} ≠ ${ref.top.toStringAsFixed(2)} (±0.5)',
    ]);
    // sem widget com a Key, a falha diz quantos achou
    expect(
      geometria01(tester, ['i01.header']),
      contains('i01.header: 0 widgets com a Key header'),
    );
  });
}

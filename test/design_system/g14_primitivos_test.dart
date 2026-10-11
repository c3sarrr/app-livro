// G14.3 — o que a folha de ajustes pede dos primitivos: o contorno tracejado da pílula (trilho do tamanho:
// `border: 1.5px dashed`, traço 3 e vão ~1,5 como o Chromium, medido na prancha @3x) e a opção de um grupo
// (radio: marcada ou não, num grupo exclusivo — não um botão).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/dashed_stadium_painter.dart';
import 'package:app_leitura/core/design_system/widgets/pressable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Tela implements ui.Canvas {
  final tracos = <(ui.Path, Paint)>[];

  @override
  void drawPath(ui.Path path, Paint paint) => tracos.add((path, paint));

  @override
  Float64List getTransform() => Float64List(16);

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('DashedStadiumPainter: traços de 3 com vão ~1,5 que fecham a pílula; traço de 1,5 na cor', () {
    final tela = _Tela();
    const DashedStadiumPainter(color: Color(0xFFCFC3AE))
        .paint(tela, const Size(215, 48));
    // contorno no meio do traço: 213,5 × 46,5 com raio 23,25 (≈ 2 × 167 + π × 46,5 = 480; o Skia aproxima o arco)
    final contorno =
        (Path()..addRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTWH(0.75, 0.75, 213.5, 46.5),
                const Radius.circular(23.25),
              ),
            ))
            .computeMetrics()
            .single
            .length;
    expect(contorno, moreOrLessEquals(480.08, epsilon: 4));
    expect(tela.tracos, hasLength((contorno / 4.5).round()));
    for (final (path, paint) in tela.tracos) {
      expect(
        path.computeMetrics().single.length,
        // nos arcos o Skia mede pela aproximação da curva
        moreOrLessEquals(3, epsilon: 0.15),
      );
      expect(
        (paint.style, paint.strokeWidth, paint.color.toARGB32()),
        (PaintingStyle.stroke, 1.5, 0xFFCFC3AE),
      );
    }
    final b = tela.tracos
        .map((t) => t.$1.getBounds())
        .reduce((a, c) => a.expandToInclude(c));
    expect(b.left, moreOrLessEquals(0.75, epsilon: 0.01));
    expect(b.right, moreOrLessEquals(214.25, epsilon: 0.01));
    expect(b.top, moreOrLessEquals(0.75, epsilon: 0.01));
    expect(b.bottom, moreOrLessEquals(47.25, epsilon: 0.01));
  });

  testWidgets(
    'Pressable com checked: opção de um grupo, marcada ou não (não é botão)',
    (tester) async {
      final h = tester.ensureSemantics();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Pressable(
                key: const ValueKey('a'),
                semanticsLabel: 'Lora, clássica',
                checked: true,
                onTap: () {},
                child: const SizedBox(width: 20, height: 20),
              ),
              Pressable(
                key: const ValueKey('b'),
                semanticsLabel: 'Figtree, sem serifa',
                checked: false,
                onTap: () {},
                child: const SizedBox(width: 20, height: 20),
              ),
              Pressable(
                key: const ValueKey('c'),
                semanticsLabel: 'Fechar',
                onTap: () {},
                child: const SizedBox(width: 20, height: 20),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('a'))),
        isSemantics(
          label: 'Lora, clássica',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          isButton: false,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('b'))),
        isSemantics(
          label: 'Figtree, sem serifa',
          hasCheckedState: true,
          isChecked: false,
          isInMutuallyExclusiveGroup: true,
          isButton: false,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('c'))),
        isSemantics(
          label: 'Fechar',
          isButton: true,
          hasCheckedState: false,
          isInMutuallyExclusiveGroup: false,
          hasTapAction: true,
        ),
      );
      h.dispose();
    },
  );
}

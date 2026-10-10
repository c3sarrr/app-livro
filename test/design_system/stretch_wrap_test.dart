// T03.7 — StretchWrap = `display: flex; flex-wrap: wrap` com o `align-items: stretch` do CSS (as pílulas do herói
// da prancha 01: na mesma linha a 430 px, o selo estica de 26,2 para 27,4; quebradas a 390 e 360, não).
import 'package:app_leitura/core/design_system/widgets/stretch_wrap.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _a = ValueKey('a'), _b = ValueKey('b'), _w = ValueKey('wrap');

Widget _caixa(Key key, double w, double h, {VoidCallback? onTap}) =>
    GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(width: w, height: h),
    );

Future<void> _montar(
  WidgetTester tester,
  double largura, {
  VoidCallback? onTapB,
  bool limitada = true,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: limitada
          ? SizedBox(width: largura, child: _wrap(onTapB))
          : UnconstrainedBox(
              alignment: Alignment.topLeft,
              child: _wrap(onTapB),
            ),
    ),
  ),
);

Widget _wrap(VoidCallback? onTapB) => StretchWrap(
  key: _w,
  spacing: 6,
  runSpacing: 6,
  children: [
    _caixa(_a, 100, 20),
    _caixa(_b, 60, 30, onTap: onTapB),
  ],
);

Rect _r(WidgetTester t, Key k) => t.getRect(find.byKey(k));

void main() {
  testWidgets(
    'na mesma linha: o mais baixo estica até a altura da linha; o contêiner ocupa a largura',
    (tester) async {
      await _montar(tester, 200);
      expect(_r(tester, _a), const Rect.fromLTWH(0, 0, 100, 30));
      expect(_r(tester, _b), const Rect.fromLTWH(106, 0, 60, 30));
      expect(_r(tester, _w), const Rect.fromLTWH(0, 0, 200, 30));
    },
  );

  testWidgets(
    'quebrado: cada linha com a altura do filho (sem esticar) e o gap entre linhas',
    (tester) async {
      await _montar(tester, 150);
      expect(_r(tester, _a), const Rect.fromLTWH(0, 0, 100, 20));
      expect(_r(tester, _b), const Rect.fromLTWH(0, 26, 60, 30));
      expect(_r(tester, _w), const Rect.fromLTWH(0, 0, 150, 56));
    },
  );

  testWidgets(
    'a quebra é a do CSS: cabe com x + gap + largura = limite; passa por qualquer fração',
    (tester) async {
      await _montar(tester, 166);
      expect(_r(tester, _b).top, 0);
      await _montar(tester, 165.9);
      expect(_r(tester, _b).top, 26);
    },
  );

  testWidgets(
    'altura intrínseca = a do layout (o herói mede a linha da capa com IntrinsicHeight)',
    (tester) async {
      for (final w in [200.0, 150.0]) {
        await _montar(tester, w);
        final box = tester.renderObject<RenderBox>(find.byKey(_w));
        expect(box.getMinIntrinsicHeight(w), box.size.height);
        expect(box.getMaxIntrinsicHeight(w), box.size.height);
        expect(box.getDryLayout(BoxConstraints.tightFor(width: w)), box.size);
      }
      final box = tester.renderObject<RenderBox>(find.byKey(_w));
      expect(box.getMaxIntrinsicWidth(double.infinity), 166);
      expect(box.getMinIntrinsicWidth(double.infinity), 100);
    },
  );

  testWidgets('sem largura limitada: a largura da linha mais larga', (
    tester,
  ) async {
    await _montar(tester, 0, limitada: false);
    expect(_r(tester, _w), const Rect.fromLTWH(0, 0, 166, 30));
  });

  testWidgets(
    'o toque chega ao filho na posição dele; trocar o gap refaz o layout',
    (tester) async {
      var toques = 0;
      await _montar(tester, 150, onTapB: () => toques++);
      await tester.tapAt(const Offset(30, 40));
      expect(toques, 1);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 150,
              child: StretchWrap(
                key: _w,
                spacing: 6,
                runSpacing: 10,
                children: [_caixa(_a, 100, 20), _caixa(_b, 60, 30)],
              ),
            ),
          ),
        ),
      );
      expect(_r(tester, _b).top, 30);
    },
  );
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configura a "tela" do teste no tamanho LÓGICO do canvas da Início (390×2650, a prancha 01 — T03)
/// com DPR 3, e safe areas zeradas (no canvas o inset de 62 px já é do layout).
void setCanvasView(
  WidgetTester tester, {
  Size logical = const Size(390, 2650),
  double dpr = 3,
  double safeTop = 0,
  double safeBottom = 0,
}) {
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logical * dpr;
  tester.view.viewPadding = FakeViewPadding(
    top: safeTop * dpr,
    bottom: safeBottom * dpr,
  );
  tester.view.padding = FakeViewPadding(
    top: safeTop * dpr,
    bottom: safeBottom * dpr,
  );
  addTearDown(tester.view.reset);
}

/// Raiz capturada pelos goldens.
const goldenRootKey = ValueKey<String>('golden-root');

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captura o [RenderRepaintBoundary] de [finder] (ou o mais próximo acima dele) em [pixelRatio]×.
///
/// O `matchesGoldenFile(Finder)` do flutter_test captura a 1× (`OffsetLayer.toImage` com
/// `pixelRatio` 1, qualquer que seja o devicePixelRatio da view — verificado neste SDK: view com
/// DPR 3 e caixa de 100×50 gera um PNG de 100×50). Os goldens "@3x" (comparáveis às referências @3x)
/// usam esta captura: `expectLater(await captureAt(tester, finder), matchesGoldenFile(...))`.
Future<ui.Image> captureAt(
  WidgetTester tester,
  Finder finder, {
  double pixelRatio = 3,
}) async {
  RenderObject node = tester.renderObject(finder);
  while (node is! RenderRepaintBoundary) {
    node = node.parent!;
  }
  final boundary = node;
  final image = await tester.runAsync(
    () => boundary.toImage(pixelRatio: pixelRatio),
  );
  return image!;
}

/// Pixels RGBA (8 bits por canal, sem pré-multiplicar) de [image].
Future<Uint8List> rgbaOf(WidgetTester tester, ui.Image image) async {
  final data = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.rawStraightRgba),
  );
  return data!.buffer.asUint8List();
}

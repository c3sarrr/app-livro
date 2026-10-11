import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// = `display: flex; flex-wrap: wrap; gap: [runSpacing] [spacing]` com o `align-items: stretch` padrão do CSS: os
/// filhos quebram em linhas como no `Wrap` (o que não cabe desce inteiro) e, numa linha com mais de um, cada filho
/// estica até a altura da linha — o `Wrap` do Flutter não estica (T03: as pílulas "pág. 159 de 256" e "E-BOOK" do
/// herói; a 430 px ficam na mesma linha e o selo de 26,2 vai a 27,4). O contêiner ocupa a largura disponível (bloco).
class StretchWrap extends MultiChildRenderObjectWidget {
  const StretchWrap({
    super.key,
    this.spacing = 0,
    this.runSpacing = 0,
    super.children,
  });

  /// Espaço entre os filhos de uma linha (o `column-gap`).
  final double spacing;

  /// Espaço entre as linhas (o `row-gap`).
  final double runSpacing;

  @override
  RenderStretchWrap createRenderObject(BuildContext context) =>
      RenderStretchWrap(spacing: spacing, runSpacing: runSpacing);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStretchWrap renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class StretchWrapParentData extends ContainerBoxParentData<RenderBox> {}

/// O layout do [StretchWrap]. Cada filho é medido solto (até a largura da linha); as linhas se formam como no CSS
/// (o filho desce quando `x + spacing + largura` passa da largura); numa linha com mais de um filho, eles são
/// medidos de novo com a altura da linha.
class RenderStretchWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StretchWrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StretchWrapParentData> {
  RenderStretchWrap({this._spacing = 0, this._runSpacing = 0});

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  double get runSpacing => _runSpacing;
  double _runSpacing;
  set runSpacing(double value) {
    if (value == _runSpacing) return;
    _runSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! StretchWrapParentData) {
      child.parentData = StretchWrapParentData();
    }
  }

  List<RenderBox> get _children {
    final out = <RenderBox>[];
    for (var c = firstChild; c != null; c = childAfter(c)) {
      out.add(c);
    }
    return out;
  }

  /// As linhas para a largura [maxWidth], com o tamanho solto de cada filho ([medir]).
  List<List<(RenderBox, Size)>> _linhas(
    double maxWidth,
    Size Function(RenderBox child, BoxConstraints c) medir,
  ) {
    final linhas = <List<(RenderBox, Size)>>[];
    var x = 0.0;
    for (final c in _children) {
      final s = medir(c, BoxConstraints(maxWidth: maxWidth));
      if (linhas.isEmpty || x + spacing + s.width > maxWidth) {
        linhas.add([(c, s)]);
        x = s.width;
      } else {
        linhas.last.add((c, s));
        x += spacing + s.width;
      }
    }
    return linhas;
  }

  /// A altura de uma linha (a do filho mais alto).
  static double _altura(List<(RenderBox, Size)> linha) =>
      linha.map((e) => e.$2.height).reduce(math.max);

  Size _tamanho(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints c) medir,
  ) {
    final linhas = _linhas(constraints.maxWidth, medir);
    if (linhas.isEmpty) return constraints.smallest;
    final altura =
        linhas.map(_altura).reduce((a, b) => a + b) +
        runSpacing * (linhas.length - 1);
    final largura = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : linhas
              .map(
                (l) =>
                    l.map((e) => e.$2.width).reduce((a, b) => a + b) +
                    spacing * (l.length - 1),
              )
              .reduce(math.max);
    return constraints.constrain(Size(largura, altura));
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      _tamanho(constraints, (c, k) => c.getDryLayout(k));

  @override
  void performLayout() {
    final linhas = _linhas(constraints.maxWidth, (c, k) {
      c.layout(k, parentUsesSize: true);
      return c.size;
    });
    var y = 0.0;
    for (final linha in linhas) {
      final h = _altura(linha);
      var x = 0.0;
      for (final (c, s) in linha) {
        // align-items: stretch — numa linha com mais de um filho, a altura da linha (a largura não muda)
        if (linha.length > 1 && s.height != h) {
          c.layout(
            BoxConstraints.tightFor(width: s.width, height: h),
            parentUsesSize: true,
          );
        }
        (c.parentData! as StretchWrapParentData).offset = Offset(x, y);
        x += s.width + spacing;
      }
      y += h + runSpacing;
    }
    size = _tamanho(constraints, (c, _) => c.size);
  }

  @override
  double computeMinIntrinsicWidth(double height) => _children.fold(
    0,
    (m, c) => math.max(m, c.getMinIntrinsicWidth(double.infinity)),
  );

  @override
  double computeMaxIntrinsicWidth(double height) {
    final cs = _children;
    if (cs.isEmpty) return 0;
    return cs
            .map((c) => c.getMaxIntrinsicWidth(double.infinity))
            .reduce((a, b) => a + b) +
        spacing * (cs.length - 1);
  }

  @override
  double computeMinIntrinsicHeight(double width) => _tamanho(
    BoxConstraints(maxWidth: width),
    (c, k) => c.getDryLayout(k),
  ).height;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}

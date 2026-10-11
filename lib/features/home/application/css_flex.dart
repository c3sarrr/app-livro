import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Resolve larguras de [texto (flex-grow 1, flex-shrink 1, min-width 0)] + [selo (flex-shrink 1, min-width =
/// min-content)] exatamente como o CSS Flexbox (§9.7 "Resolving Flexible Lengths").
///
/// `Expanded`/`Flexible` do Flutter NÃO reproduzem isso: o CSS encolhe os itens em proporção ao
/// `flex-shrink × flex base size INTERNA` (sem o padding), e o Flutter, ao dividir o espaço, não tem o conceito
/// de base interna nem de `min-width: auto`.
///
/// - Cabe tudo na largura natural → o texto (flex-grow 1) fica com a sobra e o selo com a largura natural.
/// - Estoura → o estouro é repartido entre os dois, proporcionalmente à base interna de cada um.
/// - O selo nunca encolhe abaixo do min-content (a maior palavra + padding); se o fator pedir menos, ele
///   congela nesse mínimo e o texto fica com o resto.
({double text, double tag}) resolveTextAndTag({
  required double available, // 198 no canvas 390
  required double
  textMaxContent, // max(título, subtítulo) em largura intrínseca
  required double tagTextMaxContent, // largura do texto do selo
  required double tagTextMinContent, // maior palavra do selo
  double tagHorizontalPadding = 20, // 10 + 10
}) {
  final tagBase = tagTextMaxContent + tagHorizontalPadding;
  if (textMaxContent + tagBase <= available) {
    return (text: available - tagBase, tag: tagBase); // texto cresce
  }
  final overflow = textMaxContent + tagBase - available;
  final scaledTotal =
      textMaxContent + tagTextMaxContent; // fator = flex-shrink × base INTERNA
  var text = textMaxContent - overflow * textMaxContent / scaledTotal;
  var tag = tagBase - overflow * tagTextMaxContent / scaledTotal;
  final tagMin = tagTextMinContent + tagHorizontalPadding;
  if (tag < tagMin) {
    tag = tagMin;
    text = available - tag;
  }
  // `min-width: 0` do texto: numa linha estreita demais o selo congela no mínimo e o texto some (0), nunca
  // negativo (a linha transborda, como no CSS).
  return (text: math.max(0.0, text), tag: tag);
}

/// Largura intrínseca máxima (max-content) de uma linha de texto com [style]: o `ui.Paragraph` é diagramado sem
/// limite de largura e a medida não é arredondada — a mesma que o `AppText` usa para o shrink-to-fit.
double measure(String text, TextStyle style) {
  final paragraph = _layout(text, style);
  final width = paragraph.maxIntrinsicWidth;
  paragraph.dispose();
  return width;
}

/// Largura intrínseca mínima (min-content) de [text]: a maior palavra (os espaços são as únicas oportunidades de
/// quebra; o espaço final não conta).
double longestWord(String text, TextStyle style) {
  var longest = 0.0;
  for (final word in text.split(RegExp(r'\s+'))) {
    if (word.isEmpty) continue;
    final width = measure(word, style);
    if (width > longest) longest = width;
  }
  return longest;
}

ui.Paragraph _layout(String text, TextStyle style) {
  // Mesmo caminho do `RenderAppText` (estilo → parágrafo com distribuição "even"); a largura não depende de
  // altura/leading, mas a configuração fica idêntica.
  final builder = ui.ParagraphBuilder(
    style.getParagraphStyle(
      textDirection: TextDirection.ltr,
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
    ),
  );
  TextSpan(text: text, style: style).build(builder);
  return builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
}

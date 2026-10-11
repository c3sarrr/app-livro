// G11.1 — áreas do leitor com as áreas seguras do aparelho (D-112, como a D-02 da v1). No canvas (sem área
// segura) e num iPhone 390×844 (47/34) dá exatamente o arquivo: topo do texto 92, base do texto 82, rodapé 40.
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

@immutable
final class ReaderInsets {
  const ReaderInsets({
    required this.top,
    required this.bottom,
    required this.footerBottom,
  });

  factory ReaderInsets.of(EdgeInsets viewPadding) => ReaderInsets(
    top: math.max(92.0, viewPadding.top + 45),
    bottom: math.max(82.0, viewPadding.bottom + 48),
    footerBottom: math.max(40.0, viewPadding.bottom + 6),
  );

  /// Topo e base da caixa do texto (o `article` da tela 19: `top 92`, `bottom 82`).
  final double top;
  final double bottom;

  /// Distância do rodapé à base da tela (`bottom 40`).
  final double footerBottom;
}

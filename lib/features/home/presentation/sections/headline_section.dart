import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_typography.dart';

/// Seção 2 — Título editorial (F04): um `<h1>` de duas linhas e duas fontes.
/// Uma coluna com um `AppText` por linha: as linhas têm letter-spacing diferente (−1,4 e −0,6) e o
/// `RenderAppText` desfaz o deslocamento de meio letter-spacing do SkParagraph por parágrafo.
/// `line-height: 0.98` herdado como fator → linhas de 41,16 + 49 = 90,16; baselines 34,44 e 82,66.
class HeadlineSection extends StatelessWidget {
  const HeadlineSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      header: true,
      headingLevel: 1, // <h1>
      label: 'Continue sua história.',
      excludeSemantics: true, // os dois AppText não geram nós próprios
      child: Column(
        key: const ValueKey('headline'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText('Continue', style: AppTextStyles.displayXL),
          AppText('sua história.', style: AppTextStyles.displaySerifXL),
        ],
      ),
    );
  }
}

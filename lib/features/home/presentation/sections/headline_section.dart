import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../application/home_providers.dart';

/// Seção 2 — Título editorial (F04): um `<h1>` de duas linhas e duas fontes.
/// Uma coluna com um `AppText` por linha: as linhas têm letter-spacing diferente (−1,4 e −0,6) e o
/// `RenderAppText` desfaz o deslocamento de meio letter-spacing do SkParagraph por parágrafo.
/// `line-height: 0.98` herdado como fator → linhas de 41,16 + 49 = 90,16; baselines 34,44 e 82,66.
/// Sem livro em leitura, "Comece *sua história.*" (D-78).
class HeadlineSection extends ConsumerWidget {
  const HeadlineSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = ref.watch(
      homeSnapshotProvider.select((s) => s.continueReading == null),
    );
    final verb = start ? 'Comece' : 'Continue';
    return Semantics(
      container: true,
      header: true,
      headingLevel: 1, // <h1>
      label: '$verb sua história.',
      excludeSemantics: true, // os dois AppText não geram nós próprios
      child: Column(
        key: const ValueKey('headline'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(verb, style: AppTextStyles.displayXL),
          AppText('sua história.', style: AppTextStyles.displaySerifXL),
        ],
      ),
    );
  }
}

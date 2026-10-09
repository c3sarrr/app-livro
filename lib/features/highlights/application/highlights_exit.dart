// G19.8 — o que a tela 25 devolve ao leitor que a abriu (R13): abrir num trecho (o 1º item do cartão tocado) ou
// continuar lendo onde estava. Voltar devolve nada.
import 'package:flutter/foundation.dart' show immutable;

@immutable
sealed class HighlightsExit {
  const HighlightsExit();
}

/// Tocar num cartão: o leitor salta para [annotationId] (o 1º item do cartão); [orphan] = o trecho não está mais no
/// texto (D-199: o salto vai à página [page] com o aviso).
final class HighlightsOpenAt extends HighlightsExit {
  const HighlightsOpenAt(
    this.annotationId, {
    required this.page,
    this.orphan = false,
  });

  final String annotationId;
  final int page;
  final bool orphan;

  @override
  bool operator ==(Object other) =>
      other is HighlightsOpenAt &&
      other.annotationId == annotationId &&
      other.page == page &&
      other.orphan == orphan;

  @override
  int get hashCode => Object.hash(annotationId, page, orphan);
}

/// "Continuar lendo · pág. N": volta ao leitor sem salto.
final class HighlightsContinue extends HighlightsExit {
  const HighlightsContinue();

  @override
  bool operator ==(Object other) => other is HighlightsContinue;

  @override
  int get hashCode => 1;
}

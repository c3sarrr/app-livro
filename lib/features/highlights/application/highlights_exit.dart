// G19.8 — o que a tela 25 devolve ao leitor que a abriu (R13): abrir num trecho (o 1º item do cartão tocado) ou
// continuar lendo onde estava. Voltar devolve nada.
// G20 (R5): a saída vai por um canal do app ([HighlightsExitBus]), não pelo resultado do `push` — restaurada pelo
// sistema (D-207), a 25 fica sobre um leitor refeito, que não espera mais o resultado.
import 'dart:async';

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

/// R5 (G20): a saída da 25 para o leitor do mesmo livro. O leitor escuta desde que abre — inclusive restaurado, quando
/// ninguém mais espera o resultado do `push`.
final class HighlightsExitBus {
  final StreamController<(String, HighlightsExit)> _out =
      StreamController.broadcast();

  void post(String bookId, HighlightsExit exit) => _out.add((bookId, exit));

  Stream<HighlightsExit> of(String bookId) =>
      _out.stream.where((e) => e.$1 == bookId).map((e) => e.$2);

  Future<void> dispose() => _out.close();
}

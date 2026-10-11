// T04 — D-256/D-260: o que a folha da sessão manda gravar ao encerrar, a partir da página e do total digitados (só
// dígitos; os dois opcionais). Uma página pede o total (o do livro ou o digitado) e cabe em 1…N; sem página, o total
// digitado ainda vai para o livro junto com a sessão — menos de 10 s sem página é descartar e nada é gravado, nem o
// total (R3). O que não passa volta como o aviso da folha, e nada é encerrado.
import 'package:flutter/foundation.dart' show immutable;

import 'paper_timer_format.dart';

sealed class PaperEndForm {
  const PaperEndForm();

  /// Lê os campos da folha. [bookTotal] = o total que o livro já tem (com ele, a folha não mostra o campo do total e
  /// [total] é ignorado — o livro não é regravado).
  static PaperEndForm read({
    required String page,
    required String total,
    required int? bookTotal,
  }) {
    final p = _number(page);
    final typed = bookTotal == null ? _number(total) : null;
    // um total 0 não vale (o livro tem ao menos 1 página)
    final t = typed != null && typed > 0 ? typed : null;
    final pagesTotal = bookTotal ?? t;
    if (p != null) {
      if (pagesTotal == null) {
        return const PaperEndRejected(PaperTimerFormat.totalRequired);
      }
      if (p < 1 || p > pagesTotal) {
        return PaperEndRejected(PaperTimerFormat.pageRange(pagesTotal));
      }
    }
    return PaperEndAccepted(page: p, pagesTotal: t);
  }

  static int? _number(String text) {
    final s = text.trim();
    return s.isEmpty ? null : int.tryParse(s);
  }
}

/// Pode encerrar: a página (ou nenhuma) e o total novo do livro (ou nenhum).
@immutable
final class PaperEndAccepted extends PaperEndForm {
  const PaperEndAccepted({this.page, this.pagesTotal});

  final int? page;
  final int? pagesTotal;

  @override
  bool operator ==(Object other) =>
      other is PaperEndAccepted &&
      other.page == page &&
      other.pagesTotal == pagesTotal;

  @override
  int get hashCode => Object.hash(page, pagesTotal);

  @override
  String toString() => 'PaperEndAccepted(page: $page, total: $pagesTotal)';
}

/// Não encerra: o aviso da folha.
@immutable
final class PaperEndRejected extends PaperEndForm {
  const PaperEndRejected(this.notice);

  final String notice;

  @override
  bool operator ==(Object other) =>
      other is PaperEndRejected && other.notice == notice;

  @override
  int get hashCode => notice.hashCode;

  @override
  String toString() => 'PaperEndRejected($notice)';
}

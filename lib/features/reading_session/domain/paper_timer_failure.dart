// T04 — as falhas tipadas do cronômetro do livro de papel (§4.5 do prompt mestre: `sealed class` de falhas).

/// Uma falha esperada do cronômetro, que a tela trata.
sealed class PaperTimerFailure implements Exception {
  const PaperTimerFailure();
}

/// O livro da sessão foi apagado ou não é do dono ativo: a sessão não tem onde gravar.
final class PaperBookGone extends PaperTimerFailure {
  const PaperBookGone();

  @override
  String toString() => 'PaperBookGone: o livro da sessão não está na estante';
}

/// Já há outra sessão aberta — uma por vez (D-262): a tela abre a folha dela.
final class PaperSessionAlreadyOpen extends PaperTimerFailure {
  const PaperSessionAlreadyOpen();

  @override
  String toString() => 'PaperSessionAlreadyOpen: já há uma sessão aberta';
}

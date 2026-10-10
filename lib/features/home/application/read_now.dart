// T04 — "Ler agora" do "Seu dia de leitura" (`today.readNow`, rótulo da prancha "Iniciar leitura (cronômetro)"):
// D-258 e R11 da spec docs/progresso/T04.md. Com uma sessão do papel aberta, age nela; sem sessão, o cronômetro do
// livro de papel em leitura mais recente (o herói, se for de papel; senão o 1º de papel do Também lendo, na ordem de
// leitura — inclusive além dos 2 cartões da grade); sem livro de papel em leitura, o herói no leitor (o e-book conta
// sozinho); sem nada em leitura, nada.
import 'package:flutter/foundation.dart' show immutable;

import '../../reading_session/domain/open_paper_session.dart';
import '../domain/models.dart';

/// O que o toque no "Ler agora" faz.
@immutable
sealed class ReadNowAction {
  const ReadNowAction();
}

/// A sessão aberta está pausada: retoma.
final class ResumeSession extends ReadNowAction {
  const ResumeSession();

  @override
  bool operator ==(Object other) => other is ResumeSession;

  @override
  int get hashCode => (ResumeSession).hashCode;
}

/// A sessão aberta já roda: nada.
final class KeepRunning extends ReadNowAction {
  const KeepRunning();

  @override
  bool operator ==(Object other) => other is KeepRunning;

  @override
  int get hashCode => (KeepRunning).hashCode;
}

/// Começa o cronômetro de [book] (livro de papel).
final class StartTimer extends ReadNowAction {
  const StartTimer(this.book);

  final Book book;

  @override
  bool operator ==(Object other) => other is StartTimer && other.book == book;

  @override
  int get hashCode => Object.hash(StartTimer, book);
}

/// Abre [book] (e-book ou PDF) no leitor.
final class OpenReader extends ReadNowAction {
  const OpenReader(this.book);

  final Book book;

  @override
  bool operator ==(Object other) => other is OpenReader && other.book == book;

  @override
  int get hashCode => Object.hash(OpenReader, book);
}

/// Nada em leitura (R11).
final class NoAction extends ReadNowAction {
  const NoAction();

  @override
  bool operator ==(Object other) => other is NoAction;

  @override
  int get hashCode => (NoAction).hashCode;
}

/// A regra da D-258 sobre o instantâneo da Início ([hero], [alsoReading] na ordem de leitura) e a sessão aberta.
ReadNowAction readNowAction({
  required ContinueReading? hero,
  required List<AlsoReadingItem> alsoReading,
  required OpenPaperSession? open,
}) {
  if (open != null) {
    return open.isRunning ? const KeepRunning() : const ResumeSession();
  }
  if (hero == null) return const NoAction();
  if (hero.format == BookFormat.physical) return StartTimer(hero.book);
  for (final item in alsoReading) {
    if (item.format == BookFormat.physical) return StartTimer(item.book);
  }
  return OpenReader(hero.book);
}

// G15.2 (D-149) — o clube que lê este livro, para a faixa do sumário (tela 27): nome, próximo encontro e a meta em
// capítulo (contado de 1). A G21 liga aos clubes (`ClubsReaderClubSource`): a meta é o fim da semana atual, no número
// do clube (R2, D-214).

/// A meta do clube para a faixa: "LEITORAS DE CAPITU · QUI 24/9" e "Até o cap. L · faltam 18". [goalChapter] = o cap.
/// do clube (o N-º capítulo numerado do livro); [goalLabel] = o rótulo do clube para livro sem numeração.
typedef ReaderClubGoal = ({
  String name,
  DateTime? nextMeeting,
  int goalChapter,
  String? goalLabel,
});

abstract interface class ReaderClubSource {
  /// O clube da conta [owner] que lê o livro [userBookId]; `null` = a faixa some.
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId);
}

/// Nenhum clube (o convidado, ou sem servidor).
final class NoReaderClub implements ReaderClubSource {
  const NoReaderClub();

  @override
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId) async =>
      null;
}

/// O deslocamento do fuso do aparelho no instante [utc] (as datas da folha: "marcada hoje", "QUI 24/9").
Duration readerUtcOffset(DateTime utc) => utc.toLocal().timeZoneOffset;

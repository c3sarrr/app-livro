// G15.2 (D-149) — o clube que lê este livro, para a faixa do sumário (tela 27): nome, próximo encontro e a meta em
// capítulo (contado de 1). A G21 liga aos clubes; até lá, nenhum — a faixa some, como o ticket da Início (D-80).

/// A meta do clube para a faixa: "LEITORAS DE CAPITU · QUI 24/9" e "Até o cap. L · faltam 18".
typedef ReaderClubGoal = ({
  String name,
  DateTime? nextMeeting,
  int goalChapter,
});

abstract interface class ReaderClubSource {
  /// O clube da conta [owner] que lê o livro [userBookId]; `null` = a faixa some.
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId);
}

/// Nenhum clube (até a G21).
final class NoReaderClub implements ReaderClubSource {
  const NoReaderClub();

  @override
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId) async =>
      null;
}

/// O deslocamento do fuso do aparelho no instante [utc] (as datas da folha: "marcada hoje", "QUI 24/9").
Duration readerUtcOffset(DateTime utc) => utc.toLocal().timeZoneOffset;

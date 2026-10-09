// G19.2 — o clube de um item compartilhado (o chip da tela 25): o id, o nome e o número de respostas. A G21 liga aos
// clubes; até lá, nenhum (o chip não aparece — R8), como a faixa do sumário (D-149).

/// O chip "Leitoras de Capitu · 3 respostas".
typedef ClubChip = ({String clubId, String name, int replies});

abstract interface class HighlightsClubSource {
  /// O clube do post [sharedClubPostId]; `null` = o chip não aparece.
  Future<ClubChip?> clubOf(String sharedClubPostId);
}

/// Nenhum clube (até a G21).
final class NoHighlightsClub implements HighlightsClubSource {
  const NoHighlightsClub();

  @override
  Future<ClubChip?> clubOf(String sharedClubPostId) async => null;
}

// G19.2 — o clube de um item compartilhado (o chip da tela 25): o id, o nome e o número de respostas. A G21 liga aos
// clubes (`ClubsHighlightsClubSource`, do cache) e põe o chip ao vivo ([ClubChipUpdates]); sem conta, nenhum (o chip
// não aparece — R8), como a faixa do sumário (D-149).

/// O chip "Leitoras de Capitu · 3 respostas".
typedef ClubChip = ({String clubId, String name, int replies});

abstract interface class HighlightsClubSource {
  /// O clube do post [sharedClubPostId]; `null` = o chip não aparece.
  Future<ClubChip?> clubOf(String sharedClubPostId);
}

/// Nenhum clube (o convidado, ou sem servidor).
final class NoHighlightsClub implements HighlightsClubSource {
  const NoHighlightsClub();

  @override
  Future<ClubChip?> clubOf(String sharedClubPostId) async => null;
}

/// G21.5 (D-225) — o chip ao vivo: ao abrir a 25, relê os resumos dos posts compartilhados (uma ida) e acompanha os
/// clubes deles; cada evento = os chips mudaram (o [HighlightsClubSource] lê de novo). Cancelar fecha os canais.
abstract interface class ClubChipUpdates {
  Stream<void> follow(Set<String> postIds);
}

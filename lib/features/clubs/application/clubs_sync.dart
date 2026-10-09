// G21.4 — a atualização do social (docs/progresso/G21.md §4 e §5; D-225): ao abrir o app e ao voltar a ele, com
// conta, os meus clubes (o ticket sai daqui — R3) e a contagem do sininho; ao abrir a 25, os resumos do chip dos
// itens compartilhados. Sem rede (ou qualquer falha), o cache fica como estava: a tela mostra o último dado.
import '../../social/data/community_repository.dart';
import '../../social/domain/social_failure.dart';
import '../data/clubs_cache.dart';
import '../data/clubs_repository.dart';

final class ClubsSync {
  ClubsSync({
    required this._clubs,
    required this._notifications,
    required this._cache,
  });

  final ClubsRepository _clubs;
  final NotificationsRepository _notifications;
  final ClubsCache _cache;

  /// Relê os meus clubes e a contagem do sininho da conta [owner]. Devolve a falha dos clubes, se houve (a tela
  /// que pediu na hora — o "Atualizar" — mostra a pílula; o ciclo do app ignora).
  Future<SocialFailure?> refresh(String owner) async {
    SocialFailure? failed;
    try {
      final mine = await _clubs.myClubs();
      await _cache.saveClubs(owner, mine.json);
    } on SocialFailure catch (f) {
      failed = f;
    }
    try {
      await _cache.saveNotifications(owner, await _notifications.unreadCount());
    } on SocialFailure {
      // o ponto do sininho fica como estava
    }
    return failed;
  }

  /// Os resumos do chip dos posts [postIds] (a 25 aberta, ou um aviso do tempo real): uma ida.
  Future<SocialFailure?> refreshPosts(
    String owner,
    Iterable<String> postIds,
  ) async {
    final ids = postIds.toSet();
    if (ids.isEmpty) return null;
    try {
      await _cache.savePosts(owner, ids, await _clubs.postSummaries(ids));
      return null;
    } on SocialFailure catch (f) {
      return f;
    }
  }
}

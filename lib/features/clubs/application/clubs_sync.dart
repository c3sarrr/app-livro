// G21.4 — a atualização do social (docs/progresso/G21.md §4 e §5; D-225): ao abrir o app e ao voltar a ele, com
// conta, os meus clubes (o ticket sai daqui — R3) e a contagem do sininho; ao abrir a 25, os resumos do chip dos
// itens compartilhados. Sem rede (ou qualquer falha), o cache fica como estava: a tela mostra o último dado. A conta
// saiu ou trocou enquanto o servidor respondia: nada vai para o cache da antiga (D-68).
import '../../social/data/community_repository.dart';
import '../../social/domain/social_failure.dart';
import '../data/clubs_cache.dart';
import '../data/clubs_repository.dart';
import 'publishers.dart' show CurrentOwner;

bool _anyOwner(String _) => true;

final class ClubsSync {
  ClubsSync({
    required this._clubs,
    required this._notifications,
    required this._cache,
    this._isCurrent = _anyOwner,
  });

  final ClubsRepository _clubs;
  final NotificationsRepository _notifications;
  final ClubsCache _cache;
  final CurrentOwner _isCurrent;

  /// Relê os meus clubes e a contagem do sininho da conta [owner]. Devolve a falha dos clubes, se houve (a tela
  /// que pediu na hora — o "Atualizar" — mostra a pílula; o ciclo do app ignora).
  Future<SocialFailure?> refresh(String owner) async {
    if (!_isCurrent(owner)) return const SocialNeedsAccount();
    SocialFailure? failed;
    try {
      final mine = await _clubs.myClubs();
      if (!_isCurrent(owner)) return const SocialNeedsAccount();
      await _cache.saveClubs(owner, mine.json);
    } on SocialFailure catch (f) {
      failed = f;
    }
    try {
      final unread = await _notifications.unreadCount();
      if (!_isCurrent(owner)) return const SocialNeedsAccount();
      await _cache.saveNotifications(owner, unread);
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
    if (!_isCurrent(owner)) return const SocialNeedsAccount();
    try {
      final got = await _clubs.postSummaries(ids);
      if (!_isCurrent(owner)) return const SocialNeedsAccount();
      await _cache.savePosts(owner, ids, got);
      return null;
    } on SocialFailure catch (f) {
      return f;
    }
  }
}

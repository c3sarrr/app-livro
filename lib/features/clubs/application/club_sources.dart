// G21.5 — os 4 pontos já desenhados ligados aos clubes (docs/progresso/G21.md §5): a faixa do sumário (27), o chip
// da 25 ao vivo e o "Compartilhar no clube". Leem o cache por conta (sem rede, o último dado); o que vai ao servidor
// passa pelos repositórios (só com conta e rede). O ticket da Início continua o `CachedClubTicketSource` (G08).
import 'dart:async';
import 'dart:math' as math;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/content_daos.dart';
import '../../../core/data/database/daos/library_daos.dart';
import '../../highlights/application/highlights_club_source.dart';
import '../../highlights/application/highlights_share.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/application/reader_club_source.dart';
import '../../reader/application/toc_view.dart' show chapterNumerals;
import '../../reader/content/book_index.dart';
import '../../reader/domain/locator.dart';
import '../../social/data/community_repository.dart';
import '../../social/domain/social_failure.dart';
import '../data/club_pings.dart';
import '../data/clubs_cache.dart';
import '../data/clubs_repository.dart';
import '../domain/club_models.dart';
import '../domain/club_rules.dart';
import 'clubs_sync.dart';

/// A conta com que o social fala (o id da conta entrada); `null` = convidado.
typedef SocialOwner = Future<String?> Function();

/// A faixa do sumário (27): o clube que lê o livro (R1, do encontro mais próximo) e a meta da semana atual (R4), no
/// número do clube (o sumário mostra pelo numeral do livro — R2).
final class ClubsReaderClubSource implements ReaderClubSource {
  ClubsReaderClubSource(this._cache);

  final ClubsCache _cache;

  @override
  Future<ReaderClubGoal?> goalFor(String owner, String userBookId) async {
    final book = await _cache.book(owner, userBookId);
    if (book == null) return null;
    for (final c in clubsReading(await _cache.clubs(owner), book)) {
      final w = c.reading?.currentWeek;
      if (w == null) continue;
      return (
        name: c.name,
        nextMeeting: c.nextMeeting?.startsAt,
        goalChapter: w.to,
        goalLabel: w.toLabel,
      );
    }
    return null;
  }
}

/// O chip da 25 ("Leitoras de Capitu · 3 respostas"), do cache.
final class ClubsHighlightsClubSource implements HighlightsClubSource {
  ClubsHighlightsClubSource({required this._owner, required this._cache});

  final SocialOwner _owner;
  final ClubsCache _cache;

  @override
  Future<ClubChip?> clubOf(String sharedClubPostId) async {
    final owner = await _owner();
    if (owner == null) return null;
    final s = (await _cache.posts(owner))[sharedClubPostId];
    return s == null
        ? null
        : (clubId: s.clubId, name: s.clubName, replies: s.replies);
  }
}

/// O chip ao vivo (D-225): relê os resumos dos posts (uma ida) e ouve os clubes deles; cada aviso relê. Cancelar
/// fecha os canais.
final class ClubsChipUpdates implements ClubChipUpdates {
  ClubsChipUpdates({
    required this._owner,
    required this._sync,
    required this._cache,
    this._channels,
    this._settle = const Duration(seconds: 2),
  });

  final SocialOwner _owner;
  final ClubsSync _sync;
  final ClubsCache _cache;
  final ClubChannelOpener? _channels;

  /// A espera para juntar avisos seguidos (os testes usam zero).
  final Duration _settle;

  @override
  Stream<void> follow(Set<String> postIds) {
    late final StreamController<void> out;
    ClubPings? pings;
    StreamSubscription<String>? sub;
    var closed = false;

    Future<void> start() async {
      final owner = await _owner();
      if (owner == null || closed) return;
      Future<void> refresh() async {
        try {
          final failed = await _sync.refreshPosts(owner, postIds);
          if (failed == null && !closed) out.add(null);
        } on Object catch (e, st) {
          // o banco do aparelho falhou: vai para quem ouve (a 25 relata), nunca solto
          if (!closed) out.addError(e, st);
        }
      }

      await refresh();
      final opener = _channels;
      if (opener == null || closed) return;
      final clubs = {
        for (final s in (await _cache.posts(owner)).values)
          if (postIds.contains(s.id)) s.clubId,
      };
      if (closed || clubs.isEmpty) return;
      final p = pings = ClubPings(opener, settle: _settle);
      sub = p.changes.listen((_) => unawaited(refresh()));
      await p.watch(clubs);
      if (closed) await p.close();
    }

    out = StreamController<void>(
      onListen: () => unawaited(
        start().catchError((Object e, StackTrace st) {
          if (!closed) out.addError(e, st);
        }),
      ),
      onCancel: () async {
        closed = true;
        await sub?.cancel();
        await pings?.close();
      },
    );
    return out.stream;
  }
}

/// "Compartilhar no clube" (D-217): o trecho, a cor, a página, o capítulo do clube (R2) e a fração do livro (o
/// spoiler — D-218). A nota fica no aparelho.
final class ClubsHighlightsShare implements HighlightsShare {
  ClubsHighlightsShare({
    required this._owner,
    required this._cache,
    required this._clubs,
    required this._terms,
    required this._database,
  });

  final SocialOwner _owner;
  final ClubsCache _cache;
  final ClubsRepository _clubs;
  final TermsRepository _terms;
  final Future<AppDatabase> Function() _database;

  Future<String> _me() async =>
      await _owner() ?? (throw const SocialNeedsAccount());

  @override
  Future<List<ShareClub>> clubsFor(String userBookId) async {
    final owner = await _me();
    final book = await _cache.book(owner, userBookId);
    if (book == null) return const [];
    return [
      for (final c in clubsReading(await _cache.clubs(owner), book))
        (id: c.id, name: c.name, color: c.color),
    ];
  }

  @override
  Future<ShareTerms> terms() async {
    final t = await _terms.mine();
    return (version: t.version, accepted: t.accepted);
  }

  @override
  Future<void> acceptTerms(String version) => _terms.accept(version);

  @override
  Future<String> share(ShareClub club, Annotation highlight) async {
    final owner = await _me();
    final quote = await quoteOf(highlight);
    final id = await _clubs.shareHighlight(club.id, quote);
    await _cache.addPost(
      owner,
      PostSummary(id: id, clubId: club.id, clubName: club.name, replies: 0),
    );
    return id;
  }

  /// O que vai do grifo [h]: só o trecho, a cor, a página, o capítulo do clube e a fração.
  Future<SharedQuote> quoteOf(Annotation h) async {
    final text = switch (h.anchor) {
      EpubAnchor(:final quote) when quote.exact.trim().isNotEmpty =>
        quote.exact,
      _ => throw const SocialUnexpected('sem_trecho'),
    };
    final db = await _database();
    final book = await UserBooksDao(db).byId(h.userBookId);
    BookIndex? index;
    try {
      index = await BookContentIndexDao(db).byBook(h.userBookId);
    } on Object {
      index = null;
    }
    // antes do 1º capítulo numerado (a folha do título), ou sem o índice: o cap. 1 do clube (o servidor não aceita 0)
    final chapter = math.max(
      1,
      clubChapterOf(
            chapterNumerals(index),
            chapterIndex: h.chapterIndex,
            chaptersTotal: index?.chaptersTotal ?? book?.chaptersTotal,
          ) ??
          1,
    );
    final total = book?.refPagesTotal;
    return (
      text: text,
      color: (h.color ?? '').toUpperCase(),
      page: h.refPage,
      chapter: chapter,
      ratio: total == null || total <= 0
          ? 0.0
          : (h.refPage / total).clamp(0.0, 1.0),
    );
  }
}

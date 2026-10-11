// G21.6 — o que o aparelho publica sozinho (D-216; docs/progresso/G21.md §6): a posição no livro de um clube ao sair
// do leitor (R9) e os 4 números agregados do perfil uma vez por dia (R10). Nada mais sai: a estante, os grifos e as
// sessões ficam no aparelho (Anexo 02 §1). Falha (sem rede) fica quieta: a próxima vez tenta de novo.
import 'package:drift/drift.dart' show Variable;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/codecs.dart' show parseInstant;
import '../../../core/data/database/daos/content_daos.dart';
import '../../reader/application/toc_view.dart' show chapterNumerals;
import '../../reader/content/book_index.dart';
import '../../social/data/profile_repository.dart';
import '../../social/domain/social_failure.dart';
import '../../social/domain/social_models.dart';
import '../data/clubs_cache.dart';
import '../data/clubs_repository.dart';
import '../domain/club_models.dart';
import '../domain/club_rules.dart';

/// Se [owner] ainda é a conta da sessão (trocar de conta no meio: nada da antiga segue — D-68).
typedef CurrentOwner = bool Function(String owner);

bool _anyOwner(String _) => true;

/// R9: ao sair do leitor (fechar ou ir para o segundo plano), a fração (a mesma % da Início) e o capítulo do clube
/// (R2 ao contrário) em cada clube que lê o livro, se a posição mudou desde a última publicação. Depois o ticket da
/// Início é refeito (o herói pode ter mudado).
final class ProgressPublisher {
  ProgressPublisher({
    required this._clubs,
    required this._cache,
    required this._database,
    this._isCurrent = _anyOwner,
  });

  final ClubsRepository _clubs;
  final ClubsCache _cache;
  final Future<AppDatabase> Function() _database;
  final CurrentOwner _isCurrent;

  /// Devolve em quantos clubes publicou.
  Future<int> publish(String owner, String userBookId) async {
    var sent = 0;
    final book = await _cache.book(owner, userBookId);
    final clubs = book == null
        ? const <ClubCard>[]
        : clubsReading(await _cache.clubs(owner), book);
    if (clubs.isNotEmpty) {
      final now = await _position(owner, userBookId);
      if (now != null) {
        for (final c in clubs) {
          final last = await _cache.publishedProgress(owner, c.id);
          if (!shouldPublishProgress(last, now)) continue;
          if (!_isCurrent(owner)) return sent;
          try {
            final saved = await _clubs.publishProgress(
              c.id,
              ratio: now.ratio,
              chapter: now.chapter,
            );
            // ignorada (a 2ª no mesmo minuto): fica para a próxima saída
            if (!saved || !_isCurrent(owner)) continue;
            await _cache.savePublishedProgress(owner, c.id, now);
            sent++;
          } on SocialFailure {
            // sem rede ou sem clube: a próxima saída tenta de novo
          }
        }
      }
    }
    if (_isCurrent(owner)) await _cache.refreshTicket(owner);
    return sent;
  }

  /// A posição gravada do livro: a fração (0–1, quatro casas) e o capítulo do clube; sem posição, `null`.
  Future<PublishedProgress?> _position(String owner, String userBookId) async {
    final db = await _database();
    final rows = await db
        .customSelect(
          'SELECT CAST(p.progression AS REAL) AS progression, p.chapter_index, b.chapters_total '
          'FROM reading_positions p JOIN user_books b ON b.id = p.id AND b.user_id = p.user_id '
          'WHERE p.id = ?1 AND p.user_id = ?2 AND p.deleted_at IS NULL',
          variables: [
            Variable.withString(userBookId),
            Variable.withString(owner),
          ],
        )
        .get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    BookIndex? index;
    try {
      index = await BookContentIndexDao(db).byBook(userBookId);
    } on Object {
      index = null;
    }
    final ratio = (r.readNullable<double>('progression') ?? 0).clamp(0.0, 1.0);
    return (
      ratio: (ratio * 10000).round() / 10000,
      chapter: clubChapterOf(
        chapterNumerals(index),
        chapterIndex: r.readNullable<int>('chapter_index'),
        chaptersTotal:
            index?.chaptersTotal ?? r.readNullable<int>('chapters_total'),
      ),
    );
  }
}

/// R10: os números do perfil (lidos no total e no ano, lendo agora, a sequência), uma vez por dia, com conta.
final class StatsPublisher {
  StatsPublisher({
    required this._profiles,
    required this._cache,
    required this._database,
    required this._streak,
    DateTime Function()? now,
    Duration Function(DateTime utc)? utcOffsetAt,
    this._isCurrent = _anyOwner,
  }) : _now = now ?? DateTime.now,
       _offsetAt = utcOffsetAt ?? ((t) => t.toLocal().timeZoneOffset);

  final CurrentOwner _isCurrent;
  final ProfileRepository _profiles;
  final ClubsCache _cache;
  final Future<AppDatabase> Function() _database;

  /// A sequência de dias da Início (a mesma conta da tela — G08).
  final Future<int> Function() _streak;
  final DateTime Function() _now;
  final Duration Function(DateTime utc) _offsetAt;

  /// Publica se passou um dia desde a última vez; devolve se publicou.
  Future<bool> publishIfDue(String owner) async {
    final now = _now().toUtc();
    if (!statsDue(await _cache.statsPublishedAt(owner), now)) return false;
    final numbers = await numbersOf(owner);
    // os números de uma conta nunca vão pela sessão de outra
    if (!_isCurrent(owner)) return false;
    try {
      // ignorados (menos de 1 min da última, ou a conta acabou de nascer): ficam para a próxima abertura
      if (!await _profiles.publishStats(numbers)) return false;
    } on SocialFailure {
      return false;
    }
    if (!_isCurrent(owner)) return false;
    await _cache.saveStatsPublishedAt(owner, now);
    return true;
  }

  /// Os 4 números, contados no aparelho (só eles sobem — D-216).
  Future<ProfileNumbers> numbersOf(String owner) async {
    final db = await _database();
    final now = _now().toUtc();
    final year = now.add(_offsetAt(now)).year;
    var finished = 0;
    var finishedYear = 0;
    var reading = 0;
    for (final r
        in await db
            .customSelect(
              'SELECT status, finished_at FROM user_books '
              "WHERE user_id = ?1 AND deleted_at IS NULL AND status IN ('finished', 'reading')",
              variables: [Variable.withString(owner)],
            )
            .get()) {
      if (r.read<String>('status') == 'reading') {
        reading++;
        continue;
      }
      finished++;
      final at = r.readNullable<String>('finished_at');
      if (at == null) continue;
      try {
        final t = parseInstant(at);
        if (t.add(_offsetAt(t)).year == year) finishedYear++;
      } on FormatException {
        // data que não se lê: conta só no total
      }
    }
    return ProfileNumbers(
      booksReadTotal: finished,
      booksReadYear: finishedYear,
      readingNow: reading,
      streakDays: await _streak(),
    );
  }
}

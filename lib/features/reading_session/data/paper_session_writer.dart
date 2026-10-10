// T04 — o que o fim da sessão do cronômetro grava (spec docs/progresso/T04.md R7, R3, R4, D-260, D-261), numa
// transação e pelo `LocalVersioning` (cada linha com versão nova; o Pro sincroniza pela fila de sempre, o Grátis fica
// no aparelho):
// - `reading_sessions`: a sessão (`source = 'timer'`), da página da posição antes até a informada;
// - `reading_positions`: a página do papel (`PaperLocator`), com o progresso = página ÷ total (D-253);
// - `user_books`: `last_opened_at` = o encerramento (o livro vira o herói — D-261) e o total informado (D-260).
// Menos de 10 s (sem registro) e sem página: nada é gravado — é descartar (R3).
import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/library_daos.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/model/checks.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';
import '../../library/domain/user_book.dart';
import '../../reader/domain/locator.dart';
import '../../reader/domain/reading_position.dart';
import '../../reader/domain/reading_session.dart';
import '../domain/open_paper_session.dart';
import '../domain/paper_timer_failure.dart';

/// O que a folha da sessão manda gravar ao encerrar (D-256).
@immutable
final class PaperSessionEnd {
  const PaperSessionEnd({
    required this.userBookId,
    required this.record,
    required this.at,
    this.page,
    this.pagesTotal,
  });

  final String userBookId;

  /// A sessão a gravar; `null` = menos de 10 s (R3).
  final PaperSessionRecord? record;

  /// O instante do encerramento: o `last_opened_at` do livro (D-261).
  final DateTime at;

  /// "Em que página você parou?" (opcional).
  final int? page;

  /// "De quantas páginas é o livro?" — só quando o livro não tem o total (D-260).
  final int? pagesTotal;
}

abstract interface class PaperSessionWriter {
  /// Encerrar (R7). Página sem total, fora de 1…total ou total < 1 → `ArgumentError` (a folha valida antes); livro
  /// apagado ou de outro dono → [PaperBookGone]. Nada é gravado nesses casos.
  Future<void> end(PaperSessionEnd end);

  /// Só a sessão — a divisão ao retomar noutro dia (R4): nem posição nem `last_opened_at`.
  Future<void> recordOnly(PaperSessionRecord record);
}

final class LocalPaperSessionWriter implements PaperSessionWriter {
  LocalPaperSessionWriter({
    required AppDatabase db,
    required LocalVersioning versioning,
    required Future<String> Function() owner,
    this.deviceId,
  }) : _db = db,
       _versioning = versioning,
       _owner = owner;

  final AppDatabase _db;
  final LocalVersioning _versioning;
  final Future<String> Function() _owner;
  final String? deviceId;

  @override
  Future<void> end(PaperSessionEnd e) async {
    final owner = await _owner();
    await _db.transaction(() async {
      await _bookOf(owner, e.userBookId);
      final givenTotal = e.pagesTotal;
      if (givenTotal != null) {
        Check.range(givenTotal, 1, _maxInt, 'pagesTotal');
      }
      final total =
          givenTotal ??
          (await UserBooksDao(_db).byId(e.userBookId))!.refPagesTotal;
      final page = e.page;
      if (page != null) {
        if (total == null) {
          throw ArgumentError.value(page, 'page', 'sem o total de páginas');
        }
        Check.range(page, 1, total, 'page');
      }
      final record = e.record;
      if (record == null && page == null) return;
      final before = await _pageBefore(e.userBookId);
      if (record != null) {
        await _session(owner, record, from: before, to: page);
      }
      if (page != null) await _position(owner, e.userBookId, page, total!);
      await _opened(e.userBookId, e.at, givenTotal);
    });
  }

  @override
  Future<void> recordOnly(PaperSessionRecord record) async {
    final owner = await _owner();
    await _db.transaction(() async {
      await _bookOf(owner, record.userBookId);
      await _session(
        owner,
        record,
        from: await _pageBefore(record.userBookId),
        to: null,
      );
    });
  }

  Future<UserBook> _bookOf(String owner, String id) async {
    final b = await UserBooksDao(_db).byId(id);
    if (b == null || b.meta.isDeleted || b.meta.userId != owner) {
      throw const PaperBookGone();
    }
    return b;
  }

  Future<int?> _pageBefore(String bookId) async {
    final p = await ReadingPositionsDao(_db).forBook(bookId);
    return p == null || p.meta.isDeleted ? null : p.refPage;
  }

  Future<void> _session(
    String owner,
    PaperSessionRecord r, {
    required int? from,
    required int? to,
  }) => _versioning.write('reading_sessions', r.id, (v) async {
    await ReadingSessionsDao(_db).upsert(
      ReadingSession(
        id: r.id,
        meta: RecordMeta(
          userId: owner,
          createdAt: r.startedAt,
          updatedAt: _at(v.ms),
          version: v,
        ),
        userBookId: r.userBookId,
        startedAt: r.startedAt,
        endedAt: r.endedAt,
        activeSeconds: r.activeSeconds,
        refPageFrom: from,
        refPageTo: to,
        pagesViewed: from != null && to != null && to >= from
            ? to - from
            : null,
        source: SessionSource.timer,
        deviceId: deviceId,
      ),
    );
  });

  Future<void> _position(String owner, String bookId, int page, int total) =>
      _versioning.write('reading_positions', bookId, (v) async {
        final dao = ReadingPositionsDao(_db);
        final at = _at(v.ms);
        final before = await dao.forBook(bookId);
        await dao.upsert(
          ReadingPosition(
            id: bookId,
            meta: RecordMeta(
              userId: owner,
              createdAt: before?.meta.createdAt ?? at,
              updatedAt: at,
              version: v,
            ),
            locator: PaperLocator(page),
            refPage: page,
            chapterIndex: 0,
            progression: paperProgression(page, total),
            deviceId: deviceId,
          ),
        );
      });

  Future<void> _opened(String bookId, DateTime at, int? total) =>
      _versioning.write('user_books', bookId, (v) async {
        final dao = UserBooksDao(_db);
        final cur = (await dao.byId(bookId))!;
        await dao.upsert(
          cur.copyWith(
            meta: cur.meta.edited(_at(v.ms), v),
            lastOpenedAt: Nullable(at.toUtc()),
            refPagesTotal: total == null ? null : Nullable(total),
          ),
        );
      });

  static DateTime _at(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

/// O progresso do papel: página ÷ total em 5 casas (`numeric(6,5)` no servidor), até 1.
double paperProgression(int page, int total) =>
    double.parse((page / total).clamp(0, 1).toStringAsFixed(5));

const int _maxInt = 2147483647;

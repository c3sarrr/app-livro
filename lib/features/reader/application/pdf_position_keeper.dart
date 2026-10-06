// G11.4 — posição de leitura do PDF (D-109): a página mostrada vira um `PdfLocator` (página a partir de 0,
// página de referência = página do PDF — D-89 —, % = começo da página ÷ total, 5 casas) gravado em
// `reading_positions` com versão, depois de 1 s parado e na hora ao sair (como o EPUB — G10).
import 'dart:async';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/model/record_meta.dart';
import '../domain/locator.dart';
import '../domain/reading_position.dart';
import 'reader_errors.dart';
import 'reading_position_keeper.dart' show positionSaveDelay;

/// "%" do PDF: o começo da página [page] (a partir de 0) ÷ [count], com 5 casas.
double pdfProgression(int page, int count) => count <= 0
    ? 0
    : double.parse((page / count).clamp(0, 1).toStringAsFixed(5));

final class PdfPositionKeeper {
  PdfPositionKeeper({
    required this._db,
    required this._versioning,
    required this._owner,
    required this.userBookId,
    required this.sha,
    this.deviceId,
    this.delay = positionSaveDelay,
    this._onError = reportReaderError,
  });

  final AppDatabase _db;
  final LocalVersioning _versioning;
  final Future<String> Function() _owner;
  final String userBookId;

  /// SHA-256 do arquivo (validade da posição — Anexo 03 §5.1).
  final String sha;
  final String? deviceId;
  final Duration delay;
  final ReaderErrorReporter _onError;

  Timer? _timer;
  ({int page, int count})? _pending;
  Future<void> _saving = Future<void>.value();

  PdfLocator locatorAt(int page, int count) => PdfLocator(
    sha: sha,
    page: page,
    refPage: page + 1,
    progression: pdfProgression(page, count),
  );

  /// A página [page] de [count] apareceu: grava depois de [delay] se a pessoa ficar nela.
  void pageShown(int page, int count) {
    _pending = (page: page, count: count);
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(flush()));
  }

  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    final p = _pending;
    _pending = null;
    if (p == null) return _saving;
    return _saving = _saving.then((_) async {
      try {
        await _save(p.page, p.count);
      } on Object catch (e, st) {
        _onError(e, st);
      }
    });
  }

  /// A página onde a pessoa parou, dentro de [count] (fora do total → a última; outra posição → a 1ª). Posição
  /// de outro arquivo (o PDF foi trocado): vale a % guardada, como na outra edição de um EPUB (G10).
  Future<int> savedPage(int count) async {
    final saved = await ReadingPositionsDao(_db).forBook(userBookId);
    final l = saved?.locator;
    if (l is! PdfLocator || saved!.meta.isDeleted || count <= 0) return 0;
    final page = l.sha == sha ? l.page : (l.progression * count).floor();
    return page < count ? page : count - 1;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _save(int page, int count) async {
    final locator = locatorAt(page, count);
    final owner = await _owner();
    final dao = ReadingPositionsDao(_db);
    await _versioning.write('reading_positions', userBookId, (v) async {
      final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
      final old = await dao.forBook(userBookId);
      await dao.upsert(
        ReadingPosition(
          id: userBookId,
          meta: RecordMeta(
            userId: owner,
            createdAt: old?.meta.createdAt ?? at,
            updatedAt: at,
            version: v,
          ),
          locator: locator,
          refPage: locator.refPage,
          chapterIndex: 0,
          progression: locator.progression,
          deviceId: deviceId,
        ),
      );
    });
  }
}

// T04 — onde mora a sessão aberta do cronômetro do livro de papel (R8): o `kv`, chave `paper_timer:<dono>`, só no
// aparelho (nunca sincroniza), como o rascunho da tinta da G16 (`ink_draft:`). A linha em `reading_sessions` só nasce
// ao encerrar: enquanto roda, a sessão não entra nas contas da Início (01b, D-252). O "apagar deste aparelho" apaga a
// chave e a adoção do convidado pela conta a passa adiante (`LocalLibrary`).
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../domain/open_paper_session.dart';

/// A chave da sessão aberta do [owner] no `kv`.
String paperTimerKey(String owner) => 'paper_timer:$owner';

/// Falhas inesperadas do cronômetro que não podem parar o app: vão para o relatório de falhas (sem dado da pessoa).
typedef PaperTimerErrorReporter = void Function(Object error, StackTrace stack);

void reportPaperTimerError(Object error, StackTrace stack) =>
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'cronômetro',
      ),
    );

/// A sessão guardada não pôde ser lida (JSON ilegível ou versão desconhecida): saiu do `kv`.
final class PaperTimerUnreadable implements Exception {
  const PaperTimerUnreadable();

  @override
  String toString() =>
      'PaperTimerUnreadable: sessão aberta ilegível no kv (descartada)';
}

/// A sessão aberta de cada dono deste aparelho.
abstract interface class PaperTimerStore {
  /// A sessão aberta do [owner], ou `null`.
  Future<OpenPaperSession?> load(String owner);

  Future<void> save(String owner, OpenPaperSession session);

  /// Sem sessão aberta (encerrada ou descartada).
  Future<void> clear(String owner);
}

final class KvPaperTimerStore implements PaperTimerStore {
  KvPaperTimerStore(AppDatabase db, {this._onError = reportPaperTimerError})
    : _kv = KvDao(db);

  final KvDao _kv;
  final PaperTimerErrorReporter _onError;

  @override
  Future<OpenPaperSession?> load(String owner) async {
    final key = paperTimerKey(owner);
    final raw = await _kv.get(key);
    if (raw == null) return null;
    final session = _decode(raw);
    if (session == null) {
      await _kv.delete(key);
      _onError(const PaperTimerUnreadable(), StackTrace.current);
    }
    return session;
  }

  @override
  Future<void> save(String owner, OpenPaperSession session) =>
      _kv.set(paperTimerKey(owner), jsonEncode(session.toJson()));

  @override
  Future<void> clear(String owner) => _kv.delete(paperTimerKey(owner));
}

OpenPaperSession? _decode(String raw) {
  try {
    return OpenPaperSession.fromJson(jsonDecode(raw));
  } on FormatException {
    return null;
  }
}

/// Entrar numa conta (`LocalLibrary.adopt`, dentro da transação dela): a sessão aberta do convidado [from] passa
/// para a conta [to]. Com as duas, fica a que começou por último; a ilegível sempre perde.
Future<void> adoptPaperTimer(
  AppDatabase db, {
  required String from,
  required String to,
}) async {
  final kv = KvDao(db);
  final fromKey = paperTimerKey(from);
  final toKey = paperTimerKey(to);
  final rawFrom = await kv.get(fromKey);
  if (rawFrom == null) return;
  await kv.delete(fromKey);
  final mine = _decode(rawFrom);
  if (mine == null) return;
  final rawTo = await kv.get(toKey);
  final theirs = rawTo == null ? null : _decode(rawTo);
  if (theirs != null && !mine.startedAt.isAfter(theirs.startedAt)) return;
  await kv.set(toKey, rawFrom);
}

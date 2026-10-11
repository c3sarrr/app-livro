// T04 — onde mora a sessão aberta do cronômetro do livro de papel (R8): o `kv`, chave `paper_timer:<dono>`, só no
// aparelho (nunca sincroniza), como o rascunho da tinta da G16 (`ink_draft:`). A linha em `reading_sessions` só nasce
// ao encerrar: enquanto roda, a sessão não entra nas contas da Início (01b, D-252). O "apagar deste aparelho" apaga a
// chave e a adoção do convidado pela conta a passa adiante (`LocalLibrary`); com as duas, a que perde espera em
// `paper_timer_closed:<dono>` até o controlador gravá-la (D-265).
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../domain/open_paper_session.dart';

/// A chave da sessão aberta do [owner] no `kv`.
String paperTimerKey(String owner) => 'paper_timer:$owner';

/// A chave das sessões do [owner] que perderam na adoção (D-265): pausadas no instante da troca, esperando o
/// controlador gravá-las.
String paperTimerClosedKey(String owner) => 'paper_timer_closed:$owner';

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

  /// As sessões do [owner] que perderam na adoção (D-265), para gravar; ilegíveis saem e são relatadas.
  Future<List<OpenPaperSession>> closed(String owner);

  /// Gravadas: saem da espera.
  Future<void> clearClosed(String owner);
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

  @override
  Future<List<OpenPaperSession>> closed(String owner) async {
    final key = paperTimerClosedKey(owner);
    final raw = await _kv.get(key);
    if (raw == null) return const [];
    final (sessions, unreadable) = _decodeList(raw);
    if (unreadable) {
      await _setList(_kv, owner, sessions);
      _onError(const PaperTimerUnreadable(), StackTrace.current);
    }
    return sessions;
  }

  @override
  Future<void> clearClosed(String owner) =>
      _kv.delete(paperTimerClosedKey(owner));
}

OpenPaperSession? _decode(String raw) {
  try {
    return OpenPaperSession.fromJson(jsonDecode(raw));
  } on FormatException {
    return null;
  }
}

/// As sessões guardadas numa lista (a espera da D-265) e se alguma estava ilegível (fica de fora).
(List<OpenPaperSession>, bool) _decodeList(String raw) {
  try {
    final json = jsonDecode(raw);
    if (json is! List) return (const [], true);
    final sessions = [for (final e in json) ?OpenPaperSession.fromJson(e)];
    return (sessions, sessions.length != json.length);
  } on FormatException {
    return (const [], true);
  }
}

Future<void> _setList(
  KvDao kv,
  String owner,
  List<OpenPaperSession> sessions,
) => sessions.isEmpty
    ? kv.delete(paperTimerClosedKey(owner))
    : kv.set(
        paperTimerClosedKey(owner),
        jsonEncode([for (final s in sessions) s.toJson()]),
      );

/// Entrar numa conta (`LocalLibrary.adopt`, dentro da transação dela) em [now]: a sessão aberta do convidado [from]
/// passa para a conta [to]. Com as duas, fica aberta a que começou por último e a outra vai, pausada em [now], para a
/// espera da conta — o controlador a grava sem página (D-265); a ilegível sempre perde (e some). As que já esperavam
/// no convidado também passam.
Future<void> adoptPaperTimer(
  AppDatabase db, {
  required String from,
  required String to,
  required DateTime now,
}) async {
  final kv = KvDao(db);
  final waiting = <OpenPaperSession>[];
  for (final owner in [to, from]) {
    final raw = await kv.get(paperTimerClosedKey(owner));
    if (raw != null) waiting.addAll(_decodeList(raw).$1);
  }
  await kv.delete(paperTimerClosedKey(from));
  final fromKey = paperTimerKey(from);
  final toKey = paperTimerKey(to);
  final rawFrom = await kv.get(fromKey);
  final mine = rawFrom == null ? null : _decode(rawFrom);
  if (rawFrom != null) await kv.delete(fromKey);
  if (mine != null) {
    final rawTo = await kv.get(toKey);
    final theirs = rawTo == null ? null : _decode(rawTo);
    if (theirs != null && !mine.startedAt.isAfter(theirs.startedAt)) {
      waiting.add(mine.pause(now));
    } else {
      if (theirs != null) waiting.add(theirs.pause(now));
      await kv.set(toKey, rawFrom!);
    }
  }
  await _setList(kv, to, waiting);
}

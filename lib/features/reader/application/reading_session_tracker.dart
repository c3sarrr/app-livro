// G10.4 — tempo que "conta sozinho" (Anexo 03 §8, D-27/D-95): a sessão automática conta enquanto o leitor está
// visível, o app em primeiro plano, há conteúdo na tela e a última interação (virar página, rolar, tocar) foi
// há menos de 120 s; pausa ao ir para segundo plano, ao bloquear a tela ou parado (o tempo conta até os 120 s);
// termina ao fechar o livro. Sessão com menos de 10 s ativos não é gravada. Página de referência lida = a que
// ficou ≥ 3 s ativa na tela. A linha em `reading_sessions` (source = auto) é gravada a cada 60 s ativos e a
// cada pausa — a mesma linha, atualizada — para o tempo não se perder se o app morrer.
import 'dart:async';
import 'dart:math' as math;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/data/model/record_meta.dart';
import '../domain/reading_session.dart';
import 'reader_errors.dart';

/// Parado por mais que isto: pausa (D-95).
const Duration readingIdleLimit = Duration(seconds: 120);

/// Sessão mais curta que é gravada.
const Duration minReadingSession = Duration(seconds: 10);

/// Página de referência lida = pelo menos isto ativa na tela.
const Duration pageReadAfter = Duration(seconds: 3);

/// De quanto em quanto tempo ativo a sessão aberta é gravada.
const Duration sessionCheckpoint = Duration(seconds: 60);

final class ReadingSessionTracker {
  ReadingSessionTracker({
    required this._db,
    required this._versioning,
    required this._owner,
    required this.userBookId,
    this.deviceId,
    DateTime Function()? now,
    UuidV7Generator? ids,
    bool autoTick = true,
    this._onError = reportReaderError,
  }) : _now = now ?? DateTime.now,
       _ids = ids ?? UuidV7Generator() {
    _lastInteraction = _now();
    if (autoTick) {
      _ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => unawaited(tick()),
      );
    }
  }

  final AppDatabase _db;
  final LocalVersioning _versioning;
  final Future<String> Function() _owner;
  final String userBookId;
  final String? deviceId;
  final DateTime Function() _now;
  final UuidV7Generator _ids;
  final ReaderErrorReporter _onError;
  Timer? _ticker;

  bool _visible = false;
  bool _foreground = true;
  ({int from, int to})? _shown;
  late DateTime _lastInteraction;

  DateTime? _countingSince;
  DateTime? _pageSince;
  Duration _active = Duration.zero;
  Duration _written = Duration.zero;
  DateTime? _startedAt;
  DateTime? _lastCounted;
  String? _id;
  int? _firstPage;
  int? _lastPage;
  final Map<int, Duration> _perPage = {};
  Future<void> _writing = Future<void>.value();
  bool _closed = false;

  /// Segundos ativos da sessão aberta (inclui o trecho que está contando agora).
  int get activeSeconds {
    final since = _countingSince;
    final running = since == null ? Duration.zero : _now().difference(since);
    return (_active + running).inSeconds;
  }

  bool get counting => _countingSince != null;

  /// O leitor apareceu ou sumiu da tela (outra rota por cima, tela bloqueada). Voltar a aparecer é uma
  /// interação (a pessoa fez alguma coisa para voltar).
  Future<void> setVisible(bool visible) => _event(() {
    if (visible && !_visible) _lastInteraction = _now();
    _visible = visible;
  });

  /// O app foi para o segundo plano ou voltou (voltar também é interação).
  Future<void> setForeground(bool foreground) => _event(() {
    if (foreground && !_foreground) _lastInteraction = _now();
    _foreground = foreground;
  });

  /// Virar página, rolar, tocar.
  Future<void> interaction() => _event(() => _lastInteraction = _now());

  /// A página mostrada cobre as páginas de referência [from]…[to] (também conta como interação).
  Future<void> pageShown(int from, int to) => _event(() {
    final now = _now();
    _creditPages(now);
    _shown = (from: math.min(from, to), to: math.max(from, to));
    _pageSince = now;
    _lastInteraction = now;
    _firstPage ??= from;
  });

  /// Confere a pausa por parado e grava a cada 60 s ativos (chamado a cada segundo).
  Future<void> tick() async {
    if (_closed) return;
    _idleCheck(_now());
    final total = Duration(seconds: activeSeconds);
    if (counting && total - _written >= sessionCheckpoint) await _write();
    await _writing;
  }

  /// Fecha o livro: para de contar e grava (se passou de 10 s).
  Future<void> close() async {
    if (_closed) return _writing;
    _closed = true;
    _ticker?.cancel();
    final now = _now();
    _idleCheck(now);
    if (counting) _stop(now);
    await _write();
  }

  void dispose() {
    _ticker?.cancel();
    _closed = true;
  }

  // ------------------------------------------------------------------------------------------------------

  Future<void> _event(void Function() change) async {
    if (_closed) return;
    final now = _now();
    _idleCheck(now);
    change();
    final should = _visible && _foreground && _shown != null && !_idle(now);
    if (should && !counting) {
      _countingSince = now;
      _pageSince = now;
      _startedAt ??= now;
      _id ??= _ids.next();
    } else if (!should && counting) {
      _stop(now);
      await _write();
    }
    await _writing;
  }

  bool _idle(DateTime now) =>
      now.difference(_lastInteraction) >= readingIdleLimit;

  /// Parado há 120 s: o tempo conta até os 120 s e a sessão pausa.
  void _idleCheck(DateTime now) {
    if (!counting || !_idle(now)) return;
    final at = _lastInteraction.add(readingIdleLimit);
    _stop(at.isBefore(_countingSince!) ? _countingSince! : at);
    unawaited(_write()); // quem chamou espera `_writing`
  }

  void _stop(DateTime at) {
    final since = _countingSince!;
    _creditPages(at);
    _active += at.difference(since);
    _lastCounted = at;
    _countingSince = null;
    _pageSince = null;
  }

  /// Soma o tempo ativo da página mostrada às páginas de referência dela.
  void _creditPages(DateTime now) {
    final shown = _shown;
    final since = _pageSince;
    final counted = _countingSince;
    if (shown == null || since == null || counted == null) return;
    final from = since.isBefore(counted) ? counted : since;
    final d = now.difference(from);
    if (d <= Duration.zero) return;
    for (var p = shown.from; p <= shown.to; p++) {
      _perPage[p] = (_perPage[p] ?? Duration.zero) + d;
    }
    _lastPage = shown.to;
    _pageSince = now;
  }

  Future<void> _write() {
    final id = _id;
    final started = _startedAt;
    final total = Duration(seconds: activeSeconds);
    if (id == null || started == null || total < minReadingSession) {
      return _writing;
    }
    final now = _now();
    if (counting) _creditPages(now);
    final ended = counting ? now : (_lastCounted ?? now);
    final pages = _perPage.values.where((d) => d >= pageReadAfter).length;
    final seconds = math.min(total.inSeconds, 86400);
    final first = _firstPage;
    final last = _lastPage ?? _shown?.to;
    _written = total;
    return _writing = _writing.then((_) async {
      try {
        await _save(id, started, ended, seconds, first, last, pages);
      } on Object catch (e, st) {
        _onError(e, st); // o próximo ponto de gravação tenta de novo
        _written = Duration.zero;
      }
    });
  }

  Future<void> _save(
    String id,
    DateTime started,
    DateTime ended,
    int seconds,
    int? first,
    int? last,
    int pages,
  ) async {
    final owner = await _owner();
    final dao = ReadingSessionsDao(_db);
    await _versioning.write('reading_sessions', id, (v) async {
      final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
      await dao.upsert(
        ReadingSession(
          id: id,
          meta: RecordMeta(
            userId: owner,
            createdAt: started.toUtc(),
            updatedAt: at,
            version: v,
          ),
          userBookId: userBookId,
          startedAt: started.toUtc(),
          endedAt: ended.toUtc(),
          activeSeconds: seconds,
          refPageFrom: first,
          refPageTo: last,
          pagesViewed: pages,
          source: SessionSource.auto,
          deviceId: deviceId,
        ),
      );
    });
  }
}

/// "N min hoje" (Anexo 03 §8): minutos das sessões que começaram hoje no fuso do aparelho (já gravadas) + a
/// sessão aberta ([open], que pode ainda não estar gravada), arredondado para baixo.
Future<int> minutesToday(
  AppDatabase db, {
  required String userId,
  required DateTime now,
  ReadingSessionTracker? open,
}) async {
  final local = now.toLocal();
  final dayStart = DateTime(local.year, local.month, local.day);
  final sessions = await ReadingSessionsDao(db).startedBetween(
    userId,
    dayStart.toUtc(),
    dayStart.add(const Duration(days: 1)).toUtc(),
  );
  var seconds = 0;
  final openId = open?._id;
  for (final s in sessions) {
    if (s.id == openId) continue;
    seconds += s.activeSeconds;
  }
  final openStart = open?._startedAt?.toLocal();
  if (open != null && openStart != null && !openStart.isBefore(dayStart)) {
    seconds += open.activeSeconds;
  }
  return seconds ~/ 60;
}

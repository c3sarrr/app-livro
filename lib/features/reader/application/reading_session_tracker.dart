// G10.4 — tempo que "conta sozinho" (Anexo 03 §8, D-27/D-95): a sessão automática conta enquanto o leitor está
// visível, o app em primeiro plano, há conteúdo na tela e a última interação (virar página, rolar, tocar) foi
// há menos de 120 s; pausa ao ir para segundo plano, ao bloquear a tela ou parado (o tempo conta até os 120 s);
// termina ao fechar o livro. Sessão com menos de 10 s ativos não é gravada. Página de referência lida = a que
// ficou ≥ 3 s ativa na tela. A linha em `reading_sessions` (source = auto) é gravada a cada 60 s ativos e a
// cada pausa — a mesma linha, atualizada — para o tempo não se perder se o app morrer.
//
// Revisão da G10: os intervalos (tempo ativo, parado há quanto) vêm de um relógio monotônico — acertar o
// relógio do aparelho no meio da leitura não apaga nem inventa tempo; o relógio de parede só dá o início da
// sessão (e o fim = início + o que passou). Voltar a ler noutro dia (depois de uma pausa) abre outra sessão:
// os minutos do dia contam pela data de início (D-85). Falha ao gravar é relatada uma vez por tipo e tentada
// de novo no próximo ponto de gravação.
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
    Duration Function()? elapsed,
    UuidV7Generator? ids,
    bool autoTick = true,
    this._onError = reportReaderError,
  }) : _now = now ?? DateTime.now,
       _ids = ids ?? UuidV7Generator() {
    if (elapsed == null) {
      final sw = Stopwatch()..start();
      _mono = () => sw.elapsed;
    } else {
      _mono = elapsed;
    }
    _lastInteraction = _mono();
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

  /// Relógio de parede (início da sessão, "hoje").
  final DateTime Function() _now;

  /// Relógio monotônico (intervalos).
  late final Duration Function() _mono;
  final UuidV7Generator _ids;
  final ReaderErrorReporter _onError;
  Timer? _ticker;

  bool _visible = false;
  bool _foreground = true;
  ({int from, int to})? _shown;
  late Duration _lastInteraction;

  Duration? _countingSince;
  Duration? _pageSince;
  Duration _active = Duration.zero;
  Duration _written = Duration.zero;
  DateTime? _startedAt;
  Duration? _startedMono;
  Duration? _lastCounted;
  String? _id;
  int? _firstPage;
  int? _lastPage;
  final Map<int, Duration> _perPage = {};
  Future<void> _writing = Future<void>.value();
  final Set<Type> _reported = {};
  bool _closed = false;

  /// Segundos ativos da sessão aberta (inclui o trecho que está contando agora).
  int get activeSeconds {
    final since = _countingSince;
    final running = since == null ? Duration.zero : _mono() - since;
    return (_active + running).inSeconds;
  }

  bool get counting => _countingSince != null;

  /// Início da sessão aberta (relógio de parede), `null` antes de começar a contar.
  DateTime? get startedAt => _startedAt;

  /// O leitor apareceu ou sumiu da tela (outra rota por cima, tela bloqueada). Voltar a aparecer é uma
  /// interação (a pessoa fez alguma coisa para voltar).
  Future<void> setVisible(bool visible) => _event(() {
    if (visible && !_visible) _lastInteraction = _mono();
    _visible = visible;
  });

  /// O app foi para o segundo plano ou voltou (voltar também é interação).
  Future<void> setForeground(bool foreground) => _event(() {
    if (foreground && !_foreground) _lastInteraction = _mono();
    _foreground = foreground;
  });

  /// Virar página, rolar, tocar.
  Future<void> interaction() => _event(() => _lastInteraction = _mono());

  /// A página mostrada cobre as páginas de referência [from]…[to] (também conta como interação).
  Future<void> pageShown(int from, int to) => _event(() {
    final now = _mono();
    _creditPages(now);
    _shown = (from: math.min(from, to), to: math.max(from, to));
    _pageSince = now;
    _lastInteraction = now;
    _firstPage ??= _shown!.from;
  });

  /// Confere a pausa por parado e grava a cada 60 s ativos (chamado a cada segundo).
  Future<void> tick() async {
    if (_closed) return;
    _idleCheck(_mono());
    final total = Duration(seconds: activeSeconds);
    if (counting && total - _written >= sessionCheckpoint) await _write();
    await _writing;
  }

  /// Fecha o livro: para de contar e grava (se passou de 10 s).
  Future<void> close() async {
    if (_closed) return _writing;
    _closed = true;
    _ticker?.cancel();
    final now = _mono();
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
    final now = _mono();
    _idleCheck(now);
    change();
    final should = _visible && _foreground && _shown != null && !_idle(now);
    if (should && !counting) {
      if (_id != null && _otherDay()) {
        // voltou a ler noutro dia: a sessão de antes já foi gravada na pausa; esta é outra
        await _writing;
        _newSession();
      }
      _countingSince = now;
      _pageSince = now;
      _startedAt ??= _now();
      _startedMono ??= now;
      _id ??= _ids.next();
      _firstPage ??= _shown!.from;
    } else if (!should && counting) {
      _stop(now);
      await _write();
    }
    await _writing;
  }

  /// O dia local de agora não é o do início da sessão aberta.
  bool _otherDay() {
    final s = _startedAt?.toLocal();
    if (s == null) return false;
    final n = _now().toLocal();
    return n.year != s.year || n.month != s.month || n.day != s.day;
  }

  void _newSession() {
    _id = null;
    _startedAt = null;
    _startedMono = null;
    _lastCounted = null;
    _active = Duration.zero;
    _written = Duration.zero;
    _perPage.clear();
    _firstPage = null;
    _lastPage = null;
  }

  bool _idle(Duration now) => now - _lastInteraction >= readingIdleLimit;

  /// Parado há 120 s: o tempo conta até os 120 s e a sessão pausa.
  void _idleCheck(Duration now) {
    if (!counting || !_idle(now)) return;
    final at = _lastInteraction + readingIdleLimit;
    _stop(at < _countingSince! ? _countingSince! : at);
    unawaited(_write()); // quem chamou espera `_writing`
  }

  void _stop(Duration at) {
    final since = _countingSince!;
    _creditPages(at);
    _active += at - since;
    _lastCounted = at;
    _countingSince = null;
    _pageSince = null;
  }

  /// Soma o tempo ativo da página mostrada às páginas de referência dela.
  void _creditPages(Duration now) {
    final shown = _shown;
    final since = _pageSince;
    final counted = _countingSince;
    if (shown == null || since == null || counted == null) return;
    final from = since < counted ? counted : since;
    final d = now - from;
    if (d <= Duration.zero) return;
    for (var p = shown.from; p <= shown.to; p++) {
      _perPage[p] = (_perPage[p] ?? Duration.zero) + d;
    }
    _lastPage = shown.to;
    _pageSince = now;
  }

  /// Instante de parede de um momento monotônico da sessão aberta (início + o que passou).
  DateTime _wallAt(Duration m) => _startedAt!.add(m - _startedMono!);

  Future<void> _write() {
    final id = _id;
    final started = _startedAt;
    final total = Duration(seconds: activeSeconds);
    if (id == null || started == null || total < minReadingSession) {
      return _writing;
    }
    final now = _mono();
    if (counting) _creditPages(now);
    final ended = _wallAt(counting ? now : (_lastCounted ?? now));
    final pages = _perPage.values.where((d) => d >= pageReadAfter).length;
    final seconds = math.min(total.inSeconds, 86400);
    final first = _firstPage;
    final last = _lastPage ?? _shown?.to;
    _written = total; // falhando, tenta de novo no próximo ponto de gravação (60 s), na pausa ou ao fechar
    return _writing = _writing.then((_) async {
      try {
        await _save(id, started, ended, seconds, first, last, pages);
      } on Object catch (e, st) {
        // relata uma vez por tipo de falha (um relógio do aparelho antes de 2024 falharia a cada gravação)
        if (_reported.add(e.runtimeType)) _onError(e, st);
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
  // o dia seguinte pelo calendário (dia com troca de horário tem 23 ou 25 h)
  final dayEnd = DateTime(local.year, local.month, local.day + 1);
  // a consulta compara o texto gravado; a janela larga pega também os instantes em outro formato (vindos do
  // servidor), e o dia de cada sessão é decidido aqui pelo instante lido
  final sessions = await ReadingSessionsDao(db).startedBetween(
    userId,
    dayStart.subtract(const Duration(days: 1)).toUtc(),
    dayEnd.add(const Duration(days: 1)).toUtc(),
  );
  var seconds = 0;
  final openId = open?._id;
  for (final s in sessions) {
    if (s.id == openId) continue;
    final start = s.startedAt.toLocal();
    if (start.isBefore(dayStart) || !start.isBefore(dayEnd)) continue;
    seconds += s.activeSeconds;
  }
  final openStart = open?._startedAt?.toLocal();
  if (open != null &&
      openStart != null &&
      !openStart.isBefore(dayStart) &&
      openStart.isBefore(dayEnd)) {
    seconds += open.activeSeconds;
  }
  return seconds ~/ 60;
}

// T04 — a sessão do cronômetro do livro de papel (spec docs/progresso/T04.md, R2–R4, R8). O tempo corre pelo
// relógio de parede a partir do "rodando desde" guardado: a sessão sobrevive ao app fechado (a pessoa continua
// lendo o papel). Relógio que volta não desconta nem inventa: o que já contou até o último instante visto (a marca —
// o "desde" ou o [OpenPaperSession.seenAt]) fica, e o "desde" passa a ser agora; com 24 h de tempo ativo a sessão
// pausa sozinha no instante do limite (o CHECK `active_seconds ≤ 86400`).
// Menos de 10 s não grava (G10). Retomar noutro dia local grava a sessão anterior (até a pausa) e abre outra no
// mesmo livro — o dia de uma sessão é o do início (D-85).
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/model/checks.dart';

/// Limite do banco (`active_seconds ≤ 86400`): ao chegar nele, a sessão pausa sozinha (R2).
const int maxPaperSessionSeconds = 86400;

/// Menos que isto não grava a sessão (G10, R3).
const int minPaperSessionSeconds = 10;

/// O que gravar em `reading_sessions` (`source = 'timer'`).
@immutable
final class PaperSessionRecord {
  const PaperSessionRecord({
    required this.id,
    required this.userBookId,
    required this.startedAt,
    required this.endedAt,
    required this.activeSeconds,
  });

  final String id;
  final String userBookId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int activeSeconds;

  @override
  bool operator ==(Object other) =>
      other is PaperSessionRecord &&
      other.id == id &&
      other.userBookId == userBookId &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.activeSeconds == activeSeconds;

  @override
  int get hashCode =>
      Object.hash(id, userBookId, startedAt, endedAt, activeSeconds);

  @override
  String toString() =>
      'PaperSessionRecord($userBookId, $startedAt → $endedAt, ${activeSeconds}s)';
}

/// A sessão do cronômetro aberta neste aparelho: o tempo pelo relógio de parede, a partir do "rodando desde".
@immutable
final class OpenPaperSession {
  OpenPaperSession({
    required String id,
    required String userBookId,
    required DateTime startedAt,
    required int activeSeconds,
    DateTime? runningSince,
    DateTime? pausedAt,
    DateTime? seenAt,
  }) : id = Check.uuid(id, 'id'),
       userBookId = Check.text(
         userBookId,
         min: 1,
         max: 200,
         name: 'userBookId',
       ),
       startedAt = Check.utc(startedAt, 'startedAt'),
       activeSeconds = Check.range(
         activeSeconds,
         0,
         maxPaperSessionSeconds,
         'activeSeconds',
       ),
       runningSince = Check.utcOrNull(runningSince, 'runningSince'),
       pausedAt = Check.utcOrNull(pausedAt, 'pausedAt'),
       seenAt = Check.utcOrNull(seenAt, 'seenAt');

  /// Uma sessão nova, rodando desde [now].
  factory OpenPaperSession.start({
    required String id,
    required String userBookId,
    required DateTime now,
  }) {
    final at = now.toUtc();
    return OpenPaperSession(
      id: id,
      userBookId: userBookId,
      startedAt: at,
      activeSeconds: 0,
      runningSince: at,
    );
  }

  /// O id da linha de `reading_sessions` (UUIDv7 gerado no começo).
  final String id;

  /// O livro na estante (`user_books.id`): o writer e a fonte do livro conferem no banco — livro que não está lá
  /// descarta a sessão (R8).
  final String userBookId;

  /// Início de parede (UTC) — a chave da partição mensal no servidor.
  final DateTime startedAt;

  /// Segundos já contados até o [runningSince] (rodando) ou até a pausa (pausada).
  final int activeSeconds;

  /// Desde quando roda (UTC); `null` = pausada.
  final DateTime? runningSince;

  /// O instante da última pausa (UTC) — o fim de parede de uma sessão encerrada pausada.
  final DateTime? pausedAt;

  /// O último instante de parede em que a sessão foi vista rodando (UTC), depois do "desde" — a marca do relógio que
  /// volta (R2): o controlador a guarda quando o app sai da frente; `null` = o próprio "desde".
  final DateTime? seenAt;

  bool get isRunning => runningSince != null;

  /// Segundos ativos em [now]: o trecho rodando conta até agora — ou até a marca, se o relógio voltou para antes dela
  /// (nada descontado) —, até o limite de 24 h.
  int elapsedAt(DateTime now) {
    final since = runningSince;
    if (since == null) return activeSeconds;
    final mark = seenAt ?? since;
    final at = now.toUtc();
    final run = (at.isBefore(mark) ? mark : at).difference(since).inSeconds;
    return math.min(maxPaperSessionSeconds, activeSeconds + run);
  }

  /// A sessão vista rodando em [now] (a marca do R2 anda para a frente); a pausada e a já vista depois não mudam.
  OpenPaperSession observe(DateTime now) {
    final since = runningSince;
    if (since == null) return this;
    final at = now.toUtc();
    if (!at.isAfter(seenAt ?? since)) return this;
    return _copy(seenAt: at);
  }

  /// A sessão acertada em [now] (R2): 24 h de tempo ativo (até agora ou até a marca) → pausada no instante do limite;
  /// relógio que voltou para antes da marca → o que contou até ela fica e o "desde" passa a ser agora (nada
  /// descontado nem inventado). Sem nada a acertar, a própria sessão.
  OpenPaperSession settle(DateTime now) {
    final since = runningSince;
    if (since == null) return this;
    final at = now.toUtc();
    final mark = seenAt ?? since;
    final limitAt = since.add(
      Duration(seconds: maxPaperSessionSeconds - activeSeconds),
    );
    if (!(at.isBefore(mark) ? mark : at).isBefore(limitAt)) {
      return _copy(
        activeSeconds: maxPaperSessionSeconds,
        runningSince: null,
        pausedAt: limitAt,
        seenAt: null,
      );
    }
    if (!at.isBefore(mark)) return this;
    return _copy(
      activeSeconds: activeSeconds + mark.difference(since).inSeconds,
      runningSince: at,
      seenAt: null,
    );
  }

  /// Pausada em [now] (ou no limite, se ele veio antes); a pausada não muda.
  OpenPaperSession pause(DateTime now) {
    final s = settle(now);
    if (!s.isRunning) return s;
    return s._copy(
      activeSeconds: s.elapsedAt(now),
      runningSince: null,
      pausedAt: now.toUtc(),
      seenAt: null,
    );
  }

  /// Rodando desde [now] com o tempo guardado; a que já roda (ou chegou às 24 h) não muda.
  OpenPaperSession resume(DateTime now) {
    if (isRunning || activeSeconds >= maxPaperSessionSeconds) return this;
    return _copy(runningSince: now.toUtc(), pausedAt: null, seenAt: null);
  }

  /// O que gravar ao encerrar em [now] (R3): `null` com menos de 10 s. O fim é agora (rodando) ou o instante da
  /// pausa (pausada), nunca antes do início.
  PaperSessionRecord? record(DateTime now) {
    final s = settle(now);
    final seconds = s.elapsedAt(now);
    if (seconds < minPaperSessionSeconds) return null;
    final end = s.isRunning ? now.toUtc() : (s.pausedAt ?? s.startedAt);
    return PaperSessionRecord(
      id: id,
      userBookId: userBookId,
      startedAt: startedAt,
      endedAt: end.isBefore(startedAt) ? startedAt : end,
      activeSeconds: seconds,
    );
  }

  /// A sessão começou no dia local de [now] — [offsetAt] dá o fuso de cada instante (São Paulo = −3 h; dia de 23 ou
  /// 25 h com troca de horário).
  bool isOnLocalDay(DateTime now, Duration Function(DateTime utc) offsetAt) {
    final at = now.toUtc();
    final a = startedAt.add(offsetAt(startedAt));
    final b = at.add(offsetAt(at));
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Retomar em [now] (R4): no mesmo dia local, a mesma sessão roda; noutro dia, a anterior vai para [closed] (até a
  /// pausa; `null` com menos de 10 s) e [next] é uma sessão nova no mesmo livro, com o id [newId]. A que já roda não
  /// é retomada nem dividida.
  ({PaperSessionRecord? closed, OpenPaperSession next}) resumeOnAnotherDay(
    DateTime now,
    Duration Function(DateTime utc) offsetAt,
    String newId,
  ) {
    if (isRunning) return (closed: null, next: this);
    if (isOnLocalDay(now, offsetAt)) return (closed: null, next: resume(now));
    return (
      closed: record(now),
      next: OpenPaperSession.start(id: newId, userBookId: userBookId, now: now),
    );
  }

  /// O formato guardado no `kv` (R8), versão 1.
  Map<String, Object?> toJson() => {
    'v': 1,
    'id': id,
    'book': userBookId,
    'startedAt': startedAt.toIso8601String(),
    'activeSeconds': activeSeconds,
    'runningSince': runningSince?.toIso8601String(),
    'pausedAt': pausedAt?.toIso8601String(),
    if (seenAt != null) 'seenAt': seenAt!.toIso8601String(),
  };

  /// O que veio do `kv`; versão desconhecida ou qualquer campo errado → `null` (nunca lança).
  static OpenPaperSession? fromJson(Object? json) {
    if (json is! Map || json['v'] != 1) return null;
    DateTime? instant(Object? v) {
      if (v == null) return null;
      if (v is! String) throw const FormatException('instante');
      return DateTime.parse(v).toUtc();
    }

    try {
      final id = json['id'];
      final book = json['book'];
      final started = json['startedAt'];
      final seconds = json['activeSeconds'];
      if (id is! String || book is! String || started is! String) return null;
      if (seconds is! int) return null;
      return OpenPaperSession(
        id: id,
        userBookId: book,
        startedAt: instant(started)!,
        activeSeconds: seconds,
        runningSince: instant(json['runningSince']),
        pausedAt: instant(json['pausedAt']),
        seenAt: instant(json['seenAt']),
      );
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  OpenPaperSession _copy({
    int? activeSeconds,
    Object? runningSince = _keep,
    Object? pausedAt = _keep,
    Object? seenAt = _keep,
  }) => OpenPaperSession(
    id: id,
    userBookId: userBookId,
    startedAt: startedAt,
    activeSeconds: activeSeconds ?? this.activeSeconds,
    runningSince: identical(runningSince, _keep)
        ? this.runningSince
        : runningSince as DateTime?,
    pausedAt: identical(pausedAt, _keep)
        ? this.pausedAt
        : pausedAt as DateTime?,
    seenAt: identical(seenAt, _keep) ? this.seenAt : seenAt as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      other is OpenPaperSession &&
      other.id == id &&
      other.userBookId == userBookId &&
      other.startedAt == startedAt &&
      other.activeSeconds == activeSeconds &&
      other.runningSince == runningSince &&
      other.pausedAt == pausedAt &&
      other.seenAt == seenAt;

  @override
  int get hashCode => Object.hash(
    id,
    userBookId,
    startedAt,
    activeSeconds,
    runningSince,
    pausedAt,
    seenAt,
  );

  @override
  String toString() =>
      'OpenPaperSession($userBookId, ${activeSeconds}s, '
      '${isRunning ? 'rodando desde $runningSince' : 'pausada em $pausedAt'})';
}

/// Marca de "não mudar" do `_copy` (o `null` é um valor válido: pausada / sem pausa).
const Object _keep = Object();

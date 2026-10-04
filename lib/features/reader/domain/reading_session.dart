import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/model/checks.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';

/// Origem do tempo: e-book "contando sozinho", cronômetro de livro físico ou lançamento manual.
enum SessionSource implements DbCode {
  auto('auto'),
  timer('timer'),
  manual('manual');

  const SessionSource(this.code);

  @override
  final String code;

  static SessionSource fromCode(String code) => Check.byCode(values, code);
}

/// Tempo de leitura (`personal.reading_sessions`, particionada por mês no servidor).
@immutable
final class ReadingSession {
  ReadingSession({
    required String id,
    required this.meta,
    required String userBookId,
    required DateTime startedAt,
    required DateTime endedAt,
    required int activeSeconds,
    int? refPageFrom,
    int? refPageTo,
    int? pagesViewed,
    required this.source,
    this.deviceId,
  }) : id = Check.uuid(id, 'id'),
       userBookId = Check.uuid(userBookId, 'userBookId'),
       startedAt = Check.utc(startedAt, 'startedAt'),
       endedAt = _endedAt(startedAt, endedAt),
       activeSeconds = Check.range(activeSeconds, 0, 86400, 'activeSeconds'),
       refPageFrom = Check.rangeOrNull(
         refPageFrom,
         -2147483648,
         2147483647,
         'refPageFrom',
       ),
       refPageTo = Check.rangeOrNull(
         refPageTo,
         -2147483648,
         2147483647,
         'refPageTo',
       ),
       pagesViewed = Check.rangeOrNull(
         pagesViewed,
         0,
         2147483647,
         'pagesViewed',
       );

  static DateTime _endedAt(DateTime startedAt, DateTime endedAt) {
    Check.utc(endedAt, 'endedAt');
    if (endedAt.isBefore(startedAt)) {
      throw ArgumentError.value(endedAt, 'endedAt', 'antes do início');
    }
    return endedAt;
  }

  final String id;
  final RecordMeta meta;
  final String userBookId;
  final DateTime startedAt;
  final DateTime endedAt;

  /// Segundos de leitura ativa (sem pausas), ≤ 24 h.
  final int activeSeconds;
  final int? refPageFrom;
  final int? refPageTo;
  final int? pagesViewed;
  final SessionSource source;
  final String? deviceId;

  ReadingSession copyWith({
    RecordMeta? meta,
    DateTime? startedAt,
    DateTime? endedAt,
    int? activeSeconds,
    Nullable<int>? refPageFrom,
    Nullable<int>? refPageTo,
    Nullable<int>? pagesViewed,
    SessionSource? source,
    Nullable<String>? deviceId,
  }) => ReadingSession(
    id: id,
    meta: meta ?? this.meta,
    userBookId: userBookId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    activeSeconds: activeSeconds ?? this.activeSeconds,
    refPageFrom: refPageFrom == null ? this.refPageFrom : refPageFrom.value,
    refPageTo: refPageTo == null ? this.refPageTo : refPageTo.value,
    pagesViewed: pagesViewed == null ? this.pagesViewed : pagesViewed.value,
    source: source ?? this.source,
    deviceId: deviceId == null ? this.deviceId : deviceId.value,
  );

  @override
  bool operator ==(Object other) =>
      other is ReadingSession &&
      other.id == id &&
      other.meta == meta &&
      other.userBookId == userBookId &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.activeSeconds == activeSeconds &&
      other.refPageFrom == refPageFrom &&
      other.refPageTo == refPageTo &&
      other.pagesViewed == pagesViewed &&
      other.source == source &&
      other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(
    id,
    meta,
    userBookId,
    startedAt,
    endedAt,
    activeSeconds,
    refPageFrom,
    refPageTo,
    pagesViewed,
    source,
    deviceId,
  );
}

/// Tempo lido por dia no fuso do usuário (Anexo 02 §4.2 — sempre derivado das sessões).
abstract final class ReadingTime {
  /// Minutos inteiros das sessões não apagadas que começaram no dia [localDay] (só a data conta)
  /// do fuso com deslocamento [utcOffset] (São Paulo = −3 h).
  static int minutesOn(
    Iterable<ReadingSession> sessions, {
    required DateTime localDay,
    required Duration utcOffset,
  }) {
    var seconds = 0;
    for (final s in sessions) {
      if (s.meta.isDeleted) continue;
      final local = s.startedAt.add(utcOffset);
      if (local.year == localDay.year &&
          local.month == localDay.month &&
          local.day == localDay.day) {
        seconds += s.activeSeconds;
      }
    }
    return seconds ~/ 60;
  }
}

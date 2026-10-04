import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/model/checks.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';
import 'locator.dart';

/// Posição de leitura — 1 por livro (`personal.reading_positions`, id = user_book_id).
@immutable
final class ReadingPosition {
  ReadingPosition({
    required String id,
    required this.meta,
    required this.locator,
    required int refPage,
    required int chapterIndex,
    required double progression,
    this.deviceId,
  }) : id = Check.uuid(id, 'id'),
       refPage = Check.range(refPage, 1, 2147483647, 'refPage'),
       chapterIndex = Check.range(chapterIndex, 0, 2147483647, 'chapterIndex'),
       progression = _progression(progression);

  static double _progression(double p) {
    if (p.isNaN || p < 0 || p > 1) {
      throw ArgumentError.value(p, 'progression', 'fora de 0…1');
    }
    return p;
  }

  /// = id do livro na estante.
  final String id;
  final RecordMeta meta;
  final Locator locator;

  /// Página de referência do primeiro caractere visível ("pág. 159").
  final int refPage;

  /// Índice (0 = primeiro) do capítulo no sumário.
  final int chapterIndex;

  /// Fração lida (caractere global ÷ total), `numeric(6,5)` no servidor.
  final double progression;
  final String? deviceId;

  ReadingPosition copyWith({
    RecordMeta? meta,
    Locator? locator,
    int? refPage,
    int? chapterIndex,
    double? progression,
    Nullable<String>? deviceId,
  }) => ReadingPosition(
    id: id,
    meta: meta ?? this.meta,
    locator: locator ?? this.locator,
    refPage: refPage ?? this.refPage,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    progression: progression ?? this.progression,
    deviceId: deviceId == null ? this.deviceId : deviceId.value,
  );

  @override
  bool operator ==(Object other) =>
      other is ReadingPosition &&
      other.id == id &&
      other.meta == meta &&
      other.locator == locator &&
      other.refPage == refPage &&
      other.chapterIndex == chapterIndex &&
      other.progression == progression &&
      other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(
    id,
    meta,
    locator,
    refPage,
    chapterIndex,
    progression,
    deviceId,
  );
}

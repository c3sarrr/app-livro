import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/model/checks.dart';
import '../../../core/data/model/record_meta.dart';

/// Metas de leitura — 1 linha por usuário (`personal.reading_goals`, id = user_id).
@immutable
final class ReadingGoals {
  ReadingGoals({
    required String id,
    required this.meta,
    int dailyMinutes = 30,
    int badgeTargetDays = 7,
  }) : id = _sameAsOwner(id, meta),
       dailyMinutes = Check.range(dailyMinutes, 5, 600, 'dailyMinutes'),
       badgeTargetDays = Check.range(
         badgeTargetDays,
         1,
         365,
         'badgeTargetDays',
       );

  static String _sameAsOwner(String id, RecordMeta meta) {
    if (id != meta.userId) throw ArgumentError.value(id, 'id', 'id = user_id');
    return id;
  }

  final String id;
  final RecordMeta meta;

  /// Meta diária em minutos ("Seu dia de leitura" da Início).
  final int dailyMinutes;

  /// Dias seguidos que dão o selo.
  final int badgeTargetDays;

  ReadingGoals copyWith({
    RecordMeta? meta,
    int? dailyMinutes,
    int? badgeTargetDays,
  }) => ReadingGoals(
    id: id,
    meta: meta ?? this.meta,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    badgeTargetDays: badgeTargetDays ?? this.badgeTargetDays,
  );

  @override
  bool operator ==(Object other) =>
      other is ReadingGoals &&
      other.id == id &&
      other.meta == meta &&
      other.dailyMinutes == dailyMinutes &&
      other.badgeTargetDays == badgeTargetDays;

  @override
  int get hashCode => Object.hash(id, meta, dailyMinutes, badgeTargetDays);
}

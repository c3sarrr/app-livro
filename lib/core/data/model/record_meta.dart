import 'package:flutter/foundation.dart' show immutable;

import '../clock/hlc.dart';
import 'checks.dart';
import 'nullable.dart';

/// Colunas comuns das 10 tabelas pessoais (Anexo 02 §1.7 e §3.2): dono, datas em UTC, tombstone
/// (`deleted_at` — nada pessoal é apagado de verdade fora da retenção) e versão para o LWW.
@immutable
final class RecordMeta {
  RecordMeta({
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    required this.version,
  }) : userId = Check.uuid(userId, 'userId'),
       createdAt = Check.utc(createdAt, 'createdAt'),
       updatedAt = Check.utc(updatedAt, 'updatedAt'),
       deletedAt = Check.utcOrNull(deletedAt, 'deletedAt');

  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Hlc version;

  bool get isDeleted => deletedAt != null;

  /// Edição local: nova versão (HLC de `HlcClock.sendAfterReading`) e `updated_at`.
  RecordMeta edited(DateTime at, Hlc version) =>
      copyWith(updatedAt: at, version: version);

  /// Exclusão lógica (tombstone).
  RecordMeta deleted(DateTime at, Hlc version) =>
      copyWith(updatedAt: at, deletedAt: Nullable(at), version: version);

  RecordMeta copyWith({
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Nullable<DateTime>? deletedAt,
    Hlc? version,
  }) => RecordMeta(
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt == null ? this.deletedAt : deletedAt.value,
    version: version ?? this.version,
  );

  @override
  bool operator ==(Object other) =>
      other is RecordMeta &&
      other.userId == userId &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.version == version;

  @override
  int get hashCode =>
      Object.hash(userId, createdAt, updatedAt, deletedAt, version);
}

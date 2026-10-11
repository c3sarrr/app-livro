import '../../clock/hlc.dart';
import '../../model/record_meta.dart';

/// Metadados comuns lidos de uma linha pessoal.
RecordMeta metaFromRow({
  required String userId,
  required DateTime createdAt,
  required DateTime updatedAt,
  required DateTime? deletedAt,
  required Hlc versionHlc,
}) => RecordMeta(
  userId: userId,
  createdAt: createdAt,
  updatedAt: updatedAt,
  deletedAt: deletedAt,
  version: versionHlc,
);

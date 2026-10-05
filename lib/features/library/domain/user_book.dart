import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/model/checks.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';

/// Formato do livro na estante (`user_books.format`).
enum BookFileFormat implements DbCode {
  epub('epub'),
  pdf('pdf'),
  physical('physical');

  const BookFileFormat(this.code);

  @override
  final String code;

  static BookFileFormat fromCode(String code) => Check.byCode(values, code);
}

/// Situação do livro na estante (`user_books.status`).
enum ShelfStatus implements DbCode {
  wantToRead('want_to_read'),
  reading('reading'),
  finished('finished'),
  abandoned('abandoned');

  const ShelfStatus(this.code);

  @override
  final String code;

  static ShelfStatus fromCode(String code) => Check.byCode(values, code);
}

/// Um livro na estante (e-book, PDF ou físico) — `personal.user_books` (Anexo 02 §4.1).
@immutable
final class UserBook {
  UserBook({
    required String id,
    required this.meta,
    String? editionId,
    required String title,
    required String authorDisplay,
    required this.format,
    required this.status,
    String? contentSha256,
    int? fileBytes,
    this.storageObjectPath,
    int? refPagesTotal,
    int? refPageVersion,
    int? chaptersTotal,
    this.coverRef,
    int? rating,
    required DateTime addedAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime? lastOpenedAt,
    String? isbn13,
  }) : id = Check.uuid(id, 'id'),
       editionId = Check.uuidOrNull(editionId, 'editionId'),
       title = Check.text(title, min: 1, max: 500, name: 'title'),
       authorDisplay = Check.text(
         authorDisplay,
         min: 1,
         max: 500,
         name: 'authorDisplay',
       ),
       contentSha256 = Check.sha256OrNull(contentSha256, 'contentSha256'),
       fileBytes = Check.rangeOrNull(fileBytes, 0, _maxBigint, 'fileBytes'),
       refPagesTotal = Check.rangeOrNull(
         refPagesTotal,
         1,
         _maxInteger,
         'refPagesTotal',
       ),
       refPageVersion = Check.rangeOrNull(
         refPageVersion,
         -32768,
         32767,
         'refPageVersion',
       ),
       chaptersTotal = Check.rangeOrNull(
         chaptersTotal,
         1,
         _maxInteger,
         'chaptersTotal',
       ),
       rating = Check.rangeOrNull(rating, 1, 5, 'rating'),
       addedAt = Check.utc(addedAt, 'addedAt'),
       startedAt = Check.utcOrNull(startedAt, 'startedAt'),
       finishedAt = Check.utcOrNull(finishedAt, 'finishedAt'),
       lastOpenedAt = Check.utcOrNull(lastOpenedAt, 'lastOpenedAt'),
       isbn13 = Check.isbn13OrNull(isbn13, 'isbn13');

  static const int _maxInteger = 2147483647;
  static const int _maxBigint = 9223372036854775807;

  final String id;
  final RecordMeta meta;
  final String? editionId;
  final String title;
  final String authorDisplay;
  final BookFileFormat format;
  final ShelfStatus status;

  /// sha256 do arquivo: dedupe e validade das âncoras (Anexo 03 §5).
  final String? contentSha256;
  final int? fileBytes;

  /// E-book na nuvem (Pro, opcional).
  final String? storageObjectPath;

  /// Total de páginas de referência ("de 256") e a versão da regra que as gerou (D-19).
  final int? refPagesTotal;
  final int? refPageVersion;
  final int? chaptersTotal;
  final String? coverRef;
  final int? rating;
  final DateTime addedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime? lastOpenedAt;

  /// ISBN-13 do exemplar (D-77): o scanner avisa quando o livro já está na estante.
  final String? isbn13;

  UserBook copyWith({
    RecordMeta? meta,
    Nullable<String>? editionId,
    String? title,
    String? authorDisplay,
    BookFileFormat? format,
    ShelfStatus? status,
    Nullable<String>? contentSha256,
    Nullable<int>? fileBytes,
    Nullable<String>? storageObjectPath,
    Nullable<int>? refPagesTotal,
    Nullable<int>? refPageVersion,
    Nullable<int>? chaptersTotal,
    Nullable<String>? coverRef,
    Nullable<int>? rating,
    DateTime? addedAt,
    Nullable<DateTime>? startedAt,
    Nullable<DateTime>? finishedAt,
    Nullable<DateTime>? lastOpenedAt,
    Nullable<String>? isbn13,
  }) => UserBook(
    id: id,
    meta: meta ?? this.meta,
    editionId: editionId == null ? this.editionId : editionId.value,
    title: title ?? this.title,
    authorDisplay: authorDisplay ?? this.authorDisplay,
    format: format ?? this.format,
    status: status ?? this.status,
    contentSha256: contentSha256 == null
        ? this.contentSha256
        : contentSha256.value,
    fileBytes: fileBytes == null ? this.fileBytes : fileBytes.value,
    storageObjectPath: storageObjectPath == null
        ? this.storageObjectPath
        : storageObjectPath.value,
    refPagesTotal: refPagesTotal == null
        ? this.refPagesTotal
        : refPagesTotal.value,
    refPageVersion: refPageVersion == null
        ? this.refPageVersion
        : refPageVersion.value,
    chaptersTotal: chaptersTotal == null
        ? this.chaptersTotal
        : chaptersTotal.value,
    coverRef: coverRef == null ? this.coverRef : coverRef.value,
    rating: rating == null ? this.rating : rating.value,
    addedAt: addedAt ?? this.addedAt,
    startedAt: startedAt == null ? this.startedAt : startedAt.value,
    finishedAt: finishedAt == null ? this.finishedAt : finishedAt.value,
    lastOpenedAt: lastOpenedAt == null ? this.lastOpenedAt : lastOpenedAt.value,
    isbn13: isbn13 == null ? this.isbn13 : isbn13.value,
  );

  @override
  bool operator ==(Object other) =>
      other is UserBook &&
      other.id == id &&
      other.meta == meta &&
      other.editionId == editionId &&
      other.title == title &&
      other.authorDisplay == authorDisplay &&
      other.format == format &&
      other.status == status &&
      other.contentSha256 == contentSha256 &&
      other.fileBytes == fileBytes &&
      other.storageObjectPath == storageObjectPath &&
      other.refPagesTotal == refPagesTotal &&
      other.refPageVersion == refPageVersion &&
      other.chaptersTotal == chaptersTotal &&
      other.coverRef == coverRef &&
      other.rating == rating &&
      other.addedAt == addedAt &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt &&
      other.lastOpenedAt == lastOpenedAt &&
      other.isbn13 == isbn13;

  @override
  int get hashCode => Object.hashAll([
    id,
    meta,
    editionId,
    title,
    authorDisplay,
    format,
    status,
    contentSha256,
    fileBytes,
    storageObjectPath,
    refPagesTotal,
    refPageVersion,
    chaptersTotal,
    coverRef,
    rating,
    addedAt,
    startedAt,
    finishedAt,
    lastOpenedAt,
    isbn13,
  ]);
}

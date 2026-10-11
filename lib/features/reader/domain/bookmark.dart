import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/model/checks.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';
import 'locator.dart';

/// Página marcada (fita da tela 20 / aba Marcadas da 27b) — `personal.bookmarks`.
@immutable
final class Bookmark {
  Bookmark({
    required String id,
    required this.meta,
    required String userBookId,
    required this.locator,
    required int refPage,
    required int chapterIndex,
    String? excerpt,
  }) : id = Check.uuid(id, 'id'),
       userBookId = Check.uuid(userBookId, 'userBookId'),
       refPage = Check.range(refPage, 1, 2147483647, 'refPage'),
       chapterIndex = Check.range(chapterIndex, 0, 2147483647, 'chapterIndex'),
       excerpt = Check.textOrNull(excerpt, max: 280, name: 'excerpt');

  final String id;
  final RecordMeta meta;
  final String userBookId;
  final Locator locator;
  final int refPage;
  final int chapterIndex;

  /// Começo da página gravado na criação (D-49).
  final String? excerpt;

  Bookmark copyWith({
    RecordMeta? meta,
    Locator? locator,
    int? refPage,
    int? chapterIndex,
    Nullable<String>? excerpt,
  }) => Bookmark(
    id: id,
    meta: meta ?? this.meta,
    userBookId: userBookId,
    locator: locator ?? this.locator,
    refPage: refPage ?? this.refPage,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    excerpt: excerpt == null ? this.excerpt : excerpt.value,
  );

  @override
  bool operator ==(Object other) =>
      other is Bookmark &&
      other.id == id &&
      other.meta == meta &&
      other.userBookId == userBookId &&
      other.locator == locator &&
      other.refPage == refPage &&
      other.chapterIndex == chapterIndex &&
      other.excerpt == excerpt;

  @override
  int get hashCode => Object.hash(
    id,
    meta,
    userBookId,
    locator,
    refPage,
    chapterIndex,
    excerpt,
  );
}

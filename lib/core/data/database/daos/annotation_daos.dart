// DAOs de anotações (tela 25), camadas de tinta, rótulos e predefinições da caneta.
import 'package:drift/drift.dart';

import '../../../../features/reader/annotations/domain/annotation.dart';
import '../../../../features/reader/annotations/domain/highlight_label.dart';
import '../../../../features/reader/annotations/domain/ink_layer.dart';
import '../../../../features/reader/annotations/domain/pen_presets.dart';
import '../app_database.dart';
import '../failures.dart';
import 'rows.dart';

final class AnnotationsDao {
  AnnotationsDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(Annotation a) => _db
      .into(_db.annotations)
      .insertOnConflictUpdate(
        AnnotationsCompanion(
          id: Value(a.id),
          userId: Value(a.meta.userId),
          userBookId: Value(a.userBookId),
          kind: Value(a.kind),
          parentId: Value(a.parentId),
          groupId: Value(a.groupId),
          source: Value(a.source),
          anchor: Value(a.anchor),
          refPage: Value(a.refPage),
          chapterIndex: Value(a.chapterIndex),
          color: Value(a.color),
          style: Value(a.style),
          fillHeight: Value(a.fillHeight),
          noteText: Value(a.noteText),
          inkLayerId: Value(a.inkLayerId),
          sharedClubPostId: Value(a.sharedClubPostId),
          createdAt: Value(a.meta.createdAt),
          updatedAt: Value(a.meta.updatedAt),
          deletedAt: Value(a.meta.deletedAt),
          versionHlc: Value(a.meta.version),
        ),
      );

  /// A linha [id], viva ou não (a sobreposição e a nota leem o pai que acabou de mudar — G13).
  Future<Annotation?> byId(String id) => (_db.select(
    _db.annotations,
  )..where((t) => t.id.equals(id))).map(_toEntity).getSingleOrNull();

  /// As linhas [ids], vivas ou não (o Concluir da G16 lê o que vai regravar).
  Future<List<Annotation>> byIds(Iterable<String> ids) {
    final list = ids.toList();
    if (list.isEmpty) return Future.value(const []);
    return (_db.select(
      _db.annotations,
    )..where((t) => t.id.isIn(list))).map(_toEntity).get();
  }

  /// Os desenhos (`drawing`) vivos das camadas [layerIds] (G16).
  Future<List<Annotation>> drawingsOfLayers(Iterable<String> layerIds) {
    final list = layerIds.toList();
    if (list.isEmpty) return Future.value(const []);
    return (_db.select(_db.annotations)
          ..where(
            (t) =>
                t.inkLayerId.isIn(list) &
                t.kind.equals(AnnotationKind.drawing.code) &
                t.deletedAt.isNull(),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .map(_toEntity)
        .get();
  }

  /// Itens do livro na ordem do livro (página, início da âncora, criação) — tela 25.
  Future<List<Annotation>> forBook(String userBookId) =>
      _forBook(userBookId).get();

  Stream<List<Annotation>> watchForBook(String userBookId) =>
      _forBook(userBookId).watch();

  Selectable<Annotation> _forBook(String userBookId) =>
      (_db.select(_db.annotations)
            ..where(
              (t) => t.userBookId.equals(userBookId) & t.deletedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm(expression: t.refPage),
              (_) => OrderingTerm(expression: _anchorStart),
              (t) => OrderingTerm(expression: t.createdAt),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .map(_toEntity);

  /// Quantos grifos não apagados de cada cor (`#RRGGBB` em maiúsculas) o usuário tem em todos os livros, de seleção e
  /// à mão (contagem por rótulo — D-40), contados no banco.
  Future<Map<String, int>> highlightCountsByColor(String userId) async {
    final rows = await _db
        .customSelect(
          'SELECT UPPER(color) AS c, COUNT(*) AS n FROM annotations '
          'WHERE user_id = ? AND deleted_at IS NULL AND kind = ? '
          'AND color IS NOT NULL GROUP BY UPPER(color)',
          variables: [
            Variable.withString(userId),
            Variable.withString(AnnotationKind.highlight.code),
          ],
          readsFrom: {_db.annotations},
        )
        .get();
    return {for (final r in rows) r.read<String>('c'): r.read<int>('n')};
  }

  /// Busca da tela 25 no texto do grifo e da nota (FTS5, sem acento, prefixo por palavra).
  Future<List<Annotation>> search(String userBookId, String query) async {
    final match = ftsQuery(query);
    if (match == null) return forBook(userBookId);
    final rows = await _db
        .customSelect(
          'SELECT a.* FROM annotations a '
          'JOIN annotations_fts f ON f.annotation_id = a.id '
          'WHERE f.user_book_id = ? AND annotations_fts MATCH ? '
          'AND a.deleted_at IS NULL '
          "ORDER BY a.ref_page, json_extract(a.anchor, '\$.start'), a.created_at, a.id",
          variables: [
            Variable.withString(userBookId),
            Variable.withString(match),
          ],
          readsFrom: {_db.annotations},
        )
        .get();
    return [for (final r in rows) _toEntity(_db.annotations.map(r.data))];
  }

  /// Termos entre aspas (sem operadores do FTS5) e com prefixo: `"capitu"* "olhos"*`.
  static String? ftsQuery(String query) {
    final terms = query
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll('"', ''))
        .where((t) => t.isNotEmpty)
        .map((t) => '"$t"*');
    return terms.isEmpty ? null : terms.join(' ');
  }

  static const Expression<int> _anchorStart = CustomExpression<int>(
    "json_extract(annotations.anchor, '\$.start')",
  );

  static Annotation _toEntity(AnnotationRow r) => Annotation(
    id: r.id,
    meta: metaFromRow(
      userId: r.userId,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
      versionHlc: r.versionHlc,
    ),
    userBookId: r.userBookId,
    kind: r.kind,
    parentId: r.parentId,
    groupId: r.groupId,
    source: r.source,
    anchor: r.anchor,
    refPage: r.refPage,
    chapterIndex: r.chapterIndex,
    color: r.color,
    style: r.style,
    fillHeight: r.fillHeight,
    noteText: r.noteText,
    inkLayerId: r.inkLayerId,
    sharedClubPostId: r.sharedClubPostId,
  );
}

final class InkLayersDao {
  InkLayersDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(InkLayer l) => _db
      .into(_db.inkLayers)
      .insertOnConflictUpdate(
        InkLayersCompanion(
          id: Value(l.id),
          userId: Value(l.meta.userId),
          userBookId: Value(l.userBookId),
          kind: Value(l.kind),
          anchor: Value(l.anchor),
          spaceLines: Value(l.spaceLines),
          collapsed: Value(l.collapsed),
          strokesB64: Value(l.strokesB64),
          strokeCount: Value(l.strokeCount),
          codecVersion: Value(l.codecVersion),
          createdAt: Value(l.meta.createdAt),
          updatedAt: Value(l.meta.updatedAt),
          deletedAt: Value(l.meta.deletedAt),
          versionHlc: Value(l.meta.version),
        ),
      );

  Future<List<InkLayer>> forBook(String userBookId) =>
      (_db.select(_db.inkLayers)
            ..where(
              (t) => t.userBookId.equals(userBookId) & t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .map(_toEntity)
          .get();

  /// As camadas [ids], vivas ou não (o Concluir da G16 lê o que vai regravar ou apagar).
  Future<List<InkLayer>> byIds(Iterable<String> ids) {
    final list = ids.toList();
    if (list.isEmpty) return Future.value(const []);
    return (_db.select(
      _db.inkLayers,
    )..where((t) => t.id.isIn(list))).map(_toEntity).get();
  }

  /// As camadas sobre o texto (os desenhos — G16) vivas do livro, em ordem de criação.
  Future<List<InkLayer>> liveOverTextForBook(String userBookId) =>
      (_db.select(_db.inkLayers)
            ..where(
              (t) =>
                  t.userBookId.equals(userBookId) &
                  t.kind.equals(InkLayerKind.overText.code) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm(expression: t.createdAt),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .map(_toEntity)
          .get();

  static InkLayer _toEntity(InkLayerRow r) => InkLayer(
    id: r.id,
    meta: metaFromRow(
      userId: r.userId,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
      versionHlc: r.versionHlc,
    ),
    userBookId: r.userBookId,
    kind: r.kind,
    anchor: r.anchor,
    spaceLines: r.spaceLines,
    collapsed: r.collapsed,
    strokesB64: r.strokesB64,
    strokeCount: r.strokeCount,
    codecVersion: r.codecVersion,
  );
}

final class HighlightLabelsDao {
  HighlightLabelsDao(this._db);

  final AppDatabase _db;

  /// Grava o rótulo. Recusa ([DuplicateActiveRow]) outra cor igual ativa do mesmo usuário — índice
  /// único parcial do servidor.
  Future<void> upsert(HighlightLabel l) => _db.transaction(() async {
    if (!l.meta.isDeleted) {
      final outros =
          await (_db.select(_db.highlightLabels)..where(
                (t) =>
                    t.userId.equals(l.meta.userId) &
                    t.color.equals(l.color) &
                    t.deletedAt.isNull() &
                    t.id.isNotValue(l.id),
              ))
              .get();
      if (outros.isNotEmpty) {
        throw DuplicateActiveRow(
          table: 'highlight_labels',
          column: 'color',
          existingId: outros.first.id,
        );
      }
    }
    await _db
        .into(_db.highlightLabels)
        .insertOnConflictUpdate(
          HighlightLabelsCompanion(
            id: Value(l.id),
            userId: Value(l.meta.userId),
            color: Value(l.color),
            label: Value(l.label),
            sort: Value(l.sort),
            createdAt: Value(l.meta.createdAt),
            updatedAt: Value(l.meta.updatedAt),
            deletedAt: Value(l.meta.deletedAt),
            versionHlc: Value(l.meta.version),
          ),
        );
  });

  /// Rótulos do usuário na ordem de exibição (tela 23b).
  Future<List<HighlightLabel>> forUser(String userId) =>
      (_db.select(_db.highlightLabels)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm(expression: t.sort),
              (t) => OrderingTerm(expression: t.color),
            ]))
          .map(
            (r) => HighlightLabel(
              id: r.id,
              meta: metaFromRow(
                userId: r.userId,
                createdAt: r.createdAt,
                updatedAt: r.updatedAt,
                deletedAt: r.deletedAt,
                versionHlc: r.versionHlc,
              ),
              color: r.color,
              label: r.label,
              sort: r.sort,
            ),
          )
          .get();
}

final class PenPresetsDao {
  PenPresetsDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(PenPresets p) => _db
      .into(_db.penPresetsRows)
      .insertOnConflictUpdate(
        PenPresetsRowsCompanion(
          id: Value(p.id),
          userId: Value(p.meta.userId),
          penTip: Value(p.penTip),
          penWidthMm: Value(p.penWidthMm),
          penColor: Value(p.penColor),
          favoriteColors: Value(p.favoriteColors),
          strokeSize: Value(p.strokeSize),
          highlighterStyle: Value(p.highlighterStyle),
          highlighterHeight: Value(p.highlighterHeight),
          highlighterColor: Value(p.highlighterColor),
          createdAt: Value(p.meta.createdAt),
          updatedAt: Value(p.meta.updatedAt),
          deletedAt: Value(p.meta.deletedAt),
          versionHlc: Value(p.meta.version),
        ),
      );

  Future<PenPresets?> forUser(String userId) async {
    final r = await (_db.select(
      _db.penPresetsRows,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    if (r == null) return null;
    return PenPresets(
      id: r.id,
      meta: metaFromRow(
        userId: r.userId,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
        versionHlc: r.versionHlc,
      ),
      penTip: r.penTip,
      penWidthMm: r.penWidthMm,
      penColor: r.penColor,
      favoriteColors: r.favoriteColors,
      strokeSize: r.strokeSize,
      highlighterStyle: r.highlighterStyle,
      highlighterHeight: r.highlighterHeight,
      highlighterColor: r.highlighterColor,
    );
  }
}

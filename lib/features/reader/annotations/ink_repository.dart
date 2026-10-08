// G16.4 — o repositório da tinta (§4): os desenhos salvos do livro, o Concluir numa transação e o rascunho no `kv`.
// - Concluir: uma transação, cada linha pelo `LocalVersioning.write` (HLC). Camadas novas (`created = updated` = a
//   hora do HLC) e mudadas (fica a criação); as anotações `drawing` (`source = ink`, a cor do 1º traço, a página e o
//   capítulo do começo do trecho, o grupo — que não muda depois de gravado); camadas apagadas com as anotações
//   delas; grifos à mão apagados pela Borracha, com as notas filhas (o de seleção fica — D-168). A linha que já não
//   existe ou já está apagada, pula; a que ficaria igual, não é regravada: aplicar duas vezes dá as mesmas linhas (o
//   rascunho é idempotente) e a fila do Pro só recebe o que mudou.
// - Rascunho: o JSON de `ink_changes.dart` na chave `ink_draft:<dono>:<user_book_id>` do `kv` (só do aparelho, nunca
//   sincroniza). Ao abrir o livro (D-166), é gravado como um Concluir e a chave some; se falhar, a chave fica e a
//   falha vai ao relatório sem conteúdo.
import '../../../core/data/clock/hlc.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';
import '../application/reader_errors.dart';
import 'domain/annotation.dart';
import 'domain/ink_layer.dart';
import 'ink/ink_changes.dart';

/// Um desenho salvo do livro: a camada `over_text` viva e a anotação `drawing` dela.
typedef SavedDrawing = ({InkLayer layer, Annotation annotation});

/// O rascunho não foi gravado ao abrir o livro (D-166): só o tipo da falha, sem o conteúdo.
final class InkDraftNotRecovered implements Exception {
  const InkDraftNotRecovered(this.cause);

  final String cause;

  @override
  String toString() => 'InkDraftNotRecovered($cause)';
}

abstract interface class InkRepository {
  /// Os desenhos vivos do livro, em ordem de criação.
  Future<List<SavedDrawing>> drawingsOfBook(String userBookId);

  /// Grava [c] numa transação, pelo `LocalVersioning.write`, com HLC.
  Future<void> commit(String owner, String userBookId, InkChanges c);

  /// Guarda [c] como o rascunho do livro (vazio apaga o rascunho).
  Future<void> saveDraft(String owner, String userBookId, InkChanges c);

  /// O rascunho guardado; `null` sem rascunho ou ilegível.
  Future<InkChanges?> draftOf(String owner, String userBookId);

  Future<void> clearDraft(String owner, String userBookId);

  /// D-166: grava o rascunho como um Concluir e apaga a chave; se falhar, a chave fica (`false`). Sem rascunho,
  /// `true`.
  Future<bool> recoverDraft(String owner, String userBookId);
}

final class DriftInkRepository implements InkRepository {
  DriftInkRepository(
    this.db,
    this.versioning, {
    DateTime Function()? now,
    this.onError = reportReaderError,
  }) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final LocalVersioning versioning;
  final ReaderErrorReporter onError;
  final DateTime Function() _now;

  InkLayersDao get _layers => InkLayersDao(db);
  AnnotationsDao get _annotations => AnnotationsDao(db);

  @override
  Future<List<SavedDrawing>> drawingsOfBook(String userBookId) async {
    final layers = await _layers.liveOverTextForBook(userBookId);
    final drawings = await _annotations.drawingsOfLayers([
      for (final l in layers) l.id,
    ]);
    final ofLayer = <String, Annotation>{};
    for (final a in drawings) {
      ofLayer.putIfAbsent(a.inkLayerId!, () => a);
    }
    return [
      for (final l in layers)
        if (ofLayer[l.id] case final a?) (layer: l, annotation: a),
    ];
  }

  @override
  Future<void> commit(String owner, String userBookId, InkChanges c) async {
    if (c.isEmpty) return;
    await db.transaction(() async {
      final layers = {
        for (final l in await _layers.byIds({
          for (final r in c.layers) r.layerId,
          ...c.deletedLayers,
        }))
          l.id: l,
      };
      final annotations = {
        for (final a in await _annotations.byIds([
          for (final r in c.layers) r.annotationId,
        ]))
          a.id: a,
      };
      for (final r in c.layers) {
        await _writeLayer(owner, userBookId, r, layers[r.layerId]);
        await _writeDrawing(owner, userBookId, r, annotations[r.annotationId]);
      }
      for (final id in c.deletedLayers) {
        final l = layers[id];
        if (l == null || l.meta.isDeleted) continue;
        await _write(
          'ink_layers',
          id,
          (v, at) => _layers.upsert(l.copyWith(meta: l.meta.deleted(at, v))),
        );
        for (final a in await _annotations.drawingsOfLayers([id])) {
          await _delete(a);
        }
      }
      if (c.erasedHighlights.isNotEmpty) {
        final book = await _annotations.forBook(userBookId);
        // a Borracha só apaga tinta (D-168): o grifo de seleção (e a nota dele) fica, mesmo que venha na lista
        final erasable = {
          for (final a in book)
            if (a.kind == AnnotationKind.highlight &&
                a.source == AnnotationSource.ink &&
                c.erasedHighlights.contains(a.id))
              a.id,
        };
        for (final a in book) {
          final erased =
              erasable.contains(a.id) ||
              (a.kind == AnnotationKind.note && erasable.contains(a.parentId));
          if (erased) await _delete(a);
        }
      }
    });
  }

  Future<void> _writeLayer(
    String owner,
    String userBookId,
    DrawingRow r,
    InkLayer? old,
  ) async {
    if (old != null &&
        !old.meta.isDeleted &&
        old.kind == InkLayerKind.overText &&
        old.anchor == r.anchor &&
        old.strokesB64 == r.strokesB64 &&
        old.strokeCount == r.strokeCount) {
      return;
    }
    await _write(
      'ink_layers',
      r.layerId,
      (v, at) => _layers.upsert(
        old == null
            ? InkLayer(
                id: r.layerId,
                meta: RecordMeta(
                  userId: owner,
                  createdAt: at,
                  updatedAt: at,
                  version: v,
                ),
                userBookId: userBookId,
                kind: InkLayerKind.overText,
                anchor: r.anchor,
                strokesB64: r.strokesB64,
                strokeCount: r.strokeCount,
              )
            : old.copyWith(
                meta: _touched(old.meta, at, v),
                anchor: r.anchor,
                strokesB64: r.strokesB64,
                strokeCount: r.strokeCount,
              ),
      ),
    );
  }

  Future<void> _writeDrawing(
    String owner,
    String userBookId,
    DrawingRow r,
    Annotation? old,
  ) async {
    if (old != null &&
        !old.meta.isDeleted &&
        old.kind == AnnotationKind.drawing &&
        old.anchor == r.range &&
        old.refPage == r.refPage &&
        old.chapterIndex == r.chapterIndex &&
        old.color == r.color &&
        old.inkLayerId == r.layerId) {
      return;
    }
    await _write(
      'annotations',
      r.annotationId,
      (v, at) => _annotations.upsert(
        old == null
            ? Annotation(
                id: r.annotationId,
                meta: RecordMeta(
                  userId: owner,
                  createdAt: at,
                  updatedAt: at,
                  version: v,
                ),
                userBookId: userBookId,
                kind: AnnotationKind.drawing,
                groupId: r.groupId,
                source: AnnotationSource.ink,
                anchor: r.range,
                refPage: r.refPage,
                chapterIndex: r.chapterIndex,
                color: r.color,
                inkLayerId: r.layerId,
              )
            // os grupos já gravados não mudam (Anexo 02 §4.3)
            : old.copyWith(
                meta: _touched(old.meta, at, v),
                anchor: r.range,
                refPage: r.refPage,
                chapterIndex: r.chapterIndex,
                color: Nullable(r.color),
                inkLayerId: Nullable(r.layerId),
              ),
      ),
    );
  }

  /// A linha que já existia: editada; a que estava apagada (em outro aparelho) volta, com o que a sessão desenhou.
  static RecordMeta _touched(RecordMeta m, DateTime at, Hlc v) =>
      m.isDeleted ? m.restored(at, v) : m.edited(at, v);

  Future<void> _delete(Annotation a) => _write(
    'annotations',
    a.id,
    (v, at) => _annotations.upsert(a.copyWith(meta: a.meta.deleted(at, v))),
  );

  Future<void> _write(
    String table,
    String id,
    Future<void> Function(Hlc v, DateTime at) save,
  ) => versioning.write(
    table,
    id,
    (v) => save(v, DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true)),
  );

  @override
  Future<void> saveDraft(String owner, String userBookId, InkChanges c) {
    final key = draftKey(owner, userBookId);
    if (c.isEmpty) return KvDao(db).delete(key);
    return KvDao(db).set(key, encodeDraft(c, at: _now()));
  }

  @override
  Future<InkChanges?> draftOf(String owner, String userBookId) async {
    final raw = await KvDao(db).get(draftKey(owner, userBookId));
    return raw == null ? null : decodeDraft(raw)?.changes;
  }

  @override
  Future<void> clearDraft(String owner, String userBookId) =>
      KvDao(db).delete(draftKey(owner, userBookId));

  @override
  Future<bool> recoverDraft(String owner, String userBookId) async {
    try {
      final raw = await KvDao(db).get(draftKey(owner, userBookId));
      if (raw == null) return true;
      final draft = decodeDraft(raw);
      if (draft == null) throw const FormatException('rascunho ilegível');
      await commit(owner, userBookId, draft.changes);
      await clearDraft(owner, userBookId);
      return true;
    } on Object catch (e, st) {
      onError(InkDraftNotRecovered('${e.runtimeType}'), st);
      return false;
    }
  }
}

// G16.4 — o repositório da tinta (§4): os desenhos salvos do livro, o Concluir numa transação e o rascunho no `kv`.
// - Concluir: uma transação, cada linha pelo `LocalVersioning.write` (HLC). Camadas novas (`created = updated` = a
//   hora do HLC) e mudadas (fica a criação); as anotações `drawing` (`source = ink`, a cor do 1º traço, a página e o
//   capítulo do começo do trecho, o grupo — que não muda depois de gravado); camadas apagadas com as anotações
//   delas; grifos à mão apagados pela Borracha, com as notas filhas (o de seleção fica — D-168). A linha que já não
//   existe ou já está apagada, pula; a que ficaria igual, não é regravada: aplicar duas vezes dá as mesmas linhas (o
//   rascunho é idempotente) e a fila do Pro só recebe o que mudou.
// - G17 (R24): os grifos do marca-texto — os novos (`source` do traço ou do grifo cortado; a criação = a hora do traço),
//   os salvos que a D-32 moveu (a âncora, a página e o capítulo novos, com as notas deles; o grupo e a criação ficam)
//   e os que ela tirou: somem e as notas vão para o destino, com o grupo, a âncora, a página e o capítulo dele (como
//   na tela 21); sem destino (a Borracha apagou o destino), as notas vão junto (D-168). Destino que não existe mais
//   (apagado em outro aparelho): o tirado fica, com as notas.
// - Rascunho: o JSON de `ink_changes.dart` na chave `ink_draft:<dono>:<user_book_id>:<sessão>` do `kv` (só do
//   aparelho, nunca sincroniza), uma por sessão do modo: a sessão só apaga e sobrescreve o dela. Ao abrir o livro
//   (D-166), cada um é gravado como um Concluir, na ordem das chaves, e a chave some; o que falhar fica, e a falha vai
//   ao relatório sem conteúdo.
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

/// O Concluir ou o rascunho de uma sessão não gravou: só o tipo da falha, sem o conteúdo (o erro do banco traz o
/// comando com os traços e a citação; o relatório não leva dado da pessoa).
final class InkNotSaved implements Exception {
  const InkNotSaved(this.cause);

  final String cause;

  @override
  String toString() => 'InkNotSaved($cause)';
}

abstract interface class InkRepository {
  /// Os desenhos vivos do livro, em ordem de criação.
  Future<List<SavedDrawing>> drawingsOfBook(String userBookId);

  /// Grava [c] numa transação, pelo `LocalVersioning.write`, com HLC.
  Future<void> commit(String owner, String userBookId, InkChanges c);

  /// Guarda [c] como o rascunho da sessão [session] do livro (vazio apaga o rascunho dela).
  Future<void> saveDraft(
    String owner,
    String userBookId,
    InkChanges c, {
    required String session,
  });

  /// Os rascunhos guardados do livro (de todas as sessões, na ordem das chaves), sem os ilegíveis.
  Future<List<InkChanges>> draftsOf(String owner, String userBookId);

  /// Apaga o rascunho da sessão [session] (só o dela).
  Future<void> clearDraft(
    String owner,
    String userBookId, {
    required String session,
  });

  /// D-166: grava cada rascunho do livro como um Concluir e apaga a chave dele; o que falhar fica (`false`). Sem
  /// rascunho, `true`.
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
      await _writeHighlights(owner, userBookId, c);
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

  /// Os grifos do marca-texto (G17): os novos, os movidos e os tirados, nessa ordem — o destino das notas já tem o
  /// lugar novo quando elas chegam.
  Future<void> _writeHighlights(
    String owner,
    String userBookId,
    InkChanges c,
  ) async {
    if (c.highlights.isEmpty && c.moved.isEmpty && c.removed.isEmpty) return;
    final old = {
      for (final a in await _annotations.byIds([
        for (final h in c.highlights) h.id,
        for (final m in c.moved) m.id,
        ...c.removed.keys,
      ]))
        a.id: a,
    };
    for (final h in c.highlights) {
      await _writeHighlight(owner, userBookId, h, old[h.id]);
    }
    if (c.moved.isEmpty && c.removed.isEmpty) return;
    final book = await _annotations.forBook(userBookId);
    List<Annotation> notesOf(String id) => [
      for (final n in book)
        if (n.kind == AnnotationKind.note &&
            n.parentId == id &&
            !n.meta.isDeleted)
          n,
    ];
    for (final m in c.moved) {
      final a = old[m.id];
      if (!_live(a) ||
          (a!.anchor == m.range &&
              a.refPage == m.refPage &&
              a.chapterIndex == m.chapterIndex)) {
        continue;
      }
      await _write(
        'annotations',
        a.id,
        (v, at) => _annotations.upsert(
          a.copyWith(
            meta: a.meta.edited(at, v),
            anchor: m.range,
            refPage: m.refPage,
            chapterIndex: m.chapterIndex,
          ),
        ),
      );
      // as notas do grifo andam com ele (a âncora, a página e o capítulo do pai)
      for (final n in notesOf(m.id)) {
        await _write(
          'annotations',
          n.id,
          (v, at) => _annotations.upsert(
            n.copyWith(
              anchor: m.range,
              refPage: m.refPage,
              chapterIndex: m.chapterIndex,
              meta: n.meta.edited(at, v),
            ),
          ),
        );
      }
    }
    for (final MapEntry(key: id, value: to) in c.removed.entries) {
      final a = old[id];
      if (!_live(a)) continue;
      final notes = notesOf(id);
      if (to == null) {
        await _delete(a!);
        for (final n in notes) {
          await _delete(n);
        }
        continue;
      }
      final parent = await _annotations.byId(to);
      // o destino não existe mais (apagado em outro aparelho): o tirado fica, com as notas
      if (!_live(parent)) continue;
      await _delete(a!);
      for (final n in notes) {
        await _write(
          'annotations',
          n.id,
          (v, at) => _annotations.upsert(
            n.copyWith(
              parentId: Nullable(to),
              groupId: parent!.groupId,
              anchor: parent.anchor,
              refPage: parent.refPage,
              chapterIndex: parent.chapterIndex,
              meta: n.meta.edited(at, v),
            ),
          ),
        );
      }
    }
  }

  /// Um grifo vivo.
  static bool _live(Annotation? a) =>
      a != null && !a.meta.isDeleted && a.kind == AnnotationKind.highlight;

  Future<void> _writeHighlight(
    String owner,
    String userBookId,
    HighlightRow r,
    Annotation? old,
  ) async {
    if (_live(old) &&
        old!.anchor == r.range &&
        old.refPage == r.refPage &&
        old.chapterIndex == r.chapterIndex &&
        old.color == r.color &&
        old.style == r.style &&
        old.fillHeight == r.fillHeight &&
        old.source == r.source) {
      return;
    }
    await _write(
      'annotations',
      r.id,
      (v, at) => _annotations.upsert(
        old == null
            ? Annotation(
                id: r.id,
                // a criação = a hora do traço na sessão
                meta: RecordMeta(
                  userId: owner,
                  createdAt: r.createdAt,
                  updatedAt: at,
                  version: v,
                ),
                userBookId: userBookId,
                kind: AnnotationKind.highlight,
                groupId: r.groupId,
                source: r.source,
                anchor: r.range,
                refPage: r.refPage,
                chapterIndex: r.chapterIndex,
                color: r.color,
                style: r.style,
                fillHeight: r.fillHeight,
              )
            : old.copyWith(
                meta: _touched(old.meta, at, v),
                anchor: r.range,
                refPage: r.refPage,
                chapterIndex: r.chapterIndex,
                color: Nullable(r.color),
                style: Nullable(r.style),
                fillHeight: Nullable(r.fillHeight),
              ),
      ),
    );
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
  Future<void> saveDraft(
    String owner,
    String userBookId,
    InkChanges c, {
    required String session,
  }) {
    final key = draftKey(owner, userBookId, session);
    if (c.isEmpty) return KvDao(db).delete(key);
    return KvDao(db).set(key, encodeDraft(c, at: _now()));
  }

  /// As chaves dos rascunhos do livro e o texto de cada uma.
  Future<List<(String, String)>> _drafts(String owner, String userBookId) =>
      KvDao(db).withPrefix('${draftKey(owner, userBookId)}:');

  @override
  Future<List<InkChanges>> draftsOf(String owner, String userBookId) async => [
    for (final (_, raw) in await _drafts(owner, userBookId))
      ?decodeDraft(raw)?.changes,
  ];

  @override
  Future<void> clearDraft(
    String owner,
    String userBookId, {
    required String session,
  }) => KvDao(db).delete(draftKey(owner, userBookId, session));

  @override
  Future<bool> recoverDraft(String owner, String userBookId) async {
    var ok = true;
    try {
      for (final (key, raw) in await _drafts(owner, userBookId)) {
        try {
          final draft = decodeDraft(raw);
          if (draft == null) throw const FormatException('rascunho ilegível');
          await commit(owner, userBookId, draft.changes);
          await KvDao(db).delete(key);
        } on Object catch (e, st) {
          onError(InkDraftNotRecovered('${e.runtimeType}'), st);
          ok = false;
        }
      }
    } on Object catch (e, st) {
      onError(InkDraftNotRecovered('${e.runtimeType}'), st);
      return false;
    }
    return ok;
  }
}

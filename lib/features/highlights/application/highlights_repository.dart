// G19.2 — o que a tela 25 lê e grava no banco: as anotações vivas do livro, na ordem do livro, e as camadas de tinta
// delas (relidas a cada escrita nas duas tabelas); a busca FTS5 (texto do trecho + nota, sem acento — Anexo 03 §10);
// apagar o cartão inteiro com as camadas dos desenhos e das notas à mão (D-193) e desfazer; trocar a cor do grifo no
// lugar (sem a união da D-32, que precisa do texto aberto no leitor — desvio da G19) e a nota (D-131/D-138, pela
// `planNote`). Cada escrita leva versão (`LocalVersioning`): no Pro entra na fila; no Grátis fica no aparelho.
import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;

import '../../../core/data/clock/hlc.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/annotations/domain/ink_layer.dart';
import '../../reader/annotations/domain/note_rules.dart';

/// Os itens vivos do livro (na ordem do livro) e as camadas vivas deles, por id.
typedef BookItems = ({List<Annotation> items, Map<String, InkLayer> layers});

/// O que um "apagar" levou, como estava, para o desfazer.
final class RemovedCard {
  const RemovedCard(this.annotations, this.layers);
  final List<Annotation> annotations;
  final List<InkLayer> layers;
}

final class HighlightsRepository {
  HighlightsRepository({
    required this.db,
    required this.versioning,
    required this.owner,
  });

  final AppDatabase db;
  final LocalVersioning versioning;
  final Future<String> Function() owner;

  final UuidV7Generator _ids = UuidV7Generator();

  AnnotationsDao get _dao => AnnotationsDao(db);
  InkLayersDao get _layers => InkLayersDao(db);

  Future<BookItems> read(String userBookId) async {
    final items = await _dao.forBook(userBookId);
    final ids = {
      for (final a in items)
        if (a.inkLayerId != null) a.inkLayerId!,
    };
    final layers = await _layers.byIds(ids);
    return (
      items: items,
      layers: {
        for (final l in layers)
          if (!l.meta.isDeleted) l.id: l,
      },
    );
  }

  /// Lê agora e de novo a cada escrita em `annotations` ou `ink_layers`; uma leitura velha que chega depois de uma
  /// nova é descartada.
  Stream<BookItems> watch(String userBookId) {
    late final StreamController<BookItems> out;
    StreamSubscription<Object?>? updates;
    var gen = 0;
    Future<void> emit() async {
      final g = ++gen;
      try {
        final r = await read(userBookId);
        if (g == gen && !out.isClosed) out.add(r);
      } on Object catch (e, st) {
        if (!out.isClosed) out.addError(e, st);
      }
    }

    out = StreamController<BookItems>(
      onListen: () {
        unawaited(emit());
        updates = db
            .tableUpdates(
              TableUpdateQuery.onAllTables([db.annotations, db.inkLayers]),
            )
            .listen((_) => unawaited(emit()));
      },
      onCancel: () => updates?.cancel(),
    );
    return out.stream;
  }

  /// Os ids que a busca acha; `null` = sem busca (só brancos).
  Future<Set<String>?> search(String userBookId, String query) async {
    if (AnnotationsDao.ftsQuery(query) == null) return null;
    return {for (final a in await _dao.search(userBookId, query)) a.id};
  }

  /// D-193: apaga todos os itens do grupo e as camadas dos desenhos e das notas à mão dele, numa transação.
  Future<RemovedCard?> deleteGroup(String userBookId, String groupId) async {
    final rows = [
      for (final a in await _dao.forBook(userBookId))
        if (a.groupId == groupId) a,
    ];
    if (rows.isEmpty) return null;
    final layerIds = {
      for (final a in rows)
        if ((a.kind == AnnotationKind.drawing ||
                a.kind == AnnotationKind.handwriting) &&
            a.inkLayerId != null)
          a.inkLayerId!,
    };
    final layers = [
      for (final l in await _layers.byIds(layerIds))
        if (!l.meta.isDeleted) l,
    ];
    await db.transaction(() async {
      for (final a in rows) {
        await _write(
          'annotations',
          a.id,
          (v, at) => _dao.upsert(a.copyWith(meta: a.meta.deleted(at, v))),
        );
      }
      for (final l in layers) {
        await _write(
          'ink_layers',
          l.id,
          (v, at) => _layers.upsert(l.copyWith(meta: l.meta.deleted(at, v))),
        );
      }
    });
    return RemovedCard(rows, layers);
  }

  /// "Desfazer": regrava o que [r] levou, vivo e com versão nova.
  Future<void> restore(RemovedCard r) => db.transaction(() async {
    for (final l in r.layers) {
      await _write(
        'ink_layers',
        l.id,
        (v, at) => _layers.upsert(l.copyWith(meta: l.meta.restored(at, v))),
      );
    }
    for (final a in r.annotations) {
      await _write(
        'annotations',
        a.id,
        (v, at) => _dao.upsert(a.copyWith(meta: a.meta.restored(at, v))),
      );
    }
  });

  /// Troca a cor do grifo no lugar; `false` se ele não existe mais (ou não é grifo).
  Future<bool> recolor(String highlightId, String color) async {
    final a = await _dao.byId(highlightId);
    if (a == null || a.meta.isDeleted || a.kind != AnnotationKind.highlight) {
      return false;
    }
    await _write(
      'annotations',
      a.id,
      (v, at) => _dao.upsert(
        a.copyWith(color: Nullable(color), meta: a.meta.edited(at, v)),
      ),
    );
    return true;
  }

  /// G21.5 (D-217): o grifo [highlightId] foi para o post [postId] do clube (o chip e o "Só do clube"); `false` se ele
  /// não existe mais.
  Future<bool> markShared(String highlightId, String postId) async {
    final a = await _dao.byId(highlightId);
    if (a == null || a.meta.isDeleted) return false;
    await _write(
      'annotations',
      a.id,
      (v, at) => _dao.upsert(
        a.copyWith(
          sharedClubPostId: Nullable(postId),
          meta: a.meta.edited(at, v),
        ),
      ),
    );
    return true;
  }

  /// A nota do grifo [highlightId] (D-131/D-138).
  Future<void> saveNote(
    String userBookId,
    String highlightId,
    String text,
  ) async {
    final rows = await _dao.forBook(userBookId);
    switch (planNote(rows, await _dao.byId(highlightId), text)) {
      case null:
        return;
      case NoteDelete(:final note):
        await _write(
          'annotations',
          note.id,
          (v, at) => _dao.upsert(note.copyWith(meta: note.meta.deleted(at, v))),
        );
      case NoteEdit(:final note, :final text):
        await _write(
          'annotations',
          note.id,
          (v, at) => _dao.upsert(
            note.copyWith(
              noteText: Nullable(text),
              meta: note.meta.edited(at, v),
            ),
          ),
        );
      case NoteCreate(:final parent, :final text):
        final who = await owner();
        final id = _ids.next();
        await _write(
          'annotations',
          id,
          (v, at) => _dao.upsert(
            Annotation(
              id: id,
              meta: RecordMeta(
                userId: who,
                createdAt: at,
                updatedAt: at,
                version: v,
              ),
              userBookId: parent.userBookId,
              kind: AnnotationKind.note,
              parentId: parent.id,
              groupId: parent.groupId,
              anchor: parent.anchor,
              refPage: parent.refPage,
              chapterIndex: parent.chapterIndex,
              noteText: text,
            ),
          ),
        );
    }
  }

  Future<void> _write(
    String table,
    String id,
    Future<void> Function(Hlc v, DateTime at) save,
  ) => versioning.write(
    table,
    id,
    (v) => save(v, DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true)),
  );
}

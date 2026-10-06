// G13.2 — os grifos e as notas do livro aberto (D-32, D-131, D-132, D-136). Lê do banco e acha o lugar de cada
// grifo: mesmo arquivo → início/fim; outro → reancoragem do Anexo 03 §5.3 com o texto do item, quando ele está
// aberto; sem lugar → não pinta e não apaga (D-44). Entrega ao pintor os grifos da página. Cria com a
// sobreposição da D-32, troca, apaga com desfazer e guarda a nota. Relê quando a tabela muda, sem consulta viva
// (G12), e logo depois de cada escrita (a barra mostra o resultado na hora). As escritas vão uma de cada vez e
// leem as linhas do banco, não as da memória. A última cor fica no aparelho (`kv`).
import 'dart:async';
import 'dart:ui' show Color;

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';

import '../../../core/data/clock/hlc.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/annotation_daos.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';
import '../annotations/domain/annotation.dart';
import '../annotations/domain/highlight_overlap.dart';
import '../domain/anchoring.dart';
import '../domain/locator.dart';
import '../layout/display_page.dart';
import '../presentation/page_marks.dart' show HighlightSource, PaintedHighlight;
import 'annotation_anchors.dart';
import 'reader_errors.dart';

/// A última cor de grifo usada, no aparelho (D-130, D-131).
const String lastHighlightColorKey = 'pref.leitor.ultimaCor';

/// Amarelo, a 1ª cor da barra: a última cor quando ainda não há nenhuma.
const String defaultHighlightColor = '#FED170';

/// O que um "apagar" levou (o grifo e as notas dele, como estavam), para o desfazer (D-132).
final class RemovedHighlight {
  const RemovedHighlight(this.rows);
  final List<Annotation> rows;
}

final class ReaderAnnotations extends ChangeNotifier
    implements HighlightSource {
  ReaderAnnotations({
    required this.db,
    required this.versioning,
    required this.owner,
    required this.userBookId,
    required this.anchors,
    required this.onError,
  });

  final AppDatabase db;
  final LocalVersioning versioning;
  final Future<String> Function() owner;
  final String userBookId;
  final AnnotationAnchors anchors;
  final ReaderErrorReporter onError;

  /// Um gerador só: os ids deste aparelho saem em ordem (desempate da ordem de criação).
  final UuidV7Generator _ids = UuidV7Generator();

  List<Annotation> _rows = const [];

  /// O lugar achado de cada grifo, enquanto a âncora dele for a mesma.
  final Map<String, (TextAnchor, ReaderRange?)> _places = {};
  StreamSubscription<Object?>? _sub;
  Future<void> _queue = Future.value();
  bool _disposed = false;

  AnnotationsDao get _dao => AnnotationsDao(db);

  Future<void> load() async {
    await _reload();
    _sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.annotations]))
        .listen((_) => unawaited(_reload()));
  }

  Future<void> _reload() async {
    try {
      final rows = await _dao.forBook(userBookId);
      if (_disposed) return;
      _rows = rows;
      notifyListeners();
    } on Object catch (e, st) {
      onError(e, st);
    }
  }

  /// Uma escrita de cada vez, na ordem pedida; depois relê.
  Future<T> _serial<T>(Future<T> Function() f) {
    final run = _queue.then((_) => f());
    _queue = run.then<void>((_) => _reload(), onError: (Object _) {});
    return run.then((v) async {
      await _queue;
      return v;
    });
  }

  Iterable<Annotation> get _highlights =>
      _rows.where((a) => a.kind == AnnotationKind.highlight);

  /// Onde o grifo [a] está agora; `null` = sem lugar (ou o item ainda não está aberto: tenta de novo depois).
  ReaderRange? placeOf(Annotation a) {
    final cached = _places[a.id];
    if (cached != null && cached.$1 == a.anchor) return cached.$2;
    final anchor = a.anchor;
    if (anchor is! EpubAnchor) {
      _places[a.id] = (anchor, null);
      return null;
    }
    if (anchor.sha == anchors.sha) {
      final r = (unit: anchor.spine, from: anchor.start, to: anchor.end);
      _places[a.id] = (anchor, r);
      return r;
    }
    final text = anchors.textOf(anchor.spine);
    if (text == null) return null;
    final r = switch (reanchor(anchor, text, currentSha: anchors.sha)) {
      Anchored(:final start, :final end) => (
        unit: anchor.spine,
        from: start,
        to: end,
      ),
      Orphaned() => null,
    };
    _places[a.id] = (anchor, r);
    return r;
  }

  @override
  List<PaintedHighlight> highlightsIn(ReaderRange shown) {
    final out = <(Annotation, ReaderRange)>[];
    for (final a in _highlights) {
      final r = placeOf(a);
      if (r == null ||
          r.unit != shown.unit ||
          r.from >= shown.to ||
          r.to <= shown.from) {
        continue;
      }
      out.add((a, r));
    }
    out.sort(_byCreation);
    return [
      for (final (a, r) in out)
        PaintedHighlight(
          id: a.id,
          range: r,
          color: hexColor(a.color!),
          style: a.style!,
        ),
    ];
  }

  static int _byCreation(
    (Annotation, ReaderRange) x,
    (Annotation, ReaderRange) y,
  ) {
    final c = x.$1.meta.createdAt.compareTo(y.$1.meta.createdAt);
    return c != 0 ? c : x.$1.id.compareTo(y.$1.id);
  }

  /// O grifo sob [s] (o mais novo, se houver mais de um).
  PaintedHighlight? highlightAt(ReaderSpot s) {
    final here = highlightsIn((unit: s.unit, from: s.offset, to: s.offset + 1))
        .where((h) => h.range.from <= s.offset && s.offset < h.range.to);
    return here.isEmpty ? null : here.last;
  }

  Annotation? byId(String id) => _rows.where((a) => a.id == id).firstOrNull;

  /// O texto da nota do grifo [highlightId] (D-131); `null` = sem nota.
  String? noteOf(String highlightId) => _rows
      .where((a) => a.kind == AnnotationKind.note && a.parentId == highlightId)
      .firstOrNull
      ?.noteText;

  /// Cria o grifo de [r] (D-32) e devolve o id dele; `null` se o trecho é vazio, o item não está aberto ou deu
  /// erro (relatado).
  Future<String?> addHighlight(
    ReaderRange r, {
    required String color,
    required HighlightStyle style,
  }) {
    final text = anchors.textOf(r.unit);
    if (text == null || r.from >= r.to) return Future.value();
    return _serial(() async {
      try {
        return await _add(r, text, color, style);
      } on Object catch (e, st) {
        onError(e, st);
        return null;
      }
    });
  }

  Future<String> _add(
    ReaderRange r,
    String text,
    String color,
    HighlightStyle style,
  ) async {
    final fresh = await _dao.forBook(userBookId);
    final rows = {for (final a in fresh) a.id: a};
    final spans = <HighlightSpan>[
      for (final a in fresh)
        if (a.kind == AnnotationKind.highlight)
          if (placeOf(a) case final p? when p.unit == r.unit)
            (
              id: a.id,
              start: p.from,
              end: p.to,
              color: a.color!,
              style: a.style!,
              createdAt: a.meta.createdAt,
            ),
    ];
    final plan = planHighlight(spans, (
      start: r.from,
      end: r.to,
      color: color,
      style: style,
    ));
    final who = await owner();
    final id = plan.keepId ?? _ids.next();
    // para quem vão as notas de cada grifo mexido (ele mesmo, se ficou)
    final target = <String, String>{id: id};
    await db.transaction(() async {
      final kept = rows[id];
      await _write(
        id,
        (v, at) => kept == null
            ? _newHighlight(
                id,
                who,
                at,
                v,
                (unit: r.unit, from: plan.start, to: plan.end),
                text,
                color,
                style,
                groupId: id,
              )
            : _moved(kept, at, v, (
                unit: r.unit,
                from: plan.start,
                to: plan.end,
              ), text),
      );
      for (final x in plan.resized) {
        await _write(
          x.id,
          (v, at) => _moved(rows[x.id]!, at, v, (
            unit: r.unit,
            from: x.start,
            to: x.end,
          ), text),
        );
        target[x.id] = x.id;
      }
      for (final x in plan.added) {
        final from = rows[x.from]!;
        final nid = _ids.next();
        await _write(
          nid,
          (v, at) => _newHighlight(
            nid,
            who,
            at,
            v,
            (unit: r.unit, from: x.start, to: x.end),
            text,
            from.color!,
            from.style!,
            groupId: from.groupId,
            fillHeight: from.fillHeight,
          ),
        );
      }
      for (final gone in plan.removed) {
        final row = rows[gone]!;
        await _write(
          gone,
          (v, at) => row.copyWith(meta: row.meta.deleted(at, v)),
        );
        target[gone] = plan.notesTo[gone] ?? id;
      }
      // as notas seguem quem ficou: o grupo e a âncora dele
      for (final n in fresh) {
        if (n.kind != AnnotationKind.note) continue;
        final to = target[n.parentId];
        if (to == null) continue;
        final parent = await _dao.byId(to);
        if (parent == null) continue;
        await _write(
          n.id,
          (v, at) => n.copyWith(
            parentId: Nullable(to),
            groupId: parent.groupId,
            anchor: parent.anchor,
            refPage: parent.refPage,
            chapterIndex: parent.chapterIndex,
            meta: n.meta.edited(at, v),
          ),
        );
      }
    });
    return id;
  }

  /// Troca a cor e o estilo de um grifo no lugar (D-132).
  Future<void> restyle(
    String id, {
    required String color,
    required HighlightStyle style,
  }) => _serial(() async {
    try {
      final a = await _dao.byId(id);
      if (a == null || a.meta.isDeleted) return;
      await _write(
        id,
        (v, at) => a.copyWith(
          color: Nullable(color),
          style: Nullable(style),
          fillHeight: Nullable(
            style == HighlightStyle.fill
                ? (a.fillHeight ?? FillHeight.medium)
                : null,
          ),
          meta: a.meta.edited(at, v),
        ),
      );
    } on Object catch (e, st) {
      onError(e, st);
    }
  });

  /// Apaga o grifo e as notas dele (`deleted_at`) e devolve o que levou, como estava, para o desfazer.
  Future<RemovedHighlight> remove(String id) => _serial(() async {
    var rows = const <Annotation>[];
    try {
      rows = [
        for (final a in await _dao.forBook(userBookId))
          if (a.id == id || (a.kind == AnnotationKind.note && a.parentId == id))
            a,
      ];
      await db.transaction(() async {
        for (final a in rows) {
          await _write(
            a.id,
            (v, at) => a.copyWith(meta: a.meta.deleted(at, v)),
          );
        }
      });
    } on Object catch (e, st) {
      onError(e, st);
    }
    return RemovedHighlight(rows);
  });

  /// "Desfazer": regrava o que [r] levou, vivo e com versão nova.
  Future<void> restore(RemovedHighlight r) => _serial(() async {
    try {
      await db.transaction(() async {
        for (final a in r.rows) {
          await _write(
            a.id,
            (v, at) => a.copyWith(
              meta: a.meta.copyWith(
                deletedAt: const Nullable(null),
                updatedAt: at,
                version: v,
              ),
            ),
          );
        }
      });
    } on Object catch (e, st) {
      onError(e, st);
    }
  });

  /// A nota do grifo [highlightId] (D-131): cria, edita ou, vazia, apaga (o grifo fica).
  Future<void> saveNote(String highlightId, String text) => _serial(() async {
    try {
      await _saveNote(highlightId, text.trim());
    } on Object catch (e, st) {
      onError(e, st);
    }
  });

  Future<void> _saveNote(String highlightId, String t) async {
    final parent = await _dao.byId(highlightId);
    if (parent == null || parent.meta.isDeleted) return;
    final note = (await _dao.forBook(userBookId))
        .where(
          (a) => a.kind == AnnotationKind.note && a.parentId == highlightId,
        )
        .firstOrNull;
    if (t.isEmpty) {
      if (note != null) {
        await _write(
          note.id,
          (v, at) => note.copyWith(meta: note.meta.deleted(at, v)),
        );
      }
      return;
    }
    if (note != null) {
      await _write(
        note.id,
        (v, at) =>
            note.copyWith(noteText: Nullable(t), meta: note.meta.edited(at, v)),
      );
      return;
    }
    final who = await owner();
    final id = _ids.next();
    await _write(
      id,
      (v, at) => Annotation(
        id: id,
        meta: RecordMeta(userId: who, createdAt: at, updatedAt: at, version: v),
        userBookId: userBookId,
        kind: AnnotationKind.note,
        parentId: highlightId,
        groupId: parent.groupId,
        anchor: parent.anchor,
        refPage: parent.refPage,
        chapterIndex: parent.chapterIndex,
        noteText: t,
      ),
    );
  }

  /// A última cor usada (D-130); amarelo sem histórico ou com um valor estranho.
  Future<String> lastColor() async {
    final c = await KvDao(db).get(lastHighlightColorKey);
    return c != null && RegExp(r'^#[0-9A-F]{6}$').hasMatch(c)
        ? c
        : defaultHighlightColor;
  }

  Future<void> setLastColor(String color) =>
      KvDao(db).set(lastHighlightColorKey, color);

  Future<void> _write(String id, Annotation Function(Hlc v, DateTime at) row) =>
      versioning.write('annotations', id, (v) async {
        final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
        await _dao.upsert(row(v, at));
      });

  EpubAnchor _anchor(ReaderRange r, String text) => EpubAnchor(
    sha: anchors.sha,
    spine: r.unit,
    start: r.from,
    end: r.to,
    quote: quoteAt(text, r.from, r.to),
    refPage: anchors.placeOf(r.unit, r.from).refPage,
  );

  Annotation _newHighlight(
    String id,
    String who,
    DateTime at,
    Hlc v,
    ReaderRange r,
    String text,
    String color,
    HighlightStyle style, {
    required String groupId,
    FillHeight? fillHeight,
  }) {
    final place = anchors.placeOf(r.unit, r.from);
    return Annotation(
      id: id,
      meta: RecordMeta(userId: who, createdAt: at, updatedAt: at, version: v),
      userBookId: userBookId,
      kind: AnnotationKind.highlight,
      groupId: groupId,
      anchor: _anchor(r, text),
      refPage: place.refPage,
      chapterIndex: place.chapterIndex,
      color: color,
      style: style,
      fillHeight: style == HighlightStyle.fill
          ? (fillHeight ?? FillHeight.medium)
          : null,
    );
  }

  Annotation _moved(
    Annotation a,
    DateTime at,
    Hlc v,
    ReaderRange r,
    String text,
  ) {
    final place = anchors.placeOf(r.unit, r.from);
    return a.copyWith(
      anchor: _anchor(r, text),
      refPage: place.refPage,
      chapterIndex: place.chapterIndex,
      meta: a.meta.edited(at, v),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_sub?.cancel());
    super.dispose();
  }
}

/// "#RRGGBB" → cor opaca.
Color hexColor(String hex) =>
    Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

// G13.2 — os grifos e as notas do livro aberto (D-32, D-131, D-132, D-136). Lê do banco e acha o lugar de cada
// grifo: mesmo arquivo → início/fim; outro → reancoragem do Anexo 03 §5.3 com o texto do item, quando ele está
// aberto; sem lugar → não pinta e não apaga (D-44). Entrega ao pintor os grifos da página. Cria com a
// sobreposição da D-32, troca, apaga com desfazer e guarda a nota. Relê quando a tabela muda, sem consulta viva
// (G12), e logo depois de cada escrita (a barra mostra o resultado na hora); só avisa o pintor quando as linhas
// mudaram, e guarda os grifos de cada trecho pintado até a próxima mudança. As escritas vão uma de cada vez e leem
// as linhas do banco, não as da memória. Trocar a cor ou o estilo também passa pela D-32. A última cor fica no
// aparelho (`kv`). D-138: a nota que vai ficar num grifo novo é a mais antiga dos grifos que ele une ou cobre.
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

  /// Os grifos de cada trecho já pedido pelo pintor, até as linhas mudarem.
  final Map<ReaderRange, List<PaintedHighlight>> _shown = {};

  Future<void> load() async {
    await _reload();
    if (_disposed) return;
    _sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.annotations]))
        .listen((_) => unawaited(_reload()), onError: onError);
  }

  Future<void> _reload() async {
    try {
      final rows = await _dao.forBook(userBookId);
      if (_disposed || listEquals(rows, _rows)) return;
      _rows = rows;
      _shown.clear();
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

  /// Uma leitura depois das escritas já pedidas.
  Future<T> _after<T>(Future<T> Function() f) => _queue.then((_) => f());

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
    final kept = _shown[shown];
    if (kept != null) return kept;
    final (list, complete) = _find(shown);
    // um grifo cujo item ainda não abriu fica de fora desta vez: não guarda
    if (complete) {
      if (_shown.length >= 8) _shown.clear();
      _shown[shown] = list;
    }
    return list;
  }

  /// Os grifos que tocam [shown], na ordem de criação, e se todos tiveram o lugar resolvido.
  (List<PaintedHighlight>, bool) _find(ReaderRange shown) {
    final out = <(Annotation, ReaderRange)>[];
    var complete = true;
    for (final a in _highlights) {
      // a âncora diz o item; a reancoragem não sai dele
      if (a.anchor case EpubAnchor(:final spine) when spine != shown.unit) {
        continue;
      }
      final r = placeOf(a);
      if (r == null) {
        if (_places[a.id]?.$1 != a.anchor) complete = false;
        continue;
      }
      if (r.from >= shown.to || r.to <= shown.from) continue;
      out.add((a, r));
    }
    out.sort((x, y) => _older(x.$1, y.$1));
    return (
      List.unmodifiable([
        for (final (a, r) in out)
          PaintedHighlight(
            id: a.id,
            range: r,
            color: hexColor(a.color!),
            style: a.style!,
          ),
      ]),
      complete,
    );
  }

  /// A ordem de criação (o id desempata).
  static int _older(Annotation x, Annotation y) {
    final c = x.meta.createdAt.compareTo(y.meta.createdAt);
    return c != 0 ? c : x.id.compareTo(y.id);
  }

  /// O grifo sob [s] (o mais novo, se houver mais de um).
  PaintedHighlight? highlightAt(ReaderSpot s) {
    final here = _find((unit: s.unit, from: s.offset, to: s.offset + 1)).$1
        .where((h) => h.range.from <= s.offset && s.offset < h.range.to);
    return here.isEmpty ? null : here.last;
  }

  Annotation? byId(String id) => _rows.where((a) => a.id == id).firstOrNull;

  /// O texto da nota do grifo [highlightId] (D-131): a mais antiga, se houver mais de uma; `null` = sem nota.
  String? noteOf(String highlightId) =>
      _firstNote(_rows, {highlightId})?.noteText;

  /// A nota mais antiga dos grifos [parents].
  static Annotation? _firstNote(
    Iterable<Annotation> rows,
    Set<String> parents,
  ) {
    Annotation? first;
    for (final a in rows) {
      if (a.kind != AnnotationKind.note || !parents.contains(a.parentId)) {
        continue;
      }
      if (first == null || _older(a, first) < 0) first = a;
    }
    return first;
  }

  /// A nota que fica no grifo que [r] vai virar com [color] e [style] (D-138): a mais antiga dos grifos que ele
  /// une ou cobre inteiros (os que encolhem ficam com as suas); `null` = nenhuma (ou o item não está aberto).
  Future<String?> notePreview(
    ReaderRange r, {
    required String color,
    required HighlightStyle style,
  }) {
    if (anchors.textOf(r.unit) == null || r.from >= r.to) {
      return Future.value();
    }
    return _after(() async {
      try {
        final fresh = await _dao.forBook(userBookId);
        final plan = planHighlight(_spansIn(fresh, r.unit), (
          start: r.from,
          end: r.to,
          color: color,
          style: style,
        ));
        return _firstNote(fresh, {?plan.keepId, ...plan.removed})?.noteText;
      } on Object catch (e, st) {
        onError(e, st);
        return null;
      }
    });
  }

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
        return await _apply(r, text, color, style);
      } on Object catch (e, st) {
        onError(e, st);
        return null;
      }
    });
  }

  /// Os grifos de [unit] onde estão agora; [self] entra com a cor e o estilo pedidos (trocar passa pela D-32).
  List<HighlightSpan> _spansIn(
    List<Annotation> rows,
    int unit, {
    String? self,
    String? color,
    HighlightStyle? style,
  }) => [
    for (final a in rows)
      if (a.kind == AnnotationKind.highlight)
        if (placeOf(a) case final p? when p.unit == unit)
          (
            id: a.id,
            start: p.from,
            end: p.to,
            color: a.id == self ? color! : a.color!,
            style: a.id == self ? style! : a.style!,
            createdAt: a.meta.createdAt,
          ),
  ];

  /// Grava [r] com [color] e [style] pela D-32 e devolve o id que ficou. [self] = o grifo que troca de cor ou
  /// de estilo (ele entra no plano já com os novos).
  Future<String> _apply(
    ReaderRange r,
    String text,
    String color,
    HighlightStyle style, {
    String? self,
  }) async {
    final fresh = await _dao.forBook(userBookId);
    final rows = {for (final a in fresh) a.id: a};
    final plan = planHighlight(
      _spansIn(fresh, r.unit, self: self, color: color, style: style),
      (start: r.from, end: r.to, color: color, style: style),
    );
    final who = await owner();
    final id = plan.keepId ?? _ids.next();
    // para quem vão as notas de cada grifo mexido (ele mesmo, se ficou)
    final target = <String, String>{id: id};
    await db.transaction(() async {
      final kept = rows[id];
      final joined = (unit: r.unit, from: plan.start, to: plan.end);
      await _write(
        id,
        (v, at) => kept == null
            ? _newHighlight(
                id,
                who,
                at,
                v,
                joined,
                text,
                color,
                style,
                groupId: id,
              )
            : _moved(_restyled(kept, color, style), at, v, joined, text),
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

  /// A cor e o estilo novos; no fundo, a altura que tinha (ou a média); no sublinhado, nenhuma.
  static Annotation _restyled(
    Annotation a,
    String color,
    HighlightStyle style,
  ) => a.copyWith(
    color: Nullable(color),
    style: Nullable(style),
    fillHeight: Nullable(
      style == HighlightStyle.fill ? (a.fillHeight ?? FillHeight.medium) : null,
    ),
  );

  /// Troca a cor e o estilo de um grifo (D-132) pela D-32: encostando num da cor e do estilo novos, viram um
  /// (fica o mais antigo). Devolve o id que ficou; `null` se o grifo não existe mais ou deu erro (relatado).
  Future<String?> restyle(
    String id, {
    required String color,
    required HighlightStyle style,
  }) => _serial(() async {
    try {
      final a = await _dao.byId(id);
      if (a == null || a.meta.isDeleted) return null;
      final p = placeOf(a);
      final text = p == null ? null : anchors.textOf(p.unit);
      if (p == null || text == null) {
        // sem lugar agora: troca no lugar, sem mexer em ninguém
        await _write(
          id,
          (v, at) =>
              _restyled(a, color, style).copyWith(meta: a.meta.edited(at, v)),
        );
        return id;
      }
      return await _apply(p, text, color, style, self: id);
    } on Object catch (e, st) {
      onError(e, st);
      return null;
    }
  });

  /// Apaga o grifo e as notas dele (`deleted_at`) e devolve o que levou, como estava, para o desfazer; `null` se
  /// o grifo não existe mais ou deu erro (relatado) — nada foi apagado.
  Future<RemovedHighlight?> remove(String id) => _serial(() async {
    try {
      final rows = [
        for (final a in await _dao.forBook(userBookId))
          if (a.id == id || (a.kind == AnnotationKind.note && a.parentId == id))
            a,
      ];
      if (!rows.any((a) => a.id == id)) return null;
      await db.transaction(() async {
        for (final a in rows) {
          await _write(
            a.id,
            (v, at) => a.copyWith(meta: a.meta.deleted(at, v)),
          );
        }
      });
      return RemovedHighlight(rows);
    } on Object catch (e, st) {
      onError(e, st);
      return null;
    }
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

  /// A nota do grifo [highlightId] (D-131): cria, edita (a mais antiga, se houver mais de uma) ou, vazia, apaga
  /// (o grifo fica). `false` = deu erro (relatado): a folha continua aberta com o texto.
  Future<bool> saveNote(String highlightId, String text) => _serial(() async {
    try {
      await _saveNote(highlightId, text.trim());
      return true;
    } on Object catch (e, st) {
      onError(e, st);
      return false;
    }
  });

  Future<void> _saveNote(String highlightId, String t) async {
    final parent = await _dao.byId(highlightId);
    if (parent == null || parent.meta.isDeleted) return;
    final note = _firstNote(await _dao.forBook(userBookId), {highlightId});
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

  /// A última cor usada (D-130); amarelo sem histórico, com um valor estranho ou se a leitura falhar (relatado).
  Future<String> lastColor() async {
    try {
      final c = await KvDao(db).get(lastHighlightColorKey);
      return c != null && RegExp(r'^#[0-9A-F]{6}$').hasMatch(c)
          ? c
          : defaultHighlightColor;
    } on Object catch (e, st) {
      onError(e, st);
      return defaultHighlightColor;
    }
  }

  /// Guarda a última cor; se falhar, relata e segue (o grifo já foi feito).
  Future<void> setLastColor(String color) async {
    try {
      await KvDao(db).set(lastHighlightColorKey, color);
    } on Object catch (e, st) {
      onError(e, st);
    }
  }

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

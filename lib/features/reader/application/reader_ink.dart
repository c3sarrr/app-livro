// G16.5 — a tinta salva para o leitor (§4, §5): os desenhos do livro e a mancha dos grifos feitos à mão.
// - Ao abrir o livro, o rascunho de uma sessão que morreu é gravado como um Concluir (D-166), sem perguntar; se
//   falhar, a chave fica e a falha vai ao relatório (o repositório cuida). Depois lê os desenhos e relê quando as
//   tabelas da tinta mudam (como o `ReaderAnnotations`), avisando o pintor só quando as linhas mudaram.
// - O desenho aparece na página onde começa o trecho dele. O lugar do trecho: mesmo arquivo → início e fim; outro →
//   a reancoragem do Anexo 03 §5.3 pelo texto do item; sem lugar → não pinta e não apaga (D-44, D-169).
// - Na página, a moldura em em volta pelas caixas do trecho (`placedFrame`): estica na horizontal para cobrir as
//   mesmas palavras e fica em em na vertical (D-162); a espessura não escala. Os traços já saem em coordenadas da
//   tela, guardados por página até a próxima mudança.
// - Uma camada com BNK1 quebrado não derruba a página: não aparece e a falha vai ao relatório (uma vez).
// - Os grifos feitos à mão vêm do `ReaderAnnotations` (`inkHighlightsIn`, D-161); os avisos dele passam adiante.
// - G18: as notas à mão do livro (a camada `space` e a anotação `handwriting`): o lugar da âncora (como o dos
//   desenhos), as linhas, recolhida e a tinta na unidade da caixa; os cortes de cada item para o paginador
//   (`cutsOf`); as da página pelos espaços dela; `expand` abre a faixa (D-184). Antes do 1º layout, a tinta do livro
//   é lida à parte (`readOpeningInk`): o livro abre já com os espaços das notas, e o `ReaderInk` começa com ela
//   (revisão 7).
import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';

import '../../../core/data/database/app_database.dart';
import '../annotations/ink/bnk1_codec.dart';
import '../annotations/ink/drawing_anchor.dart';
import '../annotations/ink/ink_stroke.dart';
import '../annotations/ink_repository.dart';
import '../annotations/space/space_metrics.dart';
import '../domain/anchoring.dart';
import '../domain/locator.dart';
import '../layout/display_page.dart';
import '../layout/reader_typography.dart';
import '../layout/space_cut.dart';
import '../presentation/page_marks.dart' show PaintedHighlight;
import 'annotation_anchors.dart';
import 'annotation_session.dart' show PageDrawing;
import 'reader_annotations.dart';
import 'reader_errors.dart';

/// G18 — uma nota à mão do livro no leitor: a camada, a anotação, o item e a âncora, as linhas, recolhida, a tinta
/// (unidade da nota), a criação e o grupo.
typedef ReaderNote = ({
  String id,
  String annotationId,
  int unit,
  int at,
  int lines,
  bool collapsed,
  List<InkStroke> strokes,
  DateTime createdAt,
  String groupId,
});

/// G18: as notas à mão de [saved] com lugar ([placeOf]: o trecho da âncora; `null` = sem lugar) e com a tinta legível
/// ([strokesOf]: na unidade da caixa; `null` = BNK1 quebrado) — as outras não aparecem e continuam no banco.
List<ReaderNote> readerNotesOf(
  List<SavedNote> saved, {
  required ReaderRange? Function(String id, EpubAnchor anchor) placeOf,
  required List<InkStroke>? Function(String id, String b64) strokesOf,
}) => [
  for (final n in saved)
    if (n.layer.anchor case final EpubAnchor a)
      if (placeOf(n.layer.id, a) case final r?)
        if (strokesOf(n.layer.id, n.layer.strokesB64) case final strokes?)
          (
            id: n.layer.id,
            annotationId: n.annotation.id,
            unit: r.unit,
            at: r.from,
            lines: n.layer.spaceLines ?? minSpaceLines,
            collapsed: n.layer.collapsed,
            strokes: strokes,
            createdAt: n.annotation.meta.createdAt,
            groupId: n.annotation.groupId,
          ),
];

/// G18 — o lugar e o tamanho de uma nota à mão no texto: o que o paginador precisa dela.
typedef NoteSpace = ({String id, int unit, int at, int lines, bool collapsed});

NoteSpace noteSpaceOf(ReaderNote n) =>
    (id: n.id, unit: n.unit, at: n.at, lines: n.lines, collapsed: n.collapsed);

/// Os espaços do item [spine] para o paginador: a caixa ou a faixa de cada nota de [notes] (D-182, D-184).
List<SpaceCut> noteCutsOf(
  Iterable<NoteSpace> notes,
  int spine,
  ReaderTypography t,
) => [
  for (final n in notes)
    if (n.unit == spine)
      SpaceCut(
        at: n.at,
        height: n.collapsed
            ? stripFlowHeight(t.lineHeight)
            : noteFlowHeight(n.lines),
        id: n.id,
      ),
];

/// A assinatura de [notes] (o lugar, as linhas e se está recolhida): o leitor repagina quando ela muda.
String notesSignatureOf(Iterable<NoteSpace> notes) => [
  for (final n in notes)
    '${n.id}:${n.unit}:${n.at}:${n.lines}:${n.collapsed ? 1 : 0}',
].join('|');

/// G18 — a tinta do livro lida antes do 1º layout (revisão 7): as linhas dos desenhos e das notas, a tinta já lida
/// das notas e o lugar das do arquivo de agora. O livro abre com os espaços delas e o `ReaderInk` começa com tudo
/// isto: a 1ª página já sai com a caixa e os desenhos, e a leitura dele depois só muda o que mudou.
final class OpeningInk {
  OpeningInk._({
    required this.drawings,
    required this.notes,
    required this.noteStrokes,
    required this.spaces,
  });

  final List<SavedDrawing> drawings;
  final List<SavedNote> notes;

  /// A tinta de cada nota lida (pelo id da camada: o BNK1 e os traços na unidade da caixa); a quebrada fica de fora
  /// (o `ReaderInk` a relata).
  final Map<String, (String, List<InkStroke>)> noteStrokes;

  /// As notas do arquivo de agora com a tinta legível (as de outro arquivo precisam do texto do item — a
  /// reancoragem — e chegam pela tinta do leitor, que então repagina).
  final List<NoteSpace> spaces;

  String get signature => notesSignatureOf(spaces);
}

/// Lê a tinta do livro [userBookId] (o arquivo de agora: [sha]) para o 1º layout ([OpeningInk]).
Future<OpeningInk> readOpeningInk(
  InkRepository repository,
  String userBookId,
  String sha,
) async {
  final drawings = await repository.drawingsOfBook(userBookId);
  final saved = await repository.notesOfBook(userBookId);
  final strokes = <String, (String, List<InkStroke>)>{};
  final notes = readerNotesOf(
    saved,
    placeOf: (_, a) =>
        a.sha == sha ? (unit: a.spine, from: a.start, to: a.end) : null,
    strokesOf: (id, b64) {
      try {
        final list = decodeStrokesB64(b64, Bnk1Unit.box);
        strokes[id] = (b64, list);
        return list;
      } on Bnk1Failure {
        return null;
      }
    },
  );
  return OpeningInk._(
    drawings: drawings,
    notes: saved,
    noteStrokes: strokes,
    spaces: [for (final n in notes) noteSpaceOf(n)],
  );
}

/// Quem sabe a tinta das páginas (o `ReaderInk`; nos testes, listas).
abstract interface class InkSource implements Listenable {
  /// Os grifos feitos à mão que tocam [shown]: a mancha da D-161.
  List<PaintedHighlight> inkHighlightsIn(ReaderRange shown);

  /// Os desenhos cujo trecho começa em [page], com os traços na página (coordenadas da tela).
  List<PageDrawing> drawingsOn(DisplayPage page);

  /// G18: as notas à mão que estão em [page] (pelos espaços dela), de cima para baixo.
  List<ReaderNote> notesOn(DisplayPage page);

  /// Sobe a cada mudança da tinta (a chave do cache da pintura).
  int get revision;
}

final class ReaderInk extends ChangeNotifier implements InkSource {
  ReaderInk({
    required this.db,
    required this.repository,
    required this.owner,
    required this.userBookId,
    required this.anchors,
    required this.annotations,
    this.onError = reportReaderError,
    OpeningInk? opening,
  }) : _drawings = opening?.drawings ?? const [],
       _saved = opening?.notes ?? const [] {
    // a tinta lida antes do 1º layout (revisão 7): a 1ª página já pinta as notas e os desenhos
    if (opening != null) _strokes.addAll(opening.noteStrokes);
  }

  final AppDatabase db;
  final InkRepository repository;
  final Future<String> Function() owner;
  final String userBookId;
  final AnnotationAnchors anchors;
  final ReaderAnnotations annotations;
  final ReaderErrorReporter onError;

  List<SavedDrawing> _drawings;
  List<SavedNote> _saved;
  int _revision = 0;
  StreamSubscription<Object?>? _sub;
  bool _disposed = false;
  bool _listening = false;

  /// O lugar achado do trecho de cada camada, enquanto a âncora dela for a mesma.
  final Map<String, (TextAnchor, ReaderRange?)> _places = {};

  /// Os traços decodificados de cada camada (em em), enquanto o BNK1 dela for o mesmo; `null` = quebrado.
  final Map<String, (String, List<InkStroke>?)> _strokes = {};

  /// Os desenhos de cada página já pedida, pela revisão.
  final Expando<(int, List<PageDrawing>)> _pages = Expando();

  @override
  int get revision => _revision;

  Future<void> load() async {
    try {
      await repository.recoverDraft(await owner(), userBookId);
    } on Object catch (e, st) {
      onError(e, st);
    }
    await _reload();
    if (_disposed) return;
    _sub = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([db.inkLayers, db.annotations]),
        )
        .listen((_) => unawaited(_reload()), onError: onError);
    annotations.addListener(_forward);
    _listening = true;
  }

  Future<void> _reload() async {
    try {
      final drawings = await repository.drawingsOfBook(userBookId);
      final notes = await repository.notesOfBook(userBookId);
      if (_disposed ||
          (listEquals(drawings, _drawings) && listEquals(notes, _saved))) {
        return;
      }
      _drawings = drawings;
      _saved = notes;
      _changed();
    } on Object catch (e, st) {
      onError(e, st);
    }
  }

  void _forward() {
    if (_disposed) return;
    _changed();
  }

  void _changed() {
    _revision++;
    notifyListeners();
  }

  @override
  List<PaintedHighlight> inkHighlightsIn(ReaderRange shown) =>
      annotations.inkHighlightsIn(shown);

  @override
  List<PageDrawing> drawingsOn(DisplayPage page) {
    final shown = page.shown;
    if (shown == null || _drawings.isEmpty) return const [];
    final kept = _pages[page];
    if (kept != null && kept.$1 == _revision) return kept.$2;
    final out = <PageDrawing>[];
    // o em de cada linha: o da 1ª caixa dela, como na criação (`inkGeometryOf`)
    List<(double, double)>? lineEms;
    double emAt(double baseline, double fallback) {
      lineEms ??= () {
        final out = <(double, double)>[];
        for (final b in page.boxesOf(shown.unit, shown.from, shown.to)) {
          if (!out.any((l) => (l.$1 - b.baseline).abs() < 0.5)) {
            out.add((b.baseline, b.em));
          }
        }
        return out;
      }();
      for (final (base, em) in lineEms!) {
        if ((base - baseline).abs() < 0.5) return em;
      }
      return fallback;
    }

    for (final d in _drawings) {
      final parsed = inkAnchorOf(d.layer.anchor);
      if (parsed == null) continue;
      final r = _placeOf(d.layer.id, d.layer.anchor, parsed.range);
      if (r == null ||
          r.unit != shown.unit ||
          r.from < shown.from ||
          r.from >= shown.to) {
        continue;
      }
      // o trecho que segue na página seguinte não estica sobre o pedaço que ficou (k = 1)
      final frame = placedFrame([
        for (final b in page.boxesOf(r.unit, r.from, r.to))
          (
            left: b.rect.left,
            right: b.rect.right,
            baseline: b.baseline,
            em: emAt(b.baseline, b.em),
          ),
      ], r.to <= shown.to ? parsed.w : null);
      final strokes = _strokesOf(d.layer.id, d.layer.strokesB64);
      if (frame == null || strokes == null || strokes.isEmpty) continue;
      out.add((
        saved: (
          layerId: d.layer.id,
          annotationId: d.annotation.id,
          createdAt: d.annotation.meta.createdAt,
          groupId: d.annotation.groupId,
        ),
        range: r,
        strokes: List.unmodifiable([
          for (final s in strokes) fromFrame(s, frame),
        ]),
      ));
    }
    final list = List<PageDrawing>.unmodifiable(out);
    _pages[page] = (_revision, list);
    return list;
  }

  /// Onde o trecho [range] da camada [id] está agora; `null` = sem lugar (ou o item ainda não está aberto).
  ReaderRange? _placeOf(String id, TextAnchor anchor, EpubAnchor range) {
    final cached = _places[id];
    if (cached != null && cached.$1 == anchor) return cached.$2;
    if (range.sha == anchors.sha) {
      final r = (unit: range.spine, from: range.start, to: range.end);
      _places[id] = (anchor, r);
      return r;
    }
    final text = anchors.textOf(range.spine);
    // o item ainda não abriu: tenta de novo depois, sem guardar
    if (text == null) return null;
    final r = switch (reanchor(range, text, currentSha: anchors.sha)) {
      Anchored(:final start, :final end) => (
        unit: range.spine,
        from: start,
        to: end,
      ),
      Orphaned() => null,
    };
    _places[id] = (anchor, r);
    return r;
  }

  /// G18: as notas à mão do livro com lugar (as sem lugar não aparecem e continuam no banco), guardadas até a
  /// próxima mudança.
  List<ReaderNote> get notes {
    final kept = _notes;
    if (kept != null && kept.$1 == _revision) return kept.$2;
    final list = List<ReaderNote>.unmodifiable(_notesNow());
    // a nota sem lugar (o item ainda não abriu) é procurada de novo depois
    if (list.length == _saved.length) _notes = (_revision, list);
    return list;
  }

  (int, List<ReaderNote>)? _notes;

  List<ReaderNote> _notesNow() => readerNotesOf(
    _saved,
    placeOf: (id, a) => _placeOf(id, a, a),
    strokesOf: (id, b64) => _strokesOf(id, b64, Bnk1Unit.box),
  );

  /// Os espaços do item [spine] para o paginador: a caixa ou a faixa de cada nota (D-182, D-184).
  List<SpaceCut> cutsOf(int spine, ReaderTypography t) =>
      noteCutsOf(notes.map(noteSpaceOf), spine, t);

  /// A assinatura das notas do livro (o lugar, as linhas e se está recolhida): a tela repagina quando ela muda.
  String get notesSignature => notesSignatureOf(notes.map(noteSpaceOf));

  /// As notas que estão na página [page] (pelos espaços dela), de cima para baixo.
  @override
  List<ReaderNote> notesOn(DisplayPage page) {
    final ids = [for (final s in spacesOf(page)) s.id];
    if (ids.isEmpty) return const [];
    final byId = {for (final n in notes) n.id: n};
    return [for (final id in ids) ?byId[id]];
  }

  /// D-184: um toque na faixa do leitor limpo abre a nota (grava só o `collapsed`).
  Future<void> expand(String id) async {
    try {
      await repository.setCollapsed(await owner(), id, false);
      await _reload();
    } on Object catch (e, st) {
      onError(e, st);
    }
  }

  List<InkStroke>? _strokesOf(
    String id,
    String b64, [
    Bnk1Unit unit = Bnk1Unit.em,
  ]) {
    final cached = _strokes[id];
    if (cached != null && cached.$1 == b64) return cached.$2;
    List<InkStroke>? strokes;
    try {
      strokes = decodeStrokesB64(b64, unit);
    } on Bnk1Failure catch (e, st) {
      onError(e, st);
    }
    _strokes[id] = (b64, strokes);
    return strokes;
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_sub?.cancel());
    if (_listening) annotations.removeListener(_forward);
    super.dispose();
  }
}
